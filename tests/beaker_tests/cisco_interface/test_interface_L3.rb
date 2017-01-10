# rubocop:disable Style/FileName
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
# 'test_interface_L3' primarily tests layer 3 interface properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:         agent,
  master:        master,
  intf_type:     'ethernet',
  resource_name: 'cisco_interface',
}

# Find a usable interface for this test
intf = find_interface(tests)
dot1q = intf + '.1'

# Test hash test cases
tests[:default] = {
  desc:               '1.1 Default Properties',
  title_pattern:      intf,
  code:               [0],
  sys_def_switchport: false,
  manifest_props:     {
    bfd_echo:                         'default',
    description:                      'default',
    duplex:                           'default',
    ipv4_forwarding:                  'default',
    ipv4_pim_sparse_mode:             'default',
    ipv4_proxy_arp:                   'default',
    ipv4_redirects:                   'default',
    ipv4_dhcp_relay_addr:             'default',
    ipv4_dhcp_relay_info_trust:       'default',
    ipv4_dhcp_relay_src_addr_hsrp:    'default',
    ipv4_dhcp_relay_src_intf:         'default',
    ipv4_dhcp_relay_subnet_broadcast: 'default',
    ipv4_dhcp_smart_relay:            'default',
    ipv6_dhcp_relay_addr:             'default',
    ipv6_dhcp_relay_src_intf:         'default',
    pim_bfd:                          'default',
    mtu:                              'default',
    shutdown:                         'default',
    vrf:                              'default',
  },
  resource:           {
    duplex:                           'auto',
    ipv4_forwarding:                  'false',
    ipv4_pim_sparse_mode:             'false',
    ipv4_proxy_arp:                   'false',
    ipv4_redirects:                   operating_system == 'nexus' ? 'true' : 'false',
    ipv4_dhcp_relay_info_trust:       'false',
    ipv4_dhcp_relay_src_addr_hsrp:    'false',
    ipv4_dhcp_relay_src_intf:         'false',
    ipv4_dhcp_relay_subnet_broadcast: 'false',
    ipv4_dhcp_smart_relay:            'false',
    ipv6_dhcp_relay_src_intf:         'false',
    pim_bfd:                          'false',
    mtu:                              operating_system == 'nexus' ? '1500' : '1514',
    shutdown:                         'false',
  },
}

# Note: This test should follow the default test as it requires an
# L3 parent interface and this makes it easy to set up.
tests[:dot1q] = {
  desc:           '1.2 dot1q Sub-interface',
  title_pattern:  dot1q,
  manifest_props: { encapsulation_dot1q: 30 },
}

v4_relay = ['1.1.1.1', '2.2.2.2', '3.3.3.3']
v6_relay = ['2000::11', '2001::22', '2001::12']

tests[:non_default] = {
  desc:               '2.1 Non Default Properties',
  title_pattern:      intf,
  sys_def_switchport: false,
  manifest_props:     {
    bfd_echo:                         false,
    description:                      'Configured with Puppet',
    shutdown:                         true,
    ipv4_address:                     '1.1.1.1',
    ipv4_netmask_length:              31,
    ipv4_address_secondary:           '2.2.2.2',
    ipv4_netmask_length_secondary:    31,
    ipv4_pim_sparse_mode:             true,
    ipv4_proxy_arp:                   true,
    ipv4_redirects:                   operating_system == 'nexus' ? false : true,
    ipv4_dhcp_relay_addr:             v4_relay,
    ipv4_dhcp_relay_info_trust:       'true',
    ipv4_dhcp_relay_src_addr_hsrp:    'true',
    ipv4_dhcp_relay_src_intf:         'loopback1',
    ipv4_dhcp_relay_subnet_broadcast: 'true',
    ipv4_dhcp_smart_relay:            'true',
    ipv6_dhcp_relay_addr:             v6_relay,
    ipv6_dhcp_relay_src_intf:         'ethernet1/1',
    pim_bfd:                          true,
    switchport_mode:                  'disabled',
    vrf:                              'test1',
  },
}

tests[:acl] = {
  desc:               '2.2 ACL Properties',
  title_pattern:      intf,
  operating_system:   'nexus',
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode: 'disabled',
    ipv4_acl_in:     'v4_in',
    ipv4_acl_out:    'v4_out',
    ipv6_acl_in:     'v6_in',
    ipv6_acl_out:    'v6_out',
  },
  # ACLs must exist on some platforms
  acl:                {
    'v4_in'  => 'ipv4',
    'v4_out' => 'ipv4',
    'v6_in'  => 'ipv6',
    'v6_out' => 'ipv6',
  },
}

# This test should be run last since it will break ip addressing properties.
# Note that any tests that follow need to preclean.
tests[:ip_forwarding] = {
  desc:               '2.4 IP forwarding',
  title_pattern:      intf,
  preclean_intf:      true,
  sys_def_switchport: false,
  manifest_props:     { ipv4_forwarding: true },
}

def unsupported_properties(_tests, id)
  unprops = []

  if operating_system == 'ios_xr'
    unprops <<
      :bfd_echo <<
      :duplex <<
      :ipv4_forwarding <<
      :ipv4_pim_sparse_mode <<
      :ipv4_dhcp_relay_addr <<
      :ipv4_dhcp_relay_info_trust <<
      :ipv4_dhcp_relay_src_addr_hsrp <<
      :ipv4_dhcp_relay_src_intf <<
      :ipv4_dhcp_relay_subnet_broadcast <<
      :ipv4_dhcp_smart_relay <<
      :ipv6_dhcp_relay_addr <<
      :ipv6_dhcp_relay_src_intf <<
      :pim_bfd <<
      :switchport_mode
  end

  if platform[/n(3|9)k/]
    unprops <<
      :ipv4_dhcp_relay_src_addr_hsrp
  elsif platform[/n(5|6)k/]
    unprops <<
      :ipv4_dhcp_relay_info_trust
  end

  # TBD: shutdown has unpredictable behavior. Needs investigation.
  unprops << :shutdown if id == :default

  unprops
end

# Overridden to properly handle dependencies for this test file.
def dependency_manifest(_tests, id)
  return unless id == :non_default
  # Though not required on most platforms, the test vrf context should be
  # instantiated prior to configuring settings on a vrf interface. The new
  # DME-based cli's (PIM, etc) may fail otherwise.
  dep = %( cisco_vrf { 'test1': description => 'Puppet test vrf' } )
  logger.info("\n  * dependency_manifest\n#{dep}")
  dep
end

def cleanup(agent, intf, dot1q)
  test_set(agent, 'no feature bfd ; no feature pim')
  test_set(agent, "no interface #{dot1q}")
  remove_all_vrfs(agent)
  interface_cleanup(agent, intf)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent, intf, dot1q) }
  cleanup(agent, intf, dot1q)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  interface_cleanup(agent, dot1q)
  test_harness_run(tests, :dot1q)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
  test_harness_run(tests, :acl)
  test_harness_run(tests, :ip_forwarding)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
