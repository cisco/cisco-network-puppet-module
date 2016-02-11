#
# The NXAPI provider for cisco_interface.
#
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

Puppet::Type.type(:cisco_interface).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_interface.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol arrays for method auto-generation. There are separate arrays
  # because the boolean-based methods are processed slightly different.
  # Note: switchport_mode should always process first to evaluate L2 vs L3.
  # Note: vrf should be the first L3 property to process.  The AutoGen vrf
  # setter is not used.
  INTF_NON_BOOL_PROPS = [
    :switchport_mode,
    :vrf,
    :access_vlan,
    :description,
    :encapsulation_dot1q,
    :ipv4_address,
    :ipv4_netmask_length,
    :ipv4_address_secondary,
    :ipv4_netmask_length_secondary,
    :ipv4_arp_timeout,
    :mtu,
    :speed,
    :duplex,
    :switchport_trunk_allowed_vlan,
    :switchport_trunk_native_vlan,
    :vlan_mapping,
    :vpc_id,
    :ipv4_acl_in,
    :ipv4_acl_out,
    :ipv6_acl_in,
    :ipv6_acl_out,
  ]
  INTF_BOOL_PROPS = [
    :fabric_forwarding_anycast_gateway,
    :ipv4_pim_sparse_mode,
    :ipv4_proxy_arp,
    :ipv4_redirects,
    :negotiate_auto,
    :shutdown,
    :switchport_autostate_exclude,
    :switchport_vtp,
    :svi_autostate,
    :svi_management,
    :vlan_mapping_enable,
    :vpc_peer_link,
  ]
  INTF_ALL_PROPS = INTF_NON_BOOL_PROPS + INTF_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@interface',
                                            INTF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@interface',
                                            INTF_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @interface = Cisco::Interface.interfaces[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(interface_name, intf)
    debug "Checking instance, #{interface_name}."
    current_state = {
      interface: interface_name,
      name:      interface_name,
      ensure:    :present,
    }
    # Call node_utils getter for each property
    INTF_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = intf.send(prop)
    end
    INTF_BOOL_PROPS.each do |prop|
      val = intf.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    # nested array properties
    current_state[:vlan_mapping] = intf.vlan_mapping
    new(current_state)
  end # self.properties_get

  def self.instances
    interfaces = []
    Cisco::Interface.interfaces.each do |interface_name, intf|
      begin
        # Not allowed to create an interface for mgmt0
        next if interface_name.match(/mgmt0/)
        interfaces << properties_get(interface_name, intf)
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
        @interface.send("#{prop}=", @property_flush[prop]) if
          @interface.respond_to?("#{prop}=")
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
      addr = @interface.default_ipv4_address
    else
      addr = @resource[v4_addr_prop]
    end

    if @resource[v4_mask_prop] == :default
      mask = @interface.default_ipv4_netmask_length
    else
      mask = @resource[v4_mask_prop]
    end
    @interface.ipv4_addr_mask_set(addr, mask, secondary)
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

  def vlan_mapping
    return @property_hash[:vlan_mapping] if @resource[:vlan_mapping].nil?
    if @resource[:vlan_mapping][0] == :default &&
       @property_hash[:vlan_mapping] == @interface.default_vlan_mapping
      return [:default]
    else
      @property_hash[:vlan_mapping]
    end
  end

  def vlan_mapping=(should_list)
    should_list = @interface.default_vlan_mapping if should_list[0] == :default
    @property_flush[:vlan_mapping] = should_list
  end

  # override vrf setter
  def vrf=(val)
    val = @interface.default_vrf if val == :default
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
      @interface.destroy
      @interface = nil
    else
      # Create/Update
      if @interface.nil?
        new_interface = true
        @interface = Cisco::Interface.new(@resource[:interface])
      end
      properties_set(new_interface)
    end
    puts_config
  end

  def puts_config
    if @interface.nil?
      info "Interface=#{@resource[:interface]} is absent."
      return
    end

    # Dump all current properties for this interface
    current = sprintf("\n%30s: %s", 'interface', @interface.name)
    INTF_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @interface.send(prop)))
    end
    debug current
  end # puts_config
end # Puppet::Type
