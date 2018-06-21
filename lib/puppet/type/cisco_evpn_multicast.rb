#
# June 2018
#
# Copyright (c) 2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_evpn_multicast) do
  @doc = %(Manages the Cisco Evpn Multicast configuration.

  cisco_evpn_multicast {'default':
    ..attributes..
  }

  Example:
    cisco_evpn_multicast {'default':
      ensure              => present,
    }
  )

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  ##############
  # Parameters #
  ##############
  newparam(:name, namevar: true) do
    # Creating a parameter to satisfy namevar condition
    # Only 'default' is an accepted value
    desc "Instance of EVPN Multicast, only allow the value 'default'"

    validate do |name|
      if name != 'default'
        error "only 'default' is accepted as a valid evpn_multicast resource name"
      end
    end
  end # param name

  ##############
  # Attributes #
  ##############

  apply_to_all
  ensurable
end # Puppet::Type.newtype
