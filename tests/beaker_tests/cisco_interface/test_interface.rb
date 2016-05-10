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
# TestCase Name:
# -------------
# test_interface.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet cisco_interface testcase for Puppet Agent on
# Nexus and IOS XR devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the agent node.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# The following exit_codes are validated for Puppet and Bash shell commands.
#
# Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)
# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_interface'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:operating_system] - a regexp pattern to match against supported OS.
#                            This key can be overridden by a
#                            tests[id][:operating_system] key
# tests[:platform] - a regexp pattern to match against supported platforms.
#                    This key can be overridden by a tests[id][:platform] key
#
tests = {
  master:        master,
  agent:         agent,
  svi_name:      'vlan13',
  bdi_name:      'bdi100',
  resource_name: 'cisco_interface',
}

tests_2 = {
  master:           master,
  agent:            agent,
  resource_name:    'cisco_vlan',
  operating_system: 'nexus',
  platform:         'n(3|5|6|7|9)k',
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:operating_system] - a regexp pattern to match against supported OS.
#                                This key overrides a tests[:operating_system] key
# tests[id][:platform] - a regexp pattern to match against supported platforms.
#                        This key overrides a tests[:platform] key
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:sys_def_switchport] - (Optional) Specifies state of 'system default switchport'
# tests[id][:sys_def_sw_shut] - (Optional) Specifies state of 'system default switchport shutdown'.
#    This is only meaningful for L2 interfaces.
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#
tests['L3_default'] = {
  desc:               '1.1 (L3) Default Properties',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: false,
  manifest_props:     {
    description:    'default',
    ipv4_proxy_arp: 'default',
    ipv4_redirects: 'default',
    mtu:            'default',
    shutdown:       'default',
    vrf:            'default',
  },
  resource:           {
    # 'description'    => nil,
    'ipv4_proxy_arp' => 'false',
    'ipv4_redirects' => operating_system == 'nexus' ? 'true' : 'false',
    'mtu'            => operating_system == 'nexus' ? '1500' : '1514',
    'shutdown'       => 'false',
    # 'vrf'            => nil,
  },
}

tests['L3_default_nexus'] = {
  desc:               '1.2 (L3) Default Properties - Nexus Specific',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: false,
  manifest_props:     {
    duplex:               'default',
    ipv4_forwarding:      'default',
    ipv4_pim_sparse_mode: 'default',
  },
  resource:           {
    'duplex'               => 'auto',
    'ipv4_forwarding'      => 'false',
    'ipv4_pim_sparse_mode' => 'false',
  },
}

# Note: This test should follow the L3_default test as it requires an
# L3 parent interface and this makes it easy to set up.
tests['L3_sub_int'] = {
  desc:           '1.3 (L3) Sub-interface',
  intf_type:      'dot1q',
  manifest_props: {
    encapsulation_dot1q: 30
  },
  resource:       {
    'encapsulation_dot1q' => '30'
  },
}

tests['L3_misc'] = {
  desc:               '1.4 (L3) Misc Properties',
  intf_type:          'ethernet',
  sys_def_switchport: false,
  manifest_props:     {
    description:                   'Configured with Puppet',
    shutdown:                      true,
    ipv4_address:                  '1.1.1.1',
    ipv4_netmask_length:           31,
    ipv4_address_secondary:        '2.2.2.2',
    ipv4_netmask_length_secondary: 31,
    ipv4_proxy_arp:                true,
    ipv4_redirects:                operating_system == 'nexus' ? false : true,
    vrf:                           'test1',
  },
  resource:           {
    'description'                   => 'Configured with Puppet',
    'shutdown'                      => 'true',
    'ipv4_address'                  => '1.1.1.1',
    'ipv4_netmask_length'           => '31',
    'ipv4_address_secondary'        => '2.2.2.2',
    'ipv4_netmask_length_secondary' => '31',
    'ipv4_proxy_arp'                => 'true',
    'ipv4_redirects'                => operating_system == 'nexus' ? 'false' : 'true',
    'vrf'                           => 'test1',
  },
}

