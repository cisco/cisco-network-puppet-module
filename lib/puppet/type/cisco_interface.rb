# Manages a Cisco Network Interface.
#
# May 2013
#
# Copyright (c) 2013-2016 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_interface) do
  @doc = "Manages a Cisco Network Interface.

  Any resource dependency should be run before the interface resource.

  cisco_interface {\"<interface>\":
    ..attributes..
  }

  <interface> is the complete name of the interface.

  Example:
    cisco_interface {\"Ethernet1/15\":
     shutdown                     => false,
     description                  => \"switched port\",
     switchport_mode              => access,
     access_vlan                  => 2,
     switchport_autostate_exclude => true,
     switchport_vtp               => true,
    }
    cisco_interface { \"Ethernet1/16\" :
     shutdown                       => true,
     description                    => \"routed port\",
     ipv4_address                   => \"192.168.1.1\",
     ipv4_netmask_length            => 24,
     ipv4_address_secondary         => \"192.168.2.1\",
     ipv4_netmask_length_secondary  => 24,
     ipv4_redirects                 => true,
     ipv4_proxy_arp                 => true,
     ipv4_pim_sparse_mode           => true,
     negotiate_auto                 => true,
    }
    cisco_interface { \"Ethernet9/1\" :
     switchport_mode              => 'trunk',
     vlan_mapping_enable          => 'false',
     vlan_mapping                 => [[20, 21], [30, 31]],
    }
    cisco_interface { \"loopback42\" :
     description                  => \"logical interface\",
     shutdown                     => true,
    }
    cisco_interface { \"loopback43\" :
     ensure                       => absent,
     # ensure will create or destroy a logical interface. If not specified
     # then the default behavior is to attempt to create the interface.
    }
    cisco_interface {\"Vlan98\":
     shutdown                     => true,
     description                  => \"svi interface\",
     ipv4_arp_timeout             => 300,
     svi_autostate                => true,
     svi_management               => true,
    }"

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)/,
      [
        [:interface, identity]
      ],
    ]
    patterns
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of the interface on the network element. Valid values are string.'

    validate do |name|
      if name == 'mgmt0'
        fail('Stay away from the management port.')
      end # if
    end

    munge(&:downcase)
  end # param name

  #######################################
  # Basic / L2 Configuration Attributes #
  #######################################

  ensurable

  newproperty(:channel_group) do
    desc "channel_group is an aggregation of multiple physical interfaces
          that creates a logical interface. Valid values are 1 to 4096."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property channel_group

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

    newvalues(:auto, 10, 100, 1000, 10_000, 1_000_000, 40_000, :default)
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

    # Strip whitespace if manifest specified as '20, 30' vs '20,30'
    munge { |value| value == 'default' ? :default : value.sub(/\s/, '') }
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

  ########################################
  # Begin L3 interface config attributes #
  ########################################

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

  ################
  # Autorequires #
  ################

  autorequire(:cisco_vlan) do |rel_catalog|
    reqs = []
    unless self[:access_vlan].nil? || self[:access_vlan] == :default
      reqs << rel_catalog.catalog.resource('Cisco_vlan', "#{self[:access_vlan]}")
    end # if
    reqs
  end # autorequire vlan

  autorequire(:cisco_vtp) do |rel_catalog|
    reqs = []
    reqs << rel_catalog.catalog.resource('Cisco_vtp')
    reqs # return
  end # autorequire vtp
end # Puppet::Type.newtype
