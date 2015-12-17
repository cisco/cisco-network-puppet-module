# Manages a Cisco VXLAN Network Identifier (VNI).
#
# December 2015
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

Puppet::Type.newtype(:cisco_vni) do
  @doc = "Manages a Cisco VXLAN Network Identifier (VNI).

  cisco_vni {\"<vni>\":
    ..attributes..
  }

  <vni> is the id of the vni.

  Example:
    cisco_vni {\"10000\":
      ensure      => present,
      mapped_vlan => 100,
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
      /^(\d+)$/,
      [
        [:vni, identity]
      ],
    ]
    patterns
  end

  newparam(:vni, namevar: true) do
    desc 'ID of the Virtual Network Identifier. Valid values are integer.'
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:mapped_vlan) do
    desc 'Thee VLAN id that is mapped to the VNI. Valid values are integer.'
    # Keyword 'default' is not supported as there is no default mapping
    # between a vni and vlan
    munge do |value|
      begin
        value = Integer(value)
      rescue
        raise 'mapped_vlan must be an integer.'
      end # rescue
      value
    end
  end # property name
end # Puppet::Type.newtype
