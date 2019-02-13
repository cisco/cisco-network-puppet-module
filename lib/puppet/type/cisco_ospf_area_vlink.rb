# Manages the Cisco OSPF area virtual-link configuration resource.
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

Puppet::Type.newtype(:cisco_ospf_area_vlink) do
  @doc = "Manages an area virtual_link for an OSPF router.

    cisco_ospf_area_vlink {\"<ospf> <vrf> <area> <vlink>\":
      ..attributes..
    }

    <ospf> is the name of the ospf router instance.
    <vrf> is the name of the ospf vrf.
    <area> is the name of the ospf area instance.
    <vlink> is the name of the virtual_link instance.

    Examples:
    cisco_ospf_area_vlink {'myrouter vrf1 1.1.1.1 8.8.8.8':
      ensure                             => 'present',
      auth_key_chain                     => 'keyChain',
      authentication                     => 'md5',
      authentication_key_encryption_type => cisco_type_7,
      authentication_key_password        => '98765432109876543210',
      dead_interval                      => 500,
      hello_interval                     => 2000,
      message_digest_algorithm_type      => 'md5',
      message_digest_encryption_type     => cisco_type_7,
      message_digest_key_id              => 123,
      message_digest_password            => '12345678901234567890',
      retransmit_interval                => 777,
      transmit_delay                     => 333,
    }
  "

  apply_to_all
  ensurable

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
      /^(\S+) (\S+) (\S+) (\S+)$/,
      [
        [:ospf, identity],
        [:vrf, identity],
        [:area, identity],
        [:vlink, identity],
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:ospf]} #{self[:vrf]} #{self[:area]} #{self[:vlink]}"
  end

  newparam(:name) do
    desc 'Name of cisco_ospf_area_vlink, not used, but needed for puppet'
  end

  newparam(:vlink, namevar: true) do
    desc 'Name of the virtual_link instance. Valid values are string.'
  end # param vlink

  newparam(:area, namevar: true) do
    desc 'Name of the resource instance. Valid values are string.'
    munge do |value|
      value = IPAddr.new(value.to_i, Socket::AF_INET) unless
        value[/\./]
      value
    end
  end # param area

  newparam(:vrf, namevar: true) do
    desc "Name of the vrf instance. Valid values are string. The
          name 'default' is a valid VRF."
  end # param vrf

  newparam(:ospf, namevar: true) do
    desc 'Name of the ospf instance. Valid values are string.'
  end # param ospf

  ##############
  # Attributes #
  ##############

  newproperty(:auth_key_chain) do
    desc "Authentication password key chain name. Valid
          values are string, keyword 'default'. "

    munge { |value| value == 'default' ? :default : value }
  end # property auth_key_chain

  newproperty(:authentication) do
    desc 'Enable authentication for the virtual_link.'

    newvalues(:cleartext, :md5, :null, :default)
  end # property authentication

  newproperty(:authentication_key_encryption_type) do
    desc "Specifies the scheme used for encrypting
          authentication key password. Valid values are
          'cleartext', '3des' or 'cisco_type_7' encryption,
          and 'default', which defaults to 'cleartext'."

    munge(&:to_sym)
    newvalues(:cleartext, :'3des', :cisco_type_7, :default)
  end # property authentication_key_encryption_type

  newproperty(:authentication_key_password) do
    desc "Specifies the authentication key password. Valid values are
          string, keyword 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property authentication_key_password

  newproperty(:dead_interval) do
    desc "Sets the time in seconds that a neighbor waits for a Hello packet
          before declaring the local router as dead and tearing down
          adjacencies. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property dead_interval

  newproperty(:hello_interval) do
    desc "Sets the time in seconds between successive Hello packets.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property hello_interval

  newproperty(:message_digest_algorithm_type) do
    desc "Algorithm used for authentication among neighboring routers
          within an area virtual link. Valid values are 'md5',
          keyword 'default'."

    newvalues(:md5, :default)
  end # property message_digest_algorithm_type

  newproperty(:message_digest_encryption_type) do
    desc "Specifies the scheme used for encrypting
          message digest password. Valid values are
          'cleartext', '3des' or 'cisco_type_7' encryption,
          and 'default', which defaults to 'cleartext'."

    munge(&:to_sym)
    newvalues(:cleartext, :'3des', :cisco_type_7, :default)
  end # property message_digest_encryption_type

  newproperty(:message_digest_key_id) do
    desc 'md5 authentication key id. Valid values are integer.'

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property message_digest_key_id

  newproperty(:message_digest_password) do
    desc 'Specifies the message digest password. Valid values are
          string.'

    munge { |value| value == 'default' ? :default : value }
  end # property message_digest_password

  newproperty(:retransmit_interval) do
    desc "Sets the estimated time in seconds between successive LSAs.
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property retransmit_interval

  newproperty(:transmit_delay) do
    desc "Sets the estimated time in seconds to transmit an LSA to
          a neighbor. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property transmit_delay

  def check_authentication
    return unless self[:authentication_key_password] == :default ||
                  self[:authentication_key_password] == ''
    var = :authentication_key_encryption_type
    fail ArgumentError,
         'authentication_key_encryption_type MUST be default when authentication_key_password is default' unless
      self[var].nil? || self[var] == :default || self[var] == :cleartext
  end

  def check_message_digest
    return if self[:message_digest_password].nil?
    if self[:message_digest_password] == :default ||
       self[:message_digest_password] == ''
      vars = [
        :message_digest_algorithm_type,
        :message_digest_encryption_type,
        :message_digest_key_id,
      ]
      vars.each do |p|
        fail ArgumentError,
             'All message_digest params should be default when message_digest_password is default' unless
          self[p].nil? || self[p] == :default || self[p] == :cleartext
      end
    else
      fail ArgumentError,
           'message_digest_key_id cannot be default when message_digest_password is not default' if
          self[:message_digest_key_id].nil? || self[:message_digest_key_id] == :default
    end
  end

  validate do
    check_authentication
    check_message_digest
  end
end
