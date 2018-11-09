#
# June 2018
#
# Copyright (c) 2016-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_encapsulation) do
  @doc = "Manages a Global VNI Encapsulation profile(dot1q).

  cisco_bridge_domain {\"<encap>\":
    ..attributes..
  }

  <encap> is the profile name of the encapsulation.

  Example:
    cisco_encapsulation {\"cisco\":
      ensure          => present,
      dot1q_map       => ['100-110', '5100-5110'],
    }
  "

  ##############
  # Parameters #
  ##############

  newparam(:encap, namevar: true) do
    desc 'Profile name of the Encapsulation. Valid values are alphanumeric
         with special characters.'
  end # param id

  ##############
  # Properties #
  ##############

  apply_to_all
  ensurable

  newproperty(:dot1q_map, array_matching: :all) do
    inputs = %(
      Valid values are the keyword 'default', or a mapping Array of the format:
       [dot1q_vlans, vnis]. Example:
          dot1q_map => ['100-110,150', '5000-5010,6000']
    )
    desc 'The encapsulation profile dot1q vlan-to-vni mapping.' + inputs

    validate do |value|
      fail inputs unless value.delete(' ')[/^(default|[\d,-]+)$/]
    end

    munge do |value|
      return :default if value[/default/]
      PuppetX::Cisco::Utils.range_summarize(value.delete(' '), false)
    end

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end
  end # property name
end # Puppet::Type.newtype
