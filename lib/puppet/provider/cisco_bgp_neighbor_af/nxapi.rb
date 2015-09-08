#
# The NXAPI provider for cisco_bgp_neighbor_af.
#
# August 2015 Chris Van Heuveln
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_bgp_neighbor_af).provide(:nxapi) do
  confine :feature => :cisco_node_utils
  defaultfor :operatingsystem => :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  # NOTE: For maintainability please keep this list in alphabetical order.
  BGP_NBR_AF_NON_BOOL_PROPS = [
    :allowas_in_max,
    :advertise_map_exist,
    :advertise_map_non_exist,
    :default_originate_route_map,
    :filter_list_in,
    :filter_list_out,
    :max_prefix_limit,
    :max_prefix_interval,
    :max_prefix_threshold,
    :send_community,
    :soo,
    :unsuppress_map,
    :weight,
  ]
  BGP_NBR_AF_BOOL_PROPS = [
    :allowas_in,
    :as_override,
    :cap_add_paths_send,
    :cap_add_paths_send_disable,
    :cap_add_paths_receive,
    :cap_add_paths_receive_disable,
    :default_originate,
    :disable_peer_as_check,
    :max_prefix_warning,
    :next_hop_self,
    :next_hop_third_party,
    :route_reflector_client,
    :soft_reconfiguration_in,
    :soft_reconfiguration_in_always,
    :suppress_inactive,
  ]

  BGP_NBR_AF_ALL_PROPS = BGP_NBR_AF_NON_BOOL_PROPS + BGP_NBR_AF_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@af',
                                            BGP_NBR_AF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@af',
                                            BGP_NBR_AF_BOOL_PROPS)

  def initialize(value = {})
    super(value)
    asn = @property_hash[:asn]
    vrf = @property_hash[:vrf]
    nbr = @property_hash[:neighbor]
    afi = @property_hash[:afi]
    safi = @property_hash[:safi]
    af = afi, safi

    @af = Cisco::RouterBgpNeighborAF.afs[asn][vrf][nbr][af] unless asn.nil?
    @property_flush = {}
  end

  def self.properties_get(asn, vrf, nbr, af, obj)
    current_state = {
      :name     => [asn, vrf, nbr, af.first, af.last].join(' '),
      :asn      => asn,
      :vrf      => vrf,
      :neighbor => nbr,
      :afi      => af.first,
      :safi     => af.last,
      :ensure   => :present,
    }
    # Call node_utils getter for every property
    BGP_NBR_AF_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = obj.send(prop)
    end
    BGP_NBR_AF_BOOL_PROPS.each do |prop|
      val = obj.send(prop)
      current_state[prop] = val.nil? ? nil : val.to_s.to_sym
    end
    new(current_state)
  end

  def self.instances
    af_objs = []
    Cisco::RouterBgpNeighborAF.afs.each do |asn, vrfs|
      vrfs.each do |vrf, nbrs|
        nbrs.each do |nbr, afs|
          afs.each do |af, af_obj|
            af_objs << properties_get(asn, vrf, nbr, af, af_obj)
          end
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
        af.neighbor == resources[name][:neighbor] &&
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

  def properties_set(new_af = false)
    BGP_NBR_AF_ALL_PROPS.each do |prop|
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

    # Non-AutoGen custom setters follow
    allowas_in_set
    cap_add_paths_receive_set
    cap_add_paths_send_set
    default_originate_set
    max_prefix_set
    soft_reconfiguration_in_set
  end

  # Non-AutoGen custom setters
  # The following properties are setters have additional complexity and cannot
  # be handled by PuppetX::Cisco::AutoGen.mk_puppet_methods.
  def advertise_map_exist=(val)
    val = @af.default_advertise_map_exist if val.first == :default
    @property_flush[:advertise_map_exist] = val
  end

  def advertise_map_non_exist=(val)
    val = @af.default_advertise_map_non_exist if val.first == :default
    @property_flush[:advertise_map_non_exist] = val
  end

  def allowas_in_set
    return unless
      @property_flush.key?(:allowas_in) ||
      @property_flush.key?(:allowas_in_max)

    # max is optional
    max = @property_flush[:allowas_in_max]
    if @property_flush.key?(:allowas_in_max)
      max = (max == :default) ?
              @af.default_allowas_in_max :
              @property_flush[:allowas_in_max]
    end
    if @property_flush.key?(:allowas_in)
      state = @property_flush[:allowas_in]
    else
      state = max ? true : @af.allowas_in
    end
    @af.allowas_in_set(state, max)
  end

  def cap_add_paths_receive_set
    return unless
      @property_flush.key?(:cap_add_paths_receive) ||
      @property_flush.key?(:cap_add_paths_receive_disable)

    # disable is an optional keyword
    disable = @property_flush[:cap_add_paths_receive_disable]
    if @property_flush.key?(:cap_add_paths_receive_disable)
      disable = (disable == :default) ?
                  @af.default_cap_add_paths_receive_disable :
                  @property_flush[:cap_add_paths_receive_disable]
    end

    if @property_flush.key?(:cap_add_paths_receive)
      state = @property_flush[:cap_add_paths_receive]
    else
      state = (disable) ? true : @af.cap_add_paths_receive
    end

    @af.cap_add_paths_receive_set(state, disable)
  end

  def cap_add_paths_send_set
    return unless
      @property_flush.key?(:cap_add_paths_send) ||
      @property_flush.key?(:cap_add_paths_send_disable)

    # disable is an optional keyword
    disable = @property_flush[:cap_add_paths_send_disable]
    if @property_flush.key?(:cap_add_paths_send_disable)
      disable = (disable == :default) ?
                  @af.default_cap_add_paths_send_disable :
                  @property_flush[:cap_add_paths_send_disable]
    end

    if @property_flush.key?(:cap_add_paths_send)
      state = @property_flush[:cap_add_paths_send]
    else
      state = (disable) ? true : @af.cap_add_paths_send
    end
    @af.cap_add_paths_send_set(state, disable)
  end

  def default_originate_set
    return unless
      @property_flush.key?(:default_originate) ||
      @property_flush.key?(:default_originate_route_map)

    # route_map is optional
    route_map = @property_flush[:default_originate_route_map]
    if @property_flush.key?(:default_originate_route_map)
      route_map = (route_map == :default) ?
                    @af.default_default_originate_route_map :
                    @property_flush[:default_originate_route_map]
    end

    if @property_flush.key?(:default_originate)
      state = @property_flush[:default_originate]
    else
      state = route_map ? true : @af.default_originate
    end
    @af.default_originate_set(state, route_map)
  end

  def max_prefix_set
    return unless
      @property_flush.key?(:max_prefix_limit) ||
      @property_flush.key?(:max_prefix_threshold) ||
      @property_flush.key?(:max_prefix_interval) ||
      @property_flush.key?(:max_prefix_warning)

    max_prefix_validate_args
    opt = nil
    # restart interval is optional and mutually exclusive with warning
    interval = @property_flush[:max_prefix_interval]
    if @property_flush.key?(:max_prefix_interval)
      opt = (interval == :default) ?
              @af.default_max_prefix_interval :
              @property_flush[:max_prefix_interval]
    else
      opt = @af.max_prefix_interval
    end

    # warning is optional and mutually exclusive with restart interval
    warning = @property_flush[:max_prefix_warning]
    if @property_flush.key?(:max_prefix_warning)
      opt = (warning == :default) ?
              @af.default_max_prefix_warning :
              @property_flush[:max_prefix_warning]
    else
      # Use current value, but do not overwrite opt if already populated
      opt = @af.max_prefix_warning unless opt
    end

    # threshold is optional
    threshold = @property_flush[:max_prefix_threshold]
    if @property_flush.key?(:max_prefix_threshold)
      threshold = (threshold == :default) ?
                    @af.default_max_prefix_threshold :
                    @property_flush[:max_prefix_threshold]
    else
      threshold = @af.max_prefix_threshold
    end

    # limit is required
    if @property_flush.key?(:max_prefix_limit)
      limit = @property_flush[:max_prefix_limit]
    else
      limit = @af.max_prefix_limit
    end
    @af.max_prefix_set(limit, threshold, opt)
  end

  def max_prefix_validate_args
    fail ArgumentError,
         "'max_prefix_limit' is a required property when using other " \
         'max_prefix properties.' if
      @resource[:max_prefix_limit].nil?

    fail ArgumentError,
         "'max_prefix_interval' and 'max_prefix_warning' are mutually " \
         'exclusive properties.' if
      @property_flush.key?(:max_prefix_interval) &&
      @property_flush.key?(:max_prefix_warning)
  end

  def soft_reconfiguration_in_set
    return unless
      @property_flush.key?(:soft_reconfiguration_in) ||
      @property_flush.key?(:soft_reconfiguration_in_always)

    # 'always' is an optional keyword
    always = @property_flush[:soft_reconfiguration_in_always]
    if @property_flush.key?(:soft_reconfiguration_in_always)
      always = (always == :default) ?
                  @af.default_soft_reconfiguration_in_always :
                  @property_flush[:soft_reconfiguration_in_always]
    end

    if @property_flush.key?(:soft_reconfiguration_in)
      state = @property_flush[:soft_reconfiguration_in]
    else
      state = (always) ? true : @af.soft_reconfiguration_in
    end
    @af.soft_reconfiguration_in_set(state, always)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @af.destroy
      @af = nil
    else
      if @af.nil?
        new_af = true
        @af = Cisco::RouterBgpNeighborAF.new(@resource[:asn], @resource[:vrf],
                                             @resource[:neighbor],
                                             [@resource[:afi],
                                              @resource[:safi]])
      end
      properties_set(new_af)
    end
  end
end
