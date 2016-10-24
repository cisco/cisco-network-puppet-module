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
  intf_type:     'port-channel',
  platform:      'n(3|9)k',
  resource_name: 'cisco_interface_hsrp',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
@intf = 'port-channel100'

# Test hash test cases
tests[:default] = {
  desc:               '1.1 Default properties',
  title_pattern:      @intf,
  sys_def_switchport: false,
  manifest_props:     {
    bfd:           'default',
    delay_minimum: 'default',
    delay_reload:  'default',
    mac_refresh:   'default',
    use_bia:       'default',
    version:       'default',
  },
  code:               [0, 2],
  resource:           {
    bfd:           'false',
    delay_minimum: 0,
    delay_reload:  0,
    mac_refresh:   'false',
    use_bia:       'false',
    version:       1,
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default properties',
  title_pattern:  @intf,
  manifest_props: {
    bfd:           'true',
    delay_minimum: 100,
    delay_reload:  200,
    mac_refresh:   350,
    use_bia:       'use_bia_intf',
    version:       2,
  },
}

def cleanup(agent)
  cmd = 'no feature hsrp'
  test_set(agent, cmd)
  interface_cleanup(agent, @intf)
end

# Overridden to properly handle dependencies for this test file.
def test_harness_dependencies(_tests, _id)
  cleanup(agent)

  cmd = [
    "feature hsrp ; interface #{@intf} ; no switchport"
  ].join(' ; ')
  test_set(agent, cmd)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default)

  id = :default
  tests[id][:desc] = '1.4 Common Defaults (absent)'
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default)
  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
