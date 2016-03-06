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
      ensure     => present,
      bd_name    => 'red',
      state      => 'active',
      shutdown   => 'false',
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
        [:bd, identity]
      ],
    ]
    patterns
  end

  newparam(:bd, namevar: true) do
    desc 'ID of the Bridge Domain. Valid values are integer.'

    validate do |id|
      range = *(2..16383)
      internal = *(3968..4047)
      valid_ids = range - internal

      if id.to_i == 1
        warning('Cannot make changes to the default BD.')
      elsif !valid_ids.include?(id.to_i)
        fail('ID is not in the valid range.')
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:bd_name) do
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

  newproperty(:state) do
    desc 'State of the BD.'

    newvalues(
      :active,
      :suspend,
      :default)
  end # property state

  newproperty(:shutdown) do
    desc 'whether or not the BD is shutdown'

    newvalues(
      :true,
      :false,
      :default)
  end # property shutdown
end # Puppet::Type.newtype
