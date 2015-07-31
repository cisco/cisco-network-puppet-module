#
# The NXAPI provider for cisco___RESOURCE_NAME__.
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

Puppet::Type.type(:cisco___RESOURCE_NAME__).provide(:nxapi) do
  desc "The NXAPI provider for cisco___RESOURCE_NAME__."

  confine :feature => :cisco_node_utils

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
  __CONSTANT_NAME___NON_BOOL_PROPS = [
    :__PROPERTY_INT__,
  ]
  __CONSTANT_NAME___BOOL_PROPS = [
    :__PROPERTY_BOOL__,
  ]
  __CONSTANT_NAME___ALL_PROPS =
    __CONSTANT_NAME___NON_BOOL_PROPS + __CONSTANT_NAME___BOOL_PROPS

  # Dynamic method generation for getters & setters
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, "@__RESOURCE_NAME__",
                                            __CONSTANT_NAME___NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, "@__RESOURCE_NAME__",
                                            __CONSTANT_NAME___BOOL_PROPS)

  def initialize(value={})
    super(value)
    @__RESOURCE_NAME__ = Cisco::__CLASS_NAME__.routers[@property_hash[:name]]
    @property_flush = {}
  end

  def self.get_properties(instance_name, inst)
    debug "Checking instance, #{instance_name}."
    current_state = {
      :name => instance_name,
      :ensure => :present,
    }
    # Call node_utils getter for each property
    __CONSTANT_NAME___NON_BOOL_PROPS.each { |prop|
      current_state[prop] = inst.send(prop)
    }
    __CONSTANT_NAME___BOOL_PROPS.each { |prop|
      val = inst.send(prop)
      current_state[prop] = val.nil? ? nil : (val ? :true : :false)
    }
    new(current_state)
  end # self.get_properties

  def self.instances
    instance_array = []
    Cisco::__CLASS_NAME__.routers.each { | instance_name, inst |
      begin
        instance_array << get_properties(instance_name, inst)
      end
    }
    return instance_array
  end # self.instances

  def self.prefetch(resources)
    instance_array = instances
    resources.keys.each do |name|
      provider = instance_array.find { |inst| inst.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    return (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def set_properties(new_instance=false)
    __CONSTANT_NAME___ALL_PROPS.each { |prop|
      if @resource[prop]
        if new_instance
          # Call puppet setter to set @property_flush[prop]
          self.send("#{prop}=", @resource[prop])
        end
        unless @property_flush[prop].nil?
          # Call node_utils setter to update node
          @__RESOURCE_NAME__.send("#{prop}=", @property_flush[prop]) if
            @__RESOURCE_NAME__.respond_to?("#{prop}=")
        end
      end
    }
  end

  def flush
    if @property_flush[:ensure] == :absent
      @__RESOURCE_NAME__.destroy
      @__RESOURCE_NAME__ = nil
    else
      # Create/Update
      if @__RESOURCE_NAME__.nil?
        new_instance = true
        @__RESOURCE_NAME__ = Cisco::__CLASS_NAME__.new(@resource[:name])
      end
      set_properties(new_instance)
    end
  end

end
