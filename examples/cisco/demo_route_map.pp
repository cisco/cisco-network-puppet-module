# Manifest to demo cisco_interface provider
#
# Copyright (c) 2017 Cisco and/or its affiliates.
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

class ciscopuppet::cisco::demo_route_map {

  $match_evpn_route_type_1 = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_2_all = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_2_mac_ip = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_2_mac_only = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_3 = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_4 = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_5 = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_6 = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_evpn_route_type_all = platform_get() ? {
    /(n5k|n6k|n7k)/ => true,
    default => undef
  }

  $match_length = platform_get() ? {
    /(n5k|n6k|n7k)/ => ['45', '345'],
    default => undef
  }

  $match_mac_list = platform_get() ? {
    /(n5k|n6k|n7k)/ => ['mac1', 'listmac'],
    default => undef
  }

  $match_ospf_area = platform_get() ? {
    /(n3k$|n9k$)/ => $facts['cisco']['images']['system_image'] ? {
      /(I2|I3|I4)/ => undef,
      default => ['10', '7', '222']
    },
    default => undef
  }

  $match_vlan = platform_get() ? {
    /(n5k|n6k|n7k)/ => '32, 45-200, 300-350, 400-453',
    default => undef
  }

  $set_ipv4_default_next_hop = platform_get() ? {
    /(n3k|n7k)/ => ['1.1.1.1', '2.2.2.2'],
    default => undef
  }

  $set_ipv4_default_next_hop_load_share = platform_get() ? {
    /(n3k|n7k)/ => true,
    default => undef
  }

  $set_ipv4_next_hop_load_share = platform_get() ? {
    /(n3k$|n9k$)/ => $facts['cisco']['images']['system_image'] ? {
      /(I2|I3|I4)/ => undef,
      default => true
    },
    'n7k' => true,
    default => undef
  }

  $set_ipv4_prefix = platform_get() ? {
    /(n3k|n7k|n9k)/ => 'abcdef',
    default => undef
  }

  $set_ipv6_default_next_hop = platform_get() ? {
    /(n3k|n7k)/ => ['2000::1', '2000::11', '2000::22'],
    default => undef
  }

  $set_ipv6_default_next_hop_load_share = platform_get() ? {
    /(n3k|n7k)/ => true,
    default => undef
  }

  $set_ipv4_next_hop_redist = platform_get() ? {
    /(n3k$|n9k$)/ => $facts['cisco']['images']['system_image'] ? {
      /(I2|I3|I4)/ => undef,
      default => true
    },
    default => true
  }

  $set_ipv6_next_hop_redist = platform_get() ? {
    /(n3k$|n9k$)/ => $facts['cisco']['images']['system_image'] ? {
      /(I2|I3|I4)/ => undef,
      default => true
    },
    default => true
  }

  $set_ipv6_next_hop_load_share = platform_get() ? {
    /(n3k$|n9k$)/ => $facts['cisco']['images']['system_image'] ? {
      /(I2|I3|I4)/ => undef,
      default => true
    },
    'n7k' => true,
    default => undef
  }

  $set_ipv6_prefix = platform_get() ? {
    /(n3k|n7k|n9k)/ => 'wxyz',
    default => undef
  }

  $set_extcommunity_rt_asn = platform_get() ? {
    /(n3k|n5k|n6k|n7k)/ => ['11:22', '33:44', '12.22.22.22:12', '123.256:543'],
    default => undef
  }

  $set_vrf = platform_get() ? {
    'n7k' => 'igp',
    default => undef
  }

