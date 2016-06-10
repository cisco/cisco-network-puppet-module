###############################################################################
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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
#
# 'test_interface_bdi' primarily tests BDI interface properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  platform:         'n(7)k',
  resource_name:    'cisco_interface',
  bridge_domain:    '100',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Assign a test interface.
intf = 'bdi100'

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  preclean_intf:  true,
  manifest_props: {
    shutdown: 'default'
  },
  resource:       {
    'shutdown' => 'true'
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  intf,
  manifest_props: {
    ipv4_address:        '10.10.10.1',
    ipv4_netmask_length: '24',
    shutdown:            'false',
    vrf:                 'test1',
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)

  # -------------------------------------------------------------------
  remove_interface(agent, intf)
  remove_all_vlans(agent)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
