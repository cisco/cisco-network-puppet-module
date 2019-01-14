###############################################################################
# Copyright (c) 2014-2017 Cisco and/or its affiliates.
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
# 'test_interface_svi' primarily tests SVI interface properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  resource_name:    'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Assign a test interface.
intf = 'vlan13'

# Test hash test cases
tests[:default_mgmt] = {
  desc:           "1.1 Default 'mgmt'",
  title_pattern:  intf,
  manifest_props: {
    description:    'Test default properties',
    svi_management: 'default',
  },
  resource:       {
    description:    'Test default properties',
    svi_management: 'false',
  },
}

tests[:non_default_mgmt] = {
  desc:           "1.2 Non Default 'mgmt'",
  title_pattern:  intf,
  manifest_props: {
    svi_management: 'true'
  },
}

tests[:default_autostate] = {
  platform:       'n(3|7|9)k',
  desc:           "2.1 Default 'autostate'",
  title_pattern:  intf,
  preclean_intf:  true,
  manifest_props: {
    svi_autostate: 'default'
  },
  resource:       {
    svi_autostate: 'true'
  },
}

tests[:non_default_autostate] = {
  platform:       'n(3|7|9)k',
  desc:           "2.1 Non Default 'autostate'",
  title_pattern:  intf,
  preclean_intf:  true,
  manifest_props: {
    svi_autostate: 'false'
  },
}

tests[:anycast] = {
  desc:                '3.1 Anycast Gateway',
  title_pattern:       intf,
  platform:            'n9k',
  anycast_gateway_mac: true,
  manifest_props:      {
    fabric_forwarding_anycast_gateway: 'true'
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    vdc_limit_f3_no_intf_needed(:clear)
    remove_interface(agent, intf)
  end
  remove_interface(agent, intf)
  vdc_limit_f3_no_intf_needed(:set)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Property Testing")
  test_harness_run(tests, :default_mgmt, harness_class: Interfacelib)
  test_harness_run(tests, :non_default_mgmt, harness_class: Interfacelib)

  test_harness_run(tests, :default_autostate, harness_class: Interfacelib)
  test_harness_run(tests, :non_default_autostate, harness_class: Interfacelib)

  test_harness_run(tests, :anycast, harness_class: Interfacelib)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
