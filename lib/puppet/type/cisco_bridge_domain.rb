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

Puppet::Type.newtype(:cisco_bridge_domain) do
  @doc = %{Manages a Cisco Bridge Domain (BD).

  cisco_bridge_domain {"<bd>":
    ..attributes..
  }

  <bd> is the id of the bridge domain.

  Example:
    cisco_bridge_domain {"1000":
      ensure          => present,
      bd_name         => 'red',
      fabric_control  => 'false',
      shutdown        => 'false',
    }
  }

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

    validate do |value|
      valid_ids = *(2..4096)

      fail 'bridge-domain ID needs to be an integer' unless /\d+/.match(value)
      if value.to_i == 1
        warning('Cannot make changes to the default BD.')
      else
        fail 'BD ID is not in the valid range' unless valid_ids.include?(value.to_i)
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:bd_name) do
    desc "The bridge-domain name. Valid values are String or keyword 'default'."

    munge do |value|
      fail 'BD Name is not a valid string' unless value.is_a?(String)
      value = :default if value == 'default'
      value
    end
  end # property name

  newproperty(:fabric_control) do
    desc %(Specifies this bridge-domain as the fabric control bridge-domain.
           Only one bridge-domain or VLAN can be configured as fabric-control.
           Valid values are true, false.)

    newvalues(
      :true,
      :false)
  end # property fabric_control

  newproperty(:shutdown) do
    desc "Specifies the shutdown state of the bridge-domain. Valid values are true, false, 'default'."

    newvalues(
      :true,
      :false)
  end # property shutdown
end # Puppet::Type.newtype
