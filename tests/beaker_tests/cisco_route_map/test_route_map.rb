###############################################################################
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
###############################################################################
#
# See README-develop-beaker-scripts.md (Section: Test Script Variable Reference)
# for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_route_map',
}

skip_unless_supported(tests)

# In I7 match_src_proto order is not maintained in running config.
# This behavior is currently observed only on the N9K.
if platform[/n9k/] && full_version[/I(7|8|9)/]
  @src_proto = %w(udp igmp tcp)
else
  @src_proto = %w(tcp udp igmp)
end

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Defaults',
  title_pattern:  'rm1 123 permit',
  manifest_props: {
    description:                                 'default',
    match_as_number:                             'default',
    match_as_number_as_path_list:                'default',
    match_community:                             'default',
    match_community_exact_match:                 'default',
    match_evpn_route_type_1:                     'default',
    match_evpn_route_type_2_all:                 'default',
    match_evpn_route_type_2_mac_ip:              'default',
    match_evpn_route_type_2_mac_only:            'default',
    match_evpn_route_type_3:                     'default',
    match_evpn_route_type_4:                     'default',
    match_evpn_route_type_5:                     'default',
    match_evpn_route_type_6:                     'default',
    match_evpn_route_type_all:                   'default',
    match_ext_community:                         'default',
    match_ext_community_exact_match:             'default',
    match_interface:                             'default',
    match_ipv4_addr_access_list:                 'default',
    match_ipv4_addr_prefix_list:                 'default',
    match_ipv4_multicast_enable:                 'default',
    match_ipv4_multicast_group_addr:             'default',
    match_ipv4_multicast_group_range_begin_addr: 'default',
    match_ipv4_multicast_group_range_end_addr:   'default',
    match_ipv4_multicast_rp_addr:                'default',
    match_ipv4_multicast_rp_type:                'default',
    match_ipv4_multicast_src_addr:               'default',
    match_ipv4_next_hop_prefix_list:             'default',
    match_ipv4_route_src_prefix_list:            'default',
    match_ipv6_addr_access_list:                 'default',
    match_ipv6_addr_prefix_list:                 'default',
    match_ipv6_multicast_enable:                 'default',
    match_ipv6_multicast_group_addr:             'default',
    match_ipv6_multicast_group_range_begin_addr: 'default',
    match_ipv6_multicast_group_range_end_addr:   'default',
    match_ipv6_multicast_rp_addr:                'default',
    match_ipv6_multicast_rp_type:                'default',
    match_ipv6_multicast_src_addr:               'default',
    match_ipv6_next_hop_prefix_list:             'default',
    match_ipv6_route_src_prefix_list:            'default',
    match_length:                                'default',
    match_mac_list:                              'default',
    match_metric:                                'default',
    match_ospf_area:                             'default',
    match_route_type_external:                   'default',
    match_route_type_inter_area:                 'default',
    match_route_type_internal:                   'default',
    match_route_type_intra_area:                 'default',
    match_route_type_level_1:                    'default',
    match_route_type_level_2:                    'default',
    match_route_type_local:                      'default',
    match_route_type_nssa_external:              'default',
    match_route_type_type_1:                     'default',
    match_route_type_type_2:                     'default',
    match_src_proto:                             'default',
    match_tag:                                   'default',
    match_vlan:                                  'default',
    set_as_path_prepend:                         'default',
    set_as_path_prepend_last_as:                 'default',
    set_as_path_tag:                             'default',
    set_comm_list:                               'default',
    set_community_additive:                      'default',
    set_community_asn:                           'default',
    set_community_internet:                      'default',
    set_community_local_as:                      'default',
    set_community_no_advtertise:                 'default',
    set_community_no_export:                     'default',
    set_community_none:                          'default',
    set_dampening_half_life:                     'default',
    set_dampening_max_duation:                   'default',
    set_dampening_reuse:                         'default',
    set_dampening_suppress:                      'default',
    set_distance_igp_ebgp:                       'default',
    set_distance_internal:                       'default',
    set_distance_local:                          'default',
    set_extcomm_list:                            'default',
    set_extcommunity_4bytes_additive:            'default',
    set_extcommunity_4bytes_non_transitive:      'default',
    set_extcommunity_4bytes_none:                'default',
    set_extcommunity_4bytes_transitive:          'default',
    set_extcommunity_cost_igp:                   'default',
    set_extcommunity_cost_pre_bestpath:          'default',
    set_extcommunity_rt_additive:                'default',
    set_extcommunity_rt_asn:                     'default',
    set_forwarding_addr:                         'default',
    set_interface:                               'default',
    set_ipv4_default_next_hop:                   'default',
    set_ipv4_default_next_hop_load_share:        'default',
    set_ipv4_next_hop:                           'default',
    set_ipv4_next_hop_load_share:                'default',
    set_ipv4_next_hop_peer_addr:                 'default',
    set_ipv4_next_hop_redist:                    'default',
    set_ipv4_next_hop_unchanged:                 'default',
    set_ipv4_precedence:                         'default',
    set_ipv4_prefix:                             'default',
    set_ipv6_default_next_hop:                   'default',
    set_ipv6_default_next_hop_load_share:        'default',
    set_ipv6_next_hop:                           'default',
    set_ipv6_next_hop_load_share:                'default',
    set_ipv6_next_hop_peer_addr:                 'default',
    set_ipv6_next_hop_redist:                    'default',
    set_ipv6_next_hop_unchanged:                 'default',
    set_ipv6_precedence:                         'default',
    set_ipv6_prefix:                             'default',
    set_level:                                   'default',
    set_local_preference:                        'default',
    set_metric_additive:                         'default',
    set_metric_bandwidth:                        'default',
    set_metric_delay:                            'default',
    set_metric_effective_bandwidth:              'default',
    set_metric_mtu:                              'default',
    set_metric_reliability:                      'default',
    set_metric_type:                             'default',
    set_nssa_only:                               'default',
    set_origin:                                  'default',
    set_path_selection:                          'default',
    set_tag:                                     'default',
    set_vrf:                                     'default',
    set_weight:                                  'default',
  },
  code:           [0, 2],
  resource:       {
    description:                          'false',
    match_community_exact_match:          'false',
    match_evpn_route_type_1:              'false',
    match_evpn_route_type_2_all:          'false',
    match_evpn_route_type_2_mac_ip:       'false',
    match_evpn_route_type_2_mac_only:     'false',
    match_evpn_route_type_3:              'false',
    match_evpn_route_type_4:              'false',
    match_evpn_route_type_5:              'false',
    match_evpn_route_type_6:              'false',
    match_evpn_route_type_all:            'false',
    match_ext_community_exact_match:      'false',
    match_ipv4_addr_access_list:          'false',
    match_ipv4_multicast_enable:          'false',
    match_ipv6_addr_access_list:          'false',
    match_ipv6_multicast_enable:          'false',
    match_route_type_external:            'false',
    match_route_type_inter_area:          'false',
    match_route_type_internal:            'false',
    match_route_type_intra_area:          'false',
    match_route_type_level_1:             'false',
    match_route_type_level_2:             'false',
    match_route_type_local:               'false',
    match_route_type_nssa_external:       'false',
    match_route_type_type_1:              'false',
    match_route_type_type_2:              'false',
    set_as_path_prepend_last_as:          'false',
    set_as_path_tag:                      'false',
    set_comm_list:                        'false',
    set_community_additive:               'false',
    set_community_internet:               'false',
    set_community_local_as:               'false',
    set_community_no_advtertise:          'false',
    set_community_no_export:              'false',
    set_community_none:                   'false',
    set_dampening_half_life:              'false',
    set_dampening_max_duation:            'false',
    set_dampening_reuse:                  'false',
    set_dampening_suppress:               'false',
    set_distance_igp_ebgp:                'false',
    set_distance_internal:                'false',
    set_distance_local:                   'false',
    set_extcomm_list:                     'false',
    set_extcommunity_4bytes_additive:     'false',
    set_extcommunity_4bytes_none:         'false',
    set_extcommunity_rt_additive:         'false',
    set_forwarding_addr:                  'false',
    set_interface:                        'false',
    set_ipv4_default_next_hop_load_share: 'false',
    set_ipv4_next_hop_load_share:         'false',
    set_ipv4_next_hop_peer_addr:          'false',
    set_ipv4_next_hop_redist:             'false',
    set_ipv4_next_hop_unchanged:          'false',
    set_ipv4_precedence:                  'false',
    set_ipv4_prefix:                      'false',
    set_ipv6_default_next_hop_load_share: 'false',
    set_ipv6_next_hop_load_share:         'false',
    set_ipv6_next_hop_peer_addr:          'false',
    set_ipv6_next_hop_redist:             'false',
    set_ipv6_next_hop_unchanged:          'false',
    set_ipv6_precedence:                  'false',
    set_ipv6_prefix:                      'false',
    set_level:                            'false',
    set_local_preference:                 'false',
    set_metric_additive:                  'false',
    set_metric_bandwidth:                 'false',
    set_metric_delay:                     'false',
    set_metric_effective_bandwidth:       'false',
    set_metric_mtu:                       'false',
    set_metric_reliability:               'false',
    set_metric_type:                      'false',
    set_nssa_only:                        'false',
    set_origin:                           'false',
    set_path_selection:                   'false',
    set_tag:                              'false',
    set_vrf:                              'false',
    set_weight:                           'false',
  },
}

