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

Puppet::Type.type(:cisco_fabricpath_topology).provide(:cisco) do
  desc 'The new Cisco provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  TOPO_NON_BOOL_PROPS = [:member_vlans, :topo_name]
  TOPO_ALL_PROPS = TOPO_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@topo',
                                            TOPO_NON_BOOL_PROPS)
  def initialize(value={})
    super(value)
    @topo = Cisco::FabricpathTopo.topos[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_fabricpath_topology.'
  end

  def self.properties_get(topo_id, t)
    debug "Checking instance, topo #{topo_id}"
    current_state = {
      topo_id: topo_id,
      name:    topo_id,
      ensure:  :present,
    }

    # Call node_utils getter for each property
    TOPO_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = t.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    topos = []
    Cisco::FabricpathTopo.topos.each do |topo_id, t|
      topos << properties_get(topo_id, t)
    end
    topos
  end

  def self.prefetch(resources)
    topos = instances

    resources.keys.each do |id|
      provider = topos.find { |topo| topo.instance_name == id }
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
    debug "returning topo-id #{topo_id} for inst_name"
    topo_id
  end

  def properties_set(new_topo=false)
    TOPO_ALL_PROPS.each do |prop|
      next if prop == :state # no setter for topo state
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_topo
      unless @property_flush[prop].nil?
        @topo.send("#{prop}=", @property_flush[prop]) if
          @topo.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @topo.destroy
      @topo = nil
    else
      # Create/Update
      if @topo.nil?
        new_topo = true
        @topo = Cisco::FabricpathTopo.new(@resource[:topo_id])
      end
      properties_set(new_topo)
    end
    puts_config
  end

  def puts_config
    if @topo.nil?
      info "Topo=#{@resource[:topo_id]} is absent."
      return
    end

    # Dump all current properties for this topo
    current = sprintf("\n%30s: %s", 'topo', instance_name)
    TOPO_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @topo.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
