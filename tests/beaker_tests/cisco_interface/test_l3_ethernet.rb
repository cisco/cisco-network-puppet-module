###############################################################################
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
# TestCase Name:
# -------------
# test_l3_ethernet.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet interface resource testcase for Puppet Agent on
# Nexus and IOS XR devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the agent node.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This cisco_interface resource test verifies all properties on an Ethernet
# interface configured for layer 3 routing.
#
# The following exit_codes are validated for Puppet and Bash shell commands.
#
# Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_interface (ethernet, routed)'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.
def generate_tests_hash(agent) # rubocop:disable Metrics/MethodLength
  # 'tests' hash
  # Top-level keys set by caller:
  # tests[:master] - the master object
  # tests[:agent] - the agent object
  #
  tests = {
    master: master,
    agent:  agent,
  }

  platform = fact_on(agent, 'os.name')
  if platform == 'nexus'
    interface_name = 'ethernet1/4'
  elsif platform == 'ios_xr'
    interface_name = 'gigabitethernet0/0/0/1'
  end

  # tests[id] keys set by caller and used by test_harness_common:
  #
  # tests[id] keys set by caller:
  # tests[id][:desc] - a string to use with logs & debugs
  # tests[id][:manifest] - the complete manifest, as used by test_harness_common
  # tests[id][:resource] - a hash of expected states, used by test_resource
  # tests[id][:resource_cmd] - 'puppet resource' cmd to use with test_resource
  # tests[id][:ensure] - (Optional) set to :present or :absent before calling
  # tests[id][:code] - (Optional) override the default exit code in some tests.
  #
  # These keys are local use only and not used by test_harness_common:
  #
  # tests[id][:manifest_props] - This is essentially a master list of properties
  #   that permits re-use of the properties for both :present and :absent tests
  #   without destroying the list
  # tests[id][:resource_props] - This is essentially a master hash of properties
  #   that permits re-use of the properties for both :present and :absent tests
  #   without destroying the hash
  # tests[id][:title_pattern] - (Optional) defines the manifest title.
  #   Can be used w/ :af for mixed title/af testing. If mixing, :af values will
  #   be merged with title values and override any duplicates. If omitted,
  #   :title_pattern will be set to 'id'.
  # tests[id][:af] - (Optional) defines the address-family values.
  #   Must use :title_pattern if :af is not specified. Useful for testing mixed
  #   title/af manifests
  #
  tests['preclean'] = {
    title_pattern:  interface_name,
    manifest_props: "
      ipv4_address        => 'default',
    ",
    code:           [0, 2],
    resource_props: {},
  }

  tests['default_properties'] = {
    title_pattern:  interface_name,
    manifest_props: "
      description                  => 'default',
      shutdown                     => false,
      ipv4_address                 => '192.168.1.1',
      ipv4_netmask_length          => 16,
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      mtu                          => 'default',
      switchport_autostate_exclude => 'default',
      switchport_vtp               => 'default',
      vrf                          => 'default',
    ",
    resource_props: {
      'ipv4_address'        => '192.168.1.1',
      'ipv4_netmask_length' => '16',
      'ipv4_proxy_arp'      => 'false',
      'ipv4_redirects'      => platform == 'nexus' ? 'true' : 'false',
      'mtu'                 => platform == 'nexus' ? '1500' : '1514',
      'shutdown'            => 'false',
    },
  }

  if platform == 'nexus'
    # speed and duplex don't support 'default' as a valid option
    tests['default_properties'][:manifest_props] += "
      speed                        => 'auto',
      duplex                       => 'auto',
      switchport_mode              => disabled,
    "
    tests['default_properties'][:resource_props].merge!(
      'speed'                        => 'auto',
      'duplex'                       => 'auto',
      'switchport_autostate_exclude' => 'false',
      'switchport_mode'              => 'disabled',
      'switchport_vtp'               => 'false',
    )
  end

  tests['non_default_properties_D'] = {
    desc:           "2.1 Non Default Properties 'D' commands",
    title_pattern:  interface_name,
    manifest_props: "
      description => 'Configured with Puppet',
    ",
    resource_props: {
      'description' => 'Configured with Puppet'
    },
  }
  if platform == 'nexus'
    tests['non_default_properties_D'][:manifest_props] += "
      duplex => full,
    "
    tests['non_default_properties_D'][:resource_props].merge!(
      'duplex' => 'full',
    )
  end

  if platform == 'nexus'
    tests['non_default_properties_E'] = {
      desc:           "2.2 Non Default Properties 'E' commands",
      # encapsulation requires a subinterface
      title_pattern:  interface_name + '.1',
      manifest_props: "
        encapsulation_dot1q => 30,
      ",
      resource_props: {
        'encapsulation_dot1q' => '30'
      },
    }
  end

  tests['non_default_properties_I'] = {
    desc:           "2.3 Non Default Properties 'I' commands",
    title_pattern:  interface_name,
    manifest_props: "
      ipv4_address        => '192.168.1.1',
      ipv4_netmask_length => '16',
      ipv4_proxy_arp      => true,
      ipv4_redirects      => " + (platform == 'nexus' ? 'false' : 'true') + "
    ",
    resource_props: {
      'ipv4_address'        => '192.168.1.1',
      'ipv4_netmask_length' => '16',
      'ipv4_proxy_arp'      => 'true',
      'ipv4_redirects'      => platform == 'nexus' ? 'false' : 'true',
    },
  }

  if platform == 'nexus'
    tests['non_default_properties_M'] = {
      desc:           "2.4 Non Default Properties 'M' commands",
      title_pattern:  interface_name,
      manifest_props: "
        mtu => 1556,
      ",
      resource_props: {
        'mtu' => '1556'
      },
    }
  end

  tests['non_default_properties_S'] = {
    desc:           "2.5 Non Default Properties 'S' commands",
    title_pattern:  interface_name,
    manifest_props: "
      shutdown => 'true',
    ",
    resource_props: {
      'shutdown' => 'true'
    },
  }
  if platform == 'nexus'
    tests['non_default_properties_S'][:manifest_props] += "
      speed                        => 100,
      switchport_autostate_exclude => false,
      switchport_mode              => disabled,
      switchport_vtp               => false,
    "
    tests['non_default_properties_S'][:resource_props].merge!(
      'speed'                        => '100',
      'switchport_autostate_exclude' => 'false',
      'switchport_mode'              => 'disabled',
      'switchport_vtp'               => 'false',
    )
  end

  tests['non_default_properties_V'] = {
    desc:           "2.6 Non Default Properties 'V' commands",
    title_pattern:  interface_name,
    manifest_props: "
      vrf => 'test1',
    ",
    resource_props: {
      'vrf' => 'test1'
    },
  }

  tests