tests[:non_default_1] = {
  desc:           '2.1 Non Defaults 1',
  title_pattern:  'rm1 123 permit',
  manifest_props: {
    description:                            'map1',
    match_as_number:                        ['3', '22-34', '38', '101-110'],
    match_as_number_as_path_list:           %w(abc xyz pqr),
    match_community:                        %w(public private),
    match_community_exact_match:            'true',
    match_evpn_route_type_1:                'true',
    match_evpn_route_type_2_all:            'true',
    match_evpn_route_type_2_mac_ip:         'true',
    match_evpn_route_type_2_mac_only:       'true',
    match_evpn_route_type_3:                'true',
    match_evpn_route_type_4:                'true',
    match_evpn_route_type_5:                'true',
    match_evpn_route_type_6:                'true',
    match_evpn_route_type_all:              'true',
    match_ext_community:                    %w(epublic eprivate),
    match_ext_community_exact_match:        'true',
    match_interface:                        %w(loopback2 mgmt0 null0),
    match_ipv4_addr_access_list:            'access',
    match_ipv4_addr_prefix_list:            %w(p1 p7 pre5),
    match_ipv4_multicast_enable:            'true',
    match_ipv4_multicast_group_addr:        '239.2.2.2/32',
    match_ipv4_multicast_rp_addr:           '242.1.1.1/32',
    match_ipv4_multicast_rp_type:           'ASM',
    match_ipv4_multicast_src_addr:          '242.1.1.1/32',
    match_ipv4_next_hop_prefix_list:        %w(nh5 nh1 nh42),
    match_ipv4_route_src_prefix_list:       %w(rs2 rs22 pre15),
    match_ipv6_multicast_enable:            'true',
    match_ipv6_multicast_group_addr:        'ff0e::2:101:0:0/96',
    match_ipv6_multicast_rp_addr:           '2001::348:0:0/96',
    match_ipv6_multicast_rp_type:           'ASM',
    match_ipv6_multicast_src_addr:          '2001::348:0:0/96',
    match_ipv6_next_hop_prefix_list:        %w(nhv6 v6nh1 nhv42),
    match_ipv6_route_src_prefix_list:       %w(rsv6 rs22v6 prev6),
    match_mac_list:                         %w(mac1 listmac),
    match_metric:                           [%w(1 0), %w(8 0), %w(224 9), %w(23 0), %w(5 8), %w(6 0)],
    match_ospf_area:                        %w(10 7 222),
    match_route_type_external:              'true',
    match_route_type_inter_area:            'true',
    match_route_type_internal:              'true',
    match_route_type_intra_area:            'true',
    match_route_type_level_1:               'true',
    match_route_type_level_2:               'true',
    match_route_type_local:                 'true',
    match_route_type_nssa_external:         'true',
    match_route_type_type_1:                'true',
    match_route_type_type_2:                'true',
    match_tag:                              %w(5 342 28 3221),
    match_vlan:                             '32, 45-200, 300-399, 402',
    set_as_path_prepend:                    ['55.77', '12', '45.3'],
    set_as_path_prepend_last_as:            1,
    set_as_path_tag:                        'true',
    set_comm_list:                          'abc',
    set_community_additive:                 'true',
    set_community_asn:                      ['11:22', '33:44', '123:11'],
    set_community_internet:                 'true',
    set_community_local_as:                 'true',
    set_community_no_advtertise:            'true',
    set_community_no_export:                'true',
    set_dampening_half_life:                6,
    set_dampening_max_duation:              55,
    set_dampening_reuse:                    22,
    set_dampening_suppress:                 44,
    set_distance_igp_ebgp:                  1,
    set_distance_internal:                  2,
    set_distance_local:                     3,
    set_extcomm_list:                       'xyz',
    set_extcommunity_4bytes_additive:       'true',
    set_extcommunity_4bytes_non_transitive: ['21:42', '43:22', '59:17'],
    set_extcommunity_4bytes_transitive:     ['11:22', '33:44', '66:77'],
    set_extcommunity_cost_igp:              [%w(0 23), %w(3 33), %w(100 10954)],
    set_extcommunity_cost_pre_bestpath:     [%w(23 999), %w(88 482), %w(120 2323)],
    set_extcommunity_rt_additive:           'true',
    set_extcommunity_rt_asn:                ['11:22', '33:44', '12.22.22.22:12', '123.256:543'],
    set_forwarding_addr:                    'true',
    set_ipv4_next_hop:                      ['3.3.3.3', '4.4.4.4'],
    set_ipv4_next_hop_load_share:           'true',
    set_ipv4_precedence:                    'critical',
    set_ipv4_prefix:                        'abcdef',
    set_ipv6_next_hop:                      ['2000::1', '2000::11', '2000::22'],
    set_ipv6_next_hop_load_share:           'true',
    set_ipv6_prefix:                        'wxyz',
    set_level:                              'level-1',
    set_local_preference:                   100,
    set_metric_additive:                    'false',
    set_metric_bandwidth:                   44,
    set_metric_delay:                       55,
    set_metric_effective_bandwidth:         77,
    set_metric_mtu:                         88,
    set_metric_reliability:                 66,
    set_metric_type:                        'external',
    set_nssa_only:                          'true',
    set_origin:                             'egp',
    set_path_selection:                     'true',
    set_tag:                                101,
    set_weight:                             222,
  },
}

