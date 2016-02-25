# The NXAPI provider for cisco evpn vni.
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

Puppet::Type.type(:cisco_evpn_vni).provide(:nxapi) do
  desc 'The NXAPI provider for cisco evpn vni'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  #
  # NOTE: For maintainability please keep this list in alphabetical order and
  # one property per line.

  EVPN_VNI_PROPS = [
    :route_distinguisher,
    :route_target_both,
    :route_target_export,
    :route_target_import,
  ]

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@evpn_vni',
                                            EVPN_VNI_PROPS)

  def initialize(value={})
    super(value)
    @evpn_vni = Cisco::EvpnVni.vnis[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_evpn_vni.'
  end # initialize

  def self.properties_get(vni_id, vni)
    debug "Checking instance, vni #{vni_id}"
    current_state = {
      vni:    vni_id,
      name:   vni_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    EVPN_VNI_PROPS.each do |prop|
      current_state[prop] = vni.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    vnis = []
    Cisco::EvpnVni.vnis.each do |vni_id, vni|
      vnis << properties_get(vni_id, vni)
    end
    vnis
  end # self.instances

  def self.prefetch(resources)
    vnis = instances

    resources.keys.each do |id|
      provider = vnis.find { |vni| vni.instance_name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end

  def exists?
    @property_hash[:ensure] == :present
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
    EVPN_VNI_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vni
      unless @property_flush[prop].nil?
        @evpn_vni.send("#{prop}=", @property_flush[prop]) if
          @evpn_vni.respond_to?("#{prop}=")
      end
    end
  end # properties_set

  def route_target_both
    return @property_hash[:route_target_both] if @resource[:route_target_import].nil?
    if @resource[:route_target_both][0] == :default &&
       @property_hash[:route_target_both] == @evpn_vni.default_route_target_both
      return [:default]
    else
      @property_hash[:route_target_both]
    end
  end

  # route_target setters: These properties expect a flat array but optionally
  # support a string of space-separated values in the manifest; however,
  # munge will transform the string into a nested array, hence the flatten.
  def route_target_both=(should_list)
    puts "setter: #{should_list}"
    should_list = @evpn_vni.default_route_target_both if should_list[0] == :default
    @property_flush[:route_target_both] = should_list.flatten
  end

  def route_target_export
    return @property_hash[:route_target_export] if @resource[:route_target_import].nil?
    if @resource[:route_target_export][0] == :default &&
       @property_hash[:route_target_export] == @evpn_vni.default_route_target_export
      return [:default]
    else
      @property_hash[:route_target_export]
    end
  end

  def route_target_export=(should_list)
    puts "setter: #{should_list}"
    should_list = @evpn_vni.default_route_target_export if should_list[0] == :default
    @property_flush[:route_target_export] = should_list.flatten
  end

  def route_target_import
    return @property_hash[:route_target_import] if @resource[:route_target_import].nil?
    if @resource[:route_target_import][0] == :default &&
       @property_hash[:route_target_import] == @evpn_vni.default_route_target_import
      return [:default]
    else
      @property_hash[:route_target_import]
    end
  end

  def route_target_import=(should_list)
    puts "setter: #{should_list}"
    should_list = @evpn_vni.default_route_target_import if should_list[0] == :default
    @property_flush[:route_target_import] = should_list.flatten
  end

  def flush
    if @property_flush[:ensure] == :absent
      @evpn_vni.destroy
      @evpn_vni = nil
    else
      # Create/Update
      if @evpn_vni.nil?
        new_vni = true
        @evpn_vni = Cisco::EvpnVni.new(@resource[:vni])
      end
      properties_set(new_vni)
    end
    puts_config
  end

  def puts_config
    if @evpn_vni.nil?
      info "Vni=#{@resource[:vni]} is absent."
      return
    end

    # Dump all current properties for this evpn_vni
    current = sprintf("\n%30s: %s", 'evpn_vni', instance_name)
    EVPN_VNI_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @evpn_vni.send(prop)))
    end
    debug current
  end # puts_config
end # Puppet::Type
