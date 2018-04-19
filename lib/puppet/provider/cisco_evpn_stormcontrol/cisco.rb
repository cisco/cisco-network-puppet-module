# December, 2017
#
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_evpn_stormcontrol).provide(:cisco) do
  desc 'The Cisco provider for cisco evpn stormcontrol'

  confine feature: :cisco_node_utils

  mk_resource_methods

  EVPN_STORMCONTROL_NON_BOOL_PROPS = [
    :level
  ]
  EVPN_STORMCONTROL_ALL_PROPS = EVPN_STORMCONTROL_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            EVPN_STORMCONTROL_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::EvpnStormcontrol.stormcontrol[@property_hash[:name]]
    @property_flush = {}
  end # initialize

  def self.properties_get(type, nu_obj)
    debug "Checking instance, type #{type}"
    current_state = {
      name:   type,
      ensure: :present,
      level:  nu_obj.level,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    stormcontrol = []
    Cisco::EvpnStormcontrol.stormcontrol.each do |type, nu_obj|
      stormcontrol << properties_get(type, nu_obj) unless nu_obj.nil?
    end
    stormcontrol
  end # self.instances

  def self.prefetch(resources)
    stormcontrol = instances
    resources.keys.each do |id|
      provider = stormcontrol.find { |type| type.name == id }
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

  def properties_set(new_stormcontrol=false)
    EVPN_STORMCONTROL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_stormcontrol

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
        new_stormcontrol = true
        @nu = Cisco::EvpnStormcontrol.new(@resource[:packet_type], @resource[:level])
      end
      properties_set(new_stormcontrol)
    end
  end
end # Puppet::Type
