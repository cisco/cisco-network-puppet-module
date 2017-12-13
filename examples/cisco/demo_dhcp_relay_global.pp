# Manifest to demo cisco_dhcp_relay_global provider
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

class ciscopuppet::cisco::demo_dhcp_relay_global {

  $ipv4_information_option_trust = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => true,
    default => undef
  }

  $ipv4_information_trust_all = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => true,
    default => undef
  }

  $ipv4_src_addr_hsrp = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $ipv4_sub_option_circuit_id_custom = platform_get() ? {
    /(n3k|n5k|n6k|n9k)/ => true,
    default => undef
  }

  $ipv4_sub_option_circuit_id_string = platform_get() ? {
    'n3k' => '%p%p',
    default => undef
  }

  $ipv6_option_cisco = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => true,
    default => undef
  }

  cisco_dhcp_relay_global { 'default':
    ipv4_information_option           => true,
    ipv4_information_option_trust     => $ipv4_information_option_trust,
    ipv4_information_option_vpn       => true,
    ipv4_information_trust_all        => $ipv4_information_trust_all,
    ipv4_relay                        => true,
    ipv4_smart_relay                  => true,
    ipv4_src_addr_hsrp                => $ipv4_src_addr_hsrp,
    ipv4_src_intf                     => 'port-channel100',
    ipv4_sub_option_circuit_id_custom => $ipv4_sub_option_circuit_id_custom,
    ipv4_sub_option_circuit_id_string => $ipv4_sub_option_circuit_id_string,
    ipv4_sub_option_cisco             => true,
    ipv6_option_cisco                 => $ipv6_option_cisco,
    ipv6_option_vpn                   => true,
    ipv6_relay                        => true,
    ipv6_src_intf                     => 'loopback1',
  }
}
