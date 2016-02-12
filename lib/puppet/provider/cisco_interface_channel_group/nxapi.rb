#
# The NXAPI provider for cisco_interface_channel_group.
#
# January 2016
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

Puppet::Type.type(:cisco_interface_channel_group).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_interface_channel_group.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol arrays for method auto-generation. There are separate arrays
  # because the boolean-based methods are processed slightly different.
  # Note: channel_group should always process first.
  INTF_CG_NON_BOOL_PROPS = [
    :channel_group,
    :description,
  ]
  INTF_CG_BOOL_PROPS = [
    :shutdown
  ]
  INTF_CG_ALL_PROPS = INTF_CG_NON_BOOL_PROPS + INTF_CG_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            INTF_CG_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            INTF_CG_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::InterfaceChannelGroup.interfaces[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(intf_name, nu_obj)
    debug "Checking instance, #{intf_name}."
    current_state = {
      interface: intf_name,
      name:      intf_name,
      ensure:    :present,
    }
    # Call node_utils getter for each property
    INTF_CG_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    INTF_CG_BOOL_PROPS.each do |prop|
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
    all_intf = []
    Cisco::InterfaceChannelGroup.interfaces.each do |intf_name, nu_obj|
      begin
        all_intf << properties_get(intf_name, nu_obj)
      end
    end
    all_intf
  end # self.instances

  def self.prefetch(resources)
    all_intf = instances
    resources.keys.each do |name|
      provider = all_intf.find { |intf| intf.instance_name == name }
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
    INTF_CG_ALL_PROPS.each do |prop|
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
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_interface = true
        @nu = Cisco::InterfaceChannelGroup.new(@resource[:interface])
      end
      properties_set(new_interface)
    end
  end
end # Puppet::Type
