###############################################################################
# Copyright (c) 2018 Cisco and/or its affiliates.
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

tests = {
  agent:         agent,
  master:        master,
  resource_name: 'cisco_ospf',
  # type is ensurable, but require control in testing `negatives`
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:ensurability] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'green',
  ensure:         :present,
  code:           [0, 2],
  manifest_props: {
  },
}

tests[:negative_values] = {
  desc:           '2.1 Negative Properties',
  title_pattern:  'green',
  code:           [1],
  manifest_props: {
    ensure: 'unknown',
  },
  resource:       {
  },
  stderr_pattern: /Invalid value \"unknown\". Valid values are present, absent./,
}

def cleanup(agent)
  resource_absent_cleanup(agent, 'cisco_ospf', 'Setup switch for cisco_ospf provider test')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    cleanup(agent)
  end
  cleanup(agent)

  # ---------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Ensurability Tests")
  test_harness_run(tests, :ensurability)
  tests[:ensurability][:ensure] = :absent
  tests[:ensurability][:desc] = '1.2 Default Properties'
  test_harness_run(tests, :ensurability)
  # ---------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Negative Value Tests")
  test_harness_run(tests, :negative_values, skip_idempotence_check: true)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
