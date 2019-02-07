#
# June 2018
#
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_interface_evpn_multisite) do
  @doc = %(Manages a Cisco Evpn Multisite Tracking for an interface.

  cisco_interface_evpn_multisite {'<interface>':
    ..attributes..
  }

  <interface> is the name of the interface where the evpn multisite tracking is to be setup.

  Example:
    cisco_interface_evpn_multisite {'Ethernet1/15':
      ensure         => present,
      tracking       => 'fabric-tracking',
    }
  )

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

  apply_to_all
  ensurable

  newproperty(:tracking) do
    desc "The type of tracking to use with multisite interface.
          Valid values are String."
  end # property tracking
end # Puppet::Type.newtype
