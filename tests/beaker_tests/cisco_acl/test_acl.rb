###############################################################################
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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
  resource_name:    'cisco_acl',
  operating_system: 'nexus',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default tests',
  title_pattern:  'ipv4 beaker',
  manifest_props: {
    fragments: 'default',
  },
  resource:       {
    'stats_per_entry' => 'false',
  },
}

tests[:non_default] = {
  desc:           '1.2 Non-default tests',
  title_pattern:  'ipv4 beaker',
  manifest_props: {
    stats_per_entry: 'true',
    fragments:       'permit',
  },
}

tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  title_pattern: 'ipv4',
  title_params:  { acl_name: 'beaker_t1' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: 'ipv6',
  title_params:  { acl_name: 'beaker_t2' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_3] = {
  desc:           'T.3 Title Pattern',
  title_pattern:  'beaker_t3',
  # This is an unusual pattern which can't be handled by
  # title_pattern_munge so use :manifest_props instead
  manifest_props: { afi: 'ipv4' },
  resource:       { 'ensure' => 'present' },
}

# class to contain the test_dependencies specific to this test case
class TestAcl < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    if ctx.platform[%r{n(3k-f|5k|6k|9k-f)}]
      [:fragments]
    else
      []
    end
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { resource_absent_cleanup(agent, 'cisco_acl') }
  resource_absent_cleanup(agent, 'cisco_acl')

  # ------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. ACL Testing")
  id = :default
  test_harness_run(tests, id, harness_class: TestAcl)
  tests[id][:title_pattern] = 'ipv6 beaker6'
  test_harness_run(tests, id, harness_class: TestAcl)

  id = :non_default
  test_harness_run(tests, id, harness_class: TestAcl)
  tests[id][:title_pattern] = 'ipv6 beaker6'
  test_harness_run(tests, id, harness_class: TestAcl)

  resource_absent_cleanup(agent, 'cisco_acl')
  # ------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1, harness_class: TestAcl)
  test_harness_run(tests, :title_patterns_2, harness_class: TestAcl)
  test_harness_run(tests, :title_patterns_3, harness_class: TestAcl)

  # ---------------------------------------------------------
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
