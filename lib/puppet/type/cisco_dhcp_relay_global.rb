# Manages the Cisco Spanning-tree Global configuration resource.
#
# June 2018
#
# Copyright (c) 2016-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_dhcp_relay_global) do
  @doc = "
    Manages the Cisco Dhcp Relay Global configuration resource.
    cisco_dhcp_relay_global {'default':
      ..attributes..
    }
    'default' is only acceptable name for this global config object.

    Example:
    cisco_dhcp_relay_global { 'default':
      ipv4_information_option           => true,
      ipv4_information_option_trust     => true,
      ipv4_information_option_vpn       => true,
      ipv4_information_trust_all        => true,
      ipv4_relay                        => true,
      ipv4_smart_relay                  => true,
      ipv4_src_addr_hsrp                => true,
      ipv4_src_intf                     => 'port-channel200',
      ipv4_sub_option_circuit_id_custom => true,
      ipv4_sub_option_circuit_id_string => '%p%p',
      ipv4_sub_option_cisco             => true,
      ipv6_option_cisco                 => true,
      ipv6_option_vpn                   => true,
      ipv6_relay                        => true,
      ipv6_src_intf                     => 'vlan2',
    }
  "

  apply_to_all

  ###################
  # Resource Naming #
  ###################

  newparam(:name, namevar: :true) do
    desc 'ID of the dhcp_relay global config. Valid values are default.'

    validate do |inst_name|
      fail "only acceptable name is 'default'" if inst_name != 'default'
    end
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:ipv4_information_option) do
    desc 'Enables inserting relay information in BOOTREQUEST'

    newvalues(:true, :false, :default)
  end # property ipv4_information_option

  newproperty(:ipv4_information_option_trust) do
    desc 'Enables relay trust functionality on the system'

    newvalues(:true, :false, :default)
  end # property ipv4_information_option_trust

  newproperty(:ipv4_information_option_vpn) do
    desc 'Enables relay support across VRFs'

    newvalues(:true, :false, :default)
  end # property ipv4_information_option_vpn

  newproperty(:ipv4_information_trust_all) do
    desc 'Enables relay trust on all the interfaces'

    newvalues(:true, :false, :default)
  end # property ipv4_information_trust_all

  newproperty(:ipv4_relay) do
    desc 'Enables DHCP relay agent'

    newvalues(:true, :false, :default)
  end # property ipv4_relay

  newproperty(:ipv4_smart_relay) do
    desc 'Enables DHCP smart relay'

    newvalues(:true, :false, :default)
  end # property ipv4_smart_relay

  newproperty(:ipv4_src_addr_hsrp) do
    desc 'Enables Virtual IP instead of SVI address'

    newvalues(:true, :false, :default)
  end # property ipv4_src_addr_hsrp

  newproperty(:ipv4_src_intf) do
    desc "Source interface for the DHCPV4 relay. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = value.downcase.delete(' ')
      value = :default if value == 'default'
      value
    end
  end # property ipv4_src_intf

  newproperty(:ipv4_sub_option_circuit_id_custom) do
    desc 'Enables circuit id customized to include vlan id, slot and port info'

    newvalues(:true, :false, :default)
  end # property ipv4_sub_option_circuit_id_custom

  newproperty(:ipv4_sub_option_circuit_id_string) do
    desc "Specifies suboption format type string. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = value.strip
      if value == 'default'
        value = :default
      else
        value = "\"#{value}\"" unless value.start_with?('"') && value.end_with?('"')
      end
      value
    end
  end # property ipv4_sub_option_circuit_id_string

  newproperty(:ipv4_sub_option_cisco) do
    desc 'Enables cisco propritery suboptions'

    newvalues(:true, :false, :default)
  end # property ipv4_sub_option_cisco

  newproperty(:ipv6_option_cisco) do
    desc 'Enables cisco propritery suboptions for DHCPV6'

    newvalues(:true, :false, :default)
  end # property ipv6_option_cisco

  newproperty(:ipv6_option_vpn) do
    desc 'Enables DHCPv6 relay support across VRFs'

    newvalues(:true, :false, :default)
  end # property ipv6_option_vpn

  newproperty(:ipv6_relay) do
    desc 'Enables DHCPv6 relay agent'

    newvalues(:true, :false, :default)
  end # property ipv6_relay

  newproperty(:ipv6_src_intf) do
    desc "Source interface for the DHCPV6 relay. Valid values
          are string, keyword 'default'. "

    munge do |value|
      value = value.downcase.delete(' ')
      value = :default if value == 'default'
      value
    end
  end # property ipv6_src_intf
end # Puppet::Type.newtype
