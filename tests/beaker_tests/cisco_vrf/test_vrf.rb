###############################################################################
# Copyright (c) 2016 Cisco and/or its affiliates.
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
#
# See README-develop-beaker-scripts.md (Section: Test Script Variable Reference)
# for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_vrf',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'blue',
  manifest_props: {
    description:                  'default',
    mhost_ipv4_default_interface: 'default',
    mhost_ipv6_default_interface: 'default',
    remote_route_filtering:       'default',
    shutdown:                     'default',
    vpn_id:                       'default',
  },
  resource:       {
    'remote_route_filtering' => 'true',
    'shutdown'               => 'false',
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default
tests[:non_default] = {
  desc:           '2.1 Non Default Properties commands',
  title_pattern:  'blue',
  manifest_props: {
    description:                  'test desc',
    mhost_ipv4_default_interface: 'Loopback100',
    mhost_ipv6_default_interface: 'Loopback100',
    remote_route_filtering:       false,
    route_distinguisher:          '1:1',
    shutdown:                     'true',
    vni:                          '4096',
    vpn_id:                       '1:1',
  },
}

def unsupported_properties(_tests, _id)
  unprops = []
  if operating_system == 'nexus'
    unprops <<
      :mhost_ipv4_default_interface <<
      :mhost_ipv6_default_interface <<
      :remote_route_filtering <<
      :vpn_id

    unprops << :vni unless platform[/n9k/]
    unprops << :route_distinguisher if nexus_i2_image

  else
    unprops <<
      :route_distinguisher <<
      :shutdown <<
      :vni
  end
  unprops
end

# Overridden to properly handle dependencies for this test file.
def dependency_manifest(_tests, _id)
  if operating_system == 'nexus'
    ''
  else
    "cisco_command_config { 'interface_config':
      command => '
        interface Loopback100'
    }"
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  resource_absent_cleanup(agent, 'cisco_vrf', 'VRF CLEAN :: ')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)

  # -------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_vrf', 'VRF CLEAN :: ')
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
