# The Cisco provider for cisco_bfd_global
#
# May, 2016
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

Puppet::Type.type(:cisco_bfd_global).provide(:cisco) do
  desc 'The Cisco bfd_global provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  BFD_GLOBAL_NON_BOOL_PROPS = [
    :echo_interface,
    :echo_rx_interval,
    :fabricpath_slow_timer,
    :fabricpath_vlan,
    :ipv4_echo_rx_interval,
    :ipv4_slow_timer,
    :ipv6_echo_rx_interval,
    :ipv6_slow_timer,
    :slow_timer,
    :startup_timer,
  ]

  BFD_GLOBAL_ARRAY_FLAT_PROPS = [
    :fabricpath_interval,
    :interval,
    :ipv4_interval,
    :ipv6_interval,
  ]

  BFD_GLOBAL_ALL_PROPS = BFD_GLOBAL_ARRAY_FLAT_PROPS + BFD_GLOBAL_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            BFD_GLOBAL_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            BFD_GLOBAL_ARRAY_FLAT_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::BfdGlobal.new
    @property_flush = {}
  end

  def self.properties_get(nu_obj)
    current_state = {
      name:   'default',
      ensure: :present,
    }

    # Call node_utils getter for each property
    BFD_GLOBAL_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    BFD_GLOBAL_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    # nested array properties
    current_state[:fabricpath_interval] = nu_obj.fabricpath_interval
    current_state[:interval] = nu_obj.interval
    current_state[:ipv4_interval] = nu_obj.ipv4_interval
    current_state[:ipv6_interval] = nu_obj.ipv6_interval
    new(current_state)
  end # self.properties_get

  def self.instances
    globals = []
    return globals unless Cisco::Feature.bfd_enabled?
    bfd = Cisco::BfdGlobal.new
    globals << properties_get(bfd)
    globals
  end

  def self.prefetch(resources)
    resources.values.first.provider = instances.first unless instances.first.nil?
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
    name
  end

  def properties_set(new_global=false)
    BFD_GLOBAL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_global
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
      new_global = false
      if @nu.nil?
        new_global = true
        @nu = Cisco::BfdGlobal.new
      end
      properties_set(new_global)
    end
  end
end # Puppet::Type