  if platform_get() =~ /n(3|5|6|7|9)k$/ {
    cisco_route_map {'MyRouteMap1 123 permit':
      ensure                                 => 'present',
      description                            => 'Testing',
      match_as_number                        => ['3', '22-34', '38', '101-110'],
      match_as_number_as_path_list           => ['abc', 'xyz', 'pqr'],
      match_community                        => ['public', 'private'],
      match_community_exact_match            => true,
      match_evpn_route_type_1                => $match_evpn_route_type_1,
      match_evpn_route_type_2_all            => $match_evpn_route_type_2_all,
      match_evpn_route_type_2_mac_ip         => $match_evpn_route_type_2_mac_ip,
      match_evpn_route_type_2_mac_only       => $match_evpn_route_type_2_mac_only,
      match_evpn_route_type_3                => $match_evpn_route_type_3,
      match_evpn_route_type_4                => $match_evpn_route_type_4,
      match_evpn_route_type_5                => $match_evpn_route_type_5,
      match_evpn_route_type_6                => $match_evpn_route_type_6,
      match_evpn_route_type_all              => $match_evpn_route_type_all,
      match_ext_community                    => ['epublic', 'eprivate'],
      match_ext_community_exact_match        => true,
      match_interface                        => ['ethernet1/1', 'loopback2', 'mgmt0', 'null0', 'port-channel10'],
      match_ipv4_addr_access_list            => 'access',
      match_ipv4_addr_prefix_list            => ['p1', 'p7', 'pre5'],
      match_ipv4_multicast_enable            => true,
      match_ipv4_multicast_src_addr          => '242.1.1.1/32',
      match_ipv4_multicast_group_addr        => '239.2.2.2/32',
      match_ipv4_multicast_rp_addr           => '242.1.1.1/32',
      match_ipv4_multicast_rp_type           => 'ASM',
      match_ipv4_next_hop_prefix_list        => ['nh5', 'nh1', 'nh42'],
      match_ipv4_route_src_prefix_list       => ['rs2', 'rs22', 'pre15'],
      match_ipv6_multicast_enable            => true,
      match_ipv6_multicast_src_addr          => '2001::348:0:0/96',
      match_ipv6_multicast_group_addr        => 'ff0e::2:101:0:0/96',
      match_ipv6_multicast_rp_addr           => '2001::348:0:0/96',
      match_ipv6_multicast_rp_type           => 'ASM',
      match_ipv6_next_hop_prefix_list        => ['nhv6', 'v6nh1', 'nhv42'],
      match_ipv6_route_src_prefix_list       => ['rsv6', 'rs22v6', 'prev6'],
      match_mac_list                         => $match_mac_list,
      match_metric                           => [['1', '0'], ['8', '0'], ['224', '9'], ['23', '0'], ['5', '8'], ['6', '0']],
      match_ospf_area                        => $match_ospf_area,
      match_route_type_external              => true,
      match_route_type_inter_area            => true,
      match_route_type_internal              => true,
      match_route_type_intra_area            => true,
      match_route_type_level_1               => true,
      match_route_type_level_2               => true,
      match_route_type_local                 => true,
      match_route_type_nssa_external         => true,
      match_route_type_type_1                => true,
      match_route_type_type_2                => true,
      match_src_proto                        => ['tcp', 'udp', 'igmp'],
      match_tag                              => ['5', '342', '28', '3221'],
      match_vlan                             => $match_vlan,
      set_as_path_prepend                    => ['55.77', '12', '45.3'],
      set_as_path_prepend_last_as            => 1,
      set_as_path_tag                        => true,
      set_comm_list                          => 'abc',
      set_community_additive                 => true,
      set_community_asn                      => ['11:22', '33:44', '123:11'],
      set_community_internet                 => true,
      set_community_local_as                 => true,
      set_community_no_advtertise            => true,
      set_community_no_export                => true,
      set_community_none                     => false,
      set_dampening_half_life                => 6,
      set_dampening_max_duation              => 55,
      set_dampening_reuse                    => 22,
      set_dampening_suppress                 => 44,
      set_distance_igp_ebgp                  => 1,
      set_distance_internal                  => 2,
      set_distance_local                     => 3,
      set_extcomm_list                       => 'xyz',
      set_extcommunity_4bytes_additive       => true,
      set_extcommunity_4bytes_non_transitive => ['21:42', '43:22', '59:17'],
      set_extcommunity_4bytes_transitive     => ['11:22', '33:44', '66:77'],
      set_extcommunity_cost_igp              => [['0', '23'], ['3', '33'], ['100', '10954']],
      set_extcommunity_cost_pre_bestpath     => [['23', '999'], ['88', '482'], ['120', '2323']],
      set_extcommunity_rt_additive           => true,
      set_extcommunity_rt_asn                => $set_extcommunity_rt_asn,
      set_forwarding_addr                    => true,
      set_ipv4_next_hop                      => ['3.3.3.3', '4.4.4.4'],
      set_ipv4_next_hop_load_share           => $set_ipv4_next_hop_load_share,
      set_ipv4_precedence                    => 'critical',
      set_ipv4_prefix                        => $set_ipv4_prefix,
      set_ipv6_next_hop                      => ['2000::1', '2000::11', '2000::22'],
      set_ipv6_next_hop_load_share           => $set_ipv6_next_hop_load_share,
      set_ipv6_prefix                        => $set_ipv6_prefix,
      set_level                              => 'level-1',
      set_local_preference                   => 100,
      set_metric_additive                    => false,
      set_metric_bandwidth                   => 44,
      set_metric_delay                       => 55,
      set_metric_reliability                 => 66,
      set_metric_effective_bandwidth         => 77,
      set_metric_mtu                         => 88,
      set_metric_type                        => 'external',
      set_nssa_only                          => true,
      set_origin                             => 'egp',
      set_path_selection                     => true,
      set_tag                                => 101,
      set_weight                             => 222,
    }
  }

