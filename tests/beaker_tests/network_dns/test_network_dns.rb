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
  resource_name: 'network_dns',
}
# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

original_hostname = hostname

#
# Set Properties
#
tests[:set] = {
  desc:           '1.1 Set Properties',
  title_pattern:  'settings',
  manifest_props: {
    domain:   'foo.bar.com',
    hostname: 'foo',
    search:   ['test.com'],
    servers:  ['2001:4860:4860::8888', '8.8.8.8'],
  },
  code:           [0, 1, 2],
}

#
# Set Properties without a hostname to
# account for a bug that was raised where
# it would attempt to delete an unmanaged hostname
#
tests[:no_hostname] = {
  desc:           '1.2 Set without hostname',
  title_pattern:  'settings',
  manifest_props: {
    domain: 'foo.bar.com',
    search: ['test.com'],
  },
  code:           [0, 1, 2],
}

def cleanup(original_hostname)
  create_and_apply_test_manifest('network_dns', 'settings', 'hostname', original_hostname)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(original_hostname) }
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Set Property Testing")
  test_harness_run(tests, :set, skip_idempotence_check: true)
  cleanup(original_hostname)
  test_harness_run(tests, :no_hostname, skip_idempotence_check: true)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
