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
# test_switchport_access.rb
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
# interface configured as a switchport access port.
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
testheader = 'Resource cisco_interface (switchport access)'
platform = fact_on(agent, 'os.name')

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.
def generate_tests_hash(agent)
  # 'tests' hash
  # Top-level keys set by caller:
  # tests[:master] - the master object
  # tests[:agent] - the agent object
  #
  tests = {
    master: master,
    agent:  agent,
  }

  interface_name = 'ethernet1/4'

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
      switchport_mode        => 'disabled',
    ",
    code:           [0, 2],
    resource_props: {},
  }

  tests['default_properties'] = {
    title_pattern:      interface_name,
    default_values:     {
      'access_vlan'                  => 1,
      'switchport_autostate_exclude' => false,
      'switchport_vtp'               => false,
    },
    non_default_values: {
      'switchport_mode' => 'access'
    },
  }

  tests['non_default_properties'] = {
    title_pattern:      interface_name,
    non_default_values: {
      'access_vlan'                  => 100,
      'switchport_mode'              => 'access',
      'switchport_autostate_exclude' => true,
      'switchport_vtp'               => true,
    },
  }

  tests
end

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH + 'resource cisco_interface'
  get_namespace_cmd(agent, cmd, options)
end

def build_default_values(testcase)
  testcase[:default_values].each do |key, value|
    testcase[:manifest_props] += "\n#{key} => 'default',"
    value_s = value.is_a?(String) ? "'#{value}'" : value.to_s
    testcase[:default_values][key] = value_s
    # remove key if no corresponding resource_prop
    testcase[:default_values].delete(key) if value.nil?
  end
  testcase[:resource].merge!(testcase[:default_values])
end

def build_non_default_values(testcase)
  testcase[:non_default_values].each do |key, value|
    value_s = value.is_a?(String) ? "'#{value}'" : value.to_s
    testcase[:non_default_values][key] = value_s
    testcase[:manifest_props] += "\n#{key} => #{value_s},"
  end
  testcase[:resource].merge!(testcase[:non_default_values])
end

def build_manifest_interface(tests, id)
  testcase = tests[id]
  testcase[:resource] = {}
  testcase[:manifest_props] = '' if testcase[:manifest_props].nil?
  if testcase[:ensure] == :absent
    state = 'ensure => absent,'
  else
    state = 'ensure => present,'
    res_props = testcase[:resource_props]
    testcase[:resource].merge!(res_props) unless res_props.nil?
    build_default_values(testcase) unless testcase[:default_values].nil?
    build_non_default_values(testcase) unless testcase[:non_default_values].nil?
  end

  testcase[:title_pattern] = id if testcase[:title_pattern].nil?
  logger.debug("build_manifest_interface :: title_pattern:\n" +
               testcase[:title_pattern])
  testcase[:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_interface { '#{testcase[:title_pattern]}':
      #{state}
      #{testcase[:manifest_props]}
    }
  }
EOF"
end

def invalid_absent_intf?(interface, platform)
  interface =~ /ethernet/ && platform == 'nexus'
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
  if platform == 'ios_xr'
    skip_test('switchport is not supported on this platform')
  end
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

  unless invalid_absent_intf?(tests[id][:title_pattern], platform)
    tests[id][:desc] = '1.2 Default Properties'
    tests[id][:ensure] = :absent
    test_harness_interface(tests, id)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Clean up")

  id = 'preclean'
  tests[id][:desc] = '3.2 Clean up interface'
  test_harness_interface(tests, id)

  # -------------------------------------------------------------------
  # TODO: add non-default tests for access port
  # logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  # test_harness_interface(tests, 'non_default_properties_S')

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
