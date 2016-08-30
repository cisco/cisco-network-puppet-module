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
#
# 'test_interface_storm_control' primarily tests storm_control properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
intf = find_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  preclean_intf:  true,
  code:           [0, 2],
  manifest_props: {
    switchport_mode:         'trunk',
    storm_control_broadcast: 'default',
    storm_control_multicast: 'default',
    storm_control_unicast:   'default',
  },
  resource:       {
    switchport_mode:         'trunk',
    storm_control_broadcast: '100.00',
    storm_control_multicast: '100.00',
    storm_control_unicast:   '100.00',
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  intf,
  preclean_intf:  true,
  manifest_props: {
    switchport_mode:         'disabled',
    storm_control_broadcast: '22.22',
    storm_control_multicast: '44.44',
    storm_control_unicast:   '66.66',
  },
}

def cleanup(agent, intf)
  interface_cleanup(agent, intf)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent, intf) }
  cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