  if platform_get() =~ /n(3|9)k-f/ {
    cisco_route_map {'MyRouteMap1 123 permit':
      ensure                           => 'present',
      description                      => 'Testing',
      match_as_number                  => ['3', '22-34', '38', '101-110'],
      match_as_number_as_path_list     => ['abc', 'xyz', 'pqr'],
      match_community                  => ['public', 'private'],
      match_community_exact_match      => true,
      match_evpn_route_type_1          => $match_evpn_route_type_1,
      match_evpn_route_type_2_all      => $match_evpn_route_type_2_all,
      match_evpn_route_type_2_mac_ip   => $match_evpn_route_type_2_mac_ip,
      match_evpn_route_type_2_mac_only => $match_evpn_route_type_2_mac_only,
      match_evpn_route_type_3          => $match_evpn_route_type_3,
      match_evpn_route_type_4          => $match_evpn_route_type_4,
      match_evpn_route_type_5          => $match_evpn_route_type_5,
      match_evpn_route_type_6          => $match_evpn_route_type_6,
      match_evpn_route_type_all        => $match_evpn_route_type_all,
      match_ext_community              => ['epublic', 'eprivate'],
      match_ext_community_exact_match  => true,
      match_interface                  => ['ethernet1/1', 'loopback2', 'mgmt0', 'null0', 'port-channel10'],
      match_ipv4_addr_access_list      => 'access',
      match_ipv4_addr_prefix_list      => ['p1', 'p7', 'pre5'],
      match_ipv4_multicast_enable      => true,
      match_ipv4_multicast_src_addr    => '242.1.1.1/32',
      match_ipv4_multicast_group_addr  => '239.2.2.2/32',
      match_ipv4_multicast_rp_addr     => '242.1.1.1/32',
      match_ipv4_multicast_rp_type     => 'ASM',
      match_ipv4_next_hop_prefix_list  => ['nh5', 'nh1', 'nh42'],
      match_ipv4_route_src_prefix_list => ['rs2', 'rs22', 'pre15'],
      match_ipv6_multicast_enable      => true,
      match_ipv6_multicast_src_addr    => '2001::348:0:0/96',
      match_ipv6_multicast_group_addr  => 'ff0e::2:101:0:0/96',
      match_ipv6_multicast_rp_addr     => '2001::348:0:0/96',
      match_ipv6_multicast_rp_type     => 'ASM',
      match_ipv6_next_hop_prefix_list  => ['nhv6', 'v6nh1', 'nhv42'],
      match_ipv6_route_src_prefix_list => ['rsv6', 'rs22v6', 'prev6'],
      match_mac_list                   => $match_mac_list,
      match_ospf_area                  => $match_ospf_area,
      match_route_type_external        => true,
      match_route_type_inter_area      => true,
      match_route_type_internal        => true,
      match_route_type_intra_area      => true,
      match_route_type_level_1         => true,
      match_route_type_level_2         => true,
      match_route_type_local           => true,
      match_route_type_nssa_external   => true,
      match_route_type_type_1          => true,
      match_route_type_type_2          => true,
      match_src_proto                  => ['tcp', 'udp', 'igmp'],
      match_tag                        => ['5', '342', '28', '3221'],
      match_vlan                       => $match_vlan,
      set_as_path_prepend              => ['55.77', '12', '45.3'],
      set_as_path_prepend_last_as      => 1,
      set_as_path_tag                  => true,
      set_comm_list                    => 'abc',
      set_community_additive           => true,
      set_community_asn                => ['11:22', '33:44', '123:11'],
      set_community_internet           => true,
      set_community_local_as           => true,
      set_community_no_advtertise      => true,
      set_community_no_export          => true,
      set_community_none               => false,
      set_dampening_half_life          => 6,
      set_dampening_max_duation        => 55,
      set_dampening_reuse              => 22,
      set_dampening_suppress           => 44,
      set_distance_igp_ebgp            => 1,
      set_distance_internal            => 2,
      set_distance_local               => 3,
      set_extcomm_list                 => 'xyz',
      set_level                        => 'level-1',
      set_local_preference             => 100,
      set_metric_additive              => false,
      set_metric_bandwidth             => 44,
      set_metric_delay                 => 55,
      set_metric_reliability           => 66,
      set_metric_effective_bandwidth   => 77,
      set_metric_mtu                   => 88,
      set_metric_type                  => 'external',
      set_nssa_only                    => true,
      set_origin                       => 'egp',
      set_path_selection               => true,
      set_tag                          => 101,
      set_weight                       => 222,
    }
  }

