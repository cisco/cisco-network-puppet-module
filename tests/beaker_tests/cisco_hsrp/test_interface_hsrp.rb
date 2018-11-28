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
  platform:      'n(3|7|9)k',
  resource_name: 'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)
skip_nexus_image('D1', tests)

# Find a usable interface for this test
@intf = 'port-channel100'

# Test hash test cases
tests[:default] = {
  desc:               '1.1 Default properties',
  title_pattern:      @intf,
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode:    'disabled',
    hsrp_bfd:           'default',
    hsrp_delay_minimum: 'default',
    hsrp_delay_reload:  'default',
    hsrp_mac_refresh:   'default',
    hsrp_use_bia:       'default',
    hsrp_version:       'default',
  },
  code:               [0, 2],
  resource:           {
    hsrp_delay_minimum: 0,
    hsrp_delay_reload:  0,
    hsrp_version:       1,
    # hsrp_bfd is nil when set to default
    # hsrp_mac_refresh is nil when set to default
    # hsrp_use_bia is nil when set to defaul
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default properties',
  title_pattern:  @intf,
  manifest_props: {
    switchport_mode:    'disabled',
    hsrp_bfd:           'true',
    hsrp_delay_minimum: 100,
    hsrp_delay_reload:  200,
    hsrp_mac_refresh:   350,
    hsrp_use_bia:       'use_bia_intf',
    hsrp_version:       2,
  },
}

def cleanup(agent)
  cmd = 'no feature hsrp'
  test_set(agent, cmd)
  interfaces = get_current_resource_instances(agent, 'cisco_interface')
  interfaces.each do |interface|
    if interface =~ %r{#{@intf}}
      interface_cleanup(agent, @intf)
    end
  end
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
  tests[id][:desc] = '1.2 Common Defaults (absent)'
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default)
  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