tests['L3_misc_nexus'] = {
  desc:               '1.5 (L3) Misc Properties - Nexus specific',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode:      'disabled',
    ipv4_forwarding:      true,
    ipv4_pim_sparse_mode: true,
  },
  resource:           {
    'switchport_mode'      => 'disabled',
    'ipv4_forwarding'      => 'true',
    'ipv4_pim_sparse_mode' => 'true',
  },
}

tests['L3_ACL'] = {
  desc:               '1.6 (L3) ACL Properties',
  # TODO: this requires cisco_acl support before we can enable it for IOS XR
  operating_system:   'nexus',
  intf_type:          'ethernet',
  sys_def_switchport: false,
  acl:                {
    'v4_in'  => 'ipv4',
    'v4_out' => 'ipv4',
    'v6_in'  => 'ipv6',
    'v6_out' => 'ipv6',
  },
  manifest_props:     {
    switchport_mode: 'disabled',
    ipv4_acl_in:     'v4_in',
    ipv4_acl_out:    'v4_out',
    ipv6_acl_in:     'v6_in',
    ipv6_acl_out:    'v6_out',
  },
  resource:           {
    'ipv4_acl_in'  => 'v4_in',
    'ipv4_acl_out' => 'v4_out',
    'ipv6_acl_in'  => 'v6_in',
    'ipv6_acl_out' => 'v6_out',
  },
}

tests['L2_access_default'] = {
  desc:               '2.1 (L2) Access Default',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:        'default',
    switchport_mode: 'access',
  },
  resource:           {
    'shutdown'        => 'true',
    'switchport_mode' => 'access',
  },
}

tests['L2_access'] = {
  desc:               '2.2 (L2) Access Properties',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    access_vlan:     '128',
    shutdown:        'false',
    switchport_mode: 'access',

  },
  resource:           {
    'access_vlan'     => '128',
    'shutdown'        => 'false',
    'switchport_mode' => 'access',
  },
}

tests['L2_trunk_default'] = {
  desc:               '3.1 (L2) Trunk Default',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:                      'default',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: 'default',
    switchport_trunk_native_vlan:  'default',

  },
  resource:           {
    'shutdown'                      => 'true',
    'switchport_mode'               => 'trunk',
    'switchport_trunk_allowed_vlan' => '1-4094',
    'switchport_trunk_native_vlan'  => '1',
  },
}

tests['L2_trunk'] = {
  desc:               '3.2 (L2) Trunk',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  sys_def_switchport: true,
  manifest_props:     {
    shutdown:                      'false',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: '30, 40, 31-33, 100',
    switchport_trunk_native_vlan:  '20',
    switchport_vtp:                'false',

  },
  resource:           {
    'shutdown'                      => 'false',
    'switchport_mode'               => 'trunk',
    'switchport_trunk_allowed_vlan' => '30-33,40,100',
    'switchport_trunk_native_vlan'  => '20',
  },
}

tests['SVI_default'] = {
  desc:             '4.1 (SVI) Default Properties',
  operating_system: 'nexus',
  intf_type:        'vlan',
  manifest_props:   {
    svi_management: 'default'
  },
  resource:         {
    'svi_management' => 'false'
  },
}

tests['SVI'] = {
  desc:             '4.2 (SVI) Non Default Properties',
  operating_system: 'nexus',
  intf_type:        'vlan',
  manifest_props:   {
    svi_management: 'true'
  },
  resource:         {
    'svi_management' => 'true'
  },
}

# Fabric Forwarding Anycast Gateway
if platform[/n9k/]
  tests['SVI_default'][:manifest_props][:fabric_forwarding_anycast_gateway] = 'default'
  tests['SVI'][:manifest_props][:fabric_forwarding_anycast_gateway] = 'true'
  tests['SVI'][:resource][:fabric_forwarding_anycast_gateway] = 'true'
end

tests['SVI_autostate_default'] = {
  desc:             '4.3 (SVI) Default SVI Autostate Property',
  operating_system: 'nexus',
  platform:         'n(3|7|9)k',
  intf_type:        'vlan',
  manifest_props:   {
    svi_autostate: 'default'
  },
  resource:         {
    'svi_autostate' => 'true'
  },
}

