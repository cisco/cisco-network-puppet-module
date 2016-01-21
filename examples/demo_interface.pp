# Manifest to demo cisco_interface provider
#
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

class ciscopuppet::demo_interface {

  $stp_bpdufilter = platform_get() ? {
    'n7k'  => 'enable',
    default => undef
  }

  $stp_bpduguard = platform_get() ? {
    'n7k'  => 'enable',
    default => undef
  }

  $stp_cost = platform_get() ? {
    'n7k'  => 2000,
    default => undef
  }

  $stp_guard = platform_get() ? {
    'n7k'  => 'loop',
    default => undef
  }

  $stp_link_type = platform_get() ? {
    'n7k'  => 'shared',
    default => undef
  }

  $stp_mst_cost = platform_get() ? {
    'n7k'  => [['0,2-4,6,8-12', '1000'], ['1000', '2568']],
    default => undef
  }

  $stp_mst_port_priority = platform_get() ? {
    'n7k'  => [['0,2-11,20-33', '64'], ['1111', '160']],
    default => undef
  }

  $stp_port_priority = platform_get() ? {
    'n7k'  => 64,
    default => undef
  }

  $stp_port_type = platform_get() ? {
    'n7k'  => 'network',
    default => undef
  }

  $stp_vlan_cost = platform_get() ? {
    'n7k'  => [['1-4,6,8-12', '1000'], ['1000', '2568']],
    default => undef
  }

  $stp_vlan_port_priority = platform_get() ? {
    'n7k'  => [['1-11,20-33', '64'], ['1111', '160']],
    default => undef
  }

  cisco_interface { 'Ethernet1/1' :
    shutdown                      => true,
    switchport_mode               => disabled,
    description                   => 'managed by puppet',
    ipv4_address                  => '192.168.55.5',
    ipv4_netmask_length           => 24,
    ipv4_address_secondary        => '192.168.88.1',
    ipv4_netmask_length_secondary => 24,
    ipv4_pim_sparse_mode          => false,
    mtu                           => 1600,
    speed                         => 100,
    duplex                        => 'full',
    vrf                           => 'test',
    ipv4_acl_in                   => 'v4acl1',
    ipv4_acl_out                  => 'v4acl2',
    ipv6_acl_in                   => 'v6acl1',
    ipv6_acl_out                  => 'v6acl2',
  }

  cisco_interface { 'Ethernet1/1.1':
    encapsulation_dot1q => 20,
  }

  cisco_interface { 'Ethernet1/2':
    description     => 'default',
    shutdown        => 'default',
    access_vlan     => 'default',
    switchport_mode => access,
    channel_group   => 200,
  }

  cisco_interface { 'Ethernet1/3':
    switchport_mode               => trunk,
    switchport_trunk_allowed_vlan => '20, 30',
    switchport_trunk_native_vlan  => 40,
  }

  cisco_interface { 'Ethernet1/4':
    stp_bpdufilter         => $stp_bpdufilter,
    stp_bpduguard          => $stp_bpduguard,
    stp_cost               => $stp_cost,
    stp_guard              => $stp_guard,
    stp_link_type          => $stp_link_type,
    stp_port_priority      => $stp_port_priority,
    stp_port_type          => $stp_port_type,
    stp_mst_cost           => $stp_mst_cost,
    stp_mst_port_priority  => $stp_mst_port_priority,
    stp_vlan_cost          => $stp_vlan_cost,
    stp_vlan_port_priority => $stp_vlan_port_priority,
  }

  cisco_interface { 'Vlan22':
    svi_autostate    => false,
    svi_management   => true,
    ipv4_arp_timeout => 300,
  }

  network_interface { 'ethernet1/9':
    description => 'default',
    duplex      => 'auto',
    speed       => '100m',
  }
  #  Requires F3 or newer linecards
  # cisco_interface { 'Ethernet9/1':
  #   switchport_mode                => trunk,
  #   switchport_vlan_mapping        => [[20, 21], [30, 31]]
  #   switchport_vlan_mapping_enable => false
  # }
}
