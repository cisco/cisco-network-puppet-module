#
# The NXAPI provider for cisco_vxlan_vtep.
#
# December 2015 Michael G. Wiebe
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

Puppet::Type.type(:cisco_vxlan_vtep).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  # NOTE: For maintainability please keep this list in alphabetical order.
  VXLAN_VTEP_NON_BOOL_PROPS = [
    :description,
    :host_reachability,
    :source_interface,
  ]

  VXLAN_VTEP_BOOL_PROPS = [
    :shutdown
  ]

  VXLAN_VTEP_ALL_PROPS = VXLAN_VTEP_NON_BOOL_PROPS + VXLAN_VTEP_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@vtep_interface',
                                            VXLAN_VTEP_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@vtep_interface',
                                            VXLAN_VTEP_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @vtep_interface = Cisco::VxlanVtep.vteps[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(interface_name, intf)
    debug "Checking vtep instance, #{interface_name}."
    current_state = {
      interface: interface_name,
      name:      interface_name,
      ensure:    :present,
    }
    # Call node_utils getter for each property
    VXLAN_VTEP_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = intf.send(prop)
    end
    VXLAN_VTEP_BOOL_PROPS.each do |prop|
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
    Cisco::VxlanVtep.vteps.each do |interface_name, intf|
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
    VXLAN_VTEP_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_interface
      unless @property_flush[prop].nil?
        @vtep_interface.send("#{prop}=", @property_flush[prop]) if
          @vtep_interface.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vtep_interface.destroy
      @vtep_interface = nil
    else
      # Create/Update
      if @vtep_interface.nil?
        new_vtep_interface = true
        @vtep_interface = Cisco::VxlanVtep.new(@resource[:interface])
      end
      properties_set(new_vtep_interface)
    end
    puts_config
  end

  def puts_config
    if @vtep_interface.nil?
      info "Vxlan Vtep Interface=#{@resource[:interface]} is absent."
      return
    end

    # Dump all current properties for this interface
    current = sprintf("\n%30s: %s", 'interface', @vtep_interface.name)
    VXLAN_VTEP_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @vtep_interface.send(prop)))
    end
    # debug current
    puts current
  end # puts_config
end
