# Manages ACE configuration.
#
# July 2015
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
    cisco_ace { 'ipv4 acl-foo-1 10':
      action                                => permit,
      proto                                 => tcp,
      src_addr                              => 1.2.3.4 2.3.4.5,
      src_port                              => eq 40,
      dst_addr                              => 8.9.0.4/32,
      dst_port                              => range 32 56,
      option_format                         => precedence critical
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
        /^(\S+) (\S+) (\d+)$/,
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
    desc 'acl_name '
  end

  newparam(:afi, namevar: true) do
    desc 'afi info of ace '
  end

  newparam(:acl_name, namevar: true) do
    desc 'acl_name '
  end

  newparam(:seqno, namevar: true) do
    desc 'seqno of ace'
  end

  ##############
  # Properties #
  ##############

  newproperty(:action) do
    desc ' ace action '

    validate do |action|
      fail 'action should be permit or deny ' unless
        /permit|deny/.match(action)
    end

    munge do |action|
      action
    end
  end

  newproperty(:proto) do
    desc 'protocol of ace'

    validate do |proto|
      fail 'protocol should be either string or integer' unless
        /\S+|\d+/.match(proto)
    end

    munge do |protocol|
      protocol
    end
  end

  newproperty(:src_addr) do
    desc 'src address of the ace'

    validate do |src_addr|
      fail 'src address should be ip address/prefix_len or address '\
      'wildcard or object group' unless
      %r{any|host \S+|\S+\/\d+|\S+ [:\.0-9a-fA-F]+|addrgroup \S+}
      .match(src_addr)
    end

    munge do |src_addr|
      src_addr
    end
  end

  newproperty(:src_port) do
    desc 'source port configuration of ace.'

    validate do |src_port|
      fail 'src port should be eq , neq, lt, gt or '\
        "range or portgroup object. src_port: #{src_port} " unless
        %r{eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+|portgroup \S+}
        .match(src_port)
    end

    munge do |src_port|
      src_port
    end
  end

  newproperty(:dst_addr) do
    desc 'dst address of the ace'

    validate do |dst_addr|
      fail 'dst address should be ip address/prefix_len or address '\
      'wildcard or object group' unless
      %r{any|host \S+|\S+\/\d+|\S+ [:\.0-9a-fA-F]+|addrgroup \S+}
      .match(dst_addr)
    end

    munge do |dst_addr|
      dst_addr
    end
  end

  newproperty(:dst_port) do
    desc 'destination port configuration of ace.'

    validate do |dst_port|
      fail 'src port should be eq, neq, lt, gt or '\
      "range or portgroup object dst_port: #{dst_port}" unless
      %r{eq \S+|neq \S+|lt \S+|gt \S+|range \S+ \S+|portgroup \S+}
      .match(dst_port)
    end

    munge do |dst_port|
      dst_port
    end
  end

  newproperty(:option_format) do
    desc 'ace option configuartion'

    munge do |option_format|
      option_format
    end
  end
end
