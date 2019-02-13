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
  intf_type:     'ethernet',
  resource_name: 'ntp_server',
}

intf = find_interface(tests)

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  '5.5.5.5',
  manifest_props: {
  },
  code:           [0, 2],
}

tests[:default_ipv6] = {
  desc:           '1.2 IPV6 Default Properties',
  title_pattern:  '2002::5',
  manifest_props: {
  },
  code:           [0, 2],
}

tests[:non_default] = {
  desc:           '2.1 Non-Default Properties',
  title_pattern:  '5.5.5.5',
  manifest_props: {
    key:              1,
    maxpoll:          7,
    minpoll:          5,
    prefer:           true,
    source_interface: intf,
  },
  code:           [0, 2],
}

# class to properly handle unsupported properties for this test case
class TestNtpServer < BaseHarness
  def self.unsupported_properties(_ctx, _tests, _id)
    unprops = []
    unprops << :source_interface
    unprops
  end
end

def cleanup(agent)
  resource_absent_cleanup(agent, 'ntp_auth_key')
  resource_absent_cleanup(agent, 'ntp_server')
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
  test_harness_run(tests, :default_ipv6)
  cleanup(agent)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non-Default Property Testing")
  # setting up an auth key
  test_set(agent, 'ntp authentication-key 1 md5 thisPassword 7')
  test_harness_run(tests, :non_default, harness_class: TestNtpServer)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
