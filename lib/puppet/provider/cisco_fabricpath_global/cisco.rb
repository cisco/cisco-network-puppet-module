# February, 2016
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_fabricpath_global).provide(:cisco) do
  desc 'The Cisco provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  FP_GLOBAL_NON_BOOL_PROPS = [
    :allocate_delay,
    :graceful_merge,
    :linkup_delay,
    :loadbalance_algorithm,
    :loadbalance_multicast_rotate,
    :loadbalance_unicast_layer,
    :loadbalance_unicast_rotate,
    :mode,
    :switch_id,
    :transition_delay,
    :ttl_unicast,
    :ttl_multicast,
  ]
  FP_GLOBAL_BOOL_PROPS = [
    :aggregate_multicast_routes,
    :linkup_delay_always,
    :linkup_delay_enable,
    :loadbalance_multicast_has_vlan,
    :loadbalance_unicast_has_vlan,
  ]
  FP_GLOBAL_ALL_PROPS = FP_GLOBAL_NON_BOOL_PROPS + FP_GLOBAL_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@fp_global',
                                            FP_GLOBAL_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@fp_global',
                                            FP_GLOBAL_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @fp_global = Cisco::FabricpathGlobal.globals[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_fabricpath_global'
  end

  def self.properties_get(global_id, v)
    debug "Checking instance, global #{global_id}"
    current_state = {
      name:   global_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    FP_GLOBAL_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = v.send(prop)
    end
    FP_GLOBAL_BOOL_PROPS.each do |prop|
      val = v.send(prop)
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
    Cisco::FabricpathGlobal.globals.each do |global_id, v|
      globals << properties_get(global_id, v)
    end
    globals
  end

  def self.prefetch(resources)
    globals = instances

    resources.keys.each do |id|
      provider = globals.find { |global| global.instance_name == id }
      resources[id].provider = provider unless provider.nil?
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
    name
  end

  def properties_set(new_global=false)
    FP_GLOBAL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_global
      unless @property_flush[prop].nil?
        @fp_global.send("#{prop}=", @property_flush[prop]) if
          @fp_global.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    loadbalance_multicast_set
    loadbalance_unicast_set
  end

  def loadbalance_multicast_prop_any?
    @property_flush[:loadbalance_multicast_rotate] ||
      @property_flush[:loadbalance_multicast_has_vlan]
  end

  def loadbalance_multicast_set
    return unless loadbalance_multicast_prop_any?
    if @property_flush[:loadbalance_multicast_rotate]
      rotate = @property_flush[:loadbalance_multicast_rotate]
    else
      rotate = @fp_global.loadbalance_multicast_rotate
    end
    if @property_flush[:loadbalance_multicast_has_vlan]
      has_vlan = @property_flush[:loadbalance_multicast_has_vlan]
    else
      has_vlan = @fp_global.loadbalance_multicast_has_vlan
    end
    @fp_global.send(:loadbalance_multicast=, rotate, has_vlan)
  end

  def loadbalance_unicast_prop_any?
    @property_flush[:loadbalance_unicast_rotate] ||
      @property_flush[:loadbalance_unicast_has_vlan] ||
      @property_flush[:loadbalance_unicast_layer]
  end

  def loadbalance_unicast_set
    return unless loadbalance_unicast_prop_any?
    if @property_flush[:loadbalance_unicast_layer]
      pref = @property_flush[:loadbalance_unicast_layer]
    else
      pref = @fp_global.loadbalance_unicast_layer
    end
    if @property_flush[:loadbalance_unicast_rotate]
      rotate = @property_flush[:loadbalance_unicast_rotate]
    else
      rotate = @fp_global.loadbalance_unicast_rotate
    end
    if @property_flush[:loadbalance_unicast_has_vlan]
      has_vlan = @property_flush[:loadbalance_unicast_has_vlan]
    else
      has_vlan = @fp_global.loadbalance_unicast_has_vlan
    end
    @fp_global.send(:loadbalance_unicast=, pref, rotate, has_vlan)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @fp_global.destroy
      @fp_global = nil
    else
      # Create/Update
      new_global = false
      if @fp_global.nil?
        new_global = true
        @fp_global = Cisco::FabricpathGlobal.new(@resource[:name])
      end
      properties_set(new_global)
    end
    puts_config
  end

  def puts_config
    if @fp_global.nil?
      info "FabricpathGlobal=#{@resource[:name]} is absent."
      return
    end

    # Dump all current properties for this global
    current = sprintf("\n%30s: %s", 'name', instance_name)
    FP_GLOBAL_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @fp_global.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
