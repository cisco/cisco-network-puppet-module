###############################################################################
# Copyright (c) 2017 Cisco and/or its affiliates.
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
  master:        master,
  agent:         agent,
  platform:      'n(3|7|9)k',
  resource_name: 'cisco_object_group_entry',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:seq_10_v4] = {
  title_pattern:  'ipv4 address beaker 10',
  manifest_props: {
    address: '1.2.3.4 2.3.4.5'
  },
}

tests[:seq_10_v6] = {
  desc:           'IPv6 Seq 10',
  title_pattern:  'ipv6 address beaker6 10',
  manifest_props: {
    address: '1:1::1/64'
  },
}

tests[:seq_20_v4] = {
  title_pattern:  'ipv4 port beakerp 20',
  manifest_props: {
    port: 'eq 40'
  },
}

tests[:seq_30_v4] = {
  desc:           'IPv4 Seq 30',
  title_pattern:  'ipv4 port beakerp 30',
  manifest_props: {
    port: 'range 300 550'
  },
}

# class to contain the test_dependencies specific to this test case
class TestObjectGroup < BaseHarness
  def self.dependency_manifest(_ctx, _tests, _id)
    "
      cisco_object_group { 'ipv4 address beaker':
        ensure => present,
      }

      cisco_object_group { 'ipv6 address beaker6':
        ensure => present,
      }

      cisco_object_group { 'ipv4 port beakerp':
        ensure => present,
      }
    "
  end
end

def cleanup
  logger.info('Testcase Cleanup:')
  resource_absent_cleanup(agent, 'cisco_object_group_entry')
  resource_absent_cleanup(agent, 'cisco_object_group')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  cleanup
  teardown { cleanup }

  # ---------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. ObjectGroup Testing")

  test_harness_run(tests, :seq_10_v4, harness_class: TestObjectGroup)
  test_harness_run(tests, :seq_10_v6, harness_class: TestObjectGroup)
  test_harness_run(tests, :seq_20_v4, harness_class: TestObjectGroup)
  test_harness_run(tests, :seq_30_v4, harness_class: TestObjectGroup)

  # ---------------------------------------------------------
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
