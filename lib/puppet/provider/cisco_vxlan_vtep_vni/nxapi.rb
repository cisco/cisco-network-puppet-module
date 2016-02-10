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
  VXLAN_VTEP_VNI_ARRAY_FLAT_PROPS = [
    :peer_list
  ]
  # NOTE: For maintainability please keep this list in alphabetical order.
  VXLAN_VTEP_VNI_NON_BOOL_PROPS = [
    :ingress_replication,
    :multicast_group,
  ]

  VXLAN_VTEP_VNI_BOOL_PROPS = [
    :suppress_arp
  ]

  VXLAN_VTEP_VNI_ALL_PROPS =
    VXLAN_VTEP_VNI_ARRAY_FLAT_PROPS + VXLAN_VTEP_VNI_NON_BOOL_PROPS + VXLAN_VTEP_VNI_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@vtep_vni',
                                            VXLAN_VTEP_VNI_ARRAY_FLAT_PROPS)
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
  end

  def self.properties_get(interface, vni, vni_instance)
    debug "Checking instance, name #{interface} #{vni}"
    current_state = {
      name:   	  "#{interface} #{vni}",
      interface: interface,
      vni:       vni,
      assoc_vrf: vni_instance.assoc_vrf,
      ensure:    :present,
    }
    # Call node_utils getter for each property
    VXLAN_VTEP_VNI_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = vni_instance.send(prop)
    end
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
    new(current_state)
  end # self.properties_get

  def self.instances
    vnis = []
    Cisco::VxlanVtepVni.vnis.each do |interface, all_vnis|
      all_vnis.each do |vni, vni_instance|
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
        vni.vni.to_s == resources[id][:vni].to_s &&
        vni.assoc_vrf.to_s == resources[id][:assoc_vrf].to_s
      end
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
    VXLAN_VTEP_VNI_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      if new_vni
        # Set @property_flush for the current object
        send("#{prop}=", @resource[prop])
      end
      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the @vtep_vni node_utils object.
      @vtep_vni.send("#{prop}=", @property_flush[prop]) if
        @vtep_vni.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vtep_vni.destroy
      @vtep_vni = nil
    else
      # Create/Update
      if @vtep_vni.nil?
        new_vni = true
        assoc_vrf = @resource[:assoc_vrf] == :true ? true : false
        @vtep_vni = Cisco::VxlanVtepVni.new(@resource[:interface], @resource[:vni], assoc_vrf)
      end
      properties_set(new_vni)
    end
  end
end   # Puppet::Type
