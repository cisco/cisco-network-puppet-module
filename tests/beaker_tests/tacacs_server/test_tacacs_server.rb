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
  resource_name: 'tacacs_server',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  '8.8.8.8',
  manifest_props: {
    port:       46,
    timeout:    5,
    key_format: 7,
    key:        '6666',
  },
  code:           [0, 2],
}

#
# non_default_properties
#
tests[:ipv6] = {
  desc:           '2.1 IPV6 Properties',
  title_pattern:  '2020::20',
  manifest_props: {
    port:       48,
    timeout:    5,
    key_format: 7,
    key:        '6666',
  },
}

def cleanup(agent)
  test_set(agent, 'no feature tacacs+')
  resource_absent_cleanup(agent, 'tacacs_server')
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
  logger.info("\n#{'-' * 60}\nSection 2. IPV6 Property Testing")
  test_harness_run(tests, :ipv6)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
