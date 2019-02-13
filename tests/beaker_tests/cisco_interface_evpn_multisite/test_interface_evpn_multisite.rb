###############################################################################
# Copyright (c) 2017 Cisco and/or its affiliates.
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
  master:           master,
  agent:            agent,
  intf_type:        'ethernet',
  platform:         'n9k-ex',
  operating_system: 'nexus',
  resource_name:    'cisco_interface_evpn_multisite',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
intf = find_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:               '1.1 Defaults',
  title_pattern:      "#{intf}",
  sys_def_switchport: false,
  manifest_props:     {},
  code:               [0, 2],
}

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  "#{intf}",
  preclean_intf:  true,
  manifest_props: {
    tracking: 'fabric-tracking'
  },
  resource:       {
    tracking: 'fabric-tracking'
  },
  code:           [0, 2],
}

# class to contain the test_harness_dependencies
class TestInterfaceEvpnMultisite < BaseHarness
  def self.test_harness_dependencies(ctx, _tests, id)
    return unless id == :default
    ctx.test_set(ctx.agent, 'evpn multisite border 150')
  end
end

def cleanup(agent, intf)
  test_set(agent, 'no evpn multisite border 150')
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
  id = :default
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestInterfaceEvpnMultisite)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default, harness_class: TestInterfaceEvpnMultisite)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
