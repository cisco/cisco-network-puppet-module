# Manifest to demo cisco_command_config provider
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

class ciscopuppet::demo_command_config {

  cisco_command_config { 'loop42':
    command => "
      interface loopback42
        description Peering for AS 42
        ip address 192.168.1.42/24
    "
  }

  cisco_command_config { 'system-switchport-default':
    command => 'no system default switchport'
  }

  cisco_command_config { 'feature_bgp':
    command => ' feature bgp',
    before  => Cisco_command_config['router_bgp_42'],
  }

  cisco_command_config { 'router_bgp_42':
    command => "
    router bgp 42
      router-id 192.168.1.42
      address-family ipv4 unicast
        network 10.0.0.0/8
        redistribute static route-map bgp-statics
    "
  }

  cisco_command_config { 'route42':
    command => 'ip route 192.168.42.42/32 Null0',
  }
}
