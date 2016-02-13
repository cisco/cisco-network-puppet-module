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
  cisco_overlay_global { 'default':
    dup_host_ip_addr_detection_host_moves => '100',
    dup_host_ip_addr_detection_timeout    => '10',
    anycast_gateway_mac                   => '1234.4567.6789',
    dup_host_mac_detection_host_moves     => '100',
    dup_host_mac_detection_timeout        => '10',
  }

  cisco_vxlan_vtep { 'nve1':
    ensure            => present,
    description       => 'Configured by puppet',
    host_reachability => 'evpn',
    shutdown          => 'false',
    source_interface  => 'loopback55',
  }

  cisco_vxlan_vtep_vni {'nve1 10000':
    ensure              => present,
    assoc_vrf           => false,
    ingress_replication => 'static',
    multicast_group     => undef,
    peer_list           => ['1.1.1.1', '2.2.2.2', '3.3.3.3'],
    suppress_arp        => 'default',
  }
  
  cisco_vxlan_vtep_vni {'nve1 20000':
    ensure              => present,
    assoc_vrf           => false,
    ingress_replication => undef,
    multicast_group     => '224.1.1.1',
    suppress_arp        => 'default',
  }

  cisco_interface { 'vlan97':
    ensure => present,
    fabric_forwarding_anycast_gateway => 'true',
    require                           => Cisco_overlay_global['default'],
  }
}
