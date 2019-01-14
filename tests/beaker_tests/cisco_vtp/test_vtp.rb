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

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  resource_name:    'cisco_vtp',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  title_pattern:  'default',
  manifest_props: {
    domain:   'cisco1234',
    filename: 'default',
    password: 'default',
    version:  'default',
  },
  resource:       {
    'domain'   => 'cisco1234',
    'filename' => 'bootflash:\/vlan.dat',
    'version'  => '1',
  },
}

# Test hash test cases
tests[:non_default] = {
  title_pattern:  'default',
  manifest_props: {
    'domain'   => 'cisco1234',
    'filename' => 'vtp.dat',
    'password' => 'cisco12345$^&',
    'version'  => '2',
  },
  resource:       {
    'filename' => 'bootflash:\/vtp.dat',
  },
}

# Not sure on what the defaults for negatives will be,
# and no n3k-f or n9k-f to test against, so expecting
# this test case might fail :(
tests[:negatives] = {
  title_pattern:  'default',
  platform:       'n(3|9)k-f',
  manifest_props: {
    'domain'   => '',
    'filename' => '',
    'password' => '',
    'version'  => '-1',
  },
  resource:       {
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    resource_absent_cleanup(agent, 'cisco_vtp', 'Cleardown for vtp test')
  end
  resource_absent_cleanup(agent, 'cisco_vtp', 'Setup for vtp test')

  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)
  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  test_harness_run(tests, :non_default)
  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Negative Property Testing")
  test_harness_run(tests, :negatives)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
