# Manages configuration for an SNMP user.
#
# January 2014
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_snmp_user) do
  @doc = "Manages an SNMP user on an cisco SNMP server.
  **Autorequires:** cisco_snmp_group

  cisco_snmp_user {\"<user> <engine_id>\":
    ..attributes..
  }


  <user> is the name of the SNMP user resource.
  <engine_id> is the engine id the user belongs to. If it is local user, the
  <engine_id> is empty. Otherwise, it is 5 to 32 octets separated by colon.

  Example:
    cisco_snmp_user {\"v3test\":
      ensure        => present,
      groups        => ['network-admin'],
      auth_protocol => 'md5',
      auth_password => 'xxxxx',
      localized_key => false,
    }
    or
    cisco_snmp_user {\"v3test 128:128:127:127:124:2\":
      ensure        => present,
      groups        => ['network-admin'],
      auth_protocol => 'md5',
      auth_password => 'xxxxx',
      localized_key => false,
     } "

  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these patterns.
  # These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    # please call that "optional"
    identity2 = ->(x) { x.nil? ? '' : x }

    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)\s+??(\S+)?\s+??$/,
      [
        [:user, identity],
        [:engine_id, identity2],
      ],
    ]
    patterns
  end

  # Overwrites default name method.
  def name
    "#{self[:user].strip} #{self[:engine_id]}".strip
  end

  newparam(:name) do
    desc 'Name of cisco_snmp_user, not used, just to make puppet happy'
  end

  newparam(:user, namevar: true) do
    desc 'Name of the SNMP user. Valid values are string.'
    validate do |user|
      if /^(\w+)\s*$/.match(user).nil?
        fail 'user must be string of word characters'
      end
    end
  end

  newparam(:engine_id, namevar: true) do
    desc "Engine ID of the SNMP user. Valid values are empty string or 5 to 32
    octets seprated by colon."
    validate do |engine_id|
      id = engine_id.strip
      pattern = /([0-9]{1,3}(?::[0-9]{1,3}){4,31})?\s+??$/
      if !id.empty? && pattern.match(id)[1].nil?
        fail 'Engine ID should be either empty string or 5 to 32 octets separated by colon'
      end
    end
  end

  ##############
  # Attributes #
  ##############

  # Groups associated with this user.
  newproperty(:groups, array_matching: :all) do
    desc 'Groups that the SNMP user belongs to. Valid values are string.'

    # Override puppet's insync method, which checks whether current value is equal to value specified in manifest
    # Make sure puppet considers 2 arrays with same elements but in different order as equal

    # See puppet's user#group property for a different way to do that.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end
  end

  newproperty(:auth_protocol) do
    desc 'Authentication protocol for the SNMP user.'
    newvalues(:md5, :sha, :none)
  end

  newproperty(:auth_password) do
    desc "Authentication password for the SNMP user. Valid values are
          string."

    validate do |auth_password|
      fail("auth_password property - #{auth_password} should be a string") unless auth_password.kind_of? String
    end
    # auth password from box is hashed. Override insync? method and
    # use the method provided by the provider.
    def insync?(*)
      provider.auth_password_in_sync?
    end
  end

  newproperty(:priv_protocol) do
    desc 'Privacy protocol for the SNMP user.'

    newvalues(:aes128, :des, :none)
  end

  newproperty(:priv_password) do
    desc 'Privacy password for SNMP user. Valid values are string'

    validate do |privacy_password|
      fail("privacy_password property - #{privacy_password} should be a string") unless privacy_password.kind_of? String
    end
    # Priv password from box is hashed. Override the insync method and
    # use the method provided by the provider.
    def insync?(*)
      provider.priv_password_in_sync?
    end
  end

  newparam(:localized_key) do
    desc "Specifies whether the passwords specified in manifest are in
          localized key format (in case of true) or cleartext (in case of
          false)."
    defaultto(:false)
    newvalues(:true, :false)
  end

  ################
  # Autorequires #
  ################

  # Autorequire all cisco_snmp_groups associated with this user
  autorequire(:cisco_snmp_group) do |rel_catalog|
    groups = []

    unless self[:groups].nil?
      (self[:groups]).select do |group|
        group_name = "#{group}"
        groups << rel_catalog.catalog.resource('cisco_snmp_group', group_name)
      end
    end

    groups
  end
end
