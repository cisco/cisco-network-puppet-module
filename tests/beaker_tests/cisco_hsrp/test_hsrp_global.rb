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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_hsrp_global',
  ensurable:        false,
}

skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    bfd_all_intf:  'default',
    extended_hold: 'default',
  },
  code:           [0, 2],
  resource:       {
    bfd_all_intf:  'false',
    extended_hold: 'false',
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  'default',
  manifest_props: {
    bfd_all_intf:  true,
    extended_hold: 222,
  },
}

# class to contain the test_dependencies specific to this test case
class TestHsrpGlobal < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    unprops << :bfd_all_intf if ctx.platform[/n3k$/]
    unprops
  end
end

def cleanup(agent)
  test_set(agent, 'no feature hsrp')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, harness_class: TestHsrpGlobal)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  cleanup(agent)
  test_harness_run(tests, :non_default, harness_class: TestHsrpGlobal)
  # -------------------------------------------------------------------
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
