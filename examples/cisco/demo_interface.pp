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

class ciscopuppet::cisco::demo_interface {
  cisco_acl { 'ipv4 v4acl1':
    before => Cisco_interface['Ethernet1/1'],
    ensure => 'present',
  }

  cisco_acl { 'ipv4 v4acl2':
    before => Cisco_interface['Ethernet1/1'],
    ensure => 'present',
  }

  cisco_acl { 'ipv6 v6acl1':
    before => Cisco_interface['Ethernet1/1'],
    ensure => 'present',
  }

  cisco_acl { 'ipv6 v6acl2':
    before => Cisco_interface['Ethernet1/1'],
    ensure => 'present',
  }

  cisco_interface { 'Ethernet1/1' :
    shutdown                       => true,
    switchport_mode                => disabled,
    description                    => 'managed by puppet',
    ipv4_address                   => '192.168.55.5',
    ipv4_netmask_length            => 24,
    ipv4_address_secondary         => '192.168.88.1',
    ipv4_netmask_length_secondary  => 24,
    ipv4_pim_sparse_mode           => false,
    mtu                            => 1600,
    # Removed because of too many differences between platforms and linecards
    # speed                          => 100,
    # duplex                         => 'full',
    vrf                            => 'test',
    ipv4_acl_in                    => 'v4acl1',
    ipv4_acl_out                   => 'v4acl2',
    ipv6_acl_in                    => 'v6acl1',
    ipv6_acl_out                   => 'v6acl2',
  }

  cisco_interface { 'Ethernet1/1.1':
    encapsulation_dot1q => 20,
  }

  cisco_interface_channel_group { 'Ethernet1/2':
    channel_group   => 200,
  }

  cisco_interface { 'Ethernet1/3':
    description     => 'default',
    shutdown        => 'default',
    access_vlan     => 'default',
    switchport_mode => access,
  }

  cisco_interface { 'Ethernet1/5':
    switchport_mode               => trunk,
    switchport_trunk_allowed_vlan => '20, 30',
    switchport_trunk_native_vlan  => 40,
  }

  $svi_autostate = platform_get() ? {
    /(n5k|n6k)/  => undef,
    default      => false
  }

  cisco_interface { 'Vlan22':
    svi_autostate    => $svi_autostate,
    svi_management   => true,
    ipv4_arp_timeout => 300,
  }

  #  Requires F3 or newer linecards
  # cisco_interface { 'Ethernet9/1':
  #   switchport_mode                => trunk,
  #   switchport_vlan_mapping        => [[20, 21], [30, 31]]
  #   switchport_vlan_mapping_enable => false
  # }
}
