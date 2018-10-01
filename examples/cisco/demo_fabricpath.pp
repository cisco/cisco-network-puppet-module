# Manifest to demo cisco_fabricpath_global provider
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

class ciscopuppet::cisco::demo_fabricpath {

  if platform_get() =~ /n(5|6|7)k/ {
    if platform_get() == 'n7k' {
      $aggregate_multicast_routes     = true
      $linkup_delay_always            = false
      $linkup_delay_enable            = false
      $loadbalance_algorithm          = 'symmetric'
      $loadbalance_multicast_rotate   = '3'
      $loadbalance_multicast_has_vlan = true
      $loadbalance_unicast_rotate     = '5'
      $mode                           = 'transit'
      $ttl_multicast                  = '20'
      $ttl_unicast                    = '20'

      cisco_vdc { 'default':
        ensure                     => present,
        limit_resource_module_type => 'f2e f3'
      }

    } else {
      $aggregate_multicast_routes     = undef
      $linkup_delay_always            = undef
      $linkup_delay_enable            = undef
      $loadbalance_algorithm          = 'source'
      $loadbalance_multicast_rotate   = undef
      $loadbalance_multicast_has_vlan = undef
      $loadbalance_unicast_rotate     = undef
      $mode                           = undef
      $ttl_multicast                  = undef
      $ttl_unicast                    = undef
    }

    cisco_fabricpath_global { 'default':
      ensure                         => present,
      allocate_delay                 => '30',
      graceful_merge                 => 'enable',
      linkup_delay                   => '20',
      loadbalance_unicast_layer      => 'layer4',
      loadbalance_unicast_has_vlan   => true,
      switch_id                      => '100',
      transition_delay               => '25',
      aggregate_multicast_routes     => $aggregate_multicast_routes,
      linkup_delay_always            => $linkup_delay_always,
      linkup_delay_enable            => $linkup_delay_enable,
      loadbalance_algorithm          => $loadbalance_algorithm,
      loadbalance_multicast_rotate   => $loadbalance_multicast_rotate,
      loadbalance_multicast_has_vlan => $loadbalance_multicast_has_vlan,
      loadbalance_unicast_rotate     => $loadbalance_unicast_rotate,
      mode                           => $mode,
      ttl_multicast                  => $ttl_multicast,
      ttl_unicast                    => $ttl_unicast,
    }

    cisco_vlan { '10':
      ensure   => present,
      mode     => 'fabricpath',
      shutdown => false,
    }

    cisco_fabricpath_topology { '10':
      ensure       => present,
      topo_name    => 'Topo-10',
      member_vlans => '10-20, 25, 27-30'
    }

    cisco_interface { 'Ethernet1/1':
      ensure          => present,
      switchport_mode => 'fabricpath',
      shutdown        => false,
    }
  } else {
    warning('This platform does not support fabricpath feature')
  }
}