tests[:non_default_2] = {
  desc:           '2.2 Non Defaults 2',
  title_pattern:  'rm2 149 deny',
  manifest_props: {
    match_ipv6_addr_prefix_list:                 %w(pv6 pv67 prev6),
    match_ipv4_multicast_enable:                 'true',
    match_ipv4_multicast_src_addr:               '242.1.1.1/32',
    match_ipv4_multicast_group_range_begin_addr: '239.1.1.1',
    match_ipv4_multicast_group_range_end_addr:   '239.2.2.2',
    match_ipv4_multicast_rp_addr:                '242.1.1.1/32',
    match_ipv4_multicast_rp_type:                'Bidir',
    match_ipv6_addr_access_list:                 'v6access',
    match_ipv6_multicast_enable:                 'true',
    match_ipv6_multicast_src_addr:               '2001::348:0:0/96',
    match_ipv6_multicast_group_range_begin_addr: 'ff01::',
    match_ipv6_multicast_group_range_end_addr:   'ff02::',
    match_ipv6_multicast_rp_addr:                '2001::348:0:0/96',
    match_ipv6_multicast_rp_type:                'Bidir',
    set_community_none:                          'true',
    set_extcommunity_4bytes_none:                'true',
    set_ipv4_default_next_hop:                   ['1.1.1.1', '2.2.2.2'],
    set_ipv4_default_next_hop_load_share:        'true',
    set_ipv4_next_hop_peer_addr:                 'true',
    set_ipv6_precedence:                         'flash',
    set_level:                                   'level-1-2',
    set_metric_additive:                         'true',
    set_metric_bandwidth:                        33,
    set_metric_type:                             'type-2',
    set_origin:                                  'incomplete',
  },
}

