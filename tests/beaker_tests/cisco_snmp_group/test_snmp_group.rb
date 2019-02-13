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
  agent:         agent,
  master:        master,
  resource_name: 'cisco_snmp_group',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:existing_role] = {
  desc:           '1.1 Default Present Properties',
  title_pattern:  'network-admin',
  ensure:         :present,
  manifest_props: {
  },
  resource:       {
  },
  code:           [0],
}

tests[:non_existing_role] = {
  desc:           '1.2 Default Absent Properties',
  title_pattern:  'foo',
  ensure:         :absent,
  manifest_props: {
  },
  resource:       {
  },
  code:           [0],
}

tests[:negative_non_existing_role] = {
  desc:           '2.1 Negative Present Properties',
  title_pattern:  'foo-bar',
  ensure:         :present,
  manifest_props: {
  },
  stderr_pattern: /Snmp group creation not supported/,
  code:           [4],
}

tests[:negative_existing_role] = {
  desc:           '2.2 Negative Absent Properties',
  title_pattern:  'network-operator',
  ensure:         :absent,
  manifest_props: {
  },
  resource:       {
    ensure: 'present',
  },
  code:           [0],
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :existing_role)
  test_harness_run(tests, :non_existing_role)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Negative Property Testing")
  # skipping idempotence as the role cannot be created by `cisco_snmp_group` as it is
  # a readonly provider.
  test_harness_run(tests, :negative_non_existing_role, skip_idempotence_check: true)
  test_harness_run(tests, :negative_existing_role)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
