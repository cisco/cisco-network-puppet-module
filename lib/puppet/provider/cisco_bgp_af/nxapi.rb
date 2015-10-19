#
# The NXAPI provider for cisco_bgp_af.
#
# August 2015 Rich Wellum
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

Puppet::Type.type(:cisco_bgp_af).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  #
  # NOTE: For maintainability please keep this list in alphabetical order and
  # one property per line.
  BGP_AF_NON_BOOL_PROPS = [
    :next_hop_route_map,
  ]

  BGP_AF_BOOL_PROPS = [
    :client_to_client,
    :default_information_originate,
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
