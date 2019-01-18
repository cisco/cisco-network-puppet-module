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
  resource_name: 'snmp_user',
  ensurable:     true,
}
# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)
# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default_user_test',
  manifest_props: {
    roles:         ['network-operator'],
    auth:          'sha',
    password:      '0x7e5030ffd26d7e1b366a9041e9c63c94',
    privacy:       'aes128',
    private_key:   '0xcc012f26b3384d4b3da979bff48b4ffe',
    localized_key: true,
  },
  code:           [0, 2],
}
# Test hash test cases
tests[:minimum] = {
  desc:           '2.1 Minimum Properties',
  title_pattern:  'minimum_user_test',
  manifest_props: {
    roles: ['network-operator'],
  },
  code:           [0, 2],
}
def cleanup(agent)
  test_set(agent, 'no snmp-server user default_user_test  auth sha 0x7e5030ffd26d7e1b366a9041e9c63c94 priv aes-128 0xcc012f26b3384d4b3da979bff48b4ffe localizedkey ')
  test_set(agent, 'no snmp-server user minimum_user_test     ')
end
#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Minimum Property Testing")
  test_harness_run(tests, :minimum)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
