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

Puppet::Type.newtype(:cisco_ip_multicast) do
  @doc = %(Manages a Cisco IP Multicast configuration.

  cisco_ip_multicast {'default':
    ..attributes..
  }

  Example:
    cisco_ip_multicast {'default':
      ensure                       => present,
      overlay_distributed_dr       => 'true',
      overlay_spt_only             => 'true',
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
    desc "Instance of IP Multicast, only allow the value 'default'"

    validate do |name|
      if name != 'default'
        error "only 'default' is accepted as a valid cisco_ip_multicast
               resource name"
      end
    end
  end # param name

  ##############
  # Attributes #
  ##############

  apply_to_all
  ensurable

  newproperty(:overlay_distributed_dr) do
    desc "Configure node as Distributed-DR. Valid values are true, false or
          keyword 'default'"
    newvalues(:true, :false, :default)
  end # property overlay_distributed_dr

  newproperty(:overlay_spt_only) do
    desc "Enable L3-overlay shortest path tree only. Valid values are true,
          false or keyword 'default'"
    newvalues(:true, :false, :default)
  end # property overlay_spt_only
end # Puppet::Type.newtype
