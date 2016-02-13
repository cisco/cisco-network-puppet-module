#
# Puppet resource type for pim
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_pim_rp_address) do
  # ---------------------------------------------------------------
  # @doc entry to describe the resource and usage
  # ---------------------------------------------------------------
  @doc = "Manages configuration of a pim_rp_address instance

  ~~~puppet
  cisco_pim_rp_address {'<string>':
    ..attributes..
  }
  ~~~

  `<string>` is the name of the vrf.

  Example:

  ~~~puppet
    cisco_pim_rp_address { 'ipv4' :
      ensure              => present,
      vrf                 => 'default',
      rp_addr             => '1.1.1.1',
    }
  ~~~

  ~~~puppet
    cisco_pim_rp_address { 'ipv4 blue' :
      ensure          => present,
      rp_addr         => '1.1.1.1',
    }
  ~~~

  ~~~puppet
    cisco_pim_rp_address { 'ipv4 blue 1.1.1.1' :
      ensure          => present,
    }
  ~~~

  ~~~puppet
    cisco_pim_rp_address { 'newyork' :
      ensure              => present,
      afi                 => 'ipv4'
      vrf                 => 'default',
      rp_addr          => '1.1.1.1',
    }
  ~~~
  "
  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse the title to populate the attributes in these patterns.
  # These attributes may be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(ipv4)$/, # TBD ipv6
        [
          [:afi, identity]
        ],
      ],
      [
        /^(\S+)\s+(\S+)$/,
        [
          [:afi, identity],
          [:vrf, identity],
        ],
      ],
      [
        /^(\S+)\s+(\S+)\s+(\S+)$/,
        [
          [:afi, identity],
          [:vrf, identity],
          [:rp_addr, identity],
        ],
      ],
      [
        /^(\S+)$/,
        [
          [:name, identity]
        ],
      ],
    ]
  end

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:afi]} #{self[:vrf]} #{self[:rp_addr]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:afi, namevar: true) do
    desc 'The Address-Family Indentifier (ipv4|ipv6).'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:vrf, namevar: true) do
    desc 'Vrf name. Valid values are string. ' \
      "The name 'default' is a valid VRF."

    defaultto('default')
    newvalues(/^\S+$/)
  end

  newparam(:rp_addr, namevar: true) do
    desc 'The RP Address of a PIM Instance. ' \
         ' A valid IP address must be used.'

    validate do |ip|
      begin
        IPAddr.new(ip)
      rescue
        raise 'Rp Address is not a valid IP address.'
      end
    end
  end
end