tests['SVI_autostate'] = {
  desc:             '4.4 (SVI) Non Default SVI Autostate Property',
  operating_system: 'nexus',
  platform:         'n(3|7|9)k',
  intf_type:        'vlan',
  manifest_props:   {
    svi_autostate: 'false'
  },
  resource:         {
    'svi_autostate' => 'false'
  },
}

tests[:auto] = {
  desc:               '5.1 Misc. Auto Value Properties',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  sys_def_switchport: false,
  code:               [0, 2],
  manifest_props:     {
    switchport_mode: 'disabled',
    # duplex and speed are defined by interface_pre_check
  },
}

tests[:non_default] = {
  desc:               '5.2 Misc. Non-default Value Properties',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode: 'disabled',
    # duplex, speed, and mtu are defined by interface_pre_check
  },
}

tests_2[:primary] = {
  desc:           '6.1 configure pvlan primary type',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'primary'
  },
}

tests_2[:community] = {
  desc:           '6.2 configure pvlan primary type',
  title_pattern:  '101',
  manifest_props: {
    private_vlan_type: 'community'
  },
}
tests_2[:isolated] = {
  desc:           '6.3 configure pvlan isolated type',
  title_pattern:  '102',
  manifest_props: {
    private_vlan_type: 'isolated'
  },
}
tests_2[:community_2] = {
  desc:           '6.4 configure pvlan community type',
  title_pattern:  '103',
  manifest_props: {
    private_vlan_type: 'community'
  },
}

tests_2[:community_3] = {
  desc:           '6.5 configure pvlan isolated type',
  title_pattern:  '104',
  manifest_props: {
    private_vlan_type: 'community'
  },
}
tests_2[:community_4] = {
  desc:           '6.6 configure pvlan community type',
  title_pattern:  '105',
  manifest_props: {
    private_vlan_type: 'community'
  },
}
vlan_assoc = %w(101 102 103 104 105)
tests_2[:association] = {
  desc:           '6.7 configured private vlan association',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_association: ['101-105']
  },
  resource:       {
    'private_vlan_association' => "#{vlan_assoc}"
  },
}

switchport_modes = [
  :host,
  :promiscuous,
]

tests['pvlan_host_port'] = {
  desc:               '6.9 Pvlan host port config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host:             switchport_modes[0],
    switchport_mode_private_vlan_host_association: %w(100 102),
  },
  resource:           {
    'switchport_mode_private_vlan_host'             => "#{switchport_modes[0]}",
    'switchport_mode_private_vlan_host_association' => "['100', '102']",
  },
}

tests['pvlan_promisc_port'] = {
  desc:               '6.10 Pvlan promisc port config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host:         switchport_modes[1],
    switchport_mode_private_vlan_host_promisc: ['100', '101-103'],
  },
  resource:           {
    'switchport_mode_private_vlan_host'         => "#{switchport_modes[1]}",
    'switchport_mode_private_vlan_host_promisc' => "['100', '101-103']",
  },
}
tests['pvlan_trunk_promisc_port'] = {
  desc:               '6.11 Pvlan trunk promisc port config',
  operating_system:   'nexus',
  platform:           'n(5|6|7|9)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_trunk_promiscuous: true,
    switchport_private_vlan_mapping_trunk:          ['100', '101,104-105'],
  },
  resource:           {
    'switchport_mode_private_vlan_trunk_promiscuous' => 'true',
    'switchport_private_vlan_mapping_trunk'          => "['100 101,104-105']",
  },
}

tests['pvlan_trunk_sec_port'] = {
  desc:               '6.12 Pvlan trunk sec port config',
  operating_system:   'nexus',
  platform:           'n(5|6|7|9)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_trunk_secondary: true,
    switchport_private_vlan_association_trunk:    %w(100 102),
  },
  resource:           {
    'switchport_mode_private_vlan_trunk_secondary' => 'true',
    'switchport_private_vlan_association_trunk'    => "['100 102']",
  },
}

vlan_assoc = %w(100,102-103,105)
tests['pvlan_trunk_allow_vlan'] = {
  desc:               '6.13 Pvlan trunk allow vlans config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_private_vlan_trunk_allowed_vlan: vlan_assoc
  },
  resource:           {
    'switchport_private_vlan_trunk_allowed_vlan' => "['100', '102-103', '105']"
  },
}

