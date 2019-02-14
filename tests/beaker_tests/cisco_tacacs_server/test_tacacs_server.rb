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
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  resource_name:    'cisco_tacacs_server',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 default properties',
  title_pattern:  'default',
  manifest_props: {
    'timeout'             => 'default',
    'deadtime'            => 'default',
    'encryption_type'     => 'default',
    'encryption_password' => 'default',
    'directed_request'    => 'false',
    'source_interface'    => 'default',
  },
  resource:       {
    'timeout'          => '5',
    'deadtime'         => '0',
    'directed_request' => 'false',
    'source_interface' => 'default',
  },
}

tests[:non_default] = {
  desc:           '2.1 non-default properties',
  title_pattern:  'default',
  manifest_props: {
    'timeout'             => 50,
    'deadtime'            => 'default',
    'encryption_type'     => 'encrypted',
    'encryption_password' => 'WXYZ12',
    'directed_request'    => 'false',
    'source_interface'    => 'Ethernet1/4',
  },
  resource:       {
    'timeout'             => '50',
    'deadtime'            => '0',
    'encryption_password' => 'WXYZ12',
    'encryption_type'     => 'encrypted',
    'directed_request'    => 'false',
    'source_interface'    => 'Ethernet1/4',
  },
}

tests[:negative_timeout] = {
  desc:           '3.1 negative properties',
  title_pattern:  'default',
  manifest_props: {
    'timeout' => '-1',
  },
  resource:       {
  },
  code:           [4],
  stderr_pattern: /Invalid number/,
}

tests[:negative_deadtime] = {
  desc:           '3.2 negative properties',
  title_pattern:  'default',
  manifest_props: {
    'deadtime' => '-1',
  },
  resource:       {
  },
  code:           [4],
  stderr_pattern: /Invalid number/,
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, skip_idempotence_check: true)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  test_harness_run(tests, :non_default)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Negative Property Testing")
  test_harness_run(tests, :negative_timeout, skip_idempotence_check: true)
  test_harness_run(tests, :negative_deadtime, skip_idempotence_check: true)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
