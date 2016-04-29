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
  agent:            agent,
  master:           master,
  ensurable:        false,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'network_trunk',
}

# Discover a usable test interface
intf = find_interface(tests)

# Test hash test cases
tagged_manifest = [2, 3, 4, 6, 7, 8]
tagged_resource = %w(2 3 4 6 7 8)
tests[:non_default] = {
  desc:           '2. Non Default',
  title_pattern:  intf,
  manifest_props: {
    mode:          'trunk',
    tagged_vlans:  tagged_manifest,
    untagged_vlan: 128,
  },
  resource:       {
    mode:          'trunk',
    tagged_vlans:  "#{tagged_resource}",
    untagged_vlan: '128',
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  logger.info("\n#{'-' * 60}\nSection 0. Testbed setup")
  interface_cleanup(agent, intf, 'Initial Cleanup')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Defaults")
  logger.info("\nn/a. Provider does not support explicit 'default' values.")

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Defaults")
  test_harness_run(tests, :non_default)

  interface_cleanup(agent, intf, 'Test Complete')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
