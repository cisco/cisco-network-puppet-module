# Manages a Cisco VPC domain object
#
# January 2016
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

Puppet::Type.newtype(:cisco_vpc_domain) do
  @doc = %q(
    Manages a Cisco VPC Domain.

    cisco_vpc_domain {"<domain>":
      ..attributes..
    }
  
    <domain> is the id of the vpc_domain.
  
    Example:
      cisco_vpc_domain {"100":
        ensure                       => present,
        auto_recovery                => true,
        auto_recovery_reload_delay   => 300,
        delay_restore                => 250,
        delay_restore_interface_vlan => 250,
        dual_active_exclude_interface_vlan_bridge_domain   => '10-20,500',
        graceful_consistency_check   => true,
        layer3_peer_routing          => true,
        peer_gateway                 => true,
        peer_gateway_exclude_vlan_bridge_domain            => '10-20,500',
  
      }
    )

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
      /^(\d+)$/,
      [
        [:domain, identity]
      ],
    ]
    patterns
  end

  newparam(:domain, namevar: true) do
    desc 'VPC domain ID. Valid values are integer in the range 1-1000'
    range = *(1..1000)
    validate do |name|
      fail "VPC domain must be in the range 1..1000" unless 
        range.include?(name.to_i)
    end
    munge do |name|
      name.to_i
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:auto_recovery) do
    desc 'Auto Recovery enable/disable if peer is non-operational. 
          Valid values are true/false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:auto_recovery_reload_delay) do
    desc 'Delay (in secs) before peer is assumed dead before attempting to 
          recover VPCs. Valid values are integers in the range 240 .. 3600'
    validate do |value|
      if value != 'default'
        fail('auto_recovery_reload_delay should be a value in the range 
              240 .. 3600') unless value.to_i.between?(240, 3600)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:delay_restore) do
    desc 'Delay (in secs) after peer link is restored to bring up VPCs
          Valid values are integers in the range 240 .. 3600'
    validate do |value|
      if value != 'default'
        fail('delay_restore should be a value in the range 240 .. 3600') 
          unless value.to_i.between?(240, 3600)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:delay_restore_interface_vlan) do
    desc 'Delay (in secs) after peer link is restored to bring up Interface 
          VLANs or Interface BDs. Valid values are integers in the 
          range 240 .. 3600'
    validate do |value|
      if value != 'default'
        fail('delay_restore should be a value in the range 240 .. 3600') 
          unless value.to_i.between?(240, 3600)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:dual_active_exclude_interface_vlan_bridge_domain) do
    desc 'Interface vlans or bds to exclude from suspension when dual-active
          Valid value is a string of integer ranges from 1 .. 4095'
    munge do |value|
      # convert the string value to an array
      arr = /,/.match(str) ? value.split(/\s*,\s*/) : value.lines.to_a
      arr.each do |elem|
        if match = /(\d+)\s+\-\s+(\d+)/.match(elem)
          num1, num2 = match.captures
          fail "Invalid range #{elem} in the input range #{value}" unless 
            num1.to_i.between?(1,4095) and num2.to_i.between(1, 4095)
        else
          fail "Invalid value #{elem} in the input range #{value}" unless
            elem.to_i.between?(1, 4095)
        end
      end
      value = value.gsub!(/\s+/, '') # strip all spaces within and without
    end
  end # property name

  newproperty(:graceful_consistency_check) do
    desc 'Graceful conistency check . Valid values are true/false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:layer3_peer_routing) do
    desc 'Enable/Disable Layer3 peer routing . 
          Valid values are true/false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:peer_gateway) do
    desc 'Enable/Disable Layer3 forwarding for packets with peer gateway-mac. 
          Valid values are true/false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:peer_gateway_exclude_vlan_bridge_domain) do
    desc 'Interface vlans or bds to exclude from peer gateway functionality
          Valid value is a string of integer ranges from 1 .. 4095'
    munge do |value|
      # convert the string value to an array
      arr = /,/.match(str) ? value.split(/\s*,\s*/) : value.lines.to_a
      arr.each do |elem|
        if match = /(\d+)\s+\-\s+(\d+)/.match(elem)
          num1, num2 = match.captures
          fail "Invalid range #{elem} in the input range #{value}" unless 
            num1.to_i.between?(1,4095) and num2.to_i.between(1, 4095)
        else
          fail "Invalid value #{elem} in the input range #{value}" unless
            elem.to_i.between?(1, 4095)
        end
      end
      value = value.gsub!(/\s+/, '') # strip all spaces within and without
    end
  end # property name
end # Puppet::Type.newtype
