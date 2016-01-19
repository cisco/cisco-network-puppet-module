# Manages configuration for cisco_ace
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

require 'ipaddr'
begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_ace) do
  @doc = "Manages ACE configuration.

  ~~~puppet
  cisco_ace { '<afi> <acl_name> <seqno>':
    ..attributes..
  }
  ~~~

  `<afi> <acl_name> <seqno>` is the title of the ace resource.

  Example:

  ~~~puppet
    cisco_ace { 'ipv4 my_ipv4_acl 10':
      action                                => 'permit',
      proto                                 => 'tcp',
      src_addr                              => '1.2.3.4 2.3.4.5',
      src_port                              => 'eq 40',
      dst_addr                              => '8.9.0.4/32',
      dst_port                              => 'range 32 56',
    }
    cisco_ace { 'ipv6 my_ipv6_acl 30':
      remark                                => 'remark description',
    }
  ~~~
  "

  ###################
  # Resource Naming #
  ###################
  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.

  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(ipv4|ipv6)\s+(\S+)\s+(\d+)$/,
        [
          [:afi, identity],
          [:acl_name, identity],
          [:seqno, identity],
        ],
      ]
    ]
  end

  ##############
  # Parameters #
  ##############

  ensurable

  # Overwrites the acl_name method which by default returns only
  # self[:name].
  def name
    "#{self[:afi]} #{self[:acl_name]} #{self[:seqno]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:afi, namevar: true) do
    desc 'The Address-Family Identifier (ipv4|ipv6).'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:acl_name, namevar: true) do
    desc 'Access Control List name'
  end

  newparam(:seqno, namevar: true) do
    desc 'Sequence number of the ACE'
  end

  ##############
  # Properties #
  ##############

  newproperty(:action) do
    desc 'Ace Action Identifier (permit|deny)'

    validate do |action|
      fail 'action should be permit or deny ' unless
        /permit|deny/.match(action.downcase)
    end

    munge(&:downcase)
  end

  newproperty(:proto) do
    desc 'Protocol Identifier for ACE (tcp|udp|ip etc)'

    validate do |proto|
      fail 'proto must be type String or Integer e.g tcp or 6' unless
        /\S+|\d+/.match(proto)
    end
  end

  newproperty(:src_addr) do
    desc 'Source address to match against. Valid values are an IP'\
         ' address/prefix_len (10.0.0.0/8), '\
         'an address group (addrgroup my_group), or the keyword any'

    validate do |src_addr|
      fail 'src_addr must be ip address/prefix_len (10.0.0.0/8), '\
           "address group (addrgroup foo), or keyword 'any'" unless
        %r{any|host \S+|\S+\/\d+|\S+ [:\.0-9a-fA-F]+|addrgroup \S+}.match(src_addr)
    end
  end

  newproperty(:src_port) do
    desc 'source port to match src address port number. valid'\
         ' port configuration should be eq 40 or range 30 50 etc.'

    validate do |src_port|
      fail 'src port should be eq , neq, lt, gt or '\
           "range or portgroup object. src_port: #{src_port} " unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+|portgroup \S+/.match(src_port)
    end
  end

  newproperty(:dst_addr) do
    desc 'Destination address to match against. Valid values are an IP'\
         ' address/prefix_len (10.0.0.0/8), '\
         "an address group (addrgroup foo), or the keyword 'any'"

    validate do |dst_addr|
      fail 'src_addr must be ip address/prefix_len (10.0.0.0/8), '\
           "address group (addrgroup foo), or keyword 'any'" unless
        %r{any|host \S+|\S+\/\d+|\S+ [:\.0-9a-fA-F]+|addrgroup \S+}.match(dst_addr)
    end
  end

  newproperty(:dst_port) do
    desc 'Destination port to match src address port number. valid'\
         ' port configuration should be eq 40 or range 30 50 etc.'

    validate do |dst_port|
      fail 'src port should be eq, neq, lt, gt or '\
           "range or portgroup object dst_port: #{dst_port}" unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+|portgroup \S+/.match(dst_port)
    end
  end

  newproperty(:remark) do
    desc 'A remark description for the ACL or ACE. Valid values are string'
  end
end
