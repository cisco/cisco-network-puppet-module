# Manifest to demo VXLAN providers:
# 1. cisco_overlay_global
# 2. cisco_vxlan_vtep
# 3. cisco_vxlan_vtep_vni
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

class ciscopuppet::cisco::demo_vxlan {

  if platform_get() =~ /n(5|6|7|8|9)k/ {

    if platform_get() =~ /n7k/ {
      cisco_vdc { 'default':
        ensure                     => present,
        limit_resource_module_type => 'f3'
      }
    }

    cisco_overlay_global { 'default':
      dup_host_ip_addr_detection_host_moves => '100',
      dup_host_ip_addr_detection_timeout    => '10',
      anycast_gateway_mac                   => '1234.4567.6789',
      dup_host_mac_detection_host_moves     => '100',
      dup_host_mac_detection_timeout        => '10',
    }

    $source_interface_hold_down_time = platform_get() ? {
      /n(8|9)k/  => '50',
      default    => undef,
    }

    $ingress_replication = platform_get() ? {
      /n(8|9)k/  => 'static',
      default    => undef,
    }

    $peer_list = platform_get() ? {
      /n(8|9)k/  => ['1.1.1.1', '2.2.2.2', '3.3.3.3'],
      default    => undef,
    }

    $suppress_uuc = platform_get() ? {
      /n(5|6)k/  => 'default',
      default    => undef,
     }

    cisco_vxlan_vtep { 'nve1':
      ensure                          => present,
      description                     => 'Configured by puppet',
      host_reachability               => 'evpn',
      shutdown                        => 'false',
      source_interface                => 'loopback55',
      source_interface_hold_down_time => $source_interface_hold_down_time,
    }

    cisco_vxlan_vtep_vni {'nve1 10000':
      ensure              => present,
      assoc_vrf           => false,
      multicast_group     => undef,
      ingress_replication => $ingress_replication,
      peer_list           => $peer_list,
      suppress_uuc        => $suppress_uuc,
    }

    cisco_vxlan_vtep_vni {'nve1 20000':
      ensure              => present,
      assoc_vrf           => false,
      multicast_group     => '224.1.1.1',
      suppress_arp        => 'default',
    }

    # TBD: Anycast gateway mode
    # if platform_get() =~ /n7k/ {
    #   cisco_interface { 'Bdi100':
    #     require => Cisco_overlay_global['default'],
    #     ensure  => present,
    #     fabric_forwarding_anycast_gateway => 'true',
    #   }
    # }
    #
    # else {
    #   cisco_interface { 'vlan97':
    #     require => Cisco_overlay_global['default'],
    #     ensure  => present,
    #     fabric_forwarding_anycast_gateway => 'true',
    #   }
    # }
  } else {
    notify{'SKIP: This platform does not support vxlan': }
  }
}
