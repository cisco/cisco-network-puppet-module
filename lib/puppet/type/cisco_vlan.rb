# Manages a Cisco VLAN.
#
# April 2013
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

Puppet::Type.newtype(:cisco_vlan) do
  @doc = "Manages a Cisco VLAN.

  cisco_vlan {\"<vlan>\":
    ..attributes..
  }

  <vlan> is the id of the vlan.

  Example:
    cisco_vlan {\"200\":
      ensure     => present,
      vlan_name  => 'red',
      mapped_vni => 20000,
      state      => 'active',
      shutdown   => 'true',
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
        [:vlan, identity]
      ],
    ]
    patterns
  end

  newparam(:vlan, namevar: true) do
    desc 'ID of the Virtual LAN. Valid values are integer.'

    validate do |id|
      range = *(2..4093)
      internal = *(3968..4047)
      valid_ids = range - internal

      if id.to_i == 1
        warning('Cannot make changes to the default VLAN.')
      elsif !valid_ids.include?(id.to_i)
        fail('ID is not in the valid range.')
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:vlan_name) do
    desc "The name of the VLAN. Valid values are string, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = String(value) unless value == :default
      rescue
        raise 'Name is not a valid string.'
      end # rescue
      value
    end
  end # property name

  newproperty(:mapped_vni) do
    desc 'The VNI id that is mapped to the VLAN. Valid values are integer.'
    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'mapped_vni must be an integer.'
      end # rescue
      value
    end
  end # property name

  newproperty(:state) do
    desc 'State of the VLAN.'

    newvalues(
      :active,
      :suspend,
      :default)
  end # property state

  newproperty(:shutdown) do
    desc 'whether or not the vlan is shutdown'

    newvalues(
      :true,
      :false,
      :default)
  end # property shutdown
end # Puppet::Type.newtype
