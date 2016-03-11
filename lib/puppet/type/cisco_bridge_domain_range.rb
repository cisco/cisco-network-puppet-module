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

Puppet::Type.newtype(:cisco_bridge_domain_range) do
  @doc = "Manages a Cisco Bridge Domain Range (BD).

  cisco_bridge_domain {\"<bd>\":
    ..attributes..
  }

  <bd> is the id of the bridge domain.

  Example:
    cisco_bridge_domain {\"1000-1100\":
      member_vni        => '5000-5100'
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
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:member_vni) do
    desc "The segment-id mapped to the BD. Valid values are integer
          and of valid range."

    validate do |value|
      if value.to_i < 4096
        warning('VNI value needs to greater than 4096')
      else
        narray = value.split(',')
        narray.each do |elem|
          if elem.include?('-')
            earray = elem.split('-')
            earray.each do |id|
              fail 'VNI ID needs to be an integer' unless id == id.to_i.to_s
              fail 'VNI ID is not in the valid range' unless id.to_i > 4096
            end # earray
          else
            fail 'VNI ID needs to be an integer' unless elem == elem.to_i.to_s
            fail 'VNI ID is not in the valid range' unless elem.to_i > 4096
          end # if
        end # narray
      end # if
    end
  end # property name
end # Puppet::Type.newtype
