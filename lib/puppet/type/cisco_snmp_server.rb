# Manages configuration for an SNMP server.
#
# December 2013
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

Puppet::Type.newtype(:cisco_snmp_server) do
  @doc = "Manages a Cisco SNMP Server.

  cisco_snmp_server {\"<instance_name>\":
    ..attributes..
  }

  There can only be one instance of the cisco_snmp_server.

  Example:
    cisco_snmp_server {\"<instance_name>\":
      contact                => \"user1\",
      location               => \"rtp\",
      packet_size            => 2500,
      aaa_user_cache_timeout => 1000,
      tcp_session_auth       => false,
      protocol               => false,
      global_enforce_priv    => false,
    }"

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  ##############
  # Attributes #
  ##############

  newparam(:name, namevar: :true) do
    # Note, this parameter is only created to satisfy the namevar
    # since none of the snmp_server attributes are good candidates.
    desc 'The name of the SNMP Server instance. Valid values are string.'
    validate do |name|
      warning "only 'default' is accepted as a valid name" if name != 'default'
    end
  end # property name

  newproperty(:location) do
    desc 'SNMP location (sysLocation). ' \
         "Valid values are string, keyword 'default'."

    munge do |value|
      begin
        fail("location property - #{value} should be a string") unless
          value.kind_of?(String) || value == :default
        value = :default if value == 'default'
      rescue
        raise 'Munge for default of location property failed'
      end
      value
    end
  end

  newproperty(:contact) do
    desc "SNMP system contact (sysContact). Valid values are string,
          keyword 'default'."

    munge do |value|
      begin
        fail("contact property - #{value} should be a string") unless
          value.kind_of?(String) || value == :default
        value = :default if value == 'default'
      rescue
        raise 'Munge for default of contact property failed'
      end
      value
    end
  end

  newproperty(:aaa_user_cache_timeout) do
    desc "Configures how long the AAA synchronized user configuration
          stays in the local cache. Valid values are integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "aaa user cache timeout - #{value} is not a valid number."
      end
      value
    end
  end

  newproperty(:packet_size) do
    desc "Size of SNMP packet. Valid values are integer, in bytes,
          keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "Packet size - #{value} is not a valid number."
      end
      value
    end
  end

  newproperty(:global_enforce_priv) do
    desc 'Enable/disable SNMP message encryption for all users.'

    newvalues(:true, :false, :default)
  end

  newproperty(:protocol) do
    desc 'Enable/disable SNMP protocol.'

    newvalues(:true, :false, :default)
  end

  newproperty(:tcp_session_auth) do
    desc 'Enable/disable a one time authentication for SNMP over TCP session.'

    newvalues(:true, :false, :default)
  end
end