tests['pvlan_trunk_native_vlan'] = {
  desc:               '6.14 Pvlan trunk native vlan config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_private_vlan_trunk_native_vlan: 100
  },
  resource:           {
    'switchport_private_vlan_trunk_native_vlan' => '100'
  },
}

vlan_assoc = %w(102-103)
tests['pvlan_mapping_svi'] = {
  desc:             '6.15 Pvlan vlan mapping for svi',
  operating_system: 'nexus',
  intf_type:        'vlan',
  manifest_props:   {
    private_vlan_mapping: vlan_assoc
  },
  resource:         {
    'private_vlan_mapping' => "['102-103']"
  },
}

tests['pvlan_host_port_association_default'] = {
  desc:               '6.16 Pvlan host port association default config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host_association: 'default'
  },
  resource:           {
  },
}

tests['pvlan_promisc_port_association_default'] = {
  desc:               '6.17 Pvlan promisc port association default config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host_promisc: 'default'
  },
  resource:           {
  },
}

tests['pvlan_trunk_promisc_port_default'] = {
  desc:               '6.18 Pvlan trunk promisc port default config',
  operating_system:   'nexus',
  platform:           'n(5|6|7|9)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_trunk_promiscuous: 'default'
  },
  resource:           {
  },
}

tests['pvlan_trunk_sec_port_default'] = {
  desc:               '6.19 Pvlan trunk sec port default config',
  operating_system:   'nexus',
  platform:           'n(5|6|7|9)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_trunk_secondary: 'default'
  },
  resource:           {
  },
}

tests['pvlan_trunk_allow_vlan_default'] = {
  desc:               '6.20 Pvlan trunk vlan allow port default config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_private_vlan_trunk_allowed_vlan: 'default'
  },
  resource:           {
  },
}

tests['pvlan_host_port_default'] = {
  desc:               '6.21 Pvlan host port default config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host: 'disabled'
  },
  resource:           {
  },
}

tests['pvlan_promisc_port_default'] = {
  desc:               '6.22 Pvlan promisc port default config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host: 'disabled'
  },
  resource:           {
  },
}

tests['switchport_private_vlan_trunk_native_vlan_default'] = {
  desc:               '6.23 Pvlan trunk native vlan default config',
  operating_system:   'nexus',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_private_vlan_trunk_native_vlan: 'default'
  },
  resource:           {
  },
}

tests['switchport_private_vlan_mapping_trunk_default'] = {
  desc:               '6.24 Pvlan trunk promisc association default config',
  operating_system:   'nexus',
  platform:           'n(5|6|7|9)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_private_vlan_mapping_trunk: 'default'
  },
  resource:           {
  },
}
tests['switchport_private_vlan_association_trunk_default'] = {
  desc:               '6.25 Pvlan trunk secondary association default config',
  operating_system:   'nexus',
  platform:           'n(5|6|7|9)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_private_vlan_association_trunk: 'default'
  },
  resource:           {
  },
}

tests['private_vlan_mapping_svi_default'] = {
  desc:             '6.26 Pvlan svi association default config',
  operating_system: 'nexus',
  intf_type:        'vlan',
  manifest_props:   {
    private_vlan_mapping: 'default'
  },
  resource:         {
  },
}

tests['BDI_non_default'] = {
  desc:             '7.1 (BDI) Non Default BDI Properties',
  operating_system: 'nexus',
  platform:         'n(7)k',
  intf_type:        'bdi',
  manifest_props:   {
    ipv4_address:        '10.10.10.1',
    ipv4_netmask_length: '24',
    shutdown:            'false',
    vrf:                 'test1',
  },
  resource:         {
    'ipv4_address'        => '10.10.10.1',
    'ipv4_netmask_length' => '24',
    'shutdown'            => 'false',
    'vrf'                 => 'test1',
  },
}

resource_cisco_overlay_global = {
  name:     'cisco_overlay_global',
  title:    'default',
  property: 'anycast_gateway_mac',
  value:    '1.1.1',
}

