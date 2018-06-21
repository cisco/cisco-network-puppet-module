# Manages a Cisco Network Interface.
#
# June 2018
#
# Copyright (c) 2013-2018 Cisco and/or its affiliates.
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_interface) do
  @doc = %(Manages a Cisco Network Interface.

  Resource dependencies should process before the interface resource.

  cisco_interface {'<interface>':
    ..attributes..
  }

  <interface> is the complete name of the interface.

  Examples:
    cisco_interface {'ethernet1/15':
     shutdown                     => false,
     description                  => 'switched port',
     switchport_mode              => access,
     access_vlan                  => 2,
     switchport_autostate_exclude => true,
     switchport_vtp               => true,
    }
    cisco_interface { 'ethernet1/16' :
     shutdown                       => true,
     description                    => 'routed port',
     ipv4_address                   => '192.168.1.1',
     ipv4_netmask_length            => 24,
     ipv4_address_secondary         => '192.168.2.1',
     ipv4_netmask_length_secondary  => 24,
     ipv4_forwarding                => true,
     ipv4_redirects                 => true,
     ipv4_proxy_arp                 => true,
     ipv4_pim_sparse_mode           => true,
     negotiate_auto                 => true,
     ipv4_dhcp_relay_addr           => ['1.1.1.1', '2.2.2.2'],
     ipv4_dhcp_relay_info_trust     => true,
     ipv4_dhcp_relay_src_addr_hsrp  => true,
     ipv4_dhcp_relay_src_intf       => 'port-channel 100',
     ipv4_dhcp_relay_subnet_broadcast => true,
     ipv4_dhcp_smart_relay          => true,
     ipv6_dhcp_relay_addr           => ['2000::11', '2001::22'],
     ipv6_dhcp_relay_src_intf       => 'ethernet 2/2',
     ipv6_redirects                 => true,
     pim_bfd                        => true,
    }
    cisco_interface { 'ethernet1/17' :
     stp_bpdufilter               => 'enable',
     stp_bpduguard                => 'enable',
     stp_cost                     => 2000,
     stp_guard                    => 'loop',
     stp_link_type                => 'shared',
     stp_port_priority            => 32,
     stp_port_type                => 'network',
     stp_mst_cost                 => [[0,2-4,6,8-12, 1000], [1000, 2568]],
     stp_mst_port_priority        => [[0,2-11,20-33, 64], [1111, 160],
     stp_vlan_cost                => [[1-4,6,8-12, 1000], [1000, 2568]],
     stp_vlan_port_priority       => [[1-11,20-33, 64], [1111, 160],
    }
    cisco_interface { 'ethernet1/18' :
     hsrp_bfd                     => true,
     hsrp_delay_minimum           => 222,
     hsrp_delay_reload            => 10,
     hsrp_mac_refresh             => 555,
     hsrp_use_bia                 => 'use_bia',
     hsrp_version                 => 2,
    }
    cisco_interface { 'ethernet9/1' :
     switchport_mode              => 'trunk',
     storm_control_broadcast      => '77.77',
     storm_control_multicast      => '22.22',
     storm_control_unicast        => '33.33',
     vlan_mapping_enable          => 'false',
     vlan_mapping                 => [[20, 21], [30, 31]],
    }
    cisco_interface { 'loopback42' :
     description                  => 'logical interface',
     shutdown                     => true,
    }
    cisco_interface { 'loopback43' :
     ensure                       => absent,
     # ensure will create or destroy a logical interface. If not specified
     # then the default behavior is to attempt to create the interface.
    }
    cisco_interface {'Vlan98':
     shutdown                     => true,
     description                  => 'svi interface',
     ipv4_arp_timeout             => 300,
     svi_autostate                => true,
     svi_management               => true,
     load_interval_counter_1_delay => 150,
     load_interval_counter_2_delay => 250,
     load_interval_counter_3_delay => 90,
    }
    cisco_interface { 'ethernet8/1' :
     description                        => 'Private-vlan host',
     switchport_pvlan_host              => 'host',
     switchport_pvlan_host_association  => ['10', '11'],
    }
    cisco_interface { 'ethernet8/1' :
     description                         => 'Private-vlan trunk',
     switchport_pvlan_trunk_promiscuous  => true,
     switchport_pvlan_trunk_association  => [['14', '114'], ['15', '115']],
     switchport_pvlan_trunk_allowed_vlan => '88-91,94',
     switchport_pvlan_trunk_native_vlan  => 12,
    }
    cisco_interface { 'ethernet8/2' :
     purge_config                        => true,
    }
    cisco_interface {'Vlan98':
     pvlan_mapping => '10-11,13',
    }
  )

  ###################
  # Resource Naming #
  ###################

  newparam(:interface, namevar: :true) do
    desc 'Name of the interface on the network element. Valid values are string.'

    munge(&:downcase)
  end # param name

  #######################################
  # Basic / L2 Configuration Attributes #
  #######################################

  apply_to_all
  ensurable

  newproperty(:bfd_echo) do
    desc 'Enables bfd echo function for all address families.'

    newvalues(:true, :false, :default)
  end # property bfd_echo

  newproperty(:description) do
    desc "Description of the interface. Valid values are string, keyword
         'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property description

  newproperty(:encapsulation_dot1q) do
    desc "Enable IEEE 802.1Q encapsulation of traffic on a specified
          subinterface.  Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property encapsulation_dot1q

  newproperty(:mtu) do
    desc "Maximum Trasnmission Unit size for frames received and sent on the
          specified interface. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property mtu

  newproperty(:speed) do
    desc "Configure the speed between interfaces. Default value is 'auto'."

    newvalues(:auto, 10, 100, 1000, 10_000, 100_000, 40_000, :default)
  end # property speed

  newproperty(:duplex) do
    desc "Configure duplex between interfaces. Default value is 'auto'."

    newvalues(:auto, :full, :default)
  end # property duplex

  newproperty(:shutdown) do
    desc 'Shutdown state of the interface.'

    newvalues(:true, :false, :default)
  end # property shutdown

  newproperty(:switchport_mode) do
    desc "Switchport mode of the interface. To make an interface L3, set
          switchport_mode to 'disabled'. "

    newvalues(
      :disabled,
      :access,
      :tunnel,
      :fex_fabric,
      :trunk,
      :fabricpath,
      :default)
  end # property switchport_mode

  newproperty(:access_vlan) do
    desc "The VLAN ID assigned to the interface. Valid values are
          integer, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'access_vlan must be a valid integer, or default.'
      end
      value
    end
  end # property access_vlan

  newproperty(:switchport_autostate_exclude) do
    desc 'Exclude this port for the SVI link calculation.'

    newvalues(:true, :false, :default)
  end # property switchport_autostate_exclude

  newproperty(:switchport_trunk_allowed_vlan) do
    desc "The allowed VLANs for the specified Ethernet interface. Valid values
          are string, keyword 'default'."

    # Use the range summarize utility to normalize the vlan ranges
    munge do |value|
      if value == 'default'
        value = :default
      else
        value = PuppetX::Cisco::Utils.range_summarize(value)
      end
      value
    end
  end # property switchport_trunk_allowed_vlan

  newproperty(:switchport_trunk_native_vlan) do
    desc "The Native VLAN assigned to the switch port. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property switchport_trunk_native_vlan

  newproperty(:switchport_vtp) do
    desc 'Enable or disable VTP on the interface.'

    newvalues(:true, :false, :default)
  end # property switchport vtp

  newproperty(:negotiate_auto) do
    desc 'Enable/Disable negotiate auto on the interface.'

    newvalues(:true, :false, :default)
  end # property negotiate_auto

  newproperty(:vpc_id) do
    desc 'Configure vPC id on this interface to make it a vPC link to a
          downstream device. The vPC Peer switch must have an indentical
          configuration to the same downstream device. Valid values are in
          the range 1..4096'

    munge do |value|
      value = :default if value == 'default'
      if value != :default
        range = *(1..4096)
        fail 'VPC ID must be in the range 1..4096' unless
          range.include?(value.to_i)
      end
      value
    end
  end # property vpc_id

  newproperty(:vpc_peer_link) do
    desc 'Enable/Disable this interface as a VPC Peer-link. This is valid
          only for port-channel interfaces. Valid values true or false'
    newvalues(:true, :false)
  end # property vpc_peer_link

  ########################################
  # Begin L3 interface config attributes #
  ########################################

  newproperty(:pim_bfd) do
    desc 'Enables pim BFD on this interface.'

    newvalues(:true, :false, :default)
  end # property pim_bfd

  newproperty(:ipv4_pim_sparse_mode) do
    desc '<L3 attribute> Enables or disables ipv4 pim sparse mode '\
         'on the interface.'

    newvalues(:true, :false, :default)
  end # property ipv4_pim_sparse_mode

  newproperty(:ipv4_proxy_arp) do
    desc "<L3 attribute> Enables or disables proxy arp on the
          interface."

    newvalues(:true, :false, :default)
  end # property ipv4_proxy_arp

  newproperty(:ipv4_redirects) do
    desc "<L3 attribute> Enables or disables sending of IP redirect
          messages."

    newvalues(:true, :false, :default)
  end # property ipv4_redirects

  newproperty(:ipv4_address) do
    desc "<L3 attribute> IP address of the interface. Valid values are
          string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      valid_ipaddr = true
      begin
        if value != :default
          tmp_value = IPAddr.new(value)
          # check whether it is ipv4 address
          valid_ipaddr = tmp_value.ipv4?
        end
      rescue
        valid_ipaddr = false
      end
      # fail if it is not valid ipv4 address
      fail("ipv4_address - #{@resource[:ipv4_address]} must be " \
           "either a valid IPv4 address string or 'default'.") if
           value != :default && valid_ipaddr == false
      value
    end
  end # property ipv4_address

  newproperty(:ipv4_address_secondary) do
    desc "<L3 attribute> Secondary IP address of the interface. Valid values are
          string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      valid_ipaddr = true
      begin
        if value != :default
          tmp_value = IPAddr.new(value)
          # check whether it is ipv4 address
          valid_ipaddr = tmp_value.ipv4?
        end
      rescue
        valid_ipaddr = false
      end
      # fail if it is not valid ipv4 address
      fail("ipv4_address - #{@resource[:ipv4_address]} must be " \
           "either a valid IPv4 address string or 'default'.") if
           value != :default && valid_ipaddr == false
      value
    end
  end # property ipv4_address_secondary

  newproperty(:ipv4_netmask_length) do
    desc "<L3 attribute> Network mask length of the IP address on the
          interface. Valid values are integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'Network mask length must be a valid integer.'
      end
      fail('ipv4_netmask_length must be an integer between 0 and 32') if
           (value != :default) && (value < 0 || value > 32)
      value
    end
  end # property ipv4_netmask_length

  newproperty(:ipv4_netmask_length_secondary) do
    desc "<L3 attribute> Network mask length of the secondary IP address on the
          interface. Valid values are integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'Network mask length must be a valid integer.'
      end
      fail('ipv4_netmask_length must be an integer between 0 and 32') if
           (value != :default) && (value < 0 || value > 32)
      value
    end
  end # property ipv4_netmask_length_secondary

  newproperty(:ipv4_arp_timeout) do
    desc "Configure Address Resolution Protocol (ARP) timeout. Valid values
          are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # ipv4_arp_timeout

  newproperty(:vrf) do
    desc "<L3 attribute> VRF member of the interface. Valid values
          are string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property vrf

  newproperty(:ipv4_acl_in) do
    desc "<L3 attribute> ipv4 ingress access list on the interface. Valid values
          are string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property ipv4_acl_in

  newproperty(:ipv4_acl_out) do
    desc "<L3 attribute> ipv4 egress access list on the interface. Valid values
          are string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property ipv4_acl_out

  newproperty(:ipv4_forwarding) do
    desc '<L3 attribute> Enables or disables IP forwarding on the interface. '\
         "Valid values are true, false, keyword 'default'"

    newvalues(:true, :false, :default)
  end # property ipv4_forwarding

  newproperty(:ipv6_acl_in) do
    desc "<L3 attribute> ipv6 ingress access list on the interface. Valid values
          are string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property ipv6_acl_in

  newproperty(:ipv6_acl_out) do
    desc "<L3 attribute> ipv6 egress access list on the interface. Valid values
          are string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property ipv6_acl_out

  newproperty(:ipv6_redirects) do
    desc "<L3 attribute> Enables or disables sending of IPv6 redirect
          messages."

    newvalues(:true, :false, :default)
  end # property ipv6_redirects

  # validate ipv4 address and mask combination
  validate do
    if self[:ipv4_address] != :default &&
       self[:ipv4_netmask_length] == :default
      fail('The ipv4_netmask_length should have a valid value, ' \
           'when ipv4_address has a valid IPv4 address in the manifest')
    end

    if self[:ipv4_address] == :default &&
       (!self[:ipv4_netmask_length].nil? &&
        self[:ipv4_netmask_length] != :default)
      fail('The ipv4_address should have a valid value, ' \
           'when ipv4_netmask_length has a valid value in the manifest')
    end
  end

  #########################################
  # Begin SVI interface config attributes #
  #########################################

  newproperty(:fabric_forwarding_anycast_gateway) do
    desc 'Associate SVI with anycast gateway under VLAN configuration mode. '\
         "Valid values are 'true','false' and 'default'."

    newvalues(:true, :false, :default)
  end # property fabric_forwarding_anycast_gateway

  newproperty(:svi_autostate) do
    desc 'Enable/Disable autostate on the SVI interface.'

    newvalues(:true, :false, :default)
  end # property svi_autostate

  newproperty(:svi_management) do
    desc 'Enable/Disable management on the SVI interface.'

    newvalues(:true, :false, :default)
  end # property svi_management

  ################
  # vlan mapping #
  ################

  newproperty(:vlan_mapping, array_matching: :all) do
    format = '[[original_vlan, translated_vlan], [orig2, tran2]]'
    desc 'An array of [original_vlan, translated_vlan] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_mapping

  newproperty(:vlan_mapping_enable) do
    desc 'Enable/Disable vlan mapping on the interface. '\
         "Valid values are 'true', 'false', and 'default'."

    newvalues(:true, :false, :default)
  end # property vlan_mapping_enable

  ############################
  # spanning-tree attributes #
  ############################

  newproperty(:stp_bpdufilter) do
    desc 'Enable/Disable BPDU filtering for this interface.'

    newvalues(:enable, :disable, :default)
  end # property stp_bpdufilter

  newproperty(:stp_bpduguard) do
    desc 'Enable/Disable BPDU guard for this interface.'

    newvalues(:enable, :disable, :default)
  end # property stp_bpduguard

  newproperty(:stp_cost) do
    desc "Spanning tree port path cost for this interface. Valid values are
          integer, keyword 'auto' or 'default'."

    munge do |value|
      value = :default if value == 'default'
      value = :auto if value == 'auto'
      begin
        value = Integer(value) unless value == :default || value == :auto
      rescue
        raise 'stp_cost must be a valid integer, or auto or default.'
      end
      value
    end
  end # property stp_cost

  newproperty(:stp_guard) do
    desc 'Spanning-tree guard mode for this interface.'

    newvalues(:loop, :none, :root, :default)
  end # property stp_guard

  newproperty(:stp_link_type) do
    desc 'Link type for spanning tree tree protocol use.'

    newvalues(:auto, :shared, :'point-to-point', :default)
  end # property stp_link_type

  newproperty(:stp_mst_cost, array_matching: :all) do
    format = '[[mst_inst_list, cost], [mil, cost]]'
    desc 'An array of [mst_instance_list, cost] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property stp_mst_cost

  newproperty(:stp_mst_port_priority, array_matching: :all) do
    format = '[[mst_inst_list, port_priority], [vr, port_priority]]'
    desc 'An array of [mst_inst_list, port_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property stp_mst_port_priority

  newproperty(:stp_port_priority) do
    desc "Spanning tree port priority for this interface. Valid values are
          integer, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'stp_port_priority must be a valid integer, or default.'
      end
      value
    end
  end # property stp_port_priority

  newproperty(:stp_port_type) do
    desc 'Spanning tree port type for this interface.'

    newvalues(:edge, :network, :normal, :'edge trunk', :default)
  end # property stp_port_type

  newproperty(:stp_vlan_cost, array_matching: :all) do
    format = '[[vlan_range, cost], [vr, cost]]'
    desc 'An array of [vlan_range, cost] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property stp_vlan_cost

  newproperty(:stp_vlan_port_priority, array_matching: :all) do
    format = '[[vlan_range, port_priority], [vr, pp]]'
    desc 'An array of [vlan_range, port_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property stp_vlan_port_priority

  ###########################
  # private vlan attributes #
  ###########################

  # ------------------------
  newproperty(:pvlan_mapping, array_matching: :all) do
    inputs =
      'Valid inputs are a String containing a range of secondary vlans, '\
      "example: '3-4,6'; or keyword 'default'"
    desc 'Maps secondary VLANs to the VLAN interface of a primary VLAN. ' + inputs

    validate do |value|
      fail inputs unless value.to_s.delete(' ')[/^(default|[-,\d]+)$/]
    end

    munge do |value|
      value.to_s[/default/] ? :default : value.to_s.delete(' ')
    end
  end

  # ------------------------
  newproperty(:switchport_pvlan_host) do
    inputs = "Valid values are 'true', 'false', and 'default'."
    desc 'Configures a Layer 2 interface as a private VLAN host port. ' + inputs
    newvalues(:true, :false, :default)
  end

  # ------------------------
  newproperty(:switchport_pvlan_host_association, array_matching: :all) do
    inputs =
      'Valid inputs are: An array containing the primary and secondary vlans: '\
      "e.g.: ['44', '144']; or keyword 'default'"
    desc 'Associates the Layer 2 host port with the primary and secondary '\
         'VLANs of a private VLAN. ' + inputs

    validate do |value|
      fail inputs unless value.to_s.delete(' ')[/^(default|\d+)$/]
    end

    munge { |value| value.to_s[/default/] ? :default : value.to_s.delete(' ') }
  end

  # ------------------------
  newproperty(:switchport_pvlan_mapping, array_matching: :all) do
    inputs =
      'Valid inputs are an array containing both the primary vlan and a '\
      "range of secondary vlans, example: ['44', '3-4,6'] or keyword 'default'"
    desc 'Associates the specified port with a primary VLAN and a selected '\
         'list of secondary VLANs. ' + inputs

    validate do |value|
      fail inputs unless value.to_s.delete(' ')[/^(default|[-,\d]+)$/]
    end

    munge do |value|
      if value.to_s[/default/]
        :default
      else
        PuppetX::Cisco::Utils.normalize_range_string(value)
      end
    end
  end

  # ------------------------
  newproperty(:switchport_pvlan_mapping_trunk, array_matching: :all) do
    inputs = %(
      Valid inputs are: An array containing both the primary vlan and a range
      of secondary vlans: ['44', '3-4,6']; a nested array if there are multiple
      mappings: [['44', '3-4,6'], ['99', '199']]; or the keyword 'default')
    desc 'Maps the promiscuous trunk port with the primary VLAN and a selected'\
         'list of associated secondary VLANs. ' + inputs

    validate do |value|
      if value.is_a?(Array)
        pri, range = value.map { |x| x.to_s.delete(' ') }
        fail inputs unless pri[/^\d+$/] && range[/^[-,\d]+$/]
      elsif value.is_a?(String)
        fail inputs unless value.delete(' ')[/^(default|[-,\d]+)$/]
      end
    end

    munge do |value|
      if value.is_a?(Array)
        pri, range = value
        [pri.to_s, PuppetX::Cisco::Utils.normalize_range_string(range)]
      elsif value.to_s[/default/]
        :default
      else
        PuppetX::Cisco::Utils.normalize_range_string(value)
      end
    end

    # Override puppet's insync method to check for array equality
    def insync?(is)
      is.flatten! if should[0].is_a?(String) # non-nested arrays
      (is.size == should.size && is.sort == should.sort)
    end
  end

  # ------------------------
  newproperty(:switchport_pvlan_trunk_allowed_vlan) do
    inputs = "Valid values are a String range of vlans: e.g. '3-4,6'; "\
             "or keyword 'default'."
    desc 'Sets the allowed VLANs for the private VLAN isolated trunk '\
         'interface. ' + inputs

    validate do |value|
      fail inputs unless value.delete(' ')[/^(default|none|[-,\d]+)$/]
    end

    munge do |value|
      if value.to_s[/default|none/]
        :default
      else
        PuppetX::Cisco::Utils.normalize_range_string(value)
      end
    end
  end

  # ------------------------
  newproperty(:switchport_pvlan_trunk_association, array_matching: :all) do
    inputs = %(
      Valid inputs are: An array containing an association of primary and
      secondary vlans: e.g. ['44', '244']; a nested array if there are multiple
      associations: [['44', '244'], ['45', '245']]; or the keyword 'default')
    desc 'Associates the Layer 2 isolated trunk port with the primary and '\
         'secondary VLANs of private VLANs. ' + inputs

    validate do |value|
      if value.is_a?(Array)
        pri, sec = value.map { |x| x.to_s.delete(' ') }
        fail inputs unless pri[/^\d+$/] && sec[/^\d+$/]
      elsif value.is_a?(String)
        fail inputs unless value.delete(' ')[/^(default|[-,\d]+)$/]
      end
    end

    munge do |value|
      if value.is_a?(Array)
        pri, sec = value
        [pri.to_s, sec.to_s]
      elsif value.to_s[/default/]
        :default
      else
        value.to_s
      end
    end

    # Override puppet's insync method to check for array equality
    def insync?(is)
      is.flatten! if should[0].is_a?(String) # non-nested arrays
      (is.size == should.size && is.sort == should.sort)
    end
  end

  # ------------------------
  newproperty(:switchport_pvlan_trunk_native_vlan) do
    inputs = "Valid values are Integer, String, or keyword 'default'."
    desc 'Sets the native VLAN for the 802.1Q trunk. ' + inputs

    validate do |value|
      fail inputs unless value.to_s.delete(' ')[/^(default|\d+)$/]
    end

    munge { |value| value.to_s[/default/] ? :default : value.to_s.delete(' ') }
  end

  # ------------------------
  newproperty(:switchport_pvlan_promiscuous) do
    inputs = "Valid values are 'true', 'false', and 'default'."
    desc 'Configures a Layer 2 interface as a private VLAN promiscuous '\
         'port. ' + inputs
    newvalues(:true, :false, :default)
  end

  # ------------------------
  newproperty(:switchport_pvlan_trunk_promiscuous) do
    inputs = "Valid values are 'true', 'false', and 'default'."
    desc 'Configures a Layer 2 interface as a private VLAN promiscuous '\
         'trunk port. ' + inputs
    newvalues(:true, :false, :default)
  end

  # ------------------------
  newproperty(:switchport_pvlan_trunk_secondary) do
    inputs = "Valid values are 'true', 'false', and 'default'."
    desc 'Configures a Layer 2 interface as a private VLAN isolated '\
         'trunk port. ' + inputs
    newvalues(:true, :false, :default)
  end

  #############################################################################
  #                                                                           #
  #                         DEPRECATED PROPERTIES Start                       #
  #                                                                           #
  #############################################################################

  newproperty(:switchport_mode_private_vlan_host) do
    desc %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_host' and 'switchport_pvlan_promiscuous')
    newvalues(
      :host,
      :promiscuous,
      :disabled)
  end # property switchport_mode_private_vlan_host

  newproperty(:switchport_mode_private_vlan_host_association, array_matching: :all) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_host_association')
    desc dep
    validate do |value|
      fail dep unless
            /^(\d+)$/.match(value.to_s).to_s == value.to_s ||
            value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : value.to_s.gsub(/\s+/, '')
    end
    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # property switchport_mode_private_vlan_host_association

  newproperty(:switchport_mode_private_vlan_host_promisc, array_matching: :all) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_mapping')
    desc dep
    validate do |value|
      fail dep unless
           /^(\s*\d+\s*[-,\d\s]*\d+\s*)$/.match(value).to_s == value ||
           value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : value.to_s.gsub(/\s+/, '')
    end
    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # switchport_mode_private_vlan_host_promisc

  newproperty(:switchport_mode_private_vlan_trunk_promiscuous) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_trunk_promiscuous')
    desc dep
    newvalues(
      :true,
      :false,
      :default)
  end # property switchport_mode_private_vlan_trunk_promiscuous

  newproperty(:switchport_mode_private_vlan_trunk_secondary) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_trunk_secondary')
    desc dep
    newvalues(
      :true,
      :false,
      :default)
  end # property switchport_mode_private_vlan_trunk_secondary

  newproperty(:switchport_private_vlan_association_trunk, array_matching: :all) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_trunk_association')
    desc dep
    validate do |value|
      fail dep unless
             /^(\s*\d+\s*)$/.match(value).to_s == value ||
             value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : value.to_s.gsub(/\s+/, '')
    end
    def insync?(is)
      return true if should == [:default] && is == [:default]
      pair = should.join(' ')
      is.include? pair
    end
  end # switchport_private_vlan_association_trunk

  newproperty(:switchport_private_vlan_mapping_trunk, array_matching: :all) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_mapping_trunk')
    desc dep
    validate do |value|
      fail dep unless
           /^(\s*\d+\s*[-,\d\s]*\d+\s*)$/.match(value).to_s == value ||
           value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : value.to_s.gsub(/\s+/, '')
    end
    def insync?(is)
      return true if should == [:default] && is == [:default]
      pair = should.join(' ')
      is.include? pair
    end
  end # switchport_private_vlan_mapping_trunk

  newproperty(:switchport_private_vlan_trunk_allowed_vlan, array_matching: :all) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_trunk_allowed_vlan')
    desc dep
    validate do |value|
      fail dep unless
           /^(\s*\d+\s*[-,\d\s]*\d+\s*)$/.match(value).to_s == value ||
           value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : value.to_s.gsub(/\s+/, '')
    end
    def insync?(is)
      return true if should == [:default] && is == [:default]
      return false if should == [:default]
      list = should[0].split(',')
      (is.size == list.size && is.sort == list.sort)
    end
  end # switchport_private_vlan_trunk_allowed_vlan

  newproperty(:switchport_private_vlan_trunk_native_vlan) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'switchport_pvlan_trunk_allowed_vlan')
    desc dep
    validate do |value|
      fail dep unless
            /^(\d+)$/.match(value.to_s).to_s == value.to_s ||
            value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : Integer(value)
    end
  end # switchport_private_vlan_trunk_native_vlan

  newproperty(:private_vlan_mapping, array_matching: :all) do
    dep = %(## -DEPRECATED- ## Property. Replace with: 'pvlan_mapping')
    desc dep
    validate do |value|
      fail dep unless
            /^(\s*\d+\s*[-,\d\s]*\d+\s*)$/.match(value).to_s == value ||
            value == 'default' || value == :default
    end
    munge do |value|
      value == 'default' ? :default : value.gsub(/\s+/, '')
    end
    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # private_vlan_mapping

  ############################
  # dhcp relay attributes    #
  ############################

  newproperty(:ipv4_dhcp_relay_addr, array_matching: :all) do
    format = '[addr1, addr2]'
    desc 'An array of ipv4 addresses'\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        value = :default if value == 'default'
        value
      end
    end
  end # property ipv4_dhcp_relay_addr

  newproperty(:ipv4_dhcp_relay_info_trust) do
    desc 'Enables relay trust on this interface.'

    newvalues(:true, :false, :default)
  end # property ipv4_dhcp_relay_info_trust

  newproperty(:ipv4_dhcp_relay_src_addr_hsrp) do
    desc 'Enables Virtual IP instead of SVI address'

    newvalues(:true, :false, :default)
  end # property ipv4_dhcp_relay_src_addr_hsrp

  newproperty(:ipv4_dhcp_relay_src_intf) do
    desc "Source interface for the DHCPV4 relay. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = value.downcase.delete(' ')
      value = :default if value == 'default'
      value
    end
  end # property ipv4_dhcp_relay_src_intf

  newproperty(:ipv4_dhcp_relay_subnet_broadcast) do
    desc 'Enables DHCP relay subnet-broadcast on this interface.'

    newvalues(:true, :false, :default)
  end # property ipv4_dhcp_relay_subnet_broadcast

  newproperty(:ipv4_dhcp_smart_relay) do
    desc 'Enables DHCP smart relay on this interface.'

    newvalues(:true, :false, :default)
  end # property ipv4_dhcp_smart_relay

  newproperty(:ipv6_dhcp_relay_addr, array_matching: :all) do
    format = '[addr1, addr2]'
    desc 'An array of ipv6 addresses'\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        value = :default if value == 'default'
        value
      end
    end
  end # property ipv6_dhcp_relay_addr

  newproperty(:ipv6_dhcp_relay_src_intf) do
    desc "Source interface for the DHCPV6 relay. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = value.downcase.delete(' ')
      value = :default if value == 'default'
      value
    end
  end # property ipv6_dhcp_relay_src_intf

  ############################
  # storm control attributes #
  ############################

  newproperty(:storm_control_broadcast) do
    desc "Allowed broadcast traffic level. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property storm_control_broadcast

  newproperty(:storm_control_multicast) do
    desc "Allowed multicast traffic level. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property storm_control_multicast

  newproperty(:storm_control_unicast) do
    desc "Allowed unicast traffic level. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property storm_control_unicast

  ############################
  # hsrp attributes          #
  ############################

  newproperty(:hsrp_bfd) do
    desc 'Enable HSRP BFD on this interface.'

    newvalues(:true, :false, :default)
  end # property hsrp_bfd

  newproperty(:hsrp_delay_minimum) do
    desc "Hsrp intialization minimim delay in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property hsrp_delay_minimum

  newproperty(:hsrp_delay_reload) do
    desc "Hsrp intialization delay after reload in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property hsrp_delay_reload

  newproperty(:hsrp_mac_refresh) do
    desc "Hsrp mac refresh time in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property hsrp_mac_refresh

  newproperty(:hsrp_use_bia) do
    desc 'Hsrp uses interface burned in address'

    newvalues(:use_bia, :use_bia_intf, :default)
  end # property hsrp_use_bia

  newproperty(:hsrp_version) do
    desc "Hsrp version. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property hsrp_version

  ############################
  # load-interval attributes #
  ############################

  newproperty(:load_interval_counter_1_delay) do
    desc "Load interval delay for counter 1 in seconds. Valid values
          are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property load_interval_counter_1_delay

  newproperty(:load_interval_counter_2_delay) do
    desc "Load interval delay for counter 2 in seconds. Valid values
          are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property load_interval_counter_2_delay

  newproperty(:load_interval_counter_3_delay) do
    desc "Load interval delay for counter 3 in seconds. Valid values
          are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property load_interval_counter_3_delay

  newproperty(:purge_config) do
    desc 'Puts the ethernet interface in default state.'

    newvalues(:true)
  end

  validate do
    fail ArgumentError, 'All params MUST be nil if purge_config is true' if self[:purge_config] == :true && properties.length > 2
  end
end # Puppet::Type.newtype
