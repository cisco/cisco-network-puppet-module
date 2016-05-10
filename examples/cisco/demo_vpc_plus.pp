# Manifest to demo cisco_vpc_domain provider with vPC+ features
#
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

class ciscopuppet::cisco::demo_vpc_plus {

  if platform_get() =~ /n7k/ {
    # this next block is for future use when n5k and n6k support gets added
    if platform_get() == 'n7k' {
      $fabricpath_multicast_load_balance = true
      $port_channel_limit = false
    } else {
      $fabricpath_multicast_load_balance = undef
      $port_channel_limit = undef
    }

    # fabricpath feature must be enabled to use cisco_vlan: mode => 'fabricpath'.
    # Just declare one of the fabricpath resources or a cisco_vlan with
    # fabricpath mode to automatically enable fabricpath
    cisco_fabricpath_global { 'default': ensure => present }

    cisco_vlan { '10' :
      ensure                            => present,
      mode                              => 'fabricpath',
      shutdown                          => false,
    }

    # Other than fabricpath_emulated_switch_id, only the peer_keepalive params
    # are mandatory to get the vPC+ domain up and running
    cisco_vpc_domain { '100' :
      ensure                            => present,
      fabricpath_emulated_switch_id     => 1001,
      peer_keepalive_dest               => '1.1.1.1',
      peer_keepalive_hold_timeout       => 5,
      peer_keepalive_interval           => 1000,
      peer_keepalive_interval_timeout   => 3,
      peer_keepalive_precedence         => 5,
      peer_keepalive_src                => '1.1.1.2',
      peer_keepalive_udp_port           => 3200,
      peer_keepalive_vrf                => 'management',
      role_priority                     => 32000,
      system_mac                        => '00:0c:0d:11:22:33',
      system_priority                   => 32000,
    }
  
    cisco_interface_channel_group { 'Ethernet1/1':
      require       => Cisco_vpc_domain['100'],
      channel_group => 10,
    }
  
    cisco_interface { 'port-channel10' :
      switchport_mode => 'trunk',
      vpc_id          => 5,
      shutdown        => false,
      require         => Cisco_interface_channel_group['Ethernet1/1'],
    }
  
    cisco_interface_channel_group { 'Ethernet1/2':
      require       => Cisco_vpc_domain['100'],
      channel_group => 100,
    }
  
    # peer link should be in fabricpath mode for vPC+
    cisco_interface { 'port-channel100' :
      switchport_mode => 'fabricpath',
      vpc_peer_link   => true,
      shutdown        => false,
      require         => Cisco_interface_channel_group['Ethernet1/2'],
    }

  } else {
    notify{'SKIP: This platform does not support vPC+ feature': }
  }
}
