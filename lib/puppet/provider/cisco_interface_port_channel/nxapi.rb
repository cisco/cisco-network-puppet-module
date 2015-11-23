#
# The NXAPI provider for cisco_interface_port_channel
#
# May 2015
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

Puppet::Type.type(:cisco_interface_port_channel).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_interface_port_channel.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol arrays for method auto-generation. There are separate arrays
  # because the boolean-based methods are processed slightly different.
  # Note: switchport_mode should always process first to evaluate L2 vs L3.
  # Note: vrf should be the first L3 property to process.  The AutoGen vrf
  # setting is not used.
  INTF_NON_BOOL_PROPS = [
    :lacp_max_bundle,
    :lacp_min_links,
    :per_port_hash_distribution,
    :port_channel,
    :system_port_channel_load_balance_bundle_hash,
    :system_port_channel_load_balance_bundle_select,
    :system_port_channel_load_balance_rotate,
  ]
  INTF_BOOL_PROPS = [
    :lacp_graceful_convergence,
    :lacp_suspend_individual,
    :per_port_load_defer,
    :system_hash_modulo,
    :system_port_channel_load_balance_asymmetric,
  ]
  INTF_ALL_PROPS = INTF_NON_BOOL_PROPS + INTF_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@interface_port_channel',
                                            INTF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@interface_port_channel',
                                            INTF_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @interface_port_channel = Cisco::InterfacePortChannel.interfaces[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(interface_name, intf)
    debug "Checking instance, #{interface_name}."
    current_state = {
      interface: interface_name,
      name:      interface_name,
      ensure:    :present,
    }
    # Call node_utils getter for each property
    INTF_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = intf.send(prop)
    end
    INTF_BOOL_PROPS.each do |prop|
      val = intf.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    interfaces = []
    Cisco::InterfacePortChannel.interfaces.each do |interface_name, intf|
      begin
        interfaces << properties_get(interface_name, intf)
      end
    end
    interfaces
  end # self.instances

  def self.prefetch(resources)
    interfaces = instances
    resources.keys.each do |name|
      provider = interfaces.find { |intf| intf.instance_name == name }
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
    INTF_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_interface
      unless @property_flush[prop].nil?
        @interface_port_channel.send("#{prop}=", @property_flush[prop]) if
          @interface_port_channel.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @interface_port_channel.destroy
      @interface_port_channel = nil
    else
      # Create/Update
      if @interface_port_channel.nil?
        new_interface = true
        @interface_port_channel = Cisco::InterfacePortChannel.new(@resource[:interface])
      end
      properties_set(new_interface)
    end
    puts_config
  end

  def puts_config
    if @interface_port_channel.nil?
      info "Interface=#{@resource[:interface]} is absent."
      return
    end

    # Dump all current properties for this interface
    current = sprintf("\n%30s: %s", 'interface', @interface_port_channel.name)
    INTF_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @interface_port_channel.send(prop)))
    end
    debug current
  end # puts_config
end # Puppet::Type
