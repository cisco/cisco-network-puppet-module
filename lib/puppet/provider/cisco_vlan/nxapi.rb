# The NXAPI provider for cisco vlan.
#
# November, 2014
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_vlan).provide(:nxapi) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  VLAN_NON_BOOL_PROPS = [:mapped_vni, :state, :vlan_name]
  VLAN_BOOL_PROPS = [:shutdown]
  VLAN_ALL_PROPS = VLAN_NON_BOOL_PROPS + VLAN_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@vlan',
                                            VLAN_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@vlan',
                                            VLAN_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @vlan = Cisco::Vlan.vlans[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_vlan.'
  end

  def self.properties_get(vlan_id, v)
    debug "Checking instance, vlan #{vlan_id}"
    current_state = {
      vlan:   vlan_id,
      name:   vlan_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    VLAN_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = v.send(prop)
    end
    VLAN_BOOL_PROPS.each do |prop|
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
    vlans = []
    Cisco::Vlan.vlans.each do |vlan_id, v|
      vlans << properties_get(vlan_id, v)
    end
    vlans
  end

  def self.prefetch(resources)
    vlans = instances

    resources.keys.each do |id|
      provider = vlans.find { |vlan| vlan.instance_name == id }
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
    vlan
  end

  def properties_set(new_vlan=false)
    VLAN_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vlan
      unless @property_flush[prop].nil?
        @vlan.send("#{prop}=", @property_flush[prop]) if
          @vlan.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vlan.destroy
      @vlan = nil
    else
      # Create/Update
      if @vlan.nil?
        new_vlan = true
        @vlan = Cisco::Vlan.new(@resource[:vlan])
      end
      properties_set(new_vlan)
    end
    puts_config
  end

  def puts_config
    if @vlan.nil?
      info "Vlan=#{@resource[:vlan]} is absent."
      return
    end

    # Dump all current properties for this vlan
    current = sprintf("\n%30s: %s", 'vlan', instance_name)
    VLAN_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @vlan.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
