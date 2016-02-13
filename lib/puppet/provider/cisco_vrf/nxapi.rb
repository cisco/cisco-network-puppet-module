#
# The NXAPI provider for cisco_vrf.
#
# July 2015
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

Puppet::Type.type(:cisco_vrf).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_vrf.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol arrays for method auto-generation. There are separate arrays
  # because the boolean-based methods are processed slightly different.
  VRF_NON_BOOL_PROPS = [
    :description,
    :route_distinguisher,
    :vni,
  ]
  VRF_BOOL_PROPS = [
    :shutdown
  ]
  VRF_ALL_PROPS = VRF_NON_BOOL_PROPS + VRF_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            VRF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            VRF_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::Vrf.vrfs[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(vrf, nu_obj)
    debug "Checking VRF #{vrf}."
    current_state = {
      name:   vrf,
      ensure: :present,
    }
    # Call node_utils getter for each property
    VRF_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    VRF_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      current_state[prop] = val.nil? ? nil : val.to_s.to_sym
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    vrfs = []
    Cisco::Vrf.vrfs.each do |vrf, nu_obj|
      vrfs << properties_get(vrf, nu_obj)
    end
    vrfs
  end # self.instances

  def self.prefetch(resources)
    vrfs = instances
    resources.keys.each do |name|
      provider = vrfs.find { |vrf| vrf.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def properties_set(new_vrf=false)
    VRF_ALL_PROPS.each do |prop|
      # if the manifest defined the property value, we
      # need to update using the setter accordingly.
      next unless @resource[prop]
      if new_vrf
        # set property_flush for the new object
        send("#{prop}=", @resource[prop])
      end
      next if @property_flush[prop].nil?
      # calling setters of the node utility gem using
      # values in property_flush
      @nu.send("#{prop}=", @property_flush[prop]) if
      @nu.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_vrf = true
        @nu = Cisco::Vrf.new(@resource[:name])
      end
      properties_set(new_vrf)
    end
  end
end # Puppet::Type
