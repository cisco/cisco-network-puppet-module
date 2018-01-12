# December 2017
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

Puppet::Type.type(:cisco_interface_evpn_multisite).provide(:cisco) do
  desc 'The Cisco provider for cisco_interface_evpn_multisite'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  INTF_EVPN_MS_NON_BOOL_PROPS = [
    :tracking
  ]

  INTF_EVPN_MS_ALL_PROPS = INTF_EVPN_MS_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self,
                                            '@nu',
                                            INTF_EVPN_MS_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::InterfaceEvpnMultisite.interfaces[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(interface_name, nu_obj)
    debug "Checking instance, #{interface_name}."
    current_state = {
      interface: interface_name,
      name:      interface_name,
      ensure:    :present,
      tracking:  nu_obj.tracking,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    interfaces = []
    Cisco::InterfaceEvpnMultisite.interfaces.each do |interface_name, nu_obj|
      interfaces << properties_get(interface_name, nu_obj)
    end
    interfaces
  end # self.instances

  def self.prefetch(resources)
    interfaces = instances
    resources.keys.each do |name|
      provider = interfaces.find { |nu_obj| nu_obj.instance_name == name }
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

  def instance_name
    interface
  end

  def properties_set(new_interface=false)
    INTF_EVPN_MS_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_interface
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.disable
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_interface = true
        @nu = Cisco::InterfaceEvpnMultisite.new(@resource[:interface])
      end
      properties_set(new_interface)
    end
  end
end # Puppet::Type
