# Manages configuration for an SNMP group.
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

Puppet::Type.newtype(:cisco_snmp_group) do
  @doc = "Manages a Cisco SNMP Group on a Cisco SNMP Server.

  group is a standard SNMP term but in NXOS role is used to serve the
  purpose of group; thus this provider utility does not create snmp groups
  and is limited to reporting group (role) existence only.

  cisco_snmp_group {\"<group>\":
    ..attributes..
  }

  <group> is the name of the snmp group.

  Example:
    cisco_snmp_group {\"network-admin\":
      ensure      => present,
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

  # Overwrites default name method.
  def name
    "#{self[:group]}"
  end

  newparam(:group, namevar: true) do
    desc 'Name of the snmp group. Valid values are string.'
  end
end