end

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = UtilityLib::PUPPET_BINPATH + 'resource cisco_interface'
  UtilityLib.get_namespace_cmd(agent, cmd, options)
end

def build_manifest_interface(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_interface :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_interface { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_interface(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_interface(tests, id)

  # FUTURE
  # test_harness_common(tests, id)

  test_manifest(tests, id)
  test_resource(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  tests = generate_tests_hash(agent)

  # -------------
  id = 'preclean'
  tests[id][:desc] = 'Preclean'
  test_harness_interface(tests, id)

  # ---------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_interface(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_interface(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_interface(tests, 'non_default_properties_D')
  if tests['non_default_properties_E']
    test_harness_interface(tests, 'non_default_properties_E')
  end
  test_harness_interface(tests, 'non_default_properties_I')
  if tests['non_default_properties_M']
    test_harness_interface(tests, 'non_default_properties_M')
  end
  test_harness_interface(tests, 'non_default_properties_S')
  test_harness_interface(tests, 'non_default_properties_V')

  # -------------------------------------------------------------------
  # FUTURE
  # logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  # node_feature_cleanup(agent, 'interface')

  # id = 'title_patterns'
  # tests[id][:desc] = '3.1 Title Patterns'
  # tests[id][:title_pattern] = '2'
  # tests[id][:af] = { :vrf => 'default', :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_interface(tests, id)

  # id = 'title_patterns'
  # tests[id][:desc] = '3.2 Title Patterns'
  # tests[id][:title_pattern] = '2 blue'
  # tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_interface(tests, id)
end

logger.info('TestCase :: # {testheader} :: End')
