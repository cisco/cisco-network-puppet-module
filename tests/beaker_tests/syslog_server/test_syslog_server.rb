###############################################################################
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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
  agent:         agent,
  master:        master,
  resource_name: 'syslog_server',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  title_pattern:  '1.2.3.4',
  manifest_props: {
    vrf:      'default',
    facility: 'local7',
  },
}

# Test hash test cases
tests[:non_default] = {
  title_pattern:  '4.3.2.1',
  manifest_props: {
    severity_level: 2,
    port:           48,
    vrf:            'default',
    facility:       'mail',
  },
}

def cleanup(agent)
  test_set(agent, 'no logging server 1.2.3.4')
  test_set(agent, 'no logging server 4.3.2.1')
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
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
