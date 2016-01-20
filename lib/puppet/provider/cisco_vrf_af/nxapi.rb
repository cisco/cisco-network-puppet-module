#
# The NXAPI provider for cisco_vrf_af
#
# January 2016, Chris Van Heuveln
#
# Copyright (c) 2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_vrf_af).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol arrays for method auto-generation.
  VRF_AF_ARRAY_FLAT_PROPS = [
    :route_target_import,
    :route_target_import_evpn,
    :route_target_export,
    :route_target_export_evpn,
  ]
  VRF_AF_BOOL_PROPS = [
    :route_target_both_auto,
    :route_target_both_auto_evpn,
  ]
  VRF_AF_ALL_PROPS =
    VRF_AF_ARRAY_FLAT_PROPS + VRF_AF_BOOL_PROPS
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            VRF_AF_ARRAY_FLAT_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            VRF_AF_BOOL_PROPS)

  def initialize(value={})
    super(value)
    vrf = @property_hash[:vrf]
    af = @property_hash[:afi], @property_hash[:safi]
    @nu = Cisco::VrfAF.afs[vrf][af] unless vrf.nil?
    @property_flush = {}
  end

  def self.properties_get(vrf, af, nu_obj)
    current_state = {
      name:   [vrf, af.first, af.last].join(' '),
      vrf:    vrf,
      afi:    af.first,
      safi:   af.last,
      ensure: :present,
    }
    # Call node_utils getter for every property
    VRF_AF_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    VRF_AF_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      current_state[prop] = val.nil? ? nil : val.to_s.to_sym
    end
    new(current_state)
  end

  def self.instances
    all_vrf_afs = []
    Cisco::VrfAF.afs.each do |vrf, afs|
      afs.each do |af, nu_obj|
        all_vrf_afs << properties_get(vrf, af, nu_obj)
      end
    end
    all_vrf_afs
  end

  def self.prefetch(resources)
    all_vrf_afs = instances
    resources.keys.each do |name|
      provider = all_vrf_afs.find do |af|
        af.vrf == resources[name][:vrf] &&
        af.afi.to_s == resources[name][:afi].to_s &&
        af.safi.to_s == resources[name][:safi].to_s
      end
      resources[name].provider = provider unless provider.nil?
    end
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def properties_set(new_vrf_af=false)
    VRF_AF_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      if new_vrf_af
        # Set @property_flush for the current object
        send("#{prop}=", @resource[prop])
      end
      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the @nu node_utils object.
      @nu.send("#{prop}=", @property_flush[prop]) if
        @nu.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      if @nu.nil?
        new_vrf_af = true
        @nu = Cisco::VrfAF.new(@resource[:vrf],
                               [@resource[:afi], @resource[:safi]])
      end
      properties_set(new_vrf_af)
    end
  end
end
