# The Cisco provider for cisco_hsrp_global
#
# October, 2016
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

Puppet::Type.type(:cisco_hsrp_global).provide(:cisco) do
  desc 'New Cisco provider for Hsrp Global'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  HSRP_GLOBAL_NON_BOOL_PROPS = [
    :extended_hold
  ]
  HSRP_GLOBAL_BOOL_PROPS = [
    :bfd_all_intf
  ]
  HSRP_GLOBAL_ALL_PROPS = HSRP_GLOBAL_NON_BOOL_PROPS + HSRP_GLOBAL_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            HSRP_GLOBAL_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            HSRP_GLOBAL_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::HsrpGlobal.new
    @property_flush = {}
    debug 'Created provider instance of cisco_hsrp_global'
  end

  def self.properties_get(global_id, nu_obj)
    debug "Checking instance, global #{global_id}"
    current_state = {
      name: global_id
    }

    # Call node_utils getter for each property
    HSRP_GLOBAL_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    HSRP_GLOBAL_BOOL_PROPS.each do |prop|
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
    globals = []
    Cisco::HsrpGlobal.globals.each do |global_id, nu_obj|
      globals << properties_get(global_id, nu_obj)
    end
    globals
  end

  def self.prefetch(resources)
    globals = instances

    resources.keys.each do |id|
      provider = globals.find { |nu_obj| nu_obj.instance_name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def instance_name
    name
  end

  def properties_set(new_hg=false)
    HSRP_GLOBAL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_hg
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    new_hg = false
    if @nu.nil?
      new_hg = true
      @nu = Cisco::HsrpGlobal.new
    end
    properties_set(new_hg)
  end
end # Puppet::Type
