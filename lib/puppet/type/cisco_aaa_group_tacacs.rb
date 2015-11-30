# Manages configuration for a TACACS+ server group.
#
# October 2015
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_aaa_group_tacacs) do
  @doc = "Manages configuration for a TACACS+ server group

  cisco_aaa_group_tacacs {\"<group>\":
    ..attributes..
  }

  <group> is the name of the TACACS+ server group resource.

  Example:
    cisco_aaa_group_tacacs {\"testgroup1\":
      ensure           => present,
      deadtime         => 30,
      server_hosts     => ['13.13.13.13', 'host1.cisco.com'],
      source_interface => 'Ethernet1/2',
      vrf_name         => \"blue\",
    }"

  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these patterns.
  # These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)$/,
      [
        [:group, identity]
      ],
    ]
    patterns
  end

  newparam(:group, namevar: true) do
    desc 'Name of the aaa group TACACS instance. Valid values are string.'

    validate do |value|
      fail "group #{value} must be a string" unless
        value.kind_of?(String) || value == :default
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  ##############
  # Attributes #
  ##############

  newproperty(:deadtime) do
    desc "Deadtime interval for this TACACS+ server group.
          Valid values are integer, in minutes, keyword 'default'"

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "deadtime - #{value} is not a valid number."
      end
      value
    end
  end

  newproperty(:server_hosts, array_matching: :all) do
    desc "An array of TACACS+ server hosts associated with this TACACS+ server
          group. Valid values are an array, or the keyword 'default'."

    validate do |value|
      fail "server_host #{value} must be a String" unless
        value.kind_of?(String) || value == :default
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end

    # override insync? method to compare server_hosts lists
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end
  end

  newproperty(:source_interface) do
    desc "Source interface for TACACS+ servers in this TACACS+ server group
          Valid values are string, keyword 'default'."

    validate do |value|
      fail "source_interface #{value} must be a string" unless
        value.kind_of?(String) || value == :default
    end

    munge do |value|
      value.downcase!
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:vrf_name) do
    desc "Specifies the virtual routing and forwarding instance (VRF)
          to use to contact this TACACS server group.
          Valid values are string, the keyword 'default'."

    validate do |value|
      fail "vrf_name #{value} must be a string" unless
        value.kind_of?(String) || value == :default
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end
end
