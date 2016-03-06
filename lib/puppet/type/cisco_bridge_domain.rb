# Manages a Cisco Bridge Domain.
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

Puppet::Type.newtype(:cisco_bridge_domain) do
  @doc = "Manages a Cisco Bridge Domain (BD).

  cisco_bridge_domain {\"<bd>\":
    ..attributes..
  }

  <bd> is the id of the bridge domain.

  Example:
    cisco_bridge_domain {\"1000\":
      ensure          => present,
      name            => 'red',
      member_vni      => '5000',
      fabric_control  => 'false'
      shutdown        => 'false',
    }
    cisco_bridge_domain {\"1000-1100\":
      ensure          => present,
      member_vni      => '5000-5100',
      shutdown        => 'false',
    }
    cisco_bridge_domain {\"1000,1200\":
      ensure          => present,
      member_vni      => '5000,6000',
      shutdown        => 'false',
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

  def self.number?(string)
    true if Integer(string)
  rescue
    false
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
              fail 'BD ID needs to be an integer' unless number?(id) 
              fail 'BD ID is not in the valid range' unless valid_ids.include?(id.to_i)
            end # earray
          else
              fail 'BD ID needs to be an integer' unless number?(elem)
              fail 'BD ID is not in the valid range' unless valid_ids.include?(elem.to_i)
          end # if
        end # narray 
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:name) do
    desc "The name of the BD. Valid values are string, keyword 'default'."

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

  newproperty(:member_vni) do
    desc 'The VNI id that is mapped to the BD. Valid values are integer.'
    munge do |value|
      begin
        narray = value.split(',')
        narray.each do |elem|
          if elem.include?('-')
            earray = elem.split('-')
            earray.each do |id|
              fail 'VNI ID needs to be an integer' unless number?(id) 
              fail 'VNI ID is not in the valid range' unless id.to_i>4096
            end # earray
          else
              fail 'VNI ID needs to be an integer' unless number?(elem)
              fail 'VNI ID is not in the valid range' unless elem.to_id>4096
          end # if
        end # narray 
      end # begin
    end # munge
  end

  newproperty(:fabric_control) do
    desc 'whether to change BD type to fabric-control, Only one BD can be fabric-control'

    newvalues(
      :true,
      :false)
  end # property fabric_control
  
  newproperty(:shutdown) do
    desc 'whether or not the BD is shutdown'

    newvalues(
      :true,
      :false,
      :default)
  end # property shutdown
end # Puppet::Type.newtype
