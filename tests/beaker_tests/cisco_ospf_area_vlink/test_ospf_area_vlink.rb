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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_ospf_area_vlink',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Defaults',
  title_pattern:  'dark_blue default 1.1.1.1 2.2.2.2',
  manifest_props: {
    auth_key_chain:                     'default',
    authentication:                     'default',
    authentication_key_encryption_type: 'default',
    authentication_key_password:        'default',
    dead_interval:                      'default',
    hello_interval:                     'default',
    message_digest_algorithm_type:      'default',
    message_digest_encryption_type:     'default',
    message_digest_key_id:              'default',
    message_digest_password:            'default',
    retransmit_interval:                'default',
    transmit_delay:                     'default',
  },
  code:           [0, 2],
  resource:       {
    authentication_key_encryption_type: 'cleartext',
    dead_interval:                      40,
    hello_interval:                     10,
    message_digest_algorithm_type:      'md5',
    message_digest_encryption_type:     'cleartext',
    message_digest_key_id:              0,
    retransmit_interval:                5,
    transmit_delay:                     1,
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  'dark_blue default 1.1.1.1 2.2.2.2',
  manifest_props: {
    auth_key_chain:                     'testKeyChain',
    authentication:                     'md5',
    authentication_key_encryption_type: '3des',
    authentication_key_password:        '3109a60f51374a0d',
    dead_interval:                      '500',
    hello_interval:                     '2000',
    message_digest_algorithm_type:      'md5',
    message_digest_encryption_type:     'cisco_type_7',
    message_digest_key_id:              '82',
    message_digest_password:            '046E1803362E595C260E0B240619050A2D',
    retransmit_interval:                '1000',
    transmit_delay:                     '400',
  },
}

def cleanup(agent)
  test_set(agent, 'no feature ospf')
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

  id = :default
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  cleanup(agent)
  test_harness_run(tests, :non_default)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
