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
  resource_name: 'hostname',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
# Hostname Present
tests[:hostname_present] = {
  desc:           '1.1 Hostname Present',
  title_pattern:  'testhost',
  manifest_props: {
    ensure: 'present'
  },
}

#
# Hostname absent
tests[:hostname_absent] = {
  desc:           '2.1 Hostname Absent',
  title_pattern:  'testhost',
  manifest_props: {
    ensure: 'absent'
  },
}

# Cleanup commands for test setup/cleanup
@clean_commands = []

def setup(agent)
  @clean_commands = ['no hostname']

  # If we have a current hostname, add to the cleanup command array
  previous_hostname = test_get(agent, 'include ^hostname ', :array)

  return unless previous_hostname.empty?

  @clean_commands << "hostname #{previous_hostname.first.split[1]}"
end

def cleanup(agent)
  @clean_commands.each do |cmd|
    test_set(agent, cmd)
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  setup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Hostname Present Testing")
  test_harness_run(tests, :hostname_present)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Hostname Absent Testing")
  test_harness_run(tests, :hostname_absent)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
