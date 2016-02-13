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

Puppet::Type.newtype(:cisco_snmp_community) do
  @doc = "Manages an SNMP community on a Cisco SNMP server.

  cisco_snmp_community {\"<community>\":
    ..attributes..
  }

  <community> is the name of the SNMP community resource.

  Example:
    cisco_snmp_community {\"setcom\":
      ensure    => present,
      group     => \"network-admin\",
      acl       => \"testcomacl\",
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
        [:community, identity]
      ],
    ]
    patterns
  end

  newparam(:community, namevar: true) do
    desc 'Name of the SNMP community. Valid values are string.'
  end

  ##############
  # Attributes #
  ##############

  newproperty(:group) do
    desc "Group that the SNMP community belongs to. Valid values are
          string, keyword 'default'."

    defaultto(:default)

    munge do |value|
      # can be simplified
      begin
        value = :default if value == 'default'
      rescue
        raise 'Munge for default of group property failed'
      end
      value
    end
  end

  newproperty(:acl) do
    desc "Assigns an Access Control List (ACL) to an SNMP community to
          filter SNMP requests. Valid values are string, 'default'."

    munge do |value|
      begin
        fail("acl property - #{value} should be a string") unless value.kind_of?(String) || value == :default
        value = :default if value == 'default'
      rescue
        raise 'Munge for default of acl property failed'
      end
      value
    end
  end

  ################
  # Autorequires #
  ################

  # Autorequire all cisco_snmp_groups associated with this community
  autorequire(:cisco_snmp_group) do |rel_catalog|
    groups = []
    groups << rel_catalog.catalog.resource('Cisco_snmp_group',
                                           "#{self[:group]}")
    groups
  end
end
