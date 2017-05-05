# May, 2017
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

Puppet::Type.type(:cisco_bgp_af_aa).provide(:cisco) do
  desc 'The Cisco bgp_af_aa provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  BGP_AF_AA_NON_BOOL_PROPS = [
    :advertise_map,
    :attribute_map,
    :suppress_map,
  ]

  BGP_AF_AA_BOOL_PROPS = [
    :as_set,
    :summary_only,
  ]

  BGP_AF_AA_ALL_PROPS = BGP_AF_AA_NON_BOOL_PROPS + BGP_AF_AA_BOOL_PROPS
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            BGP_AF_AA_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            BGP_AF_AA_BOOL_PROPS)

  def initialize(value={})
    super(value)
    asn  = @property_hash[:asn]
    vrf  = @property_hash[:vrf]
    afi  = @property_hash[:afi]
    safi = @property_hash[:safi]
    aa = @property_hash[:aa]
    af = [afi.to_s, safi.to_s]

    @nu = Cisco::RouterBgpAFAggrAddr.aas[asn][vrf][af][aa] unless asn.nil?
    @property_flush = {}
  end

  def self.properties_get(asn, vrf, af, aa, nu_obj)
    current_state = {
      name:   [asn, vrf, af.first, af.last, aa].join(' '),
      asn:    asn,
      vrf:    vrf,
      afi:    af.first,
      safi:   af.last,
      aa:     aa,
      ensure: :present,
    }

    # Call node_utils getter for each property
    BGP_AF_AA_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end

    BGP_AF_AA_BOOL_PROPS.each do |prop|
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
    aa_objs = []
    Cisco::RouterBgpAFAggrAddr.aas.each do |asn, vrfs|
      vrfs.each do |vrf, afs|
        afs.each do |af, aas|
          aas.each do |aa, nu_obj|
            aa_objs << properties_get(asn, vrf, af, aa, nu_obj)
          end
        end
      end
    end
    aa_objs
  end # self.instances

  def self.prefetch(resources)
    aas = instances
    resources.keys.each do |name|
      provider = aas.find do |aga|
        aga.asn.to_s == resources[name][:asn].to_s &&
        aga.vrf == resources[name][:vrf] &&
        aga.afi.to_s == resources[name][:afi].to_s &&
        aga.safi.to_s == resources[name][:safi].to_s &&
        aga.aa.to_s == resources[name][:aa].to_s
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

  def properties_set(new_obj=false)
    BGP_AF_AA_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_obj
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # Custom set methods
    aa_set
  end

  def aa_set
    attrs = {}
    vars = [
      :advertise_map,
      :attribute_map,
      :suppress_map,
      :as_set,
      :summary_only,
    ]
    return unless vars.any? { |p| @property_flush.key?(p) }
    # At least one var has changed, get all vals from manifest
    vars.each do |p|
      if @resource[p] == :default
        attrs[p] = @nu.send("default_#{p}")
      else
        attrs[p] = @resource[p]
        attrs[p] = PuppetX::Cisco::Utils.bool_sym_to_s(attrs[p])
      end
    end
    @nu.aa_set(attrs)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      new_obj = false
      if @nu.nil?
        new_obj = true
        @nu = Cisco::RouterBgpAFAggrAddr.new(@resource[:asn],
                                             @resource[:vrf],
                                             [@resource[:afi],
                                              @resource[:safi]],
                                             @resource[:aa])
      end
      properties_set(new_obj)
    end
  end
end
