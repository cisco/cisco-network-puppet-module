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
        [:encap, identity]
      ],
    ]
    patterns
  end

  newparam(:encap, namevar: true) do
    desc 'Profile name of the Encapsulation. Valid values are alphanumeric
         with special characters.'
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:dot1q_map, array_matching: :all) do
    format = '[dot1q vlans, vnis]'
    desc "Dot1q vlan to vni mapping under encapsulation profile.
         Valid values match format #{format}"

    validate do |dot1q_map|
      puts "#{dot1q_map.length} values #{dot1q_map}"
      fail "Dot1q vlan to vni mapping should be of the format #{format}" unless
           dot1q_map.length == 2
      dot1q_map.split.each do |value|
        fail 'Values in dot1q list is not of integer type' unless /^[\d\s,-]*$/.match(value)
      end
      dot1q_map
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # property name
end # Puppet::Type.newtype
