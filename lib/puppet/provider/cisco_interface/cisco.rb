# May 2015
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_interface).provide(:cisco) do
  desc 'The provider for cisco_interface.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: [:ios_xr, :nexus]

  mk_resource_methods

  # Property symbol arrays for getter/setter method auto-generation. Separate
  # arrays are used to classify different property behaviors and generate
  # appropriate dynamic methods. Note that some auto-generated methods may be
  # overridden within this file; e.g. the vrf getter is auto-generated but the
  # vrf setter is overridden with an explicit method.
  # Please maintain the properties in alpha order except where noted.
  INTF_NON_BOOL_PROPS = [
    # Note: :switchport_mode must always process first to evaluate L2 vs L3
    :switchport_mode,
    # Note: :vrf must be the first L3 property to process
    :vrf,
    :access_vlan,
    :description,
    :encapsulation_dot1q,
    :ipv4_acl_in,
    :ipv4_acl_out,
    :ipv4_address,
    :ipv4_netmask_length,
    :ipv4_address_secondary,
    :ipv4_netmask_length_secondary,
    :ipv4_arp_timeout,
    :ipv6_acl_in,
    :ipv6_acl_out,
    :mtu,
    :speed,
    :duplex,
    :stp_bpdufilter,
    :stp_bpduguard,
    :stp_cost,
    :stp_guard,
    :stp_link_type,
    :stp_port_priority,
    :stp_port_type,
    :switchport_trunk_allowed_vlan,
    :switchport_trunk_native_vlan,
    :switchport_pvlan_trunk_native_vlan,
    :switchport_pvlan_trunk_allowed_vlan,
    :vlan_mapping,
    :vpc_id,
  ]
  INTF_BOOL_PROPS = [
    :bfd_echo,
    :fabric_forwarding_anycast_gateway,
    :ipv4_forwarding,
    :ipv4_pim_sparse_mode,
    :ipv4_proxy_arp,
    :ipv4_redirects,
    :negotiate_auto,
    :shutdown,
    :switchport_autostate_exclude,
    :switchport_pvlan_host,
    :switchport_pvlan_promiscuous,
    :switchport_pvlan_trunk_promiscuous,
    :switchport_pvlan_trunk_secondary,
    :switchport_vtp,
    :svi_autostate,
    :svi_management,
    :vlan_mapping_enable,
    :vpc_peer_link,
  ]
  INTF_ARRAY_FLAT_PROPS = [
    :pvlan_mapping,
    :stp_mst_cost,
    :stp_mst_port_priority,
    :stp_vlan_cost,
    :stp_vlan_port_priority,
    :switchport_pvlan_host_association,
    :switchport_pvlan_mapping,
  ]

  INTF_ARRAY_NESTED_PROPS = [
    :switchport_pvlan_mapping_trunk,
    :switchport_pvlan_trunk_association,
  ]

  # TBD: These DEPRECATED arrays will be removed with release 2.0.0
  DEPRECATED_INTF_FLAT = [
    :private_vlan_mapping,
    # Replaced by: pvlan_mapping
    :switchport_mode_private_vlan_host_association,
    # Replaced by: switchport_pvlan_host_association
    :switchport_mode_private_vlan_host_promisc,
    # Replaced by: switchport_pvlan_mapping,
    :switchport_private_vlan_trunk_allowed_vlan,
    # Replaced by: switchport_pvlan_trunk_allowed_vlan,
    :switchport_private_vlan_association_trunk,
    # Replaced by: switchport_pvlan_trunk_association
    :switchport_private_vlan_mapping_trunk,
    # Replaced by: switchport_pvlan_mapping_trunk
  ]
  DEPRECATED_INTF_BOOL = [
    :switchport_mode_private_vlan_trunk_promiscuous,
    # Replaced by: switchport_pvlan_trunk_promiscuous,
    :switchport_mode_private_vlan_trunk_secondary,
    # Replaced by: switchport_pvlan_trunk_secondary,
  ]
  DEPRECATED_INTF_NON_BOOL = [
    :switchport_mode_private_vlan_host,
    # Replaced by: switchport_pvlan_host,
    :switchport_private_vlan_trunk_allowed_vlan,
    # Replaced by: switchport_pvlan_trunk_allowed_vlan,
    :switchport_private_vlan_trunk_native_vlan,
    # Replaced by: switchport_pvlan_trunk_native_vlan,
  ]
  INTF_ARRAY_FLAT_PROPS.concat(DEPRECATED_INTF_FLAT)
  INTF_BOOL_PROPS.concat(DEPRECATED_INTF_BOOL)
  INTF_NON_BOOL_PROPS.concat(DEPRECATED_INTF_NON_BOOL)
  # End DEPRECATED

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            INTF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            INTF_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            INTF_ARRAY_FLAT_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_nested, self, '@nu',
                                            INTF_ARRAY_NESTED_PROPS)

  INTF_NON_BOOL_PROPS.concat(INTF_ARRAY_FLAT_PROPS + INTF_ARRAY_NESTED_PROPS)
  INTF_ALL_PROPS = INTF_NON_BOOL_PROPS + INTF_BOOL_PROPS

  def initialize(value={})
    super(value)
    @nu = Cisco::Interface.interfaces[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(interface_name, nu_obj)
    debug "Checking instance, #{interface_name}."
    current_state = {
      interface: interface_name,
      name:      interface_name,
      ensure:    :present,
    }
    # Call node_utils getter for each property
    INTF_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    INTF_BOOL_PROPS.each do |prop|
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
    interfaces = []
    Cisco::Interface.interfaces.each do |interface_name, nu_obj|
      begin
        # Not allowed to create an interface for mgmt0 or MgmtEth0/*
        next if interface_name.match(/mgmt/i)
        interfaces << properties_get(interface_name, nu_obj)
      end
    end
    interfaces
  end # self.instances

  def self.prefetch(resources)
    interfaces = instances
    resources.keys.each do |name|
      provider = interfaces.find { |intf| intf.instance_name == name }
      resources[name].provider = provider unless provider.nil?
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
    interface
  end

  def properties_set(new_interface=false)
    INTF_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_interface
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    ipv4_addr_mask_set
  end

  def ipv4_addr_mask_configure(secondary=false)
    if secondary
      v4_addr_prop = :ipv4_address_secondary
      v4_mask_prop = :ipv4_netmask_length_secondary
    else
      v4_addr_prop = :ipv4_address
      v4_mask_prop = :ipv4_netmask_length
    end

    # Combo property: ipv4 address/mask
    return unless @property_flush[v4_addr_prop] ||
                  @property_flush[v4_mask_prop] ||
                  @resource[v4_addr_prop] == :default

    if @resource[v4_addr_prop] == :default
      addr = @nu.default_ipv4_address
    else
      addr = @resource[v4_addr_prop]
    end

    if @resource[v4_mask_prop] == :default
      mask = @nu.default_ipv4_netmask_length
    else
      mask = @resource[v4_mask_prop]
    end
    @nu.ipv4_addr_mask_set(addr, mask, secondary)
  end

  def ipv4_addr_mask_set
    # Primary addr/mask must be configured before secondary addr/mask.
    # Secondary addr/mask must be removed before primary addr/mask.
    if @resource[:ipv4_address] == :default
      ipv4_addr_mask_configure(true)
      ipv4_addr_mask_configure
    else
      ipv4_addr_mask_configure
      ipv4_addr_mask_configure(true)
    end
  end

  def stp_mst_cost=(should_list)
    should_list = @nu.default_stp_mst_cost if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:stp_mst_cost] = should_list
  end

  def stp_mst_port_priority=(should_list)
    should_list = @nu.default_stp_mst_port_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:stp_mst_port_priority] = should_list
  end

  def stp_vlan_cost=(should_list)
    should_list = @nu.default_stp_vlan_cost if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:stp_vlan_cost] = should_list
  end

  def stp_vlan_port_priority=(should_list)
    should_list = @nu.default_stp_vlan_port_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:stp_vlan_port_priority] = should_list
  end

  def vlan_mapping
    return @property_hash[:vlan_mapping] if @resource[:vlan_mapping].nil?
    if @resource[:vlan_mapping][0] == :default &&
       @property_hash[:vlan_mapping] == @nu.default_vlan_mapping
      return [:default]
    else
      @property_hash[:vlan_mapping]
    end
  end

  def vlan_mapping=(should_list)
    should_list = @nu.default_vlan_mapping if should_list[0] == :default
    @property_flush[:vlan_mapping] = should_list
  end

  # override vrf setter
  def vrf=(val)
    val = @nu.default_vrf if val == :default
    @property_flush[:vrf] = val

    # flush other L3 properties because vrf will wipe them out
    l3_props = [
      :ipv4_proxy_arp, :ipv4_redirects,
      :ipv4_address, :ipv4_netmask_length,
      :ipv4_address_secondary, :ipv4_netmask_length_secondary
    ]
    l3_props.each do |prop|
      if @property_flush[prop].nil?
        @property_flush[prop] = @property_hash[prop] unless @property_hash[prop].nil?
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
        new_interface = true
        @nu = Cisco::Interface.new(@resource[:interface])
      end
      properties_set(new_interface)
    end
  end
end # Puppet::Type
