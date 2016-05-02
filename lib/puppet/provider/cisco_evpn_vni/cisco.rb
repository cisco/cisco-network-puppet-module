# December, 2015
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

Puppet::Type.type(:cisco_evpn_vni).provide(:cisco) do
  desc 'The Cisco provider for cisco evpn vni'

  confine feature: :cisco_node_utils

  mk_resource_methods

  # Property symbol arrays for method auto-generation.
  EVPN_VNI_ARRAY_FLAT_PROPS = [
    :route_target_both,
    :route_target_export,
    :route_target_import,
  ]
  EVPN_VNI_NON_BOOL_PROPS = [
    :route_distinguisher
  ]
  EVPN_VNI_ALL_PROPS = EVPN_VNI_ARRAY_FLAT_PROPS + EVPN_VNI_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            EVPN_VNI_ARRAY_FLAT_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            EVPN_VNI_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::EvpnVni.vnis[@property_hash[:name]]
    @property_flush = {}
  end # initialize

  def self.properties_get(vni_id, nu_obj)
    debug "Checking instance, vni #{vni_id}"
    current_state = {
      vni:    vni_id,
      name:   vni_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    EVPN_VNI_ALL_PROPS.each { |prop| current_state[prop] = nu_obj.send(prop) }

    new(current_state)
  end # self.properties_get

  def self.instances
    vnis = []
    Cisco::EvpnVni.vnis.each do |vni_id, nu_obj|
      vnis << properties_get(vni_id, nu_obj)
    end
    vnis
  end # self.instances

  def self.prefetch(resources)
    vnis = instances

    resources.keys.each do |id|
      provider = vnis.find { |vni| vni.instance_name == id }
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

  def instance_name
    vni
  end

  def properties_set(new_vni=false)
    EVPN_VNI_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vni

      next if @property_flush[prop].nil?
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
        new_vni = true
        @nu = Cisco::EvpnVni.new(@resource[:vni])
      end
      properties_set(new_vni)
    end
  end
end # Puppet::Type
