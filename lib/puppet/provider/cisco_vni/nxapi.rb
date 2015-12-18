# The NXAPI provider for cisco vni.
#
# December, 2015
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

Puppet::Type.type(:cisco_vni).provide(:nxapi) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  VNI_PROPS = [:mapped_vlan]

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@vni',
                                            VNI_PROPS)

  def initialize(value={})
    super(value)
    @vni = Cisco::Vni.vnis[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_vni.'
  end

  def self.properties_get(vni_id, vni)
    debug "Checking instance, vni #{vni_id}"
    current_state = {
      vni:    vni_id,
      name:   vni_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    VNI_PROPS.each do |prop|
      current_state[prop] = vni.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    vnis = []
    Cisco::Vni.vnis.each do |vni_id, vni|
      vnis << properties_get(vni_id, vni)
    end
    vnis
  end

  def self.prefetch(resources)
    vnis = instances

    resources.keys.each do |id|
      provider = vnis.find { |vni| vni.instance_name == id }
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
    vni
  end

  def properties_set(new_vni=false)
    VNI_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vni
      unless @property_flush[prop].nil?
        @vni.send("#{prop}=", @property_flush[prop]) if
          @vni.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vni.destroy
      @vni = nil
    else
      # Create/Update
      if @vni.nil?
        new_vni = true
        @vni = Cisco::Vni.new(@resource[:vni])
      end
      properties_set(new_vni)
    end
    puts_config
  end

  def puts_config
    if @vni.nil?
      info "Vni=#{@resource[:vni]} is absent."
      return
    end

    # Dump all current properties for this vni
    current = sprintf("\n%30s: %s", 'vni', instance_name)
    VNI_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @vni.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
