# The NXAPI provider for cisco vni to vtep binding.
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

Puppet::Type.type(:cisco_vxlan_vtep_vni).provide(:nxapi) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  # NOTE: For maintainability please keep this list in alphabetical order.
  VXLAN_VTEP_VNI_NON_BOOL_PROPS = [
    :ingress_replication,
    :multicast_group,
  ]

  VXLAN_VTEP_VNI_BOOL_PROPS = [
    :suppress_arp
  ]

  VXLAN_VTEP_VNI_ALL_PROPS = VXLAN_VTEP_VNI_NON_BOOL_PROPS + VXLAN_VTEP_VNI_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@vtep_vni',
                                            VXLAN_VTEP_VNI_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@vtep_vni',
                                            VXLAN_VTEP_VNI_BOOL_PROPS)

  def initialize(value={})
    super(value)
    interface = @property_hash[:interface]
    vni = @property_hash[:vni]
    @vtep_vni = Cisco::VxlanVtepVni.vnis[interface][vni] unless
      interface.nil? || vni.nil?
    @property_flush = {}
    puts "property_hash = #{@property_hash}, vtep_vni = #{@vtep_vni}"
    debug 'Created provider instance of cisco_vxlan_vtep_vni.'
  end

  def self.properties_get(interface, vni, vni_instance)
    debug "Checking instance, name #{interface} #{vni}"
    current_state = {
      name:   	  "#{interface} #{vni}",
      interface: interface,
      vni:       vni,
      assoc_vrf: vni_instance.assoc_vrf,
      ensure:    :present,
      peer_ips:  vni_instance.peer_list,
    }
    # Call node_utils getter for each property
    VXLAN_VTEP_VNI_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = vni_instance.send(prop)
    end
    VXLAN_VTEP_VNI_BOOL_PROPS.each do |prop|
      val = vni_instance.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    puts "curent_state = #{current_state}"
    new(current_state)
  end # self.properties_get

  def self.instances
    vnis = []
    Cisco::VxlanVtepVni.vnis.each do |interface, all_vnis|
      all_vnis.each do |vni, vni_instance|
        puts "vni = #{vni}"
 #       puts "assoc_vrf = #{vni_instance.assoc_vrf}"
        puts "vni_instance = #{vni_instance.inspect}"
        vnis << properties_get(interface, vni, vni_instance)
      end
    end
    vnis
  end

  def self.prefetch(resources)
    vnis = instances
    resources.keys.each do |id|
      provider = vnis.find do |vni|
        vni.interface.to_s == resources[id][:interface].to_s &&
        vni.vni == resources[id][:vni] &&
        vni.assoc_vrf.to_s == resources[id][:assoc_vrf].to_s
      end
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    puts "exists? #{(@property_hash[:ensure] == :present)}"
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
    VXLAN_VTEP_VNI_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vni
      unless @property_flush[prop].nil?
        @vtep_vni.send("#{prop}=", @property_flush[prop]) if
          @vtep_vni.respond_to?("#{prop}=")
      end
    end
    # node utils is named peer_list= instead of peer_ips=
    return unless @resource[:peer_ips]
    self.peer_ips = @resource[:peer_ips] if new_vni
    @vtep_vni.peer_list = @property_flush[:peer_ips] unless
      @property_flush[:peer_ips].nil?
  end

  # can't autogen peer_ips, special array handling
  def peer_ips
    return [:default] if @resource[:peer_ips] &&
                         @resource[:peer_ips][0] == :default &&
                         @property_hash[:peer_ips] ==
                         @vtep_vni.default_peer_list
    @property_hash[:peer_ips]
  end

  def peer_ips=(set_value)
    if set_value.is_a?(Array) && set_value[0] == :default
      set_value = @vtep_vni.default_peer_list
    end
    @property_flush[:peer_ips] = set_value
  end

  def flush
    if @property_flush[:ensure] == :absent
      puts "vni to be destroyed = #{@vtep_vni}"
      @vtep_vni.destroy
      @vtep_vni = nil
    else
      # Create/Update
      if @vtep_vni.nil?
        new_vni = true
        puts "flush create..."
        puts @resource[:interface]
        puts @resource[:vni]
        puts @resource[:assoc_vrf]
        puts "flush create end..."
        @vtep_vni = Cisco::VxlanVtepVni.new(@resource[:interface], @resource[:vni], @resource[:assoc_vrf])
        puts "created vni = #{@vtep_vni}"
      end
      properties_set(new_vni)
    end
    puts_config
  end

  def puts_config
    if @vtep_vni.nil?
      info "Vxlan Vtep Vni=#{@resource[:vni]} is absent."
      return
    end

    # Dump all current properties for this vni
    current = sprintf("\n%30s: %s", 'vtep_vni', instance_name)
    VXLAN_VTEP_VNI_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @vtep_vni.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
