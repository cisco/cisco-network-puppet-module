# Manages the Cisco route map configuration resource.
#
# June 2018
#
# Copyright (c) 2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_route_map) do
  @doc = "Manages a route map.

    cisco_route_map {\"<rmname> <sequence> <action>\":
      ..attributes..
    }

    <rmname> is the name of the route map.
    <sequence> is sequence to insert/delete existing route-map entry
    <action> is permit or deny.

    Examples:
    cisco_route_map {'MyRouteMap1 123 permit':
      ensure                                 => 'present',
      description                            => 'Testing',
      match_as_number                        => ['3', '22-34', '38'],
      match_as_number_as_path_list           => ['abc', 'xyz', 'pqr'],
      match_community                        => ['public', 'private'],
      match_community_exact_match            => true,
      match_evpn_route_type_1                => true,
      match_evpn_route_type_2_all            => true,
      match_evpn_route_type_2_mac_ip         => true,
      match_evpn_route_type_2_mac_only       => true,
      match_evpn_route_type_3                => true,
      match_evpn_route_type_4                => true,
      match_evpn_route_type_5                => true,
      match_evpn_route_type_6                => true,
      match_evpn_route_type_all              => true,
      match_ext_community                    => ['epublic', 'eprivate'],
      match_ext_community_exact_match        => true,
      match_interface                        => ['loopback2', 'mgmt0'],
      match_ipv4_addr_access_list            => 'access1',
      match_ipv4_addr_prefix_list            => ['p1', 'p7', 'pre5'],
      match_ipv4_multicast_enable            => true,
      match_ipv4_multicast_src_addr          => '242.1.1.1/32',
      match_ipv4_multicast_group_addr        => '239.2.2.2/32',
      match_ipv4_multicast_group_range_begin_addr => default,
      match_ipv4_multicast_group_range_end_addr => default,
      match_ipv4_multicast_rp_addr           => '242.1.1.1/32',
      match_ipv4_multicast_rp_type           => 'ASM',
      match_ipv4_next_hop_prefix_list        => ['nh5', 'nh1', 'nh42'],
      match_ipv4_route_src_prefix_list       => ['rs2', 'rs22', 'pre15'],
      match_ipv6_addr_access_list            => 'v6access',
      match_ipv6_addr_prefix_list            => ['pv6', 'pv67', 'prev6'],
      match_ipv6_multicast_enable            => true,
      match_ipv6_multicast_src_addr          => '2001::348:0:0/96',
      match_ipv6_multicast_group_addr        => 'ff0e::2:101:0:0/96',
      match_ipv6_multicast_group_range_begin_addr => default,
      match_ipv6_multicast_group_range_end_addr => default,
      match_ipv6_multicast_rp_addr           => '2001::348:0:0/96',
      match_ipv6_multicast_rp_type           => 'ASM',
      match_ipv6_next_hop_prefix_list        => ['nhv6', 'v6nh1', 'nhv42'],
      match_ipv6_route_src_prefix_list       => ['rsv6', 'rs22v6', 'prev6'],
      match_length                           => ['45', '345'],
      match_mac_list                         => ['mac1', 'listmac'],
      match_metric                           => [['8', '0'], ['224', '9']]
      match_ospf_area                        => ['10', '7', '222'],
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
      match_vlan                             => '32, 45-200, 300-399, 402',
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
      set_distance_igp_ebgp                  => 44,
      set_dampening_suppress                 => 44,
      set_dampening_suppress                 => 1,
      set_distance_internal                  => 2,
      set_distance_local                     => 3,
      set_extcomm_list                       => 'xyz',
      set_extcommunity_4bytes_additive       => true,
      set_extcommunity_4bytes_non_transitive => ['21:42', '43:22', '59:17'],
      set_extcommunity_4bytes_transitive     => ['11:22', '33:44', '66:77'],
      set_extcommunity_cost_igp              => [[0, 23], [3, 33]],
      set_extcommunity_cost_pre_bestpath     => [[23, 999], [88, 482]],
      set_extcommunity_rt_additive           => true,
      set_extcommunity_rt_asn                => ['11:22', '123.256:543'],
      set_forwarding_addr                    => true,
      set_interface                          => 'Null0',
      set_ipv4_default_next_hop              => ['1.1.1.1', '2.2.2.2'],
      set_ipv4_default_next_hop_load_share   => true,
      set_ipv4_next_hop                      => ['3.3.3.3', '4.4.4.4'],
      set_ipv4_next_hop_load_share           => true,
      set_ipv4_next_hop_peer_addr            => true,
      set_ipv4_next_hop_redist               => true,
      set_ipv4_next_hop_unchanged            => true,
      set_ipv4_precedence                    => 'critical',
      set_ipv4_prefix                        => 'abcdef',
      set_ipv6_default_next_hop              => ['2000::1', '2000::11'],
      set_ipv6_default_next_hop_load_share   => true,
      set_ipv6_next_hop                      => ['2000::1', '2000::11'],
      set_ipv6_next_hop_load_share           => true,
      set_ipv6_next_hop_peer_addr            => true,
      set_ipv6_next_hop_redist               => true,
      set_ipv6_next_hop_unchanged            => true,
      set_ipv6_precedence                    => 'network',
      set_ipv6_prefix                        => 'wxyz',
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
      set_vrf                                => 'igp',
      set_weight                             => 222,
    }
  "

  apply_to_all
  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+) (\d+) (\S+)$/,
      [
        [:rmname, identity],
        [:sequence, identity],
        [:action, identity],
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:rmname]} #{self[:sequence]} #{self[:action]}"
  end

  newparam(:name) do
    desc 'Name of cisco_route_map, not used, but needed for puppet'
  end

  newparam(:rmname, namevar: true) do
    desc 'Name of the route map instance. Valid values are string.'
  end # param rmname

  newparam(:sequence, namevar: true) do
    desc "Sequence to insert/delete existing route-map entry.
          Valid values are integer."
  end # param sequence

  newparam(:action, namevar: true) do
    desc 'Action for set oprtations. Valid values are permit or deny.'
    munge(&:to_s)
    newvalues(:permit, :deny)
  end # param action

  ##############
  # Attributes #
  ##############

  newproperty(:description) do
    desc "Description of the route-map. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property description

  newproperty(:match_as_number, array_matching: :all) do
    format = '[range1, range2]'
    desc 'Match BGP peer AS number. An array of [range1, range2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_as_number

  newproperty(:match_as_number_as_path_list, array_matching: :all) do
    format = '[list1, list2]'
    desc 'Match BGP AS path list. An array of [list1, list2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_as_number_as_path_list

  newproperty(:match_community, array_matching: :all) do
    format = '[comm1, comm2]'
    desc 'Match BGP community list. An array of [comm1, comm2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_community

  newproperty(:match_community_exact_match) do
    desc 'Enable exact matching of communities'

    newvalues(:true, :false, :default)
  end # property match_community_exact_match

  newproperty(:match_evpn_route_type_1) do
    desc 'Enable match BGP EVPN route type-1'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_1

  newproperty(:match_evpn_route_type_2_all) do
    desc 'Enable match all BGP EVPN route in type-2'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_2_all

  newproperty(:match_evpn_route_type_2_mac_ip) do
    desc 'Enable match mac-ip BGP EVPN route in type-2'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_2_mac_ip

  newproperty(:match_evpn_route_type_2_mac_only) do
    desc 'Enable match mac-only BGP EVPN route in type-2'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_2_mac_only

  newproperty(:match_evpn_route_type_3) do
    desc 'Enable match BGP EVPN route type-3'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_3

  newproperty(:match_evpn_route_type_4) do
    desc 'Enable match BGP EVPN route type-4'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_4

  newproperty(:match_evpn_route_type_5) do
    desc 'Enable match BGP EVPN route type-5'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_5

  newproperty(:match_evpn_route_type_6) do
    desc 'Enable match BGP EVPN route type-6'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_6

  newproperty(:match_evpn_route_type_all) do
    desc 'Enable match BGP EVPN route type 1-6'

    newvalues(:true, :false, :default)
  end # property match_evpn_route_type_all

  newproperty(:match_ext_community, array_matching: :all) do
    format = '[ecomm1, ecomm2]'
    desc 'Match BGP extended community list. An array of [ecomm1, ecomm2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ext_community

  newproperty(:match_ext_community_exact_match) do
    desc 'Enable exact matching of extended communities'

    newvalues(:true, :false, :default)
  end # property match_ext_community_exact_match

  newproperty(:match_interface, array_matching: :all) do
    format = '[int1, int2]'
    desc 'Match first hop interface of route. An array of [int1, int2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_interface

  newproperty(:match_ipv4_addr_access_list) do
    desc "IPv4 access-list name. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv4_addr_access_list

  newproperty(:match_ipv4_addr_prefix_list, array_matching: :all) do
    format = '[pf1, pf2]'
    desc 'Match entries of prefix-lists for IPv4. An array of [pf1, pf2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ipv4_addr_prefix_list

  newproperty(:match_ipv4_multicast_enable) do
    desc 'Enable match IPv4 multicast'

    newvalues(:true, :false, :default)
  end # property match_ipv4_multicast_enable

  newproperty(:match_ipv4_multicast_group_addr) do
    desc "Match IPv4 multicast group prefix. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv4_multicast_group_addr

  newproperty(:match_ipv4_multicast_group_range_begin_addr) do
    desc "Match IPv4 multicast group address begin range.
          Valid values are string, keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv4_multicast_group_range_begin_addr

  newproperty(:match_ipv4_multicast_group_range_end_addr) do
    desc "Match IPv4 multicast group address end range.
          Valid values are string, keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv4_multicast_group_range_end_addr

  newproperty(:match_ipv4_multicast_rp_addr) do
    desc "Match IPv4 multicast rendezvous prefix. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv4_multicast_rp_addr

  newproperty(:match_ipv4_multicast_rp_type) do
    desc 'Match IPv4 multicast rendezvous point type'

    newvalues(:ASM, :Bidir, :default)
  end # property match_ipv4_multicast_rp_type

  newproperty(:match_ipv4_multicast_src_addr) do
    desc "Match IPv4 multicast source prefix. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv4_multicast_src_addr

  newproperty(:match_ipv4_next_hop_prefix_list, array_matching: :all) do
    format = '[pf1, pf2]'
    desc 'Match entries of prefix-lists for next-hop address of route for IPv4. An array of [pf1, pf2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ipv4_next_hop_prefix_list

  newproperty(:match_ipv4_route_src_prefix_list, array_matching: :all) do
    format = '[pf1, pf2]'
    desc 'Match entries of prefix-lists for advertising source address of route for IPv4. An array of [pf1, pf2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ipv4_route_src_prefix_list

  newproperty(:match_ipv6_addr_access_list) do
    desc "IPv6 access-list name. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv6_addr_access_list

  newproperty(:match_ipv6_addr_prefix_list, array_matching: :all) do
    format = '[pf1, pf2]'
    desc 'Match entries of prefix-lists for IPv6. An array of [pf1, pf2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ipv6_addr_prefix_list

  newproperty(:match_ipv6_multicast_enable) do
    desc 'Enable match IPv6 multicast'

    newvalues(:true, :false, :default)
  end # property match_ipv6_multicast_enable

  newproperty(:match_ipv6_multicast_group_addr) do
    desc "Match IPv6 multicast group prefix. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv6_multicast_group_addr

  newproperty(:match_ipv6_multicast_group_range_begin_addr) do
    desc "Match IPv6 multicast group address begin range.
          Valid values are string, keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv6_multicast_group_range_begin_addr

  newproperty(:match_ipv6_multicast_group_range_end_addr) do
    desc "Match IPv6 multicast group address end range.
          Valid values are string, keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv6_multicast_group_range_end_addr

  newproperty(:match_ipv6_multicast_rp_addr) do
    desc "Match IPv6 multicast rendezvous prefix. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv6_multicast_rp_addr

  newproperty(:match_ipv6_multicast_rp_type) do
    desc 'Match IPv6 multicast rendezvous point type'

    newvalues(:ASM, :Bidir, :default)
  end # property match_ipv6_multicast_rp_type

  newproperty(:match_ipv6_multicast_src_addr) do
    desc "Match IPv6 multicast source prefix. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property match_ipv6_multicast_src_addr

  newproperty(:match_ipv6_next_hop_prefix_list, array_matching: :all) do
    format = '[pf1, pf2]'
    desc 'Match entries of prefix-lists for next-hop address of route for IPv6. An array of [pf1, pf2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ipv6_next_hop_prefix_list

  newproperty(:match_ipv6_route_src_prefix_list, array_matching: :all) do
    format = '[pf1, pf2]'
    desc 'Match entries of prefix-lists for advertising source address of route for IPv6. An array of [pf1, pf2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ipv6_route_src_prefix_list

  newproperty(:match_length, array_matching: :all) do
    format = '[minlen, maxlen]'
    desc 'Match packet length. An array of [minlen, maxlen]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_length

  newproperty(:match_mac_list, array_matching: :all) do
    format = '[list1, list2]'
    desc 'Match entries of mac-lists. An array of [list1, list2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_mac_list

  newproperty(:match_metric, array_matching: :all) do
    format = '[[metric, deviation], [met, dev]]'
    desc 'An array of [metric, deviation] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property match_metric

  newproperty(:match_ospf_area, array_matching: :all) do
    format = '[area1, area2]'
    desc 'Match entries of ospf area IDs. An array of [area1, area2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_ospf_area

  newproperty(:match_route_type_external) do
    desc 'Enable match external route type (BGP, EIGRP and OSPF type 1/2)'

    newvalues(:true, :false, :default)
  end # property match_route_type_external

  newproperty(:match_route_type_inter_area) do
    desc 'Enable match OSPF inter area type'

    newvalues(:true, :false, :default)
  end # property match_route_type_inter_area

  newproperty(:match_route_type_internal) do
    desc 'Enable match OSPF inter area type (OSPF intra/inter area)'

    newvalues(:true, :false, :default)
  end # property match_route_type_internal

  newproperty(:match_route_type_intra_area) do
    desc 'Enable match OSPF intra area route'

    newvalues(:true, :false, :default)
  end # property match_route_type_intra_area

  newproperty(:match_route_type_level_1) do
    desc 'Enable match IS-IS level-1 route'

    newvalues(:true, :false, :default)
  end # property match_route_type_level_1

  newproperty(:match_route_type_level_2) do
    desc 'Enable match IS-IS level-2 route'

    newvalues(:true, :false, :default)
  end # property match_route_type_level_2

  newproperty(:match_route_type_local) do
    desc 'Enable match locally generated route'

    newvalues(:true, :false, :default)
  end # property match_route_type_local

  newproperty(:match_route_type_nssa_external) do
    desc 'Enable match nssa-external route (OSPF type 1/2)'

    newvalues(:true, :false, :default)
  end # property match_route_type_nssa_external

  newproperty(:match_route_type_type_1) do
    desc 'Enable match OSPF external type 1 route'

    newvalues(:true, :false, :default)
  end # property match_route_type_type_1

  newproperty(:match_route_type_type_2) do
    desc 'Enable match OSPF external type 2 route'

    newvalues(:true, :false, :default)
  end # property match_route_type_type_2

  newproperty(:match_src_proto, array_matching: :all) do
    format = '[pr1, pr2]'
    desc 'Match source protocol. An array of [pr1, pr2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_src_proto

  newproperty(:match_tag, array_matching: :all) do
    format = '[tag1, tag2]'
    desc 'Match tag of route. An array of [tag1, tag2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property match_tag

  newproperty(:match_vlan) do
    desc "Match Vlan ID. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = value == 'default' ? :default : PuppetX::Cisco::Utils.range_summarize(value)
      value = value.gsub(',', ', ') unless value == :default
      value
    end
  end # property match_vlan

  newproperty(:set_as_path_prepend, array_matching: :all) do
    format = '[asn1, asn2]'
    desc 'Prepend string for a BGP AS-path attribute. An array of [asn1, asn2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_as_path_prepend

  newproperty(:set_as_path_prepend_last_as) do
    desc "Number of last-AS prepends. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_as_path_prepend_last_as

  newproperty(:set_as_path_tag) do
    desc 'Set the tag as an AS-path attribute'

    newvalues(:true, :false, :default)
  end # property set_as_path_tag

  newproperty(:set_comm_list) do
    desc "Set BGP community list (for deletion). Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property set_comm_list

  newproperty(:set_community_additive) do
    desc 'Add to existing BGP community'

    newvalues(:true, :false, :default)
  end # property set_community_additive

  newproperty(:set_community_asn, array_matching: :all) do
    format = '[asn1, asn2]'
    desc 'Set community number. An array of [asn1, asn2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_community_asn

  newproperty(:set_community_internet) do
    desc 'Set Internet community'

    newvalues(:true, :false, :default)
  end # property set_community_internet

  newproperty(:set_community_local_as) do
    desc 'Do not send outside local AS'

    newvalues(:true, :false, :default)
  end # property set_community_local_as

  newproperty(:set_community_no_advtertise) do
    desc 'Do not advertise to any peer'

    newvalues(:true, :false, :default)
  end # property set_community_no_advtertise

  newproperty(:set_community_no_export) do
    desc 'Do not export to next AS'

    newvalues(:true, :false, :default)
  end # property set_community_no_export

  newproperty(:set_community_none) do
    desc 'Set no community attribute'

    newvalues(:true, :false, :default)
  end # property set_community_none

  newproperty(:set_dampening_half_life) do
    desc "Set half-life time for the penalty of BGP route flap dampening.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_dampening_half_life

  newproperty(:set_dampening_max_duation) do
    desc "Set maximum duration to suppress a stable route of BGP route
          flap dampening. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_dampening_max_duation

  newproperty(:set_dampening_reuse) do
    desc "Set penalty to start reusing a route of BGP route flap dampening.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_dampening_reuse

  newproperty(:set_dampening_suppress) do
    desc "Set penalty to start suppressing a route of BGP route
          flap dampening. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_dampening_suppress

  newproperty(:set_distance_igp_ebgp) do
    desc "Set administrative distance for IGP or EBGP routes.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_distance_igp_ebgp

  newproperty(:set_distance_internal) do
    desc "Set administrative distance for internal routes.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_distance_internal

  newproperty(:set_distance_local) do
    desc "Set administrative distance for local routes.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_distance_local

  newproperty(:set_extcomm_list) do
    desc "Set BGP extended community list (for deletion). Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property set_extcomm_list

  newproperty(:set_extcommunity_4bytes_additive) do
    desc 'Add to existing generic extcommunity'

    newvalues(:true, :false, :default)
  end # property set_extcommunity_4bytes_additive

  newproperty(:set_extcommunity_4bytes_non_transitive, array_matching: :all) do
    format = '[nt1, nt2]'
    desc 'Set non-transitive extended community. An array of [nt1, nt2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_extcommunity_4bytes_non_transitive

  newproperty(:set_extcommunity_4bytes_none) do
    desc 'Set no extcommunity generic attribute'

    newvalues(:true, :false, :default)
  end # property set_extcommunity_4bytes_none

  newproperty(:set_extcommunity_4bytes_transitive, array_matching: :all) do
    format = '[tr1, tr2]'
    desc 'Set transitive extended community. An array of [tr1, tr2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_extcommunity_4bytes_transitive

  newproperty(:set_extcommunity_cost_igp, array_matching: :all) do
    format = '[[communityId, cost], [cid, co]]'
    desc 'An array of [communityId, cost] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property set_extcommunity_cost_igp

  newproperty(:set_extcommunity_cost_pre_bestpath, array_matching: :all) do
    format = '[[communityId, cost], [cid, co]]'
    desc 'An array of [communityId, cost] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property set_extcommunity_cost_pre_bestpath

  newproperty(:set_extcommunity_rt_additive) do
    desc 'Set add to existing route target extcommunity'

    newvalues(:true, :false, :default)
  end # property set_extcommunity_rt_additive

  newproperty(:set_extcommunity_rt_asn, array_matching: :all) do
    format = '[asn1, asn2]'
    desc 'Set community number. An array of [asn1, asn2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_extcommunity_rt_asn

  newproperty(:set_forwarding_addr) do
    desc 'Set the forwarding address'

    newvalues(:true, :false, :default)
  end # property set_forwarding_addr

  newproperty(:set_interface) do
    desc 'Set output interface'

    newvalues(:Null0, :default)
  end # property set_interface

  newproperty(:set_ipv4_default_next_hop, array_matching: :all) do
    format = '[dnh1, dnh2]'
    desc 'Set default next-hop IPv4 address. An array of [dnh1, dnh2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_ipv4_default_next_hop

  newproperty(:set_ipv4_default_next_hop_load_share) do
    desc 'Enable default IPv4 next-hop load-sharing'

    newvalues(:true, :false, :default)
  end # property set_ipv4_default_next_hop_load_share

  newproperty(:set_ipv4_next_hop, array_matching: :all) do
    format = '[nh1, nh2]'
    desc 'Set default next-hop ip address. An array of [nh1, nh2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_ipv4_next_hop

  newproperty(:set_ipv4_next_hop_load_share) do
    desc 'Enable IPv4 next-hop load-sharing'

    newvalues(:true, :false, :default)
  end # property set_ipv4_next_hop_load_share

  newproperty(:set_ipv4_next_hop_peer_addr) do
    desc 'Enable IPv4 next-hop peer address'

    newvalues(:true, :false, :default)
  end # property set_ipv4_next_hop_peer_addr

  newproperty(:set_ipv4_next_hop_redist) do
    desc 'Enable IPv4 next-hop unchanged address during redistribution'

    newvalues(:true, :false, :default)
  end # property set_ipv4_next_hop_redist

  newproperty(:set_ipv4_next_hop_unchanged) do
    desc 'Enable IPv4 next-hop unchanged address'

    newvalues(:true, :false, :default)
  end # property set_ipv4_next_hop_unchanged

  newproperty(:set_ipv4_precedence) do
    desc 'Set precedence field'

    newvalues(:critical, :flash, :'flash-override', :immediate,
              :internet, :network, :priority, :routine, :default)
  end # property set_ipv4_precedence

  newproperty(:set_ipv4_prefix) do
    desc "Set IPv4 prefix-list. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property set_ipv4_prefix

  newproperty(:set_ipv6_default_next_hop, array_matching: :all) do
    format = '[nh1, nh2]'
    desc 'Set default next-hop IPv6 address. An array of [nh1, nh2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_ipv6_default_next_hop

  newproperty(:set_ipv6_default_next_hop_load_share) do
    desc 'Enable default IPv6 next-hop load-sharing'

    newvalues(:true, :false, :default)
  end # property set_ipv6_default_next_hop_load_share

  newproperty(:set_ipv6_next_hop, array_matching: :all) do
    format = '[dnh1, dnh2]'
    desc 'Set default next-hop ip address. An array of [dnh1, dnh2 and so on]' \
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property set_ipv6_next_hop

  newproperty(:set_ipv6_next_hop_load_share) do
    desc 'Enable IPv6 next-hop load-sharing'

    newvalues(:true, :false, :default)
  end # property set_ipv6_next_hop_load_share

  newproperty(:set_ipv6_next_hop_peer_addr) do
    desc 'Enable IPv6 next-hop peer address'

    newvalues(:true, :false, :default)
  end # property set_ipv6_next_hop_peer_addr

  newproperty(:set_ipv6_next_hop_redist) do
    desc 'Enable IPv6 next-hop unchanged address during redistribution'

    newvalues(:true, :false, :default)
  end # property set_ipv6_next_hop_redist

  newproperty(:set_ipv6_next_hop_unchanged) do
    desc 'Enable IPv6 next-hop unchanged address'

    newvalues(:true, :false, :default)
  end # property set_ipv6_next_hop_unchanged

  newproperty(:set_ipv6_precedence) do
    desc 'Set precedence field'

    newvalues(:critical, :flash, :'flash-override', :immediate,
              :internet, :network, :priority, :routine, :default)
  end # property set_ipv6_precedence

  newproperty(:set_ipv6_prefix) do
    desc "Set IPv6 prefix-list. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property set_ipv6_prefix

  newproperty(:set_level) do
    desc 'Set where to import route'

    newvalues(:'level-1', :'level-1-2', :'level-2', :default)
  end # property set_level

  newproperty(:set_local_preference) do
    desc "Set BGP local preference path attribute.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_local_preference

  newproperty(:set_metric_additive) do
    desc 'Set add to metric'

    newvalues(:true, :false, :default)
  end # property set_metric_additive

  newproperty(:set_metric_bandwidth) do
    desc "Set metric value or Bandwidth in kbps.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_metric_bandwidth

  newproperty(:set_metric_delay) do
    desc "Set IGRP delay metric.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_metric_delay

  newproperty(:set_metric_effective_bandwidth) do
    desc "Set IGRP Effective bandwidth metric.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_metric_effective_bandwidth

  newproperty(:set_metric_mtu) do
    desc "Set IGRP MTU of the path.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_metric_mtu

  newproperty(:set_metric_reliability) do
    desc "Set IGRP reliability metric.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_metric_reliability

  newproperty(:set_metric_type) do
    desc 'Set type of metric for destination routing protocol'

    newvalues(:external, :internal, :'type-1', :'type-2', :default)
  end # property set_metric_type

  newproperty(:set_nssa_only) do
    desc 'Set OSPF NSSA Areas'

    newvalues(:true, :false, :default)
  end # property set_nssa_only

  newproperty(:set_origin) do
    desc 'Set BGP origin code'

    newvalues(:egp, :igp, :incomplete, :default)
  end # property set_origin

  newproperty(:set_path_selection) do
    desc 'Set path selection criteria for BGP'

    newvalues(:true, :false, :default)
  end # property set_path_selection

  newproperty(:set_tag) do
    desc "Set tag value for destination routing protocol.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_tag

  newproperty(:set_vrf) do
    desc "Set the VRF for next-hop resolution. Valid values are string,
          keyword 'default'"

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property set_vrf

  newproperty(:set_weight) do
    desc "Set BGP weight for routing table.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property set_weight

  def cmprop(prop)
    self[prop].nil? || self[prop].empty? || self[prop] == :default
  end

  def check_match_ipv4_multicast
    return if cmprop(:match_ipv4_multicast_enable)
    fail ArgumentError, 'At least one of the ipv4 multicast properties MUST be non default' if
      cmprop(:match_ipv4_multicast_src_addr) &&
      cmprop(:match_ipv4_multicast_group_addr) &&
      cmprop(:match_ipv4_multicast_rp_addr) &&
      cmprop(:match_ipv4_multicast_group_range_begin_addr) &&
      cmprop(:match_ipv4_multicast_group_range_end_addr)
  end

  def check_match_ipv6_multicast
    return if cmprop(:match_ipv6_multicast_enable)
    fail ArgumentError, 'At least one of the ipv6 multicast properties MUST be non default' if
      cmprop(:match_ipv6_multicast_src_addr) &&
      cmprop(:match_ipv6_multicast_group_addr) &&
      cmprop(:match_ipv6_multicast_rp_addr) &&
      cmprop(:match_ipv6_multicast_group_range_begin_addr) &&
      cmprop(:match_ipv6_multicast_group_range_end_addr)
  end

  validate do
    check_match_ipv4_multicast
    check_match_ipv6_multicast
  end
end
