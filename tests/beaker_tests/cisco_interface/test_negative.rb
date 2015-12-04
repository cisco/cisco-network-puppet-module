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
# test_negative.rb
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
# This cisco_interface resource test covers negative testing for title patterns
# and properties
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
testheader = 'Resource cisco_interface (negative tests)'

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

  if platform == 'nexus'
    mgmt_name = 'mgmt0'
    interface_name = 'ethernet1/4'
  elsif platform == 'ios_xr'
    mgmt_name = 'mgmteth0/rp0/cpu0/0'
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

  tests['title_pattern'] = {
    title_pattern:  mgmt_name,
    manifest_props: '',
  }

  tests['ipv4_address'] = {
    title_pattern:  interface_name,
    manifest_props: "
      ipv4_address => 0.0.0.0,
      ipv4_netmask_length => 16,
    ",
  }

  tests['ipv4_netmask_length'] = {
    title_pattern:  interface_name,
    manifest_props: "
      ipv4_address => 1.1.1.1,
      ipv4_netmask_length => 0,
    ",
  }

  tests['ipv4_proxy_arp'] = {
    title_pattern:  interface_name,
    manifest_props: "
      ipv4_proxy_arp => 'invalid',
    ",
  }

  tests['ipv4_redirects'] = {
    title_pattern:  interface_name,
    manifest_props: "
      ipv4_redirects => 'invalid',
    ",
  }

  tests['mtu'] = {
    title_pattern:  interface_name,
    manifest_props: "
      mtu => -1,
    ",
  }

  tests['shutdown'] = {
    title_pattern:  interface_name,
    manifest_props: "
      shutdown => 'invalid',
    ",
  }

  tests['vrf'] = {
    title_pattern:  interface_name,
    manifest_props: "
      vrf => '~',
    ",
  }

  if platform == 'nexus'
    tests['encapsulation_dot1q'] = {
      title_pattern:  interface_name + '.1',
      manifest_props: "
        encapsulation_dot1q => invalid,
      ",
    }
    tests['switchport_trunk_allowed_vlan'] = {
      title_pattern:  interface_name,
      manifest_props: "
        switchport_trunk_allowed_vlan => 'invalid',
      ",
    }
    tests['switchport_trunk_native_vlan'] = {
      title_pattern:  interface_name,
      manifest_props: "
        switchport_trunk_native_vlan => 'invalid',
      ",
    }
  end

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

def platform
  fact_on(agent, 'os.name')
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
  logger.info("\n#{'-' * 60}\nSection 1. Negative Tests for Properties")

  counter = 1
  tests.each_key do |k|
    next if k == 'preclean' || k == :master || k == :agent
    tests[k][:desc] = "1.#{counter}. #{k} negative test"
    counter += 1
    tests[k][:ensure] = :present
    tests[k][:code] = [1, 6]
    build_manifest_interface(tests, k)
    test_manifest(tests, k)
  end
end

logger.info('TestCase :: # {testheader} :: End')