# Create actual manifest for a given test scenario.
def build_manifest_interface(tests, id)
  manifest = prop_hash_to_manifest(tests[id][:manifest_props])
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
  end
  create_interface_title(tests, id)

  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  \nnode default {
  cisco_interface { '#{tests[id][:title_pattern]}':
    #{state}\n#{manifest}
  }\n}\nEOF"

  cmd = PUPPET_BINPATH +
        "resource cisco_interface '#{tests[id][:title_pattern]}'"
  tests[id][:resource_cmd] = cmd
end

def interface_pre_check(tests) # rubocop:disable Metrics/AbcSize
  # Discover a usable test interface
  intf = find_interface(tests, :auto)
  tests[:auto][:title_pattern] = intf
  tests[:non_default][:title_pattern] = intf

  # Clean the test interface
  system_default_switchport(agent, false)
  interface_cleanup(agent, intf, 'Initial Cleanup')

  # Get the capabilities and update the caps list with any add'l test values
  caps = interface_capabilities(agent, intf)

  if caps.empty?
    tests[:skipped] ||= []
    tests[:skipped] << tests[:auto][:desc]
    tests[:skipped] << tests[:non_default][:desc]
    return false
  end

  caps['Speed'] += ',auto' unless caps['Speed']['auto']
  caps['Duplex'] += ',auto' unless caps['Duplex']['auto']
  caps['MTU'] = '1600'

  # Create a probe hash to pre-test the properties
  probe = {
    cmd:         PUPPET_BINPATH + 'resource cisco_interface ',
    intf:        intf,
    caps:        caps,
    probe_props: %w(Speed Duplex MTU),
  }
  caps = interface_probe(tests, probe)[:caps]

  # Fixup the test manifests with usable values
  spd = caps['Speed']
  dup = caps['Duplex']
  mtu = caps['MTU']

  tests[:auto][:manifest_props][:negotiate_auto] = 'true' unless platform[/n7k/]
  tests[:auto][:manifest_props][:duplex] = 'auto' if dup.delete('auto')
  tests[:auto][:manifest_props][:speed] = 'auto' if spd.delete('auto')

  tests[:non_default][:manifest_props][:duplex] = dup.shift unless dup.empty?
  tests[:non_default][:manifest_props][:speed] = spd.shift unless spd.empty?
  tests[:non_default][:manifest_props][:mtu] = mtu.shift unless mtu.empty?

  # Cannot turn off auto-negotiate for speeds 10G+
  non_default_speed = tests[:non_default][:manifest_props][:speed]
  tests[:non_default][:manifest_props][:negotiate_auto] = 'false' unless
    platform[/n7k/] || non_default_speed.to_i >= 10_000

  logger.info "\n      Pre-Check :non_default hash: #{tests[:non_default]}"\
              "\n      Pre-Check :auto hash: #{tests[:auto]}"
  interface_cleanup(agent, intf, 'Post-Pre-Check Cleanup')
  true
end

# Helper for 'system default switchport'
def sys_def_switchport?(tests, id)
  return unless tests[id].key?(:sys_def_switchport)

  state = tests[id][:sys_def_switchport]
  # cached state
  return if tests[:sys_def_switchport] == state

  system_default_switchport(agent, state)
  # cache for later tests
  tests[:sys_def_switchport] = state
end

# Helper for 'system default switchport shutdown'
def sys_def_switchport_shutdown?(tests, id)
  return unless tests[id].key?(:sys_def_sw_shut)

  state = tests[id][:sys_def_sw_shut]
  # cached state
  return if tests[:sys_def_sw_shut] == state

  system_default_switchport_shutdown(agent, state)
  # cache for later tests
  tests[:sys_def_sw_shut] = state
end

# Helper for setting up ACL dependencies
def acl?(tests, id)
  tests[id][:acl].each { |acl, afi| config_acl(agent, afi, acl, true) } if
    tests[id][:acl]
end

