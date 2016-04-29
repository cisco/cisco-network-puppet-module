# The NXAPI provider for cisco bridge domain.
#
# March, 2016
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

Puppet::Type.type(:cisco_bridge_domain).provide(:cisco) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  BD_NON_BOOL_PROPS = [:bd_name]
  BD_BOOL_PROPS = [:fabric_control, :shutdown]
  BD_ALL_PROPS = BD_NON_BOOL_PROPS + BD_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            BD_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            BD_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::BridgeDomain.bds[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_bridge_domain.'
  end

  def self.properties_get(bd_id, nu)
    debug "Checking instance, bd #{bd_id}"
    current_state = {
      bd:     bd_id,
      name:   bd_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    BD_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu.send(prop)
    end
    BD_BOOL_PROPS.each do |prop|
      val = nu.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    bds = []
    Cisco::BridgeDomain.bds.each do |bd_id, nu|
      bds << properties_get(bd_id, nu)
    end
    bds
  end

  def self.prefetch(resources)
    bds = instances

    resources.keys.each do |id|
      provider = bds.find { |bd| bd.instance_name == id }
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
    bd
  end

  def properties_set(new_bd=false)
    BD_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_bd
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
        new_bd = true
        @nu = Cisco::BridgeDomain.new(@resource[:bd])
      end
      properties_set(new_bd)
    end
    puts_config
  end

  def puts_config
    if @nu.nil?
      debug "BD=#{@resource[:bd]} is absent."
      return
    end

    # Dump all current properties for this bd
    current = sprintf("\n%30s: %s", 'bd', instance_name)
    BD_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @nu.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
