# Manages a Cisco Network Interface Channel Group.
#
# January 2016
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

Puppet::Type.newtype(:cisco_interface_channel_group) do
  @doc = "Manages a Cisco Network Interface Channel Group.

  Any resource dependency should be run before the interface resource.

  cisco_interface {'<interface>':
    ..attributes..
  }

  <interface> is the complete name of the interface.

  Example:
  cisco_interface_channel_group {'Ethernet1/15':
    channel_group   => 201,
    description     => 'my channel group',
    shutdown        => true,
  }
  "

  ###################
  # Resource Naming #
  ###################

  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(\S+)/,
        [
          [:interface, identity]
        ],
      ]
    ]
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of the interface on the network element. Valid values are string.'
    munge(&:downcase)
  end

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:channel_group) do
    desc "channel_group is an aggregation of multiple physical interfaces
          that creates a logical interface. Valid values are 1 to 4096."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property channel_group

  newproperty(:description) do
    desc "Description of the interface. Valid values are string, keyword
         'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property description

  newproperty(:shutdown) do
    desc 'Shutdown state of the interface.'

    newvalues(:true, :false, :default)
  end # property shutdown
end # Puppet::Type.newtype
