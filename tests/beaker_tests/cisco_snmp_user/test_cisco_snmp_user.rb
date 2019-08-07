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
  resource_name:    'cisco_snmp_user',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# This feature is very buggy on camden images so skip it.
skip_nexus_image(/I2/, tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 default properties',
  title_pattern:  'snmpuser1',
  manifest_props: {
    'groups'        => ['network-operator'],
    'auth_protocol' => 'md5',
    'auth_password' => 'XXWWPass0wrf',
    'priv_protocol' => 'aes128',
    'priv_password' => 'WWXXPaas0wrf',
    'localized_key' => false,
  },
  resource:       {
    'auth_protocol' => 'md5',
    'auth_password' => '0x[0-9a-fA-F]*',
    'priv_protocol' => 'aes128',
    'priv_password' => '0x[0-9a-fA-F]*',
  },
}

tests[:non_default] = {
  desc:           '2.1 non-default properties',
  title_pattern:  'snmpuser1',
  manifest_props: {
    'groups'        => ['network-operator'],
    'auth_protocol' => 'sha',
    'auth_password' => 'XXWWPass0wrf',
    'priv_protocol' => 'des',
    'priv_password' => 'WWXXPaas0wrf',
    'localized_key' => false,
  },
  resource:       {
    'auth_protocol' => 'sha',
    'auth_password' => '0x[0-9a-fA-F]*',
    'priv_protocol' => 'des',
    'priv_password' => '0x[0-9a-fA-F]*',
  },
}

tests[:negatives] = {
  desc:           '3.1 negatives properties',
  title_pattern:  'snmpuser1',
  manifest_props: {
    'groups'        => ['network-operator'],
    'auth_protocol' => 'unknown',
    'auth_password' => 'XXWWPass0wrf',
    'priv_protocol' => 'unknown',
    'priv_password' => 'WWXXPaas0wrf',
    'localized_key' => false,
  },
  resource:       {
    'auth_password' => '0x[0-9a-fA-F]*',
    'priv_password' => '0x[0-9a-fA-F]*',
  },
  stderr_pattern: /Invalid value \"unknown\". Valid values are/,
  code:           [1, 4],
}

def cleanup(agent)
  resource_absent_cleanup(agent, 'cisco_snmp_user')
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

  # A few image versions have a bug where the device displays the
  # previously configured auth protocol.  Remove the snmp user
  # before executing non-default property test.
  cleanup(agent) if image?[/7.0.3.I2|I3|I4/]

  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  test_harness_run(tests, :non_default)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Negative Property Testing")
  test_harness_run(tests, :negatives, skip_idempotence_check: true)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
