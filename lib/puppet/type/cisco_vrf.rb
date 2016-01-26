# Manages a Cisco VRF.
#
# July 2015
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_vrf) do
  @doc = "Manages a Cisco VRF.
  ~~~puppet
  cisco_vrf {'<vrf>':
    ..attributes..
  }
  ~~~

  <vrf> is the complete name of the VRF.

  Example:
  ~~~puppet
    cisco_vrf {'red':
     ensure                       => present,
     shutdown                     => false,
     description                  => 'vrf red',
     route_distinguisher          => '2:3'
     vni                          => 4096,
    }
  ~~~
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
        [:name, identity]
      ],
    ]
    patterns
  end

  newparam(:name, namevar: :true) do
    desc "Name of the VRF. Valid value is a string of non-whitespace
          characters. It is not case-sensitive"
    munge do |value|
      value.downcase.strip
    end
  end # param name

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:description) do
    desc 'Description of the VRF. Valid value is string.'

    munge do |val|
      val = :default if val == 'default'
      val
    end
  end # property description

  newproperty(:route_distinguisher) do
    desc 'VPN Route Distinguisher (RD). The RD is combined with the IPv4 '\
         'or IPv6 prefix learned by the PE router to create a globally '\
         'unique address. Valid values are a String in one of the '\
         'route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN); '\
         "the keyword 'auto', or the keyword 'default'."

    match_error = 'must be specified in ASN:nn or IPV4:nn notation'
    validate do |rd|
      fail "Route Distinguisher '#{value}' #{match_error}" unless
        /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(rd) || rd == 'auto' ||
        rd == 'default' || rd == :default
    end

    munge do |rd|
      rd = :default if rd == 'default'
      rd
    end
  end # property router_distinguisher

  newproperty(:shutdown) do
    desc 'Shutdown state of the VRF. '\
         'Valid values are true, false, or default'
    newvalues(:true, :false, :default)
  end # property shutdown

  newproperty(:vni) do
    desc "Specify virtual network identifier. Valid values are
          Integer or keyword 'default'"
    munge do |value|
      value == 'default' ? :default : value.to_i
    end
  end
end # Puppet::Type.newtype
