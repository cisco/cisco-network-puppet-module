###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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
# port_channel_provider_defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet port_channel resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This port_channel resource test verifies default values for all
# properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
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
testheader = 'Resource port_channel'

# Define PUPPETMASTER_MANIFESTPATH.

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
#
tests = {
  master:    master,
  agent:     agent,
  intf_type: 'ethernet',
}

def find_ethernet_interface_array(tests)
  if tests[:ethernet]
    array = tests[:ethernet]
  else
    array = find_interface_array(tests)
    # cache for later tests
    tests[:ethernet] = array
  end
  msg = 'Unable to find suitable interface module for this test.'
  prereq_skip(tests[:resource_name], self, msg) if
    array.length < 3
  array
end

def find_ethernet_interface(tests, index)
  array = find_ethernet_interface_array(tests)
  array[index]
end

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#   Can be used with :af for mixed title/af testing. If mixing, :af values will
#   be merged with title values and override any duplicates. If omitted,
#   :title_pattern will be set to 'id'.
#

int_arr1 = []
int_arr1 << find_ethernet_interface(tests, 1)

tests['default_properties'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    id            => '100',
    interfaces    => #{int_arr1},
    minimum_links => '1',
  ",
  code:           [0, 2],
  resource_props: {
    'id'            => '100',
    'interfaces'    => int_arr1,
    'minimum_links' => '1',
  },
}

int_arr2 = []
int_arr2 << int_arr1[0] << find_ethernet_interface(tests, 2)

tests['non_default_properties'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    id            => '100',
    interfaces    => #{int_arr2},
    minimum_links => '3',
  ",
  resource_props: {
    'id'            => '100',
    'interfaces'    => int_arr2,
    'minimum_links' => '3',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  PUPPET_BINPATH + 'resource port_channel port-channel100'
end

def build_manifest_portchannel(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_portchannel :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    port_channel { 'port-channel100':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_portchannel(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_portchannel(tests, id)

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
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  resource_absent_cleanup(agent, 'port_channel',
                          'Setup switch for port_channel provider test')
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  id = 'default_properties'

  tests[id][:desc] = '1.1 Default Properties'
  test_harness_portchannel(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_portchannel(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  id = 'non_default_properties'
  tests[id][:desc] = '2.1 Non Default Properties'
  test_harness_portchannel(tests, id)

  tests[id][:desc] = '2.2 Non Default Properties (absent)'
  tests[id][:ensure] = :absent
  test_harness_portchannel(tests, id)
end

logger.info("TestCase :: #{testheader} :: End")