tests[:non_default_3] = {
  desc:           '2.3 Non Defaults 3',
  title_pattern:  'rm3 159 deny',
  manifest_props: {
    set_ipv6_default_next_hop:            ['2000::1', '2000::11', '2000::22'],
    set_ipv6_default_next_hop_load_share: 'true',
    set_ipv6_next_hop_peer_addr:          'true',
  },
}

tests[:non_default_4] = {
  desc:           '2.4 Non Defaults 4',
  title_pattern:  'rm4 200 permit',
  manifest_props: {
    set_interface:               'Null0',
    set_ipv4_next_hop_redist:    'true',
    set_ipv6_next_hop_redist:    'true',
    set_ipv4_next_hop_unchanged: 'true',
    set_ipv6_next_hop_unchanged: 'true',
  },
}

tests[:non_default_5] = {
  desc:           '2.5 Non Defaults 5',
  title_pattern:  'rm5 199 deny',
  manifest_props: {
    match_length: %w(45 345),
    set_vrf:      'igp',
  },
}

tests[:non_default_6] = {
  desc:           '2.6 Non Defaults 6',
  title_pattern:  'rm6 321 permit',
  manifest_props: {
    match_src_proto: %w(tcp udp igmp).sort
  },
}

# class to contain the test_dependencies specific to this test case
class TestRouteMap < BaseHarness
  def self.unsupp_n3k
    unprops = []
    unprops <<
      :match_evpn_route_type_1 <<
      :match_evpn_route_type_2_all <<
      :match_evpn_route_type_2_mac_ip <<
      :match_evpn_route_type_2_mac_only <<
      :match_evpn_route_type_3 <<
      :match_evpn_route_type_4 <<
      :match_evpn_route_type_5 <<
      :match_evpn_route_type_6 <<
      :match_evpn_route_type_all <<
      :match_length <<
      :match_mac_list <<
      :match_vlan <<
      :set_vrf
    unprops
  end

  def self.unsupp_n56k
    unprops = []
    unprops <<
      :match_ospf_area <<
      :set_ipv4_default_next_hop <<
      :set_ipv4_default_next_hop_load_share <<
      :set_ipv4_next_hop_load_share <<
      :set_ipv4_prefix <<
      :set_ipv6_default_next_hop <<
      :set_ipv6_default_next_hop_load_share <<
      :set_ipv6_next_hop_load_share <<
      :set_ipv6_prefix <<
      :set_vrf
    unprops
  end

  def self.unsupp_n7k
    unprops = []
    unprops <<
      :match_ospf_area
    unprops
  end

  def self.unsupp_n9k(ctx)
    im = ctx.nexus_image
    unprops = []
    unprops <<
      :match_evpn_route_type_1 <<
      :match_evpn_route_type_2_all <<
      :match_evpn_route_type_2_mac_ip <<
      :match_evpn_route_type_2_mac_only <<
      :match_evpn_route_type_3 <<
      :match_evpn_route_type_4 <<
      :match_evpn_route_type_5 <<
      :match_evpn_route_type_6 <<
      :match_evpn_route_type_all <<
      :match_length <<
      :match_mac_list <<
      :match_vlan <<
      :set_ipv4_default_next_hop <<
      :set_ipv4_default_next_hop_load_share <<
      :set_ipv6_default_next_hop <<
      :set_ipv6_default_next_hop_load_share <<
      :set_extcommunity_rt_asn <<
      :set_vrf
    unprops << :match_metric if im['I4']
    unprops
  end

  def self.unsupp_n9kf
    unprops = []
    unprops <<
      :match_evpn_route_type_1 <<
      :match_evpn_route_type_2_all <<
      :match_evpn_route_type_2_mac_ip <<
      :match_evpn_route_type_2_mac_only <<
      :match_evpn_route_type_3 <<
      :match_evpn_route_type_4 <<
      :match_evpn_route_type_5 <<
      :match_evpn_route_type_6 <<
      :match_evpn_route_type_all <<
      :match_length <<
      :match_mac_list <<
      :match_ospf_area <<
      :match_vlan <<
      :set_extcommunity_cost_igp <<
      :set_extcommunity_cost_pre_bestpath <<
      :set_extcommunity_rt_additive <<
      :set_extcommunity_rt_asn <<
      :set_forwarding_addr <<
      :set_ipv4_default_next_hop <<
      :set_ipv4_default_next_hop_load_share <<
      :set_ipv6_default_next_hop <<
      :set_ipv6_default_next_hop_load_share <<
      :set_ipv4_next_hop <<
      :set_ipv4_precedence <<
      :set_ipv4_prefix <<
      :set_ipv6_next_hop <<
      :set_ipv6_prefix <<
      :set_vrf
    unprops
  end

  def self.unsupported_properties(ctx, _tests, _id)
    if ctx.platform[/n3k$/]
      unsupp_n3k
    elsif ctx.platform[/n(5|6)k/]
      unsupp_n56k
    elsif ctx.platform[/n7k/]
      unsupp_n7k
    elsif ctx.platform[/n9k$|n9k-ex/]
      unsupp_n9k(ctx)
    elsif ctx.platform[/n(3|9)k-f/]
      unsupp_n9kf
    end
  end

  def self.version_unsupported_properties(ctx, _tests, _id)
    unprops = {}
    if ctx.platform[/n(3|9)k-f/]
      unprops[:match_metric] = '7.0.3.F2.1'
      unprops[:set_extcommunity_4bytes_additive] = '7.0.3.F2.1'
      unprops[:set_extcommunity_4bytes_non_transitive] = '7.0.3.F2.1'
      unprops[:set_extcommunity_4bytes_transitive] = '7.0.3.F2.1'
      unprops[:set_ipv4_next_hop_load_share] = '7.0.3.F2.1'
      unprops[:set_ipv6_next_hop_load_share] = '7.0.3.F2.1'
    elsif ctx.platform[/n9k/]
      unprops[:match_ospf_area] = '7.0.3.I5.1'
      unprops[:set_ipv4_next_hop_load_share] = '7.0.3.I5.1'
      unprops[:set_ipv6_next_hop_load_share] = '7.0.3.I5.1'
      unprops[:set_ipv4_next_hop_redist] = '7.0.3.I5.1'
      unprops[:set_ipv6_next_hop_redist] = '7.0.3.I5.1'
      unprops[:set_community] = '7.0.3.I5.1'
    elsif ctx.platform[/n3k/]
      unprops[:match_ospf_area] = '7.0.3.I5.1'
      unprops[:set_ipv4_next_hop_redist] = '7.0.3.I5.1'
      unprops[:set_ipv6_next_hop_redist] = '7.0.3.I5.1'
    end
    unprops
  end
end

def cleanup(agent)
  resource_absent_cleanup(agent, 'cisco_route_map')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, harness_class: TestRouteMap)

  id = :default
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestRouteMap)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default_1, harness_class: TestRouteMap)
  test_harness_run(tests, :non_default_2, harness_class: TestRouteMap)
  test_harness_run(tests, :non_default_3, harness_class: TestRouteMap)
  test_harness_run(tests, :non_default_4, harness_class: TestRouteMap)
  test_harness_run(tests, :non_default_5, harness_class: TestRouteMap)
  test_harness_run(tests, :non_default_6, harness_class: TestRouteMap)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
