# Puppet type that manages BGP Neighbor configuration.
#
# September 2015
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_bgp_neighbor) do
  @doc = "Manages BGP Neighbor configuration.

  ~~~puppet
  cisco_bgp_neighbor { '<title>':
    ..attributes..
  }
  ~~~

  `<title>` is the title of the bgp_neighbor resource.

  Example:

  ~~~puppet
    cisco_bgp_neighbor { 'raleigh':
      ensure                    => present,
      asn                       => '1'
      vrf                       => 'default',
      neighbor                  => '10.1.1.1',
      description               => 'my descritpion',
      connected_check           => true,
      capability_negotiation    => true,
      dynamic_capability        => true,
      ebgp_multihop             => 2,
      local_as                  => 1,
      log_neighbor_changes      => false,
      low_memory_exempt         => true,
      max_peers                 => 100,
      password                  => 'my password',
      password_type             => cleartext,
      remote_as                 => 12,
      remove_private_as         => 'all',
      shutdown                  => true,
      suppress_4_byte_as        => true,
      timers_keepalive          => 90,
      timers_holdtime           => 270,
      transport_passive_only    => true,
      update_source             => 'Ethernet1/1',
    }
  ~~~

  Example Title Patterns:

  ~~~puppet
    cisco_bgp_neighbor { 'new_york':
      ensure                    => present,
      asn                       => '1'
      vrf                       => 'red',
      neighbor                  => '10.1.1.1',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor { '1':
      ensure                    => present,
      vrf                       => 'red',
      neighbor                  => '10.1.1.1',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor { '1 red':
      ensure                    => present,
      neighbor                  => '10.1.1.1',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor { '1 red 10.1.1.1':
      ensure                    => present,
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
        /^(\d+|\d+\.\d+)$/,
        [
          [:asn, identity]
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:neighbor, identity],
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

  ##############
  # Parameters #
  ##############

  ensurable

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:asn]} #{self[:vrf]} #{self[:neighbor]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:asn, namevar: true) do
    desc "BGP autonomous system number.  Valid values are String in ASPLAIN
          or ASDOT notation or Integer"
    munge(&:to_s)
  end

  newparam(:vrf, namevar: true) do
    desc 'BGP vrf name. Valid values are string. ' \
         "The name 'default' is a valid VRF."

    defaultto('default')
    newvalues(/^\S+$/)
  end

  newparam(:neighbor, namevar: true) do
    desc 'BGP Neighbor ID. Valid values are string in the format of ipv4,
          ipv4/prefix length, ipv6, or ipv6/prefix length'
    munge do |value|
      begin
        value = PuppetX::Cisco::Utils.process_network_mask(value) unless value.nil?
        value
      rescue
        raise "neighbor must be in valid ipv4/v6 address or address/length
              format"
      end
    end
  end

  ##############
  # Properties #
  ##############
  newproperty(:description) do
    desc 'Description of the neighbor. Valid value is string.'
  end

  newproperty(:connected_check) do
    desc "Configure whether or not to check for directly connected peer. Valid
          values are true or false"
    newvalues(:true, :false)
  end

  newproperty(:capability_negotiation) do
    desc "Configure whether or not to negotiate capability with this neighbor.
          Valid values are true or false"
    newvalues(:true, :false)
  end

  newproperty(:dynamic_capability) do
    desc 'Enable dynamic capability or not. Valid values are true or false'
    newvalues(:true, :false)
  end

  newproperty(:ebgp_multihop) do
    desc "Specify multihop TTL for remote peer. Valid values are
          integers between 2 and 255, or keyword 'default' to
          disable this property"
    munge do |value|
      value = :default if value == 'default'
      unless value == :default
        value = value.to_i
        fail 'ebgp_multihop value should be between 2 and 255' unless
          value.between?(2, 255)
      end
      value
    end
  end

  newproperty(:local_as) do
    desc "Specify the local-as number for the eBGP neighbor. Valid values are
          String or Integer in ASPLAIN or ASDOT notation, or 'default', which
          means not to configure it"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      value.to_s unless value == :default
    end
  end

  newproperty(:log_neighbor_changes) do
    desc 'Enables logging of BGP neighbor status changes. '\
         "Valid values are 'enable', 'disable', or 'inherit'."
    munge(&:to_sym)
    newvalues(:enable, :disable, :inherit)
  end

  newproperty(:low_memory_exempt) do
    desc "Whether or not to shut down this neighbor under memory pressue. Valid
          values are 'true' to exempt the neighbor from being shutdown, 'false'
          to shut it down, or 'default' which is the default behavior"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      value.to_s.to_sym
    end
    newvalues(:true, :false, :default)
  end

  newproperty(:maximum_peers) do
    desc "Maximum number of peers for this neighbor prefix. Valid values are between
          1 and 1000, or 'default', which does not impose any limit. This attribute
          can only be configured if neighbor is in 'ip/prefix' format"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      unless value == :default
        value = value.to_i
        fail 'maximum peer value should be between 1 and 1000' unless
          value.between?(1, 1000)
      end
      value
    end
  end

  newproperty(:password) do
    desc "Specify the password for neighbor. Valid value is string, where an
          empty string means removing the password config"

    validate do |password|
      fail("password - #{password} should be a string") unless
        password.nil? || password.kind_of?(String)
    end
  end

  newparam(:password_type) do
    desc "Specify the encryption type that password will use.
          Valid values are 'cleartext', '3des', 'md5', or
          'cisco_type_7' encryption, and 'default',
          which defaults to 'cleartext'."

    newvalues(:cleartext,
              :"3des",
              :md5,
              :cisco_type_7,
              :default)

    munge do |value|
      value = :cleartext if value.to_sym == :default
      value.to_sym
    end
  end

  newproperty(:remote_as) do
    desc "Specify Autonomous System Number of the neighbor. Valid values are
          String or Integer in ASPLAIN or ASDOT notation, or 'default', which
          means not to configure it"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      value.to_s unless value == :default
    end
  end

  newproperty(:remove_private_as) do
    desc "Specify the config to remove private AS number from outbound updates.
          Valid values are 'enable' to enable this config, 'disable' to disable
          this config, 'all' to remove all private AS number, or 'replace-as'
          to replace the private AS number"
    munge(&:to_sym)
    newvalues(:enable, :disable, :all, :"replace-as")
  end

  newproperty(:shutdown) do
    desc "Shutdown state of the neighbor. Valid values are 'true' and 'false'"
    newvalues(:true, :false)
  end

  newproperty(:suppress_4_byte_as) do
    desc "Suppress sending out 4-byte AS capability. Valid values are 'true',
          'false', and 'default', which sets to the default 'false' value"
    newvalues(:true, :false, :default)
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      value.to_s.to_sym
    end
  end

  newproperty(:timers_keepalive) do
    desc "Keepalive timer value. Valid values are integers between 0 and 3600
          in terms of seconds, or 'default', which is 60"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      unless value == :default
        value = value.to_i
        fail 'keepalive timer value should be between 0 and 3600 seconds' unless
          value.between?(0, 3600)
      end
      value
    end
  end

  newproperty(:timers_holdtime) do
    desc "holdtime timer value. Valid values are integers between 0 and 3600
          in terms of seconds, or 'default', which is 180"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      unless value == :default
        value = value.to_i
        fail 'holdtime timer value should be between 0 and 3600 seconds' unless
          value.between?(0, 3600)
      end
      value
    end
  end

  newproperty(:transport_passive_mode) do
    desc "Specify the transport mode. Valid values are 'passive_only',
          'active_only', 'both', 'none', which clears the property,
          and 'default' which defaults to 'none'."
    newvalues(:passive_only,
              :active_only,
              :both,
              :none,
              :default)
    munge do |value|
      value = :none if value.to_sym == :default
      value.to_sym
    end
  end

  newproperty(:transport_passive_only) do
    desc "Allow passive connection setup only. Valid values are 'true',
          'false', and 'default' which defaults to 'false'. This attribute can
          only be configured when neighbor is in 'ip' address format"
    munge do |value|
      value = :default if value.to_s.to_sym == :default
      value.to_s.to_sym
    end
    newvalues(:true, :false, :default)
  end

  newproperty(:update_source) do
    desc "Specify source interface of BGP session and updates. Valid value is
          a string of the interface name"
    munge do |value|
      fail 'Interface name must be a string' unless value.kind_of?(String)
      value.downcase
    end
  end

  validate do
    fail("The 'asn' parameter must be set in the manifest.") if self[:asn].nil?
    fail("The 'vrf' parameter must be set in the manifest.") if self[:vrf].nil?
    fail("The 'neighbor' parameter must be set in the manifest.") if self[:neighbor].nil?

    if self[:password] && !self[:password].strip.empty? &&
       self[:password_type].nil?
      fail "the 'password_type' must be present if 'password' is present \
            and not an empty string"
    elsif self[:password].nil? && self[:password_type]
      fail "the 'password' must be present if 'password_type' is present"
    end
    mask = self[:neighbor].split('/')[1]
    if mask.nil?
      fail "attribute 'maximum_peers' is only available when the neighbor
            address is in 'ip/prefix' format" if self[:maximum_peers]
    else
      fail "attribute 'transport_passive_only' is only available when the
            neighbor address is in 'ip' format" if self[:transport_passive_only]
    end
  end
end