# Wrapper for interface specific settings prior to calling the
# common test_harness.
def test_harness_interface(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_interface(tests, id)

  # Set up system default switchport
  sys_def_switchport?(tests, id)
  sys_def_switchport_shutdown?(tests, id)

  # Set up ACL
  acl?(tests, id)

  tests[id][:code] = [0, 2]

  interface_cleanup(agent, tests[id][:title_pattern]) if tests[id][:preclean]

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. (L3) Property Testing")
  test_harness_interface(tests, 'L3_default')
  test_harness_interface(tests, 'L3_default_nexus')
  test_harness_interface(tests, 'L3_sub_int')
  test_harness_interface(tests, 'L3_misc')
  test_harness_interface(tests, 'L3_misc_nexus')
  test_harness_interface(tests, 'L3_ACL')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. (L2) Access Property Testing")
  test_harness_interface(tests, 'L2_access_default')
  test_harness_interface(tests, 'L2_access')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. (L2) Trunk Property Testing")
  test_harness_interface(tests, 'L2_trunk_default')
  test_harness_interface(tests, 'L2_trunk')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. (SVI) Property Testing")
  if platform_supports_test(tests, 'SVI')
    resource_set(agent, resource_cisco_overlay_global,
                 'Overlay Global mac setup')
  end
  interface_cleanup(agent, tests[:svi_name])
  test_harness_interface(tests, 'SVI_default')
  test_harness_interface(tests, 'SVI')
  test_harness_interface(tests, 'SVI_autostate_default')
  test_harness_interface(tests, 'SVI_autostate')

  ### -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 5. Negotiate Auto, MTU, Speed, Duplex")
  if interface_pre_check(tests)
    test_harness_run(tests, :auto)
    test_harness_run(tests, :non_default)
  else
    msg = 'Could not find interface capabilities'
    logger.error("\n#{tests[:auto][:desc]} :: auto :: SKIP" \
                 "\n#{msg}")
    logger.error("\n#{tests[:non_default][:desc]} :: non_default :: SKIP" \
                 "\n#{msg}")
  end
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 6. Private vlan Property Testing")
  resource_absent_cleanup(agent, 'cisco_vlan', 'private-vlan CLEANUP :: ')
  test_harness_run(tests_2, :primary)
  test_harness_run(tests_2, :community)
  test_harness_run(tests_2, :isolated)
  test_harness_run(tests_2, :community_2)
  test_harness_run(tests_2, :community_3)
  test_harness_run(tests_2, :community_4)
  test_harness_run(tests_2, :association)
  test_harness_interface(tests, 'pvlan_host_port')
  test_harness_interface(tests, 'pvlan_promisc_port')
  test_harness_interface(tests, 'pvlan_trunk_promisc_port')
  test_harness_interface(tests, 'pvlan_trunk_sec_port')
  test_harness_interface(tests, 'pvlan_trunk_allow_vlan')
  test_harness_interface(tests, 'pvlan_trunk_native_vlan')
  test_harness_interface(tests, 'pvlan_host_port_association_default')
  test_harness_interface(tests, 'pvlan_promisc_port_association_default')
  test_harness_interface(tests, 'pvlan_trunk_promisc_port_default')
  test_harness_interface(tests, 'pvlan_trunk_sec_port_default')
  test_harness_interface(tests, 'pvlan_trunk_allow_vlan_default')
  test_harness_interface(tests, 'pvlan_host_port_default')
  test_harness_interface(tests, 'pvlan_promisc_port_default')
  test_harness_interface(tests, 'switchport_private_vlan_trunk_native_vlan_default')
  test_harness_interface(tests, 'switchport_private_vlan_mapping_trunk_default')
  test_harness_interface(tests, 'switchport_private_vlan_association_trunk_default')
  interface_cleanup(agent, tests[:svi_name])
  test_harness_interface(tests, 'private_vlan_mapping_svi_default')
  test_harness_interface(tests, 'pvlan_mapping_svi')
  interface_cleanup(agent, tests[:svi_name])

  # -------------------------------------------------------------------
  if platform_supports_test(tests, 'BDI_non_default')
    logger.info("\n#{'-' * 60}\nSection 7. BDI Property Testing")
    bd = tests[:bdi_name][/(\d+)/]
    config_bridge_domain(agent, bd)
    test_harness_interface(tests, 'BDI_non_default')
  end
  # -------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_vlan', 'private-vlan CLEANUP :: ')
  interface_cleanup(agent, tests[:ethernet]) if tests[:ethernet]
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{testheader} :: End")
