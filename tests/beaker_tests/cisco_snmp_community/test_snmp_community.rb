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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_snmp_community',
}

skip_unless_supported(tests)

tests[:defaults] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'test',
  manifest_props: {
    group: 'default',
    acl:   'default',
  },
  resource:       {
    group: 'default',
  }
}

tests[:non_defaults] = {
  desc:           '2.1 Non-Default Properties',
  title_pattern:  'test',
  manifest_props: {
    group: 'default',
    acl:   'aclname',
  },
}

tests[:negative_group] = {
  desc:           '3.1 Negative Properties',
  title_pattern:  'test',
  manifest_props: {
    group: '',
    acl:   'aclname',
  },
  resource:       {
    group: 'default',
    acl:   'aclname',
  },
  code:           [2, 4],
  stderr_pattern: /Invalid command/,
}

tests[:negative_acl] = {
  desc:           '3.2 Negative Properties',
  title_pattern:  'test',
  manifest_props: {
    group: 'default',
    acl:   '',
  },
  resource:       {
    group: 'default',
  },
  code:           [2, 4],
}

def cleanup(agent)
  resource_absent_cleanup(agent, 'cisco_snmp_community', 'Setup switch for cisco_snmp_community provider test')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :defaults)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  test_harness_run(tests, :non_defaults)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Negative Property Testing")
  # existing tests did not check idempotence as the provider is not equipped
  # to be idempotent when setting `negatives` as they are referred too
  test_harness_run(tests, :negative_group, skip_idempotence_check: true)
  test_harness_run(tests, :negative_acl, skip_idempotence_check: true)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