  cisco_route_map {'MyRouteMap2 149 deny':
    ensure                                      => 'present',
    match_ipv6_addr_prefix_list                 => ['pv6', 'pv67', 'prev6'],
    match_ipv4_multicast_enable                 => true,
    match_ipv4_multicast_src_addr               => '242.1.1.1/32',
    match_ipv4_multicast_group_range_begin_addr => '239.1.1.1',
    match_ipv4_multicast_group_range_end_addr   => '239.2.2.2',
    match_ipv4_multicast_rp_addr                => '242.1.1.1/32',
    match_ipv4_multicast_rp_type                => 'Bidir',
    match_ipv6_addr_access_list                 => 'v6access',
    match_ipv6_multicast_enable                 => true,
    match_ipv6_multicast_src_addr               => '2001::348:0:0/96',
    match_ipv6_multicast_group_range_begin_addr => 'ff01::',
    match_ipv6_multicast_group_range_end_addr   => 'ff02::',
    match_ipv6_multicast_rp_addr                => '2001::348:0:0/96',
    match_ipv6_multicast_rp_type                => 'Bidir',
    set_community_none                          => true,
    set_extcommunity_4bytes_none                => true,
    set_ipv4_default_next_hop                   => $set_ipv4_default_next_hop,
    set_ipv4_default_next_hop_load_share        => $set_ipv4_default_next_hop_load_share,
    set_ipv4_next_hop_peer_addr                 => true,
    set_ipv6_precedence                         => 'flash',
    set_level                                   => 'level-1-2',
    set_metric_additive                         => true,
    set_metric_bandwidth                        => 33,
    set_metric_type                             => 'type-2',
    set_origin                                  => 'incomplete',
  }

  cisco_route_map {'MyRouteMap3 159 deny':
    ensure                               => 'present',
    set_ipv6_default_next_hop            => $set_ipv6_default_next_hop,
    set_ipv6_default_next_hop_load_share => $set_ipv6_default_next_hop_load_share,
    set_ipv6_next_hop_peer_addr          => true,
  }

  cisco_route_map {'MyRouteMap4 200 permit':
    ensure                      => 'present',
    set_interface               => 'Null0',
    set_ipv4_next_hop_redist    => $set_ipv4_next_hop_redist,
    set_ipv6_next_hop_redist    => $set_ipv6_next_hop_redist,
    set_ipv6_next_hop_unchanged => true,
    set_ipv4_next_hop_unchanged => true,
  }

  cisco_route_map {'MyRouteMap5 199 deny':
    ensure       => 'present',
    match_length => $match_length,
    set_vrf      => $set_vrf,
  }
}
