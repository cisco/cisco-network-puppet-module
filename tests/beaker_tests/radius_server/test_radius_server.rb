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
  resource_name: 'radius_server',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:manifest_present] = {
  desc:           '1.1 Create Radius Server Manifest Present',
  title_pattern:  '8.8.8.8',
  manifest_props: {
    ensure:              'present',
    accounting_only:     true,
    acct_port:           66,
    auth_port:           77,
    authentication_only: true,
    key:                 '44444444',
    key_format:          7,
    retransmit_count:    4,
    timeout:             2,
  },
  code:           [0, 2],
}

tests[:manifest_present_change] = {
  desc:           '1.2 Update Radius Server Manifest Present Change',
  title_pattern:  '8.8.8.8',
  manifest_props: {
    ensure:              'present',
    accounting_only:     false,
    acct_port:           44,
    auth_port:           55,
    authentication_only: true,
    key:                 'unset',
    retransmit_count:    -1,
    timeout:             -1,
  },
  resource:       {
    ensure:              'present',
    accounting_only:     false,
    acct_port:           44,
    auth_port:           55,
    authentication_only: true,
    key:                 'unset',
    retransmit_count:    'unset',
    timeout:             'unset',
  },
  code:           [0, 2],
}

tests[:manifest_absent] = {
  desc:           '2.1 Radius Server Manifest Absent',
  title_pattern:  '8.8.8.8',
  manifest_props: {
    ensure: 'absent',
  },
  code:           [0, 2],
}

tests[:manifest_present_ipv6] = {
  desc:           '3.1 Create Radius Server Manifest Present IPv6',
  title_pattern:  '2003::7',
  manifest_props: {
    ensure:              'present',
    accounting_only:     true,
    acct_port:           66,
    auth_port:           77,
    authentication_only: true,
    key:                 '44444444',
    key_format:          7,
    retransmit_count:    4,
    timeout:             2,
  },
  code:           [0, 2],
}

tests[:manifest_absent_ipv6] = {
  desc:           '4.1 Radius Server Manifest Absent IPv6',
  title_pattern:  '2003::7',
  manifest_props: {
    ensure: 'absent',
  },
  code:           [0, 2],
}

def cleanup(agent)
  resource_absent_cleanup(agent, 'radius_server')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Property Testing")
  test_harness_run(tests, :manifest_present)
  test_harness_run(tests, :manifest_present_change)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Absent Testing")
  test_harness_run(tests, :manifest_absent)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. IPv6 Property Testing")
  test_harness_run(tests, :manifest_present_ipv6)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. IPv6 Absent Testing")
  test_harness_run(tests, :manifest_absent_ipv6)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
