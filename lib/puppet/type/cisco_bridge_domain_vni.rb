# Manages a Cisco Bridge Domain.
#
# March 2016
#
# Copyright (c) 2016 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_bridge_domain_vni) do
  @doc = "Manages a Cisco Bridge Domain (BD).

  cisco_bridge_domain_vni {\"<bd>\":
    ..attributes..
  }

  <bd> is the range of ids of bridge domain.

  Example:
    cisco_bridge_domain_vni {\"100-110\":
      ensure          => present,
      member_vni      => '5100-5110',
    }
  "

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
      /^(\S+)$/,
      [
        [:bd, identity]
      ],
    ]
    patterns
  end

  newparam(:bd, namevar: true) do
    desc 'ID of the Bridge Domain. Valid values are integer.'

    validate do |value|
      range = *(2..4096)
      internal = *(3968..4096)
      valid_ids = range - internal

      if value.to_i == 1
        warning('Cannot make changes to the default BD.')
      else
        narray = value.split(',')
        narray.each do |elem|
          if elem.include?('-')
            earray = elem.split('-')
            earray.each do |id|
              fail 'BD ID needs to be an integer' unless id == id.to_i.to_s
              fail 'BD ID is not in the valid range' unless valid_ids.include?(id.to_i)
            end # earray
          else
            fail 'BD ID needs to be an integer' unless elem == elem.to_i.to_s
            fail 'BD ID is not in the valid range' unless valid_ids.include?(elem.to_i)
          end # if
        end # narray
      end
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:member_vni) do
    desc "The Virtual Network Identifier (VNI) id that is mapped to the VLAN.
          Valid values are integer"

    validate do |value|
      if value.to_i < 4097
        warning('Cannot map a vni less than 4097.')
      else
        narray = value.split(',')
        narray.each do |elem|
          if elem.include?('-')
            earray = elem.split('-')
            earray.each do |id|
              fail 'BD ID needs to be an integer' unless id == id.to_i.to_s
              fail 'BD ID is not in the valid range' unless id.to_i > 4097
            end # earray
          else
            fail 'BD ID needs to be an integer' unless elem == elem.to_i.to_s
            fail 'BD ID is not in the valid range' unless elem.to_i > 4097
          end # if
        end # narray
      end # if
      puts "member vni validate passed #{value}"
    end # validate

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property name
end # Puppet::Type.newtype
