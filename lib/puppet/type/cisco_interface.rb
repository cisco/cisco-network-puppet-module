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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

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
     ipv4_forwarding                => true,
     ipv4_redirects                 => true,
     ipv4_proxy_arp                 => true,
     ipv4_pim_sparse_mode           => true,
     negotiate_auto                 => true,
    }
    cisco_interface { \"Ethernet1/17\" :
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
    }
    #Private vlan config example
    cisco_interface { \"Ethernet8/1\" :
     switchport_mode_private_vlan_host  => 'host',
     switchport_mode_private_vlan_host_association => ['10', '11'],
    }
    cisco_interface { \"Ethernet8/1\" :
     switchport_mode_private_vlan_host  => 'promiscuous',
     switchport_mode_private_vlan_host_promisc=> ['10', '11'],
    }
    cisco_interface { \"Ethernet8/1\" :
     switchport_mode_private_vlan_trunk_promiscuous => true,
     switchport_private_vlan_mapping_trunk => ['10', '11'],
    }
    cisco_interface { \"Ethernet8/1\" :
     switchport_mode_private_vlan_trunk_secondary => true,
     switchport_private_vlan_association_trunk => ['10', '11'],
    }
    cisco_interface { \"Ethernet8/1\" :
     switchport_private_vlan_trunk_allowed_vlan => ['10-11'],
    }
    cisco_interface { \"Ethernet8/1\" :
     switchport_private_vlan_trunk_native_vlan => 10,
    }
    cisco_interface {\"Vlan98\":
     private_vlan_mapping => ['10-11'],
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
      if name[/mgmt/i]
        fail('Stay away from the management port.')
      end # if
    end

    munge(&:downcase)
  end # param name

  #######################################
  # Basic / L2 Configuration Attributes #
  #######################################

  ensurable

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
    range = *(1..4096)
    validate do |id|
      fail 'VPC ID must be in the range 1..4096' unless
        range.include?(id.to_i)
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

  newproperty(:switchport_mode_private_vlan_host) do
    desc 'Switchport private host mode of the interface.'

    newvalues(
      :host,
      :promiscuous,
      :disabled)
  end # property switchport_mode_private_vlan_host

  newproperty(:switchport_mode_private_vlan_host_association, array_matching: :all) do
    format = '["primary_vlan", "secondary_vlan"]'
    desc "An array of #{format} pairs. "\
         "Valid values match format #{format}. "\
         'primary_vlan and secondary_vlan are integers.'
    match_error = "must be of format #{format}. "\
                  'primary_vlan and secondary_vlan must be specified as integers.'

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
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
    format = '["primary_vlan", "secondary_vlan"]'
    desc "An array of #{format} pairs. "\
         "Valid values match format #{format}. "\
         'primary_vlan and secondary_vlan are integers.'
    match_error = "must be of format #{format}. "\
                  'primary_vlan and secondary_vlan must be specified as integers.'

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
            value.kind_of? String
      fail "Vlan '#{value}' #{match_error}" unless
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
    desc 'Switchport private trunk promisc mode for the interface.'

    newvalues(
      :true,
      :false,
      :default)
  end # property switchport_mode_private_vlan_trunk_promiscuous

  newproperty(:switchport_mode_private_vlan_trunk_secondary) do
    desc 'Switchport private trunk secondary mode for the interface.'

    newvalues(
      :true,
      :false,
      :default)
  end # property switchport_mode_private_vlan_trunk_secondary

  newproperty(:switchport_private_vlan_association_trunk, array_matching: :all) do
    format = '["primary_vlan", "secondary_vlan"]'
    desc "An array of #{format} pairs. "\
         "Valid values match format #{format}. "\
         'primary_vlan and secondary_vlan are integers.'
    match_error = "Input must be of #{format}. "\
                  'primary_vlan and secondary_vlan must be specified as integers. '\
                  "Ex ['10', '20']"

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
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
    format = '["primary_vlan", "secondary_vlan"]'
    desc "An array of #{format} pairs. "\
         "Valid values match format #{format}. "\
         'primary_vlan and secondary_vlan are integers.'

    match_error = "Input must be of format #{format}. "\
                  'primary_vlan and secondary_vlan must be specified as integers.'\
                  " Ex ['10', '20'], ['10', '20-30']"\
                  " or ['10', '20,24']"

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
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
    format = '["vlans"]'
    desc "An array of #{format}. "\
         "Valid values match format #{format} with vlans as integers."
    match_error = "must be of format #{format}. "\
                  'vlans must be specified as integers.'\
                  " Ex ['10'], ['20-30'] or ['20,24']"

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
            value.kind_of? String
      fail "Vlan '#{value}' #{match_error}" unless
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
    format = '<vlan>'
    desc 'The  private native vlan. '\
         "Valid values match format #{format} with vlan as integer"
    match_error = "must be of format #{format}. "\
                  'vlan must be specified as integer. Ex 10 or 20'

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
            /^(\d+)$/.match(value.to_s).to_s == value.to_s ||
            value == 'default' || value == :default
    end

    munge do |value|
      value == 'default' ? :default : Integer(value)
    end
  end # switchport_private_vlan_trunk_native_vlan

  newproperty(:private_vlan_mapping, array_matching: :all) do
    format = '["vlans"]'
    desc "An array of #{format}. "\
         "Valid values match format #{format} with vlans as integer"
    match_error = "must be of format #{format}. "\
                  'vlans must be specified as integers. '\
                  "Ex ['10'], ['20-30'] or ['20,24']"

    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
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
