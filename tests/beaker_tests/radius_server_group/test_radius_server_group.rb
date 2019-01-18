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
  resource_name: 'radius_server_group',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:create_present] = {
  desc:           '1.1 Create Present',
  title_pattern:  'red',
  manifest_props: {
    ensure:  'present',
    servers: ['2.2.2.2', '3.3.3.3'],
  },
  code:           [0, 2],
}

tests[:update_servers] = {
  desc:           '2.1 Update Servers',
  title_pattern:  'red',
  manifest_props: {
    ensure:  'present',
    servers: ['2.2.2.2', '4.4.4.4'],
  },
}

tests[:unset_servers] = {
  desc:           '3.1 Unset Servers',
  title_pattern:  'red',
  manifest_props: {
    ensure:  'present',
    servers: ['unset'],
  },
}

tests[:delete_absent] = {
  desc:           '4.1 Delete Absent',
  title_pattern:  'red',
  manifest_props: {
    ensure: 'absent',
  },
}

def cleanup(agent)
  resource_absent_cleanup(agent, 'radius_server')
  resource_absent_cleanup(agent, 'radius_server_group')
end

def test_setup(agent)
  cleanup(agent)
  command_config(agent, 'radius-server host 2.2.2.2')
  command_config(agent, 'radius-server host 3.3.3.3')
  command_config(agent, 'radius-server host 4.4.4.4')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  test_setup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Create Present Testing")
  test_harness_run(tests, :create_present)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Update Servers Testing")
  test_harness_run(tests, :update_servers)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Unset Servers Testing")
  test_harness_run(tests, :unset_servers)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. Delete Absent Testing")
  test_harness_run(tests, :delete_absent)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
