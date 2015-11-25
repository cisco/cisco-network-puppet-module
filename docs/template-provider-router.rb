#
# The NXAPI provider for cisco_X__RESOURCE_NAME__X.
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

Puppet::Type.type(:cisco_X__RESOURCE_NAME__X).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_X__RESOURCE_NAME__X.'

  confine feature: :cisco_node_utils

  mk_resource_methods

  # -----------------------------------------------------------------------
  # TEMPLATE STEP 1. Add property names to the *_PROPS arrays. The AutoGen
  #          code will dynamically create getter & setter methods for each
  #          property in the arrays. Some multi-value properties like
  #          ip_address/masklen will require customer getters & setters.
  #          See existing providers for example code.
  # -----------------------------------------------------------------------
  # Property symbol arrays for method auto-generation. There are separate arrays
  # because the boolean-based methods are processed slightly different.
  X__CONSTANT_NAME__X_NON_BOOL_PROPS = [
    :X__PROPERTY_INT__X
  ]
  X__CONSTANT_NAME__X_BOOL_PROPS = [
    :X__PROPERTY_BOOL__X
  ]
  X__CONSTANT_NAME__X_ALL_PROPS =
    X__CONSTANT_NAME__X_NON_BOOL_PROPS + X__CONSTANT_NAME__X_BOOL_PROPS

  # Dynamic method generation for getters & setters
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@X__RESOURCE_NAME__X',
                                            X__CONSTANT_NAME__X_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@X__RESOURCE_NAME__X',
                                            X__CONSTANT_NAME__X_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @X__RESOURCE_NAME__X = Cisco::X__CLASS_NAME__X.routers[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(instance_name, inst)
    debug "Checking instance, #{instance_name}."
    current_state = {
      name:   instance_name,
      ensure: :present,
    }
    # Call node_utils getter for each property
    X__CONSTANT_NAME__X_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = inst.send(prop)
    end

    X__CONSTANT_NAME__X_BOOL_PROPS.each do |prop|
      val = inst.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end

    new(current_state)
  end # self.properties_get

  def self.instances
    instance_array = []
    Cisco::X__CLASS_NAME__X.routers.each do |instance_name, inst|
      begin
        instance_array << properties_get(instance_name, inst)
      end
    end
    instance_array
  end # self.instances

  def self.prefetch(resources)
    instance_array = instances
    resources.keys.each do |name|
      provider = instance_array.find { |inst| inst.name == name }
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

  def properties_set(new_instance=false)
    X__CONSTANT_NAME__X_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      # Call puppet setter to set @property_flush[prop]
      send("#{prop}=", @resource[prop]) if new_instance
      next if @property_flush[prop].nil?
      # Call node_utils setter to update node
      @X__RESOURCE_NAME__X.send("#{prop}=", @property_flush[prop]) if
        @X__RESOURCE_NAME__X.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @X__RESOURCE_NAME__X.destroy
      @X__RESOURCE_NAME__X = nil
    else
      # Create/Update
      if @X__RESOURCE_NAME__X.nil?
        new_instance = true
        @X__RESOURCE_NAME__X = Cisco::X__CLASS_NAME__X.new(@resource[:name])
      end
      properties_set(new_instance)
    end
  end
end
