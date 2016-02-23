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
    cisco_ace { 'ipv4 my_ipv4_acl 20':
        action                                => 'permit',
        proto                                 => 'tcp',
        src_addr                              => '1.2.3.4 2.3.4.5',
        src_port                              => 'eq 40',
        dst_addr                              => '8.9.0.4/32',
        dst_port                              => 'range 32 56',
        tcp_flags                             => 'ack syn fin'
        dscp                                  => 'af11',
        established                           => false,
        http_method                           => 'post',
        packet_length                         => 'range 80 1000',
        tcp_option_length                     => '20',
        time_range                            => 'my_range',
        ttl                                   => '153',
        redirect                              => 'Ethernet1/1,Ethernet1/2,port-channel1',
        log                                   => false,
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
    desc 'The Address-Family Identifier (ipv4|ipv6)'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:acl_name, namevar: true) do
    desc 'The Access Control List (ACL) name'
  end

  newparam(:seqno, namevar: true) do
    desc 'The Access Control Entry (ACE) Sequence number'
  end

  ##############
  # Properties #
  ##############

  newproperty(:action) do
    msg = 'The Action Identifier. Valid values are keywords `permit`, `deny`.'
    desc msg
    validate do |action|
      fail msg unless /permit|deny/.match(action.downcase)
    end

    munge(&:downcase)
  end

  newproperty(:proto) do
    msg = 'The protocol to match against. Valid values are String or Integer.'\
           'Examples are: `tcp`, `udp`, `ip`, `6`.'
    desc msg
    validate do |proto|
      fail msg unless /\S+|\d+/.match(proto)
    end
  end

  newproperty(:src_addr) do
    msg = 'The Source Address to match against. Valid values are type '\
          'String and must be one of the following forms: '\
          'An IPv4/IPv6 address or subnet; '\
          'keyword `host` and a host address; '\
          'keyword `addrgroup` and its object group name; or '\
          'keyword `any`.'
    desc msg
    validate do |src_addr|
      fail msg unless
        %r{any|host \S+|\S+\/\d+|\S+ [:\.0-9a-fA-F]+|addrgroup \S+}.match(src_addr)
    end
  end

  newproperty(:src_port) do
    msg = 'The TCP or UDP Source Port to match against. Valid values are type '\
          'String and must be one of the following forms: '\
          'A comparison operator (`eq`, `neq`, `lt`, `gt`) and value; '\
          'keyword `range` and range values; or '\
          'keyword `portgroup` and its object group name'
    desc msg
    validate do |src_port|
      fail msg unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+|portgroup \S+/.match(src_port)
    end
  end

  newproperty(:dst_addr) do
    msg = 'The Destination Address to match against. Valid values are '\
          'type String and must be one of the following forms: '\
          'An IPv4/IPv6 address or subnet; '\
          'keyword `host` and a host address; '\
          'keyword `addrgroup` and its object group name; or '\
          'keyword `any`.'
    desc msg
    validate do |dst_addr|
      fail msg unless
        %r{any|host \S+|\S+\/\d+|\S+ [:\.0-9a-fA-F]+|addrgroup \S+}.match(dst_addr)
    end
  end

  newproperty(:dst_port) do
    msg = 'The TCP or UDP Destination Port to match against. Valid values are '\
          'type String and must be one of the following forms: '\
          'A comparison operator (`eq`, `neq`, `lt`, `gt`) and value; '\
          'keyword `range` and range values; or '\
          'keyword `portgroup` and its object group name.'
    desc msg
    validate do |dst_port|
      fail msg unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+|portgroup \S+/.match(dst_port)
    end
  end

  newproperty(:remark) do
    desc 'This is a Remark description for the ACL or ACE. '\
         'Valid values are string.'
  end

  newproperty(:tcp_flags) do
    msg = 'The TCP flags or control bits. Valid values are a String of some '\
          'or all of flags: `urg`, `ack`, `psh`, `rst`, `syn`, or `fin`.'
    desc msg
    validate do |tcp_flags|
      fail msg unless
        /(ack *|fin *|urg *|syn *|psh *|rst *)*/.match(tcp_flags) ||
        tcp_flags.nil?
    end
  end

  newproperty(:established) do
    desc 'Allows matching against TCP Established connections. '\
         'Valid values are true or false.'
    newvalues(:true, :false)
  end

  newproperty(:precedence) do
    msg = 'Allows matching by precedence value. Valid values are String, '\
          'which must be one of the following forms: A numeric precedence '\
          'value; or one of the precedence keyword names: (`critical` `flash` '\
          '`flash-override` `immediate` `internet` `network` `priority` '\
          '`routine`)'
    desc msg
    validate do |precedence|
      fail msg unless
        /^([0-7]|critical|flash|flash-override|immediate|internet|network|priority|routine)$/.match(precedence)
    end
  end

  newproperty(:dscp) do
    msg = 'Allows matching by Differentiated Services Code Point (DSCP) '\
          'value. Valid values are String, which must be one of the '\
          'following forms: A numeric dscp value; or one of the dscp '\
          'keyword names.'
    desc msg
    validate do |dscp|
      fail msg unless
        /^([0-9]|[1-5][0-9]|6[0-3]|af[1-4][1-3]|cs[1-7]|default|ef)$/.match(dscp)
    end
  end

  newproperty(:time_range) do
    desc 'Allows matching by Time Range. Valid values are String, which '\
         'references a `time-range` name.'
  end

  newproperty(:packet_length) do
    msg = 'Allows matching based on Layer 3 Packet Length. Valid values are '\
          'type String, which must be one of the following forms: '\
          'A comparison operator (`eq`, `neq`, `lt`, `gt`) and value; or the '\
          'keyword `range` and range values.'
    desc msg
    validate do |packet_length|
      fail msg unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+/.match(packet_length)
    end
  end

  newproperty(:ttl) do
    msg = 'Allows matching based on Time-To-Live (TTL) value. Valid values '\
          'are type Integer or String.'
    desc msg
    validate do |ttl|
      fail msg unless ttl.to_f.between?(0, 255)
    end
  end

  newproperty(:http_method) do
    msg = 'Allows matching based on http-method. Valid values are '\
          'String, which must be one of the following forms: '\
          'A numeric http-method value; or one of the http-method keyword '\
          'names: (`connect` `delete` `get` `head` `post` `put` `trace`)'
    desc msg
    validate do |http_method|
      fail msg unless
        /^([1-7]|connect|delete|get|head|post|put|trace)$/.match(http_method)
    end
  end

  newproperty(:tcp_option_length) do
    msg = 'Allows matching on TCP options length. Valid values are type '\
          'Integer or String, which must be a multiple of 4 in the range 0-40.'
    desc msg
    validate do |tcp_option_length|
      fail msg unless
        /^(0|4|8|12|16|20|24|28|32|36|40)$/.match(tcp_option_length)
    end
  end

  newproperty(:redirect) do
    desc 'Allows for redirecting traffic to one or more interfaces. This '\
         'property is only useful with VLAN ACL (VACL) applications. Valid '\
         'values are a String containing a list of interface names.'
  end

  newproperty(:log) do
    desc 'Enables logging for the ACE. Valid values are true or false.'
    newvalues(:true, :false)
  end
end
