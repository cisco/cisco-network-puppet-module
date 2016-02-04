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
  # Exceptions:
  #   remote_as must process before local_as
  BGP_NBR_NON_BOOL_PROPS = [
    :description,
    :ebgp_multihop,
    :remote_as,
    :local_as,
    :log_neighbor_changes,
    :maximum_peers,
    :password,
    :password_type,
    :remove_private_as,
    :timers_keepalive,
    :timers_holdtime,
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

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            (BGP_NBR_NON_BOOL_PROPS))
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            BGP_NBR_BOOL_PROPS)

  def initialize(value={})
    super(value)
    asn = @property_hash[:asn]
    vrf = @property_hash[:vrf]
    nbr = @property_hash[:neighbor]
    @nu = Cisco::RouterBgpNeighbor.neighbors[asn][vrf][nbr] unless asn.nil?
    @property_flush = {}
  end

  def self.properties_get(asn, vrf, addr, nu_obj)
    current_state = {
      name:     [asn, vrf, addr].join(' '),
      asn:      asn,
      vrf:      vrf,
      neighbor: addr,
      ensure:   :present,
    }
    # Call node_utils getter for every property
    BGP_NBR_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    BGP_NBR_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      current_state[prop] = val.nil? ? nil : val.to_s.to_sym
    end
    new(current_state)
  end

  def self.instances
    neighbors = []
    Cisco::RouterBgpNeighbor.neighbors.each do |asn, vrfs|
      vrfs.each do |vrf, nbrs|
        nbrs.each do |addr, nu_obj|
          neighbors << properties_get(asn, vrf, addr, nu_obj)
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

  def properties_set(new_nbr=false)
    BGP_NBR_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      if new_nbr
        # Set @property_flush for the current object
        send("#{prop}=", @resource[prop])
      end
      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the node_utils object.
      @nu.send("#{prop}=", @property_flush[prop]) if
        @nu.respond_to?("#{prop}=")
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
    @nu.password_set(password, type)
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
    @nu.timers_set(keepalive, holdtime)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      if @nu.nil?
        new_nbr = true
        @nu = Cisco::RouterBgpNeighbor.new(@resource[:asn], @resource[:vrf],
                                           @resource[:neighbor])
      end
      properties_set(new_nbr)
    end
  end
end
