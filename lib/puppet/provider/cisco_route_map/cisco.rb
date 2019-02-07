# January, 2017
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

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?
begin
  require 'puppet_x/cisco/autogen'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end
Puppet::Type.type(:cisco_route_map).provide(:cisco) do
  desc 'The Cisco route map provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  ROUTE_MAP_NON_BOOL_PROPS = [
    :description,
    :match_ipv4_addr_access_list,
    :match_ipv4_multicast_group_addr,
    :match_ipv4_multicast_group_range_begin_addr,
    :match_ipv4_multicast_group_range_end_addr,
    :match_ipv4_multicast_rp_addr,
    :match_ipv4_multicast_rp_type,
    :match_ipv4_multicast_src_addr,
    :match_ipv6_addr_access_list,
    :match_ipv6_multicast_group_addr,
    :match_ipv6_multicast_group_range_begin_addr,
    :match_ipv6_multicast_group_range_end_addr,
    :match_ipv6_multicast_rp_addr,
    :match_ipv6_multicast_rp_type,
    :match_ipv6_multicast_src_addr,
    :match_vlan,
    :set_as_path_prepend_last_as,
    :set_comm_list,
    :set_dampening_half_life,
    :set_dampening_max_duation,
    :set_dampening_reuse,
    :set_dampening_suppress,
    :set_distance_igp_ebgp,
    :set_distance_internal,
    :set_distance_local,
    :set_extcomm_list,
    :set_interface,
    :set_ipv4_precedence,
    :set_ipv4_prefix,
    :set_ipv6_precedence,
    :set_ipv6_prefix,
    :set_level,
    :set_local_preference,
    :set_metric_bandwidth,
    :set_metric_delay,
    :set_metric_reliability,
    :set_metric_effective_bandwidth,
    :set_metric_mtu,
    :set_metric_type,
    :set_origin,
    :set_tag,
    :set_vrf,
    :set_weight,
  ]

  ROUTE_MAP_BOOL_PROPS = [
    :match_community_exact_match,
    :match_evpn_route_type_1,
    :match_evpn_route_type_2_all,
    :match_evpn_route_type_2_mac_ip,
    :match_evpn_route_type_2_mac_only,
    :match_evpn_route_type_3,
    :match_evpn_route_type_4,
    :match_evpn_route_type_5,
    :match_evpn_route_type_6,
    :match_evpn_route_type_all,
    :match_ext_community_exact_match,
    :match_ipv4_multicast_enable,
    :match_ipv6_multicast_enable,
    :match_route_type_external,
    :match_route_type_inter_area,
    :match_route_type_internal,
    :match_route_type_intra_area,
    :match_route_type_level_1,
    :match_route_type_level_2,
    :match_route_type_local,
    :match_route_type_nssa_external,
    :match_route_type_type_1,
    :match_route_type_type_2,
    :set_as_path_tag,
    :set_community_additive,
    :set_community_internet,
    :set_community_local_as,
    :set_community_no_advtertise,
    :set_community_no_export,
    :set_community_none,
    :set_extcommunity_4bytes_additive,
    :set_extcommunity_4bytes_none,
    :set_extcommunity_rt_additive,
    :set_forwarding_addr,
    :set_ipv4_default_next_hop_load_share,
    :set_ipv4_next_hop_load_share,
    :set_ipv4_next_hop_peer_addr,
    :set_ipv4_next_hop_redist,
    :set_ipv4_next_hop_unchanged,
    :set_ipv6_default_next_hop_load_share,
    :set_ipv6_next_hop_load_share,
    :set_ipv6_next_hop_peer_addr,
    :set_ipv6_next_hop_redist,
    :set_ipv6_next_hop_unchanged,
    :set_metric_additive,
    :set_nssa_only,
    :set_path_selection,
  ]

  ROUTE_MAP_ARRAY_FLAT_PROPS = [
    :match_as_number,
    :match_as_number_as_path_list,
    :match_community,
    :match_ext_community,
    :match_interface,
    :match_ipv4_addr_prefix_list,
    :match_ipv4_next_hop_prefix_list,
    :match_ipv4_route_src_prefix_list,
    :match_ipv6_addr_prefix_list,
    :match_ipv6_next_hop_prefix_list,
    :match_ipv6_route_src_prefix_list,
    :match_length,
    :match_mac_list,
    :match_ospf_area,
    :match_src_proto,
    :match_tag,
    :set_as_path_prepend,
    :set_community_asn,
    :set_extcommunity_4bytes_non_transitive,
    :set_extcommunity_4bytes_transitive,
    :set_extcommunity_rt_asn,
    :set_ipv4_default_next_hop,
    :set_ipv4_next_hop,
    :set_ipv6_default_next_hop,
    :set_ipv6_next_hop,
  ]

  ROUTE_MAP_ARRAY_NESTED_PROPS = [
    :match_metric,
    :set_extcommunity_cost_igp,
    :set_extcommunity_cost_pre_bestpath,
  ]

  ROUTE_MAP_ALL_PROPS =  ROUTE_MAP_NON_BOOL_PROPS +
                         ROUTE_MAP_ARRAY_FLAT_PROPS +
                         ROUTE_MAP_ARRAY_NESTED_PROPS +
                         ROUTE_MAP_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            ROUTE_MAP_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            ROUTE_MAP_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            ROUTE_MAP_ARRAY_FLAT_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_nested, self, '@nu',
                                            ROUTE_MAP_ARRAY_NESTED_PROPS)

  def initialize(value={})
    super(value)
    rmname = @property_hash[:rmname]
    sequence = @property_hash[:sequence]
    action = @property_hash[:action]
    @nu = Cisco::RouteMap.maps[rmname][sequence][action] unless
      rmname.nil? || sequence.nil? || action.nil?
    @property_flush = {}
  end

  def self.properties_get(rmname, sequence, action, nu_obj)
    debug "Checking route map instance, #{rmname} #{sequence} #{action}"
    current_state = {
      name:     "#{rmname} #{sequence} #{action}",
      rmname:   rmname,
      sequence: sequence,
      action:   action,
      ensure:   :present,
    }

    # Call node_utils getter for each property
    (ROUTE_MAP_NON_BOOL_PROPS).each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    ROUTE_MAP_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    ROUTE_MAP_ARRAY_NESTED_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    ROUTE_MAP_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    rm_instances = []
    Cisco::RouteMap.maps.each do |rmname, sequences|
      sequences.each do |sequence, actions|
        actions.each do |action, nu_obj|
          rm_instances << properties_get(rmname, sequence, action, nu_obj)
        end
      end
    end
    rm_instances
  end # self.instances

  def self.prefetch(resources)
    rm_instances = instances
    resources.keys.each do |id|
      provider = rm_instances.find do |rmi|
        rmi.rmname.to_s == resources[id][:rmname].to_s &&
        rmi.sequence.to_s == resources[id][:sequence].to_s &&
        rmi.action.to_s == resources[id][:action].to_s
      end
      resources[id].provider = provider unless provider.nil?
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def properties_set(new_rm=false)
    ROUTE_MAP_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_rm
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    match_community_set
    match_ext_community_set
    match_ipv4_multicast_set
    match_ipv6_multicast_set
    match_ip_addr_access_list_set
    match_ip_addr_prefix_list_set
    match_route_type_set
    set_dampening_set
    set_distance_set
    set_community_set
    set_extcommunity_4bytes_set
    set_extcommunity_rt_set
    set_extcommunity_cost_set
    set_ip_next_hop_set
    set_ip_precedence_set
    set_metric_set
  end

  def match_ip_addr_access_list_set
    pf = @property_flush[:match_ipv4_addr_access_list]
    v4 = pf.nil? ? @nu.match_ipv4_addr_access_list : pf
    pf = @property_flush[:match_ipv6_addr_access_list]
    v6 = pf.nil? ? @nu.match_ipv6_addr_access_list : pf
    @nu.match_ip_addr_access_list(v4, v6)
  end

  def match_ip_addr_prefix_list_set
    pf = @property_flush[:match_ipv4_addr_prefix_list]
    v4 = pf.nil? ? @nu.match_ipv4_addr_prefix_list : pf
    pf = @property_flush[:match_ipv6_addr_prefix_list]
    v6 = pf.nil? ? @nu.match_ipv6_addr_prefix_list : pf
    @nu.match_ip_addr_prefix_list(v4, v6)
  end

  def match_community_set
    comm = @property_flush[:match_community] ? @property_flush[:match_community] : @nu.match_community
    pf = @property_flush[:match_community_exact_match]
    exact = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.match_community_exact_match
    @nu.match_community_set(comm, exact)
  end

  def match_ext_community_set
    comm = @property_flush[:match_ext_community] ? @property_flush[:match_ext_community] : @nu.match_ext_community
    pf = @property_flush[:match_ext_community_exact_match]
    exact = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.match_ext_community_exact_match
    @nu.match_ext_community_set(comm, exact)
  end

  def match_set_helper(properties, setter)
    return unless properties.any? { |p| @property_flush.key?(p) }
    attrs = {}
    # At least one var has changed, get all vals from manifest
    properties.each do |p|
      if @resource[p] == :default
        attrs[p] = @nu.send("default_#{p}")
      else
        attrs[p] = @resource[p]
        attrs[p] = PuppetX::Cisco::Utils.bool_sym_to_s(attrs[p])
      end
    end
    @nu.send(setter, *[attrs])
  end

  def match_ipv4_multicast_set
    properties = [
      :match_ipv4_multicast_src_addr,
      :match_ipv4_multicast_group_addr,
      :match_ipv4_multicast_group_range_begin_addr,
      :match_ipv4_multicast_group_range_end_addr,
      :match_ipv4_multicast_rp_addr,
      :match_ipv4_multicast_rp_type,
      :match_ipv4_multicast_enable,
    ]
    match_set_helper(properties, 'match_ipv4_multicast_set')
  end

  def match_ipv6_multicast_set
    properties = [
      :match_ipv6_multicast_src_addr,
      :match_ipv6_multicast_group_addr,
      :match_ipv6_multicast_group_range_begin_addr,
      :match_ipv6_multicast_group_range_end_addr,
      :match_ipv6_multicast_rp_addr,
      :match_ipv6_multicast_rp_type,
      :match_ipv6_multicast_enable,
    ]
    match_set_helper(properties, 'match_ipv6_multicast_set')
  end

  def match_route_type_set
    properties = [
      :match_route_type_external,
      :match_route_type_inter_area,
      :match_route_type_internal,
      :match_route_type_intra_area,
      :match_route_type_level_1,
      :match_route_type_level_2,
      :match_route_type_local,
      :match_route_type_nssa_external,
      :match_route_type_type_1,
      :match_route_type_type_2,
    ]
    match_set_helper(properties, 'match_route_type_set')
  end

  def set_ip_precedence_set
    pf = @property_flush[:set_ipv4_precedence]
    v4 = pf.nil? ? @nu.set_ipv4_precedence : pf
    pf = @property_flush[:set_ipv6_precedence]
    v6 = pf.nil? ? @nu.set_ipv6_precedence : pf
    @nu.set_ip_precedence(v4, v6)
  end

  def set_metric_set
    pf = @property_flush[:set_metric_additive]
    plus = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_metric_additive
    bw = @property_flush[:set_metric_bandwidth].nil? ? @nu.set_metric_bandwidth : @property_flush[:set_metric_bandwidth]
    del = @property_flush[:set_metric_delay].nil? ? @nu.set_metric_delay : @property_flush[:set_metric_delay]
    rel = @property_flush[:set_metric_reliability].nil? ? @nu.set_metric_reliability : @property_flush[:set_metric_reliability]
    pf = @property_flush[:set_metric_effective_bandwidth]
    ebw = pf.nil? ? @nu.set_metric_effective_bandwidth : pf
    mtu = @property_flush[:set_metric_mtu].nil? ? @nu.set_metric_mtu : @property_flush[:set_metric_mtu]
    @nu.set_metric_set(plus, bw, del, rel, ebw, mtu)
  end

  def set_dampening_set
    hl = @property_flush[:set_dampening_half_life].nil? ? @nu.set_dampening_half_life : @property_flush[:set_dampening_half_life]
    md = @property_flush[:set_dampening_max_duation].nil? ? @nu.set_dampening_max_duation : @property_flush[:set_dampening_max_duation]
    re = @property_flush[:set_dampening_reuse].nil? ? @nu.set_dampening_reuse : @property_flush[:set_dampening_reuse]
    sup = @property_flush[:set_dampening_suppress].nil? ? @nu.set_dampening_suppress : @property_flush[:set_dampening_suppress]
    @nu.set_dampening_set(hl, re, sup, md)
  end

  def set_distance_set
    igp = @property_flush[:set_distance_igp_ebgp].nil? ? @nu.set_distance_igp_ebgp : @property_flush[:set_distance_igp_ebgp]
    int = @property_flush[:set_distance_internal].nil? ? @nu.set_distance_internal : @property_flush[:set_distance_internal]
    loc = @property_flush[:set_distance_local].nil? ? @nu.set_distance_local : @property_flush[:set_distance_local]
    @nu.set_distance_set(igp, int, loc)
  end

  def set_ipv4_default_next_hop_set
    nh = @property_flush[:set_ipv4_default_next_hop] ? @property_flush[:set_ipv4_default_next_hop] : @nu.set_ipv4_default_next_hop
    pf = @property_flush[:set_ipv4_default_next_hop_load_share]
    ls = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_default_next_hop_load_share
    @nu.set_ipv4_default_next_hop_set(nh, ls)
  end

  def set_ipv4_next_hop_set
    nh = @property_flush[:set_ipv4_next_hop] ? @property_flush[:set_ipv4_next_hop] : @nu.set_ipv4_next_hop
    pf = @property_flush[:set_ipv4_next_hop_load_share]
    ls = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_next_hop_load_share
    @nu.set_ipv4_next_hop_set(nh, ls)
  end

  def set_ipv6_default_next_hop_set
    nh = @property_flush[:set_ipv6_default_next_hop] ? @property_flush[:set_ipv6_default_next_hop] : @nu.set_ipv6_default_next_hop
    pf = @property_flush[:set_ipv6_default_next_hop_load_share]
    ls = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_default_next_hop_load_share
    @nu.set_ipv6_default_next_hop_set(nh, ls)
  end

  def set_ipv6_next_hop_set
    nh = @property_flush[:set_ipv6_next_hop] ? @property_flush[:set_ipv6_next_hop] : @nu.set_ipv6_next_hop
    pf = @property_flush[:set_ipv6_next_hop_load_share]
    ls = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_next_hop_load_share
    @nu.set_ipv6_next_hop_set(nh, ls)
  end

  def set_community_set
    pf = @property_flush[:set_community_none]
    none = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_community_none
    pf = @property_flush[:set_community_no_advtertise]
    noadv = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_community_no_advtertise
    pf = @property_flush[:set_community_no_export]
    noexp = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_community_no_export
    pf = @property_flush[:set_community_additive]
    add = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_community_additive
    pf = @property_flush[:set_community_local_as]
    local = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_community_local_as
    pf = @property_flush[:set_community_internet]
    inter = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_community_internet
    asn = @property_flush[:set_community_asn] ? @property_flush[:set_community_asn] : @nu.set_community_asn
    @nu.set_community_set(none, noadv, noexp, add, local, inter, asn)
  end

  def set_extcommunity_4bytes_set
    pf = @property_flush[:set_extcommunity_4bytes_none]
    none = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_extcommunity_4bytes_none
    pf = @property_flush[:set_extcommunity_4bytes_transitive]
    tr = pf ? pf : @nu.set_extcommunity_4bytes_transitive
    pf = @property_flush[:set_extcommunity_4bytes_non_transitive]
    ntr = pf ? pf : @nu.set_extcommunity_4bytes_non_transitive
    pf = @property_flush[:set_extcommunity_4bytes_additive]
    add = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_extcommunity_4bytes_additive
    @nu.set_extcommunity_4bytes_set(none, tr, ntr, add)
  end

  def set_extcommunity_rt_set
    pf = @property_flush[:set_extcommunity_rt_asn]
    asn = pf ? pf : @nu.set_extcommunity_rt_asn
    pf = @property_flush[:set_extcommunity_rt_additive]
    add = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_extcommunity_rt_additive
    @nu.set_extcommunity_rt_set(asn, add)
  end

  def set_extcommunity_cost_set
    pf = @property_flush[:set_extcommunity_cost_igp]
    igp = pf ? pf : @nu.set_extcommunity_cost_igp
    pf = @property_flush[:set_extcommunity_cost_pre_bestpath]
    pre = pf ? pf : @nu.set_extcommunity_cost_pre_bestpath
    @nu.set_extcommunity_cost_set(igp, pre)
  end

  def legacy_image?
    require 'puppet/util/network_device'
    if Puppet::Util::NetworkDevice.current.nil?
      fd = Facter.value('cisco')
      image = fd['images']['full_version']
    else
      image = Puppet::Util::NetworkDevice.current.facts['cisco']['images']['full_version']
    end
    image[/7.0.3.I2|I3|I4/]
  end

  def v4_ip_next_hop(attrs)
    pf = @property_flush[:set_ipv4_default_next_hop]
    attrs[:v4dnh] = pf ? pf : @nu.set_ipv4_default_next_hop
    pf = @property_flush[:set_ipv4_default_next_hop_load_share]
    attrs[:v4dls] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_default_next_hop_load_share
    pf = @property_flush[:set_ipv4_next_hop]
    attrs[:v4nh] = pf ? pf : @nu.set_ipv4_next_hop
    pf = @property_flush[:set_ipv4_next_hop_load_share]
    attrs[:v4ls] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_next_hop_load_share
    pf = @property_flush[:set_ipv4_next_hop_peer_addr]
    attrs[:v4peer] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_next_hop_peer_addr
    pf = @property_flush[:set_ipv4_next_hop_redist]
    if legacy_image?
      attrs[:v4red] = nil
    else
      attrs[:v4red] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_next_hop_redist
    end
    pf = @property_flush[:set_ipv4_next_hop_unchanged]
    attrs[:v4unc] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv4_next_hop_unchanged
  end

  def v6_ip_next_hop(attrs)
    pf = @property_flush[:set_ipv6_default_next_hop]
    attrs[:v6dnh] = pf ? pf : @nu.set_ipv6_default_next_hop
    pf = @property_flush[:set_ipv6_default_next_hop_load_share]
    attrs[:v6dls] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_default_next_hop_load_share
    pf = @property_flush[:set_ipv6_next_hop]
    attrs[:v6nh] = pf ? pf : @nu.set_ipv6_next_hop
    pf = @property_flush[:set_ipv6_next_hop_load_share]
    attrs[:v6ls] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_next_hop_load_share
    pf = @property_flush[:set_ipv6_next_hop_peer_addr]
    attrs[:v6peer] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_next_hop_peer_addr
    pf = @property_flush[:set_ipv6_next_hop_redist]
    if legacy_image?
      attrs[:v4red] = nil
    else
      attrs[:v6red] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_next_hop_redist
    end
    pf = @property_flush[:set_ipv6_next_hop_unchanged]
    attrs[:v6unc] = PuppetX::Cisco::Utils.flush_boolean?(pf) ? pf : @nu.set_ipv6_next_hop_unchanged
  end

  def set_ip_next_hop_set
    attrs = {}
    attrs[:intf] = @property_flush[:set_interface] ? @property_flush[:set_interface] : @nu.set_interface
    v4_ip_next_hop(attrs)
    v6_ip_next_hop(attrs)
    @nu.set_ip_next_hop_set(attrs)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      new_rm = false
      if @nu.nil?
        new_rm = true
        @nu = Cisco::RouteMap.new(@resource[:rmname],
                                  @resource[:sequence],
                                  @resource[:action])
      end
      properties_set(new_rm)
    end
  end
end
