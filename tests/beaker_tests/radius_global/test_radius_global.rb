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
  resource_name: 'radius_global',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    timeout:          'unset',
    retransmit_count: 'unset',
    key:              'unset',
    source_interface: ['unset'],
  },
  resource:       {
    timeout:          5,
    retransmit_count: 1,
    key:              'unset',
    source_interface: ['unset'],
  },
  code:           [0, 2],
}

# Test hash test cases
tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  'default',
  manifest_props: {
    timeout:          6,
    retransmit_count: 2,
    key:              '55555',
    source_interface: ['ethernet1/1'],
  },
  code:           [0, 2],
}

def cleanup(agent)
  cmds = 'radius-server timeout 5 ; radius-server retransmit 1 ; no ip radius source-interface'
  test_set(agent, cmds, ignore_errors: true)

  # To remove a configured key we have to know the key value
  out = test_get(agent, 'include radius-server.key')
  return unless out

  # AgentFull cc output has escape chars; clean up the noise and remove quotes from the key.
  # e.g. "cisco_command_config { 'cc':\n  test_get => \"\\nradius-server key 7 \\\"55555\\\"\\n\",\n}\n"
  #      "cisco_command_config { 'cc':\n  test_get => \"\\nradius-server key 7 55555"
  logger.info(out)
  out = out.sub(/\\\"\\n.*/m, '').sub(/\\\"/, '') if out[/\\\"/]

  key = out.match('radius-server key (\d+)\s+(.*)')
  command_config(agent, "no radius-server key #{key[1]} #{key[2]}", "removing key #{key[2]}") if key
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
  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
