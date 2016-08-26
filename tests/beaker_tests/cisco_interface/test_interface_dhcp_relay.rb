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
#
# 'test_interface_dhcp_relay' primarily tests dhcp relay properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
intf = find_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  preclean_intf:  true,
  code:           [0],
  manifest_props: {
    switchport_mode:                  'disabled',
    ipv4_dhcp_relay_addr:             'default',
    ipv4_dhcp_relay_info_trust:       'default',
    ipv4_dhcp_relay_src_addr_hsrp:    'default',
    ipv4_dhcp_relay_src_intf:         'default',
    ipv4_dhcp_relay_subnet_broadcast: 'default',
    ipv4_dhcp_smart_relay:            'default',
    ipv6_dhcp_relay_addr:             'default',
    ipv6_dhcp_relay_src_intf:         'default',
  },
  resource:       {
    switchport_mode:                  'disabled',
    ipv4_dhcp_relay_info_trust:       'false',
    ipv4_dhcp_relay_src_addr_hsrp:    'false',
    ipv4_dhcp_relay_src_intf:         'false',
    ipv4_dhcp_relay_subnet_broadcast: 'false',
    ipv4_dhcp_smart_relay:            'false',
    ipv6_dhcp_relay_src_intf:         'false',
  },
}

v4_relay = ['1.1.1.1', '2.2.2.2', '3.3.3.3']
v6_relay = ['2000::11', '2001::22', '2001::12']

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  intf,
  preclean_intf:  true,
  code:           [0],
  manifest_props: {
    switchport_mode:                  'disabled',
    ipv4_dhcp_relay_addr:             v4_relay,
    ipv4_dhcp_relay_info_trust:       'true',
    ipv4_dhcp_relay_src_addr_hsrp:    'true',
    ipv4_dhcp_relay_src_intf:         'loopback 1',
    ipv4_dhcp_relay_subnet_broadcast: 'true',
    ipv4_dhcp_smart_relay:            'true',
    ipv6_dhcp_relay_addr:             v6_relay,
    ipv6_dhcp_relay_src_intf:         'ethernet 1/1',
  },
}

def unsupported_properties(_tests, _id)
  unprops = []
  if platform[/n(3|8|9)k/]
    unprops <<
      :ipv4_dhcp_relay_src_addr_hsrp
  elsif platform[/n(5|6)k/]
    unprops <<
      :ipv4_dhcp_relay_info_trust
  end
  unprops
end

def cleanup(agent, intf)
  interface_cleanup(agent, intf)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent, intf) }
  cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
