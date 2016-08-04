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
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'cisco_interface_ospf',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
@intf = find_interface(tests)
tp = @intf + ' Sample'

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Defaults',
  title_pattern:  tp,
  preclean_intf:  true,
  manifest_props: {
    area:                           200,
    bfd:                            'default',
    cost:                           'default',
    dead_interval:                  'default',
    hello_interval:                 'default',
    message_digest:                 'default',
    message_digest_key_id:          'default',
    message_digest_algorithm_type:  'default',
    message_digest_encryption_type: 'default',
    message_digest_password:        'default',
    network_type:                   'default',
    passive_interface:              'default',
  },
  code:           [0, 2],
  resource:       {
    area:                           '0.0.0.200',
    cost:                           0,
    dead_interval:                  40,
    hello_interval:                 10,
    message_digest:                 'false',
    message_digest_key_id:          0,
    message_digest_algorithm_type:  'md5',
    message_digest_encryption_type: 'cleartext',
    passive_interface:              'false',
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  tp,
  preclean_intf:  true,
  manifest_props: {
    area:                           200,
    bfd:                            'true',
    cost:                           '200',
    dead_interval:                  '200',
    hello_interval:                 '200',
    message_digest:                 'true',
    message_digest_key_id:          27,
    message_digest_algorithm_type:  'md5',
    message_digest_encryption_type: 'cisco_type_7',
    message_digest_password:        '046E1803362E595C260E0B240619050A2D',
    network_type:                   'p2p',
    passive_interface:              'true',
  },
  resource:       {
    area: '0.0.0.200'
  },
}

# Overridden to properly handle dependencies for this test file.
def test_harness_dependencies(_tests, id)
  return unless id == :default
  cmd = [
    'feature ospf ; router ospf Sample',
    "interface #{@intf} ; no switchport",
  ].join(' ; ')
  command_config(agent, cmd, cmd)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  id = :default
  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default)
  interface_cleanup(agent, @intf)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
