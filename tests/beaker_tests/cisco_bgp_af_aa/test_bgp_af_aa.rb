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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_bgp_af_aa',
}

skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  '2 default ipv4 unicast 1.1.1.1/32',
  manifest_props: {
    as_set:        'default',
    summary_only:  'default',
    advertise_map: 'default',
    attribute_map: 'default',
    suppress_map:  'default',
  },
  code:           [0, 2],
  resource:       {
    as_set:       'false',
    summary_only: 'false',
  },
}

tests[:non_default1] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  '2 red ipv6 multicast 2000::1/128',
  manifest_props: {
    as_set:        'true',
    advertise_map: 'adm',
    attribute_map: 'atm',
    suppress_map:  'sum',
  },
}

tests[:non_default2] = {
  desc:           '2.2 Non Defaults',
  title_pattern:  '2 red ipv6 multicast 2000::1/128',
  manifest_props: {
    summary_only: 'true'
  },
}

# class to contain the test_dependencies specific to this test case
class TestBgpAfAa < BaseHarness
  def self.dependency_manifest(_ctx, _tests, _id)
    "
      cisco_bgp { '2 default':
        ensure => present,
      }

      cisco_bgp_af { '2 default ipv4 unicast':
        ensure => present,
      }

      cisco_bgp_af { '2 red ipv6 multicast':
        ensure => present,
      }
    "
  end
end

def cleanup(agent)
  test_set(agent, 'no feature bgp')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, harness_class: TestBgpAfAa)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default1, harness_class: TestBgpAfAa)
  test_harness_run(tests, :non_default2, harness_class: TestBgpAfAa)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
