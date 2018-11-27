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

tests = {
  agent:         agent,
  master:        master,
  ensurable:     false,
  resource_name: 'service',
  agent_only:    true,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

os_service = 'puppet'
os_service = 'crond' if system_manager[/systemd|redhat/]

tests[:service_start] = {
  desc:           "1.1 Start Service '#{os_service}'",
  title_pattern:  os_service,
  manifest_props: {
    name:     os_service,
    ensure:   'running',
    enable:   'true',
    provider: system_manager,
  },
  resource:       { 'ensure' => 'running' },
}

tests[:service_stop] = {
  desc:           "1.2 Stop Service '#{os_service}'",
  title_pattern:  os_service,
  manifest_props: {
    name:     os_service,
    ensure:   'stopped',
    enable:   'false',
    provider: system_manager,
  },
  resource:       { 'ensure' => 'stopped' },
}

def cleanup(tests)
  puppet_resource_cmd_from_params(tests, :service_stop)
  cmd = tests[:service_stop][:resource_cmd] + ' ensure=stopped enable=false'
  logger.info("Cleanup: #{cmd}")
  on(tests[:agent], cmd, acceptable_error_codes: [0, 2])
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(tests) }
  cleanup(tests)

  # ----------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Service Tests")
  test_harness_run(tests, :service_start)
  test_harness_run(tests, :service_stop)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
