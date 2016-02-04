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
  resource_name: 'cisco_pim_rp_address',
}

# Test hash test cases
tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  preclean:      'cisco_pim_rp_address',
  title_pattern: 'new_york',
  title_params:  { afi: 'ipv4', vrf: 'red', rp_addr: '1.1.1.1' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: 'ipv4',
  title_params:  { vrf: 'blue', rp_addr: '1.1.1.1' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_3] = {
  desc:          'T.3 Title Pattern',
  title_pattern: 'ipv4 cyan',
  title_params:  { rp_addr: '1.1.1.1' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_4] = {
  desc:          'T.4 Title Pattern',
  title_pattern: 'ipv4 magenta 1.1.1.1',
  resource:      { 'ensure' => 'present' },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  test_harness_run(tests, :title_patterns_3)
  test_harness_run(tests, :title_patterns_4)
  # -------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_pim_rp_address')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
