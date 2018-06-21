# Manages configuration for cisco_ace
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
    cisco_ace { 'ipv4 my_icmp_acl 20':
        action                                => 'permit',
        proto                                 => 'icmp',
        src_addr                              => 'any',
        dst_addr                              => 'any',
        dscp                                  => 'af11',
        set_erspan_dscp                       => '3',
        set_erspan_gre_proto                  => '300',
        proto_option                          => 'time-exceeded',
        vlan                                  => '2',
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

  apply_to_all
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
    desc 'Destination port to match src address port number. Valid'\
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

  newproperty(:tcp_flags) do
    desc 'TCP flags or control bits. Valid value is a whitespace separated'\
         ' list of the following flags: urg, ack, psh, rst, syn, fin.'

    validate do |tcp_flags|
      fail 'tcp_flags should be a whitespace separated list of zero or more'\
           ' of the following flags: urg, ack, psh, rst, syn, fin: #tcp_flags}' \
           unless /(ack *|fin *|urg *|syn *|psh *|rst *)*/.match(tcp_flags) \
           || tcp_flags.nil?
    end
  end

  newproperty(:established) do
    desc 'Match established connections'
    newvalues(:true, :false)
  end

  newproperty(:precedence) do
    desc 'Match packets with given precedence value. Valid values are '\
         '[0-7]|critical|flash|flash-override|immediate|internet|network|'\
         'priority|routine'

    validate do |precedence|
      fail 'precedence must be one of [0-7]|critical|flash|flash-override|'\
           'immediate|internet|network|priority|routine "#precedence' unless \
           /^([0-7]|critical|flash|flash-override|immediate|internet|network|priority|routine)$/.match(precedence)
    end
  end

  newproperty(:dscp) do
    desc 'Match packets with given dscp value. Valid values are '\
         '<0-63>|af11|af12|af13|af21|af22|af23|af31|af32|af33|af41|af42|af43|'\
         'cs1|cs2|cs3|cs4|cs5|cs6|cs7|default|ef'

    validate do |dscp|
      fail 'dscp must be one of <0-63>|af11|af12|af13|af21|af22|af23|af31|'\
           'af32|af33|af41|af42|af43|cs1|cs2|cs3|cs4|cs5|cs6|cs7|default|ef'\
           ' : #dscp' unless \
           /^([0-9]|[1-5][0-9]|6[0-3]|af[1-4][1-3]|cs[1-7]|default|ef)$/.match(dscp)
    end
  end

  newproperty(:time_range) do
    desc 'Match on time range. Valid values are string'
  end

  newproperty(:packet_length) do
    desc 'Match packets based on layer 3 packet length. '\
         'Packet Length should be eq 40 or range 100 250 etc. '\
         'Min. Packet Length is 20 and Max. is 9210'

    validate do |packet_length|
      fail 'packet length should be eq, neq, lt, gt or '\
           'range: #{packet_length}' unless
        /eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+/.match(packet_length)
    end
  end

  newproperty(:ttl) do
    desc 'Match packets with given TTL value. Valid values are bw 0 and 255'

    validate do |ttl|
      fail 'TTL must be between 0 and 255: #ttl' \
           unless ttl.to_f.between?(0, 255)
    end
  end

  newproperty(:http_method) do
    desc 'Match packets based on http-method. Valid values are '\
         '[1-7]|connect|delete|get|head|post|put|trace'

    validate do |http_method|
      fail 'http_method must be one of [1-7]|connect|delete|get|head|post|'\
           'put|trace :#http_method' unless \
           /^([1-7]|connect|delete|get|head|post|put|trace)$/.match(http_method)
    end
  end

  newproperty(:tcp_option_length) do
    desc 'Match on TCP options size. Valid values are multiples of 4 between 0 and 40'

    validate do |tcp_option_length|
      fail 'tcp_option_length should be a multiple of 4 between 0 and 40'\
           ' :#tcp_option_length' \
           unless /^(0|4|8|12|16|20|24|28|32|36|40)$/.match(tcp_option_length)
    end
  end

  newproperty(:redirect) do
    desc 'Redirect to interface(s). Syntax example: redirect Ethernet1/1,'\
         'Ethernet1/2,port-channel1'
  end

  newproperty(:proto_option) do
    desc 'Any protocol option. Example: time-exceeded. Valid values are string.'\
         'Currently this is valid only for icmp protocol.'
  end

  newproperty(:set_erspan_dscp) do
    desc 'Set ERSPAN outer IP DSCP value. Valid values are bw 1 and 63'\
         'Currently this is valid only for icmp protocol.'
  end

  newproperty(:set_erspan_gre_proto) do
    desc 'Set ERSPAN GRE protocol. Valid values are bw 1 and 65535'\
         'Currently this is valid only for icmp protocol.'
  end

  newproperty(:vlan) do
    desc 'Configure match based on vlan. Valid values are bw 0 and 4095'\
         'Currently this is valid only for icmp protocol.'
  end

  newproperty(:log) do
    desc 'Log matches against this entry'
    newvalues(:true, :false)
  end

  validate do
    unless self[:remark].nil?
      fail ArgumentError,
           "'established', 'proto_option' and 'log' properties should not be set for remark ace" unless
        self[:log].nil? && self[:established].nil? && self[:proto_option].nil?
    end
  end
end
