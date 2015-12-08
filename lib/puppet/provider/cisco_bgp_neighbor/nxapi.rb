#
# The NXAPI provider for cisco_bgp_neighbor.
#
# September 2015 Jie Yang
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

Puppet::Type.type(:cisco_bgp_neighbor).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  # NOTE: For maintainability please keep this list in alphabetical order.
  BGP_NBR_NON_BOOL_PROPS = [
    :remote_as, # must be first for XR
    :description,
    :ebgp_multihop,
    :local_as,
    :log_neighbor_changes,
    :maximum_peers,
    :password,
    :password_type,
    :remove_private_as,
    :timers_keepalive,
    :timers_holdtime,
    :transport_passive_mode,
    :update_source,
  ]
  BGP_NBR_BOOL_PROPS = [
    :connected_check,
    :capability_negotiation,
    :dynamic_capability,
    :low_memory_exempt,
    :shutdown,
    :suppress_4_byte_as,
    :transport_passive_only,
  ]

  BGP_NBR_ALL_PROPS = BGP_NBR_NON_BOOL_PROPS + BGP_NBR_BOOL_PROPS

  # We need to write our own getter and setter for local_as and remote_as
  # to cover different AS format
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nbr',
                                            (BGP_NBR_NON_BOOL_PROPS - [:local_as, :remote_as]))
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nbr',
                                            BGP_NBR_BOOL_PROPS)

  def initialize(value={})
    super(value)
    asn = @property_hash[:asn]
    vrf = @property_hash[:vrf]
    nbr = @property_hash[:neighbor]
    @nbr = Cisco::RouterBgpNeighbor.neighbors[asn][vrf][nbr] unless asn.nil?
    @property_flush = {}
  end

  def self.properties_get(asn, vrf, addr, nbr)
    current_state = {
      name:     [asn, vrf, addr].join(' '),
      asn:      asn,
      vrf:      vrf,
      neighbor: addr,
      ensure:   :present,
    }
    # Call node_utils getter for every property
    BGP_NBR_ALL_PROPS.each do |prop|
      current_state[prop] = nbr.send(prop)
    end
    new(current_state)
  end

  def self.instances
    neighbors = []
    Cisco::RouterBgpNeighbor.neighbors.each do |asn, vrfs|
      vrfs.each do |vrf, nbrs|
        nbrs.each do |addr, nbr|
          neighbors << properties_get(asn, vrf, addr, nbr)
        end
      end
    end
    neighbors
  end

  def self.prefetch(resources)
    nbrs = instances
    resources.keys.each do |name|
      provider = nbrs.find do |nbr|
        nbr.asn.to_s == resources[name][:asn].to_s &&
        nbr.vrf == resources[name][:vrf] &&
        nbr.neighbor == resources[name][:neighbor]
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

  def local_as
    current_as = Cisco::RouterBgp.process_asnum(@property_hash[:local_as]).to_s
    if @resource[:local_as]
      if @resource[:local_as] == :default
        return :default if @property_hash[:local_as] == @nbr.default_local_as
      elsif current_as == Cisco::RouterBgp.process_asnum(@resource[:local_as]).to_s
        # if current as is same as the resource value, return resource value in
        # its current format (dot or integer)
        return @resource[:local_as]
      end
    end
    @property_hash[:local_as]
  end

  def local_as=(asnum)
    asnum = @nbr.default_local_as if asnum == :default
    @property_flush[:local_as] = asnum
  end

  def remote_as
    current_as = Cisco::RouterBgp.process_asnum(@property_hash[:remote_as]).to_s
    if @resource[:remote_as]
      if @resource[:remote_as] == :default
        return :default if @property_hash[:remote_as] == @nbr.default_remote_as
      elsif current_as ==
            Cisco::RouterBgp.process_asnum(@resource[:remote_as]).to_s
        # if current as is same as the resource value, return resource value in
        # its current format (dot or integer)
        return @resource[:remote_as]
      end
    end
    @property_hash[:remote_as]
  end

  def remote_as=(asnum)
    asnum = @nbr.default_remote_as if asnum == :default
    @property_flush[:remote_as] = asnum
  end

  def properties_set(new_nbr=false)
    BGP_NBR_ALL_PROPS.each do |prop|
      next unless @resource[prop]

      # Set @property_flush for the current object
      send("#{prop}=", @resource[prop]) if new_nbr

      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the @nbr node_utils object.
      # For password and type, keepalive and hold timers, we don't have
      # individual setters (respond_to? will return false). For these
      # properties, we need to process them separately.
      @nbr.send("#{prop}=", @property_flush[prop]) if
        @nbr.respond_to?("#{prop}=")
    end

    # Non-AutoGen custom setters follow
    password_set
    timers_set
  end

  # Non-AutoGen custom setters
  # The following properties have additional complexity and cannot
  # be handled by PuppetX::Cisco::AutoGen.mk_puppet_methods
  def password_set
    return if @property_flush[:password].nil?
    if @resource[:password_type].nil?
      type = @property_hash[:password_type]
    else
      type = @resource[:password_type]
    end
    if @property_flush[:password].nil?
      password = @property_hash[:password]
    else
      password = @property_flush[:password]
    end
    @nbr.password_set(password, type)
  end

  def timers_set
    return if @property_flush[:timers_keepalive].nil? &&
              @property_flush[:timers_holdtime].nil?
    if @property_flush[:timers_keepalive].nil?
      keepalive = @property_hash[:timers_keepalive]
    else
      keepalive = @property_flush[:timers_keepalive]
    end
    if @property_flush[:timers_holdtime].nil?
      holdtime = @property_hash[:timers_holdtime]
    else
      holdtime = @property_flush[:timers_holdtime]
    end
    @nbr.timers_set(keepalive, holdtime)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nbr.destroy
      @nbr = nil
    else
      if @nbr.nil?
        new_nbr = true
        @nbr = Cisco::RouterBgpNeighbor.new(@resource[:asn], @resource[:vrf],
                                            @resource[:neighbor])
      end
      properties_set(new_nbr)
    end
  end
end
