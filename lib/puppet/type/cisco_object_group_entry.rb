# Manages configuration for cisco_object_group_entry
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

Puppet::Type.newtype(:cisco_object_group_entry) do
  @doc = "Manages ObjectGroupEntry configuration.

  ~~~puppet
  cisco_object_group_entry { '<afi> <type> <grp_name> <seqno>':
    ..attributes..
  }
  ~~~

  `<afi> <type> <grp_name> <seqno>` is the title of the object_group_entry resource.

  Example:

  ~~~puppet
    cisco_object_group_entry { 'ipv4 address my_obj_grp_entry1 10':
      address                               => '1.2.3.4 2.3.4.5',
    }
    cisco_object_group_entry { 'ipv6 address my_obj_grp_entry2 10':
      address                               => '2000::1/64',
    }
    cisco_object_group_entry { 'ipv4 port my_obj_grp_entry3 20':
        port                              => 'eq 40',
    }
    cisco_object_group_entry { 'ipv4 port my_obj_grp_entry4 30':
        port                              => 'range 40 100',
    }
  ~~~
  "

  apply_to_all

  ###################
  # Resource Naming #
  ###################
  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.

  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(ipv4|ipv6)\s+(\S+)\s+(\S+)\s+(\d+)$/,
        [
          [:afi, identity],
          [:type, identity],
          [:grp_name, identity],
          [:seqno, identity],
        ],
      ]
    ]
  end

  ##############
  # Parameters #
  ##############

  ensurable

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:afi]} #{self[:type]} #{self[:grp_name]} #{self[:seqno]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:afi, namevar: true) do
    desc 'The Address-Family Identifier (ipv4|ipv6).'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:type, namevar: true) do
    desc 'Type of the object_group instance.'
    newvalues(:address, :port)
  end

  newparam(:grp_name, namevar: true) do
    desc 'Object Group Entry name'
  end

  newparam(:seqno, namevar: true) do
    desc 'Sequence number of the entry'
  end

  ##############
  # Properties #
  ##############

  newproperty(:address) do
    desc 'Address to match against. Valid values are an IP'\
         ' address/prefix_len, IP Address and wildcard, host and '\
         'host address'

    validate do |address|
      addr_arr = address.split
      addr_arr.each do |addr|
        next if addr == 'host'
        PuppetX::Cisco::Utils.process_network_mask(addr)
      end
    end
  end

  newproperty(:port) do
    desc 'port number to match against. valid'\
         ' port configuration should be eq 40 or range 30 50 etc.'

    validate do |port|
      fail 'port should be eq , neq, lt, gt or '\
           "range. port: #{port} " unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+/.match(port)
    end
  end
end
