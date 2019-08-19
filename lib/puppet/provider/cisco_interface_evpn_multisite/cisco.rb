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
  require 'puppet_x/cisco/cmnutils'
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
    if value.is_a?(Hash)
      # value is_a hash when initialized from properties_get()
      all_intf = value[:all_intf]
      single_intf = value[:interface]
    else
      # @property_hash[:name] is nil in this codepath; since it's nil
      # it will cause @nu to become nil, thus @nu instantiation is just
      # skipped altogether.
      all_intf = false
    end
    if all_intf
      @nu = Cisco::InterfaceEvpnMultisite.interfaces[@property_hash[:name]]
    elsif single_intf
      # 'puppet agent' caller
      @nu = Cisco::InterfaceEvpnMultisite.interfaces(single_intf)[@property_hash[:name]]
    end

    @property_flush = {}
  end

  def self.properties_get(interface_name, nu_obj, all_intf: nil)
    debug "Checking instance, #{interface_name}."
    current_state = {
      interface: interface_name,
      name:      interface_name,
      ensure:    :present,
      tracking:  nu_obj.tracking,
      all_intf:  all_intf,
    }
    new(current_state)
  end # self.properties_get

  def self.instances(single_intf=nil, interface_threshold=0)
    # 'puppet resource' calls here directly; will always get all interfaces.
    # 'puppet agent' callpath is initialize->prefetch; may pass a single intf.
    if single_intf && interface_threshold > 0
      all_intf = false
      nu_interfaces = Cisco::InterfaceEvpnMultisite.interfaces(single_intf)
    else
      all_intf = true
      nu_interfaces = Cisco::InterfaceEvpnMultisite.interfaces
    end
    interfaces = []
    nu_interfaces.each do |interface_name, nu_obj|
      begin
        interfaces << properties_get(interface_name, nu_obj, all_intf: all_intf)
      end
    end
    interfaces
  end # self.instances

  def self.prefetch(resources)
    interface_threshold = PuppetX::Cisco::Utils.interface_threshold
    if resources.keys.length > interface_threshold
      info '[prefetch all interfaces]:begin - please be patient...'
      interfaces = instances
      resources.keys.each do |name|
        provider = interfaces.find { |intf| intf.instance_name == name }
        resources[name].provider = provider unless provider.nil?
      end
      info "[prefetch all interfaces]:end - found: #{interfaces.length}"
    else
      info "[prefetch each interface independently] (threshold: #{interface_threshold})"
      resources.keys.each do |name|
        provider = instances(name, interface_threshold).find { |intf| intf.instance_name == name }
        resources[name].provider = provider unless provider.nil?
      end
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
        @nu = Cisco::InterfaceEvpnMultisite.new(@resource[:interface],
                                                @resource[:interface])
      end
      properties_set(new_interface)
    end
  end
end # Puppet::Type
