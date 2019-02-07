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
  if $operatingsystem == 'nexus' {
    cisco_acl { 'ipv4 v4acl1':
      ensure => 'present',
      before => Cisco_interface['Ethernet1/1'],
    }

    cisco_acl { 'ipv4 v4acl2':
      ensure => 'present',
      before => Cisco_interface['Ethernet1/1'],
    }

    cisco_acl { 'ipv6 v6acl1':
      ensure => 'present',
      before => Cisco_interface['Ethernet1/1'],
    }

    cisco_acl { 'ipv6 v6acl2':
      ensure => 'present',
      before => Cisco_interface['Ethernet1/1'],
    }

    $ipv4_dhcp_relay_info_trust = platform_get() ? {
      /(n3k|n7k|n3k-f|n9k-f|n9k)/ => true,
      default => undef
    }

    $ipv4_dhcp_relay_src_addr_hsrp = platform_get() ? {
      /(n5k|n6k|n7k)/ => true,
      default => undef
    }

    cisco_interface { 'Ethernet1/1' :
      shutdown                      => true,
      switchport_mode               => disabled,
      bfd_echo                      => false,
      description                   => 'managed by puppet',
      ipv4_address                  => '192.168.55.5',
      ipv4_netmask_length           => 24,
      ipv4_address_secondary        => '192.168.88.1',
      ipv4_netmask_length_secondary => 24,
      ipv4_forwarding               => false,
      ipv4_pim_sparse_mode          => false,
      mtu                           => 1600,
      # Removed because of too many differences between platforms and linecards
      # speed                          => 100,
      # duplex                         => 'full',
      vrf                           => 'test',
      ipv4_acl_in                   => 'v4acl1',
      ipv4_acl_out                  => 'v4acl2',
      ipv6_acl_in                   => 'v6acl1',
      ipv6_acl_out                  => 'v6acl2',
      pim_bfd                       => true,
    }

    cisco_interface { 'Ethernet1/1.1':
      encapsulation_dot1q => 20,
    }

    cisco_interface_channel_group { 'Ethernet1/2':
      channel_group      => 200,
      channel_group_mode => 'active',
    }

    cisco_interface { 'Ethernet1/3':
      description                   => 'default',
      shutdown                      => 'default',
      access_vlan                   => 'default',
      load_interval_counter_1_delay => 150,
      load_interval_counter_2_delay => 250,
      load_interval_counter_3_delay => 90,
      switchport_mode               => access,
    }

    cisco_interface { 'Ethernet1/4':
      switchport_mode                  => disabled,
      ipv4_dhcp_relay_addr             => ['1.1.1.1', '2.2.2.2'],
      ipv4_dhcp_relay_info_trust       => $ipv4_dhcp_relay_info_trust,
      ipv4_dhcp_relay_src_addr_hsrp    => $ipv4_dhcp_relay_src_addr_hsrp,
      ipv4_dhcp_relay_src_intf         => 'port-channel 100',
      ipv4_dhcp_relay_subnet_broadcast => true,
      ipv4_dhcp_smart_relay            => true,
      ipv6_dhcp_relay_addr             => ['2000::11', '2001::22'],
      ipv6_dhcp_relay_src_intf         => 'ethernet 2/2',
    }
    $storm_control_broadcast = platform_get() ? {
      /(n3k|n5k|n6k|n3k-f|n9k-f|n9k)/ => '77.77',
      default => undef
    }

    $storm_control_multicast = platform_get() ? {
      /(n3k|n5k|n6k|n3k-f|n9k-f|n9k)/ => '22.22',
      default => undef
    }

    cisco_interface { 'Ethernet1/5':
      switchport_mode               => trunk,
      switchport_trunk_allowed_vlan => '30, 29, 31-33, 100',
      switchport_trunk_native_vlan  => 40,
      storm_control_broadcast       => $storm_control_broadcast,
      storm_control_multicast       => $storm_control_multicast,
      storm_control_unicast         => '33.33',
    }

    $svi_autostate = platform_get() ? {
      /(n5k|n6k)/  => undef,
      default      => false
    }

    cisco_interface { 'Vlan22':
      bfd_echo         => false,
      svi_autostate    => $svi_autostate,
      svi_management   => true,
      ipv4_arp_timeout => 300,
    }

    if platform_get() =~ /n7k/ {
      cisco_bridge_domain { '100':
        ensure   => 'present',
        shutdown => false,
        bd_name  => 'test1'
      }

      cisco_interface { 'Bdi100':
        ensure              => 'present',
        require             => Cisco_bridge_domain['100'],
        shutdown            => false,
        ipv4_address        => '10.10.10.1',
        ipv4_netmask_length => 24,
        vrf                 => 'test1'
      }
    } else {
      warning('This platform does not support cisco_bridge_domain')
    }

    # Private-vlan
    if platform_get() =~ /n(3|5|6|7|9)k/ {
      cisco_vlan { '12': pvlan_type => 'community' }
      cisco_vlan {  '2': pvlan_type => 'primary', pvlan_association => '12' }

      cisco_interface { 'Ethernet1/6':
        description                       => 'Private-vlan Host Port',
        switchport_pvlan_host             => true,
        switchport_pvlan_host_association => [2, 12],
      }

      cisco_vlan { '13': pvlan_type => 'isolated' }
      cisco_vlan { '14': pvlan_type => 'isolated' }
      cisco_vlan {  '3': pvlan_type => 'primary', pvlan_association => '13' }
      cisco_vlan {  '4': pvlan_type => 'primary', pvlan_association => '14' }

      cisco_vlan { '15': pvlan_type => 'community' }
      cisco_vlan {  '5': pvlan_type => 'primary', pvlan_association => '15' }

      cisco_vlan { '17': pvlan_type => 'community' }
      cisco_vlan { '27': pvlan_type => 'community' }
      cisco_vlan { '37': pvlan_type => 'community' }
      cisco_vlan {  '7': pvlan_type => 'primary', pvlan_association => '17,27,37' }

      # Ethernet1/7 platform checks
      $trunk_secondary = platform_get() ? {
        /(n3k)/        => undef,
        default        => true
      }
      $trunk_assoc     = platform_get() ? {
        /(n3k)/        => undef,
        default        => [[3, 13], [4, 14]]
      }
      $trunk_map       = platform_get() ? {
        /(n3k)/        => undef,
        default        => [['5', '15'], ['7', '17,27,37']]
      }
      cisco_interface { 'Ethernet1/7':
        description                         => 'Private-vlan Trunk Port',
        switchport_pvlan_trunk_secondary    => $trunk_secondary,
        switchport_pvlan_trunk_allowed_vlan => '106,102-103,105',
        switchport_pvlan_trunk_association  => $trunk_assoc,
        switchport_pvlan_trunk_native_vlan  => 42,
        switchport_pvlan_mapping_trunk      => $trunk_map,
      }
      cisco_interface { 'vlan29':
        description   => 'SVI Private-vlan Mapping',
        pvlan_mapping => '108-109',
      }
    } else {
      warning('This platform does not support the private-vlan feature')
    }

    #  Requires F3 or newer linecards
    # cisco_interface { 'Ethernet9/1':
    #   switchport_mode                => trunk,
    #   switchport_vlan_mapping        => [[20, 21], [30, 31]]
    #   switchport_vlan_mapping_enable => false
    # }
  }
  elsif $operatingsystem == 'ios_xr' {
    cisco_interface { 'GigabitEthernet0/0/0/1' :
      shutdown            => true,
      description         => 'managed by puppet',
      ipv4_address        => '192.168.55.55',
      ipv4_netmask_length => 24,
      mtu                 => 1600,
      vrf                 => 'test',
    }

    cisco_interface { 'GigabitEthernet0/0/0/2':
      description => 'default',
      shutdown    => 'default',
    }
  }
}
