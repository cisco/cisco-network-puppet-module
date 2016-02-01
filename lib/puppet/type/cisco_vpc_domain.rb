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
        ensure                                           => 'present',
        auto_recovery                                    => 'true',
        auto_recovery_reload_delay                       => '300',
        delay_restore                                    => '250',
        delay_restore_interface_vlan                     => '300',
        dual_active_exclude_interface_vlan_bridge_domain => '10-30,500',
        graceful_consistency_check                       => 'true',
        layer3_peer_routing                              => 'true',
        peer_keepalive_dest                              => '1.1.1.1',
        peer_keepalive_hold_timeout                      => 5,
        peer_keepalive_interval                          => 1000,
        peer_keepalive_interval_timeout                  => 3,
        peer_keepalive_precedence                        => 5,
        peer_keepalive_src                               => '1.1.1.2',
        peer_keepalive_udp_port                          => 3200,
        peer_keepalive_vrf                               => 'management',
        peer_gateway                                     => 'true',
        peer_gateway_exclude_vlan                        => '500-1000,1100,1120',
        role_priority                                    => '32000',
        self_isolation                                   => 'false',
        shutdown                                         => 'false',
        system_mac                                       => '00:0c:0d:11:22:33',
        system_priority                                  => '32000',
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
      fail 'VPC domain must be in the range 1..1000' unless
        range.include?(name.to_i)
    end
    # We will retain the domain as a string and expect the provider
    # to return string as well
  end # param name

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:auto_recovery) do
    desc 'Auto Recovery enable or disable if peer is non-operational.
          Valid values are true, false or default'
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
        fail('delay_restore should be a value in the range 240 .. 3600') unless
          value.to_i.between?(240, 3600)
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
        fail('delay_restore should be a value in the range 240 .. 3600') unless
          value.to_i.between?(240, 3600)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:dual_active_exclude_interface_vlan_bridge_domain) do
    desc 'Interface vlans or bds to exclude from suspension when dual-active
          Valid value is a string of integer ranges from 1 .. 4095'
    munge do |value|
      # convert the string value to an array
      arr = /,/.match(value) ? value.split(/\s*,\s*/) : value.lines.to_a
      arr.each do |elem|
        if (match = /(\d+)\s+\-\s+(\d+)/.match(elem))
          num1, num2 = match.captures
          fail "Invalid range #{elem} in the input range #{value}" unless
            num1.to_i.between?(1, 4095) && num2.to_i.between?(1, 4095)
        else
          fail "Invalid value #{elem} in the input range #{value}" unless
            elem.to_i.between?(1, 4095)
        end
      end
      value.gsub!(/\s+/, '') # strip all spaces within and without
      value
    end
  end # property name

  newproperty(:graceful_consistency_check) do
    desc 'Graceful conistency check . Valid values are true, false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:layer3_peer_routing) do
    desc 'Enable or Disable Layer3 peer routing.
          Valid values are true/false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:peer_keepalive_dest) do
    desc 'Destination IPV4 address of the peer where Peer Keep-alives are terminated.
          Valid values are IPV4 unicast address'
    # use /x modifier to ignore whitespace in the regex which is split in 2 lines
    newvalues(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}
                (?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/x)
  end # property name

  newproperty(:peer_keepalive_hold_timeout) do
    desc 'Peer keep-alive hold timeout in secs. Valid Values are integers in the
          range 3 .. 10'
    validate do |value|
      if value != 'default'
        fail('pka hold_timeout should be a value in the range 3 .. 10') unless
          value.to_i.between?(3, 10)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:peer_keepalive_interval) do
    desc 'Peer keep-alive interval in millisecs. Valid Values are integers in the
          range 400 .. 10000'
    validate do |value|
      if value != 'default'
        fail('pka interval should be a value in the range 400 .. 10000') unless
          value.to_i.between?(400, 10_000)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:peer_keepalive_interval_timeout) do
    desc 'Peer keep-alive interval timeout. Valid Values are integers in the
          range 3 .. 20'
    validate do |value|
      if value != 'default'
        fail('pka interval timeout should be a value in the range 3 .. 20') unless
          value.to_i.between?(3, 20)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:peer_keepalive_precedence) do
    desc 'Peer keep-alive precedence. Valid Values are integers in the
          range 0 .. 7'
    validate do |value|
      if value != 'default'
        fail('pka precedence should be a value in the range 0 .. 7') unless
          value.to_i.between?(0, 7)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:peer_keepalive_src) do
    desc 'Source IPV4 address of this switch where Peer Keep-alives are Sourced.
          Valid values are IPV4 unicast address'
    # use /x modifier to ignore whitespace in the regex which is split in 2 lines
    newvalues(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}
                (?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/x)
  end # property name

  newproperty(:peer_keepalive_udp_port) do
    desc 'Peer keep-alive udp port used for hellos. Valid Values are integers in the
          range 1024 .. 65000'
    validate do |value|
      if value != 'default'
        fail('pka udp port should be a value in the range 1024 .. 65000') unless
          value.to_i.between?(1024, 65_000)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:peer_keepalive_vrf) do
    desc 'Peer keep-alive VRF. Valid Values are string'
    munge { |value| value == 'default' ? :default : value }
  end # property name

  newproperty(:peer_gateway) do
    desc 'Enable or Disable Layer3 forwarding for packets with peer gateway-mac.
          Valid values are true/false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:peer_gateway_exclude_bridge_domain) do
    desc 'Interface bds to exclude from peer gateway functionality
          Valid value is a string of integer ranges from 1 .. 16383'
    #
    # NOTE: This property depends on the availability of cisco_bridge_domain
    #
    munge do |value|
      # convert the string value to an array
      arr = /,/.match(value) ? value.split(/\s*,\s*/) : value.lines.to_a
      arr.each do |elem|
        if (match = /(\d+)\s+\-\s+(\d+)/.match(elem))
          num1, num2 = match.captures
          fail "Invalid range #{elem} in the input range #{value}" unless
            num1.to_i.between?(1, 16_383) && num2.to_i.between?(1, 16_383)
        else
          fail "Invalid value #{elem} in the input range #{value}" unless
            elem.to_i.between?(1, 16_383)
        end
      end
      value.gsub!(/\s+/, '') # strip all spaces within and without
      value
    end
  end # property name

  newproperty(:peer_gateway_exclude_vlan) do
    desc 'Interface vlans to exclude from peer gateway functionality
          Valid value is a string of integer ranges from 1 .. 4095'
    munge do |value|
      # convert the string value to an array
      arr = /,/.match(value) ? value.split(/\s*,\s*/) : value.lines.to_a
      arr.each do |elem|
        if (match = /(\d+)\s+\-\s+(\d+)/.match(elem))
          num1, num2 = match.captures
          fail "Invalid range #{elem} in the input range #{value}" unless
            num1.to_i.between?(1, 4095) && num2.to_i.between?(1, 4095)
        else
          fail "Invalid value #{elem} in the input range #{value}" unless
            elem.to_i.between?(1, 4095)
        end
      end
      value.gsub!(/\s+/, '') # strip all spaces within and without
      value
    end
  end # property name

  newproperty(:role_priority) do
    desc 'Priority to be used during vPC role selection of primary vs secondary
          Valid values are integers in the range 1 .. 65535'
    validate do |value|
      if value != 'default'
        fail('system_priority should be a value in the range 1 .. 65535') unless
          value.to_i.between?(1, 65_535)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:self_isolation) do
    desc 'Enable or Disable self-isolation function for VPC.
          Valid values are true, false or default'
    newvalues(:true, :false, :default)
  end # property name

  newproperty(:shutdown) do
    desc 'whether or not the VPC domain is shutdown'
    newvalues(:true, :false, :default)
  end # property shutdown

  newproperty(:system_mac) do
    desc 'VPC system mac. Valid values are in mac addresses format'
    newvalues(/^([0-9a-f]{2}[:]){5}([0-9a-f]{2})$/)
  end # property name

  newproperty(:system_priority) do
    desc 'VPC system priority. Valid values are integers in the range 1 .. 65535'
    validate do |value|
      if value != 'default'
        fail('system_priority should be a value in the range 1 .. 65535') unless
          value.to_i.between?(1, 65_535)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name
end # Puppet::Type.newtype
