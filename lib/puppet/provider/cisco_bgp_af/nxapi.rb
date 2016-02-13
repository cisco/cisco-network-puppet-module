#
# The NXAPI provider for cisco_bgp_af.
#
# August 2015 Rich Wellum
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_bgp_af).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  #
  # NOTE: For maintainability please keep this list in alphabetical order and
  # one property per line.
  BGP_AF_NON_BOOL_PROPS = [
    :additional_paths_selection,
    :dampen_igp_metric,
    :dampening_half_time,
    :dampening_max_suppress_time,
    :dampening_reuse_time,
    :dampening_routemap,
    :dampening_suppress_time,
    :default_metric,
    :distance_ebgp,
    :distance_ibgp,
    :distance_local,
    :inject_map,
    :maximum_paths,
    :maximum_paths_ibgp,
    :networks,
    :next_hop_route_map,
    :redistribute,
    :table_map,
  ]

  BGP_AF_BOOL_PROPS = [
    :additional_paths_install,
    :additional_paths_receive,
    :additional_paths_send,
    :advertise_l2vpn_evpn,
    :client_to_client,
    :default_information_originate,
    :dampening_state,
    :suppress_inactive,
    :table_map_filter,
  ]

  BGP_AF_ALL_PROPS = BGP_AF_NON_BOOL_PROPS + BGP_AF_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@af',
                                            BGP_AF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@af',
                                            BGP_AF_BOOL_PROPS)

  def initialize(value={})
    super(value)
    asn  = @property_hash[:asn]
    vrf  = @property_hash[:vrf]
    afi  = @property_hash[:afi]
    safi = @property_hash[:safi]
    af   = afi, safi

    @af = Cisco::RouterBgpAF.afs[asn][vrf][af] unless
      asn.nil? || vrf.nil? || afi.nil? || safi.nil?
    @property_flush = {}
  end

  def self.properties_get(asn, vrf, af, obj)
    debug "Checking bgp af instance, #{asn} #{vrf} #{af}"
    current_state = {
      name:   [asn, vrf, af.first, af.last].join(' '),
      asn:    asn,
      vrf:    vrf,
      afi:    af.first,
      safi:   af.last,
      ensure: :present,
    }
    # Call node_utils getter for every property
    BGP_AF_NON_BOOL_PROPS.each { |prop| current_state[prop] = obj.send(prop) }
    BGP_AF_BOOL_PROPS.each do |prop|
      val = obj.send(prop)
      current_state[prop] = val.nil? ? nil : val.to_s.to_sym
    end
    # networks/redistribute use nested arrays, thus require special handling
    current_state[:networks] = obj.networks
    current_state[:redistribute] = obj.redistribute
    current_state[:inject_map] = obj.inject_map
    new(current_state)
  end # self.properties_get

  def self.instances
    af_objs = []
    Cisco::RouterBgpAF.afs.each do |asn, vrfs|
      vrfs.each do |vrf, afs|
        afs.each do |af, af_obj|
          af_objs << properties_get(asn, vrf, af, af_obj)
        end
      end
    end
    af_objs
  end

  def self.prefetch(resources)
    afs = instances
    resources.keys.each do |name|
      provider = afs.find do |af|
        af.asn.to_s == resources[name][:asn].to_s &&
        af.vrf == resources[name][:vrf] &&
        af.afi.to_s == resources[name][:afi].to_s &&
        af.safi.to_s == resources[name][:safi].to_s
      end
      resources[name].provider = provider unless provider.nil?
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

  def properties_set(new_af=false)
    BGP_AF_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      if new_af
        # Set @property_flush for the current object
        send("#{prop}=", @resource[prop])
      end
      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the @af node_utils object.
      @af.send("#{prop}=", @property_flush[prop]) if
        @af.respond_to?("#{prop}=")
    end
    # Custom set methods
    dampening_set
    distance_set
    table_map_set
  end

  # Property 'dampening' helper and custom setter methods
  def dampening_enable
    @af.dampening = '' unless dampening_properties?
  end

  def dampening_disable
    @af.dampening = nil
    @property_flush[:dampening_half_time] = nil
    @property_flush[:dampening_reuse_time] = nil
    @property_flush[:dampening_suppress_time] = nil
    @property_flush[:dampening_max_suppress_time] = nil
    @property_flush[:dampening_dampening_routemap] = nil
  end

  def dampening_properties?
    @property_flush[:dampening_half_time] ||
      @property_flush[:dampening_reuse_time] ||
      @property_flush[:dampening_suppress_time] ||
      @property_flush[:dampening_max_suppress_time] ||
      @property_flush[:dampening_routemap]
  end

  def dampening_properties_set
    if @property_flush[:dampening_half_time]
      half = @property_flush[:dampening_half_time]
    else
      half = @af.dampening_half_time
    end

    if @property_flush[:dampening_reuse_time]
      reuse = @property_flush[:dampening_reuse_time]
    else
      reuse = @af.dampening_reuse_time
    end

    if @property_flush[:dampening_suppress_time]
      suppress = @property_flush[:dampening_suppress_time]
    else
      suppress = @af.dampening_suppress_time
    end

    if @property_flush[:dampening_max_suppress_time]
      max_suppress = @property_flush[:dampening_max_suppress_time]
    else
      max_suppress = @af.dampening_max_suppress_time
    end
    @af.dampening = [half, reuse, suppress, max_suppress]
  end

  def dampening_routemap_set
    if @property_flush[:dampening_routemap]
      rtmap = @property_flush[:dampening_routemap]
    else
      rtmap = @af.dampening_routemap
    end

    @af.dampening = rtmap
  end

  def dampening_set
    dampening_disable if @property_flush[:dampening_state].to_s == 'false'
    dampening_enable if @property_flush[:dampening_state].to_s == 'true'

    return if @resource[:dampening_state].to_s == 'false'
    return unless dampening_properties?

    if @property_flush[:dampening_routemap]
      dampening_routemap_set
    else
      dampening_properties_set
    end
  end

  def distance_set
    return unless
      @property_flush[:distance_ebgp] ||
      @property_flush[:distance_ibgp] ||
      @property_flush[:distance_local]

    if @property_flush[:distance_ebgp]
      ebgp = @property_flush[:distance_ebgp]
    else
      ebgp = @af.distance_ebgp
    end

    if @property_flush[:distance_ibgp]
      ibgp = @property_flush[:distance_ibgp]
    else
      ibgp = @af.distance_ibgp
    end

    if @property_flush[:distance_local]
      local = @property_flush[:distance_local]
    else
      local = @af.distance_local
    end
    @af.distance_set(ebgp, ibgp, local)
  end

  def table_map_set
    return unless
      @property_flush[:table_map] ||
      @property_flush[:table_map_filter]

    if @property_flush[:table_map]
      map = @property_flush[:table_map]
    else
      map = @af.table_map
    end

    if @property_flush[:table_map_filter]
      filter = @property_flush[:table_map_filter]
    else
      filter = @af.table_map_filter
    end
    @af.table_map_set(map, filter)
  end

  def inject_map
    return @property_hash[:inject_map] if @resource[:inject_map].nil?
    if @resource[:inject_map][0] == :default &&
       @property_hash[:inject_map] == @af.default_inject_map
      return [:default]
    else
      @property_hash[:inject_map]
    end
  end

  def inject_map=(should_list)
    should_list = @af.default_inject_map if should_list[0] == :default
    @property_flush[:inject_map] = should_list
  end

  # Networks requires a custom getter and setter because we are
  # working with arrays.  When the manifest entry is set to default,
  # puppet creates an array with the symbol default. [:default].
  # The net result is the getter needs to return [:default] and
  # the setter must check the array for symbol :default.
  def networks
    return @property_hash[:networks] if @resource[:networks].nil?
    if @resource[:networks][0] == :default &&
       @property_hash[:networks] == @af.default_networks
      return [:default]
    else
      @property_hash[:networks]
    end
  end

  def networks=(should_list)
    should_list = @af.default_networks if should_list[0] == :default
    @property_flush[:networks] = should_list
  end

  # redistribute uses a nested array, thus requires special handling
  def redistribute
    return @property_hash[:redistribute] if @resource[:redistribute].nil?
    if @resource[:redistribute][0] == :default &&
       @property_hash[:redistribute] == @af.default_redistribute
      return [:default]
    else
      @property_hash[:redistribute]
    end
  end

  def redistribute=(should_list)
    should_list = @af.default_redistribute if should_list[0] == :default
    @property_flush[:redistribute] = should_list
  end

  def flush
    if @property_flush[:ensure] == :absent
      @af.destroy
      @af = nil
    else
      if @af.nil?
        new_af = true
        @af = Cisco::RouterBgpAF.new(@resource[:asn], @resource[:vrf],
                                     [@resource[:afi], @resource[:safi]])
      end
      properties_set(new_af)
    end
  end
end
