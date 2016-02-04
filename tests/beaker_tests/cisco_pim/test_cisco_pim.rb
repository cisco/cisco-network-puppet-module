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
  resource_name: 'cisco_pim',
}

# Test hash test cases
tests[:non_def_S1] = {
  desc:           ' 1.1 Non default properties',
  preclean:       'cisco_pim',
  title_pattern:  'ipv4 red',
  manifest_props: {
    ssm_range: '224.0.0.0/8'
  },
}

tests[:non_def_S2] = {
  desc:           ' 1.2 Non default properties',
  title_pattern:  'ipv4 red',
  manifest_props: {
    ssm_range: 'none'
  },
}

# Note: The [:manifest_props] key is not normally needed for title_pattern
# testing but cisco_pim will fail this test without it because cisco_pim can
# exist as an empty object with no property state; in which case the manifest
# test will fail because it won't detect any changes. For this reason we
# include at least one property.
#
tests[:title_patterns_1] = {
  desc:           'T.1 Title Pattern',
  preclean:       'cisco_pim',
  title_pattern:  'new_york',
  title_params:   { afi: 'ipv4', vrf: 'red' },
  manifest_props: { ssm_range: '224.0.0.0/8 225.0.0.0/8' },
  resource:       { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:           'T.2 Title Pattern',
  title_pattern:  'ipv4',
  title_params:   { vrf: 'blue' },
  manifest_props: { ssm_range: '224.0.0.0/8 225.0.0.0/8' },
  resource:       { 'ensure' => 'present' },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")
  test_harness_run(tests, :non_def_S1)
  test_harness_run(tests, :non_def_S2)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_pim')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
