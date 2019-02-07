# Manages a Cisco fabricpath Topology.
#
# June 2018
#
# Copyright (c) 2013-2018 Cisco and/or its affiliates.
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

require 'ipaddr'
begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_fabricpath_topology) do
  @doc = "Manages a Cisco fabricpath Topology.

  cisco_fabricpath_topology {'<topo_id>':
    ..attributes..
  }

  <topo_id> is the id of the topology.

  Example:
    cisco_fabricpath_topology {'1':
      ensure       => present,
      topo_name    => 'Topo-1',
      member_vlans => ['101-200', '250']
      member_vnis  => ['5000-5010', '10000']
    }

  "

  apply_to_all
  ensurable

  ###################
  # Resource Naming #
  ###################

  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\d+)$/,
      [
        [:topo_id, identity]
      ],
    ]
    patterns
  end

  newparam(:topo_id, namevar: true) do
    desc 'ID of the fabricpath topology. Valid values are integer in the range
          1-63. Value of 0 is reserved for default topology.'

    validate do |id|
      valid_ids = 1..63

      if id.to_i == 0
        warning('Cannot make changes to the default Topology.')
      elsif !valid_ids.include?(id.to_i)
        fail('ID is not in the valid range.')
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:member_vlans) do
    desc 'ID of the member VLAN(s). Valid values are integer /integer ranges.'

    munge do |value|
      value = PuppetX::Cisco::Utils.range_summarize(value)
      value
    end
  end # param id

  newproperty(:member_vnis) do
    desc 'ID of the member VNI(s). Valid values are integer /integer ranges.
         This property is dependent on Cisco_bridge_domain'

    munge do |value|
      value = PuppetX::Cisco::Utils.range_summarize(value)
      value
    end
  end # param id

  newproperty(:topo_name) do
    desc 'Descriptive name of the topology. Valid values are string'

    munge { |value| value == 'default' ? :default : value }
  end # property topo_name
end # Puppet::Type.newtype
