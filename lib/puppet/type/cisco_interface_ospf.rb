# Manages configuration for an ospf interface instance
#
# March 2014
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

Puppet::Type.newtype(:cisco_interface_ospf) do
  @doc = "Manages configuration of an OSPF interface instance
  **Autorequires:** cisco_interface, cisco_ospf

  cisco_interface_ospf {\"<interface> <ospf>\":
    ..attributes..
  }

  <interface> is the name of the interface where the ospf interface config is to be applied. <ospf> is the name of the ospf router instance.

  Example:
    cisco_interface_ospf {\"Ethernet1/8 green\":
      ensure                         => present,
      area                           => \"0.0.0.0\",
      cost                           => 10,
      hello_interval                 => 10,
      dead_interval                  => 40,
      passive_interface              => true,
      message_digest                 => true,
      message_digest_key_id          => 5,
      message_digest_algorithm_type  => md5,
      message_digest_encryption_type => \"clear\",
      message_digest_password        => \"xxxxx\",
    }"

  ensurable

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+) (\S+)$/,
      [
        [:interface, identity],
        [:ospf, identity],
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:interface]} #{self[:ospf]}"
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of this cisco_interface resource. Valid values are string.'

    munge(&:downcase)
  end

  newparam(:ospf, namevar: :true) do
    desc 'Name of the cisco_ospf resource. Valid values are string.'
  end

  newparam(:name) do
    desc 'dummy paramenter to support puppet resource command'
  end

  newproperty(:cost) do
    desc "The cost associated with this cisco_interface_ospf
          instance. Valid values are integer."

    munge do |value|
      begin
        value = Integer(value)
      rescue
        raise 'cost property must be an integer.'
      end
      value
    end
  end

  newproperty(:hello_interval) do
    desc "The hello_interval associated with this cisco_interface_ospf
          instance. Time between sending successive hello packets. Valid
          values are integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'hello_interval property must be an integer.'
      end
      value
    end
  end

  newproperty(:dead_interval) do
    desc "The dead_interval associated with the cisco_interface_ospf
          instance. Time interval an ospf neighbor waits for a hello
          packet before tearing down adjacencies. Valid values are
          integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'dead_interval property must be an integer.'
      end
      value
    end
  end

  newproperty(:passive_interface) do
    desc "Passive interface associated with the cisco_interface_ospf
          instance. Setting to true will prevent this interface from
          receiving HELLO packets."

    newvalues(:true, :false)
  end

  newproperty(:message_digest) do
    desc "Enables or disables the usage of message digest
          authentication. "

    newvalues(:true, :false)
  end

  newproperty(:message_digest_key_id) do
    desc "md5 authentication key-id associated with the
          cisco_interface_ospf instance. If this is present in the
          manifest, message_digest_encryption_type,
          message_digest_algorithm_type and message_digest_password are
          mandatory. Valid values are integer."

    munge do |value|
      begin
        value = Integer(value)
      rescue
        raise "message_digest_key_id provided in the manifest - #{value} is not a valid integer."
      end
      value
    end
  end

  newparam(:message_digest_algorithm_type) do
    desc "Algorithm used for authentication among neighboring routers
          within an area. Keyword: 'default'"

    munge do |value|
      value = :md5 if value == 'default'
      value.to_sym
    end
    newvalues(:md5, :default)
  end

  newparam(:message_digest_encryption_type) do
    desc "Specifies the scheme used for encrypting
          message_digest_password. Valid values are 'cleartext',
          '3des' or 'cisco_type_7' encryption, and
          'default', which defaults to 'cleartext'."

    newvalues(:clear,
              :cleartext,
              :"3des",
              :cisco_type_7,
              :encrypted,
              :default)

    validate do |value|
      warning("keyword 'clear' is deprecated, please use 'cleartext'") if
        value.to_sym == :clear
      warning("keyword 'encrypted' is deprecated, please use 'cisco_type_7'") if
        value.to_sym == :encrypted
    end

    munge do |value|
      value = :cleartext if value.to_sym == :default || value.to_sym == :clear
      value = :cisco_type_7 if value.to_sym == :encrypted
      value.to_sym
    end
  end

  newproperty(:message_digest_password) do
    desc 'Specifies the message_digest password. Valid values are string.'

    validate do |message_digest_password|
      fail("message_digest_password - #{message_digest_password} should be a string")  \
        unless message_digest_password.nil? || message_digest_password.kind_of?(String)
    end
  end

  newproperty(:area) do
    desc "Ospf area associated with this cisco_interface_ospf
          instance. Valid values are string, formatted as an IP address
          i.e. \"0.0.0.0\" or as an integer. Mandatory parameter."

    validate do |value|
      valid_integer = true
      valid_ipaddr  = true

      begin
        Integer(value)
      rescue
        valid_integer = false
      end

      begin
        IPAddr.new(value)
      rescue
        valid_ipaddr = false
      end

      fail "area [#{value}] must be a valid ip address or integer" if
        valid_integer == false && valid_ipaddr == false
    end

    munge do |value|
      # Coerce numeric area to the expected dot-decimal format.
      value = IPAddr.new(value.to_i, Socket::AF_INET) unless value.to_s[/\./]
      value.to_s
    end
  end

  # validation for area, message_digest_key_id,
  # message_digest_encryption_type, message_digest_encryption_password
  # and message_digest_password combination

  validate do
    fail('area must be supplied when ensure=present') if
      self[:ensure] == :present && self[:area].nil?

    if (self[:message_digest_key_id].nil?) &&
       (!self[:message_digest_algorithm_type].nil? ||
        !self[:message_digest_encryption_type].nil? ||
        !self[:message_digest_password].nil?)
      fail("If message_digest_key_id is not present in the manifest, \
            the following attributes must not be present - \
            message_digest_algorithm_type, \
            message_digest_encryption_type, message_digest_password" )
    end

    if (!self[:message_digest_key_id].nil?) &&
       (self[:message_digest_algorithm_type].nil? ||
        self[:message_digest_encryption_type].nil? ||
        self[:message_digest_password].nil?)
      fail("If message_digest_key_id is present in the manifest, \
      the following attributes must also be present - \
            message_digest_algorithm_type, \
            message_digest_encryption_type, message_digest_password")
    end

    if self[:passive_interface] &&
       !/^lo\S+$/.match(self[:interface].downcase).nil?
      fail 'passive_interface value cannot be set on loopback interfaces'
    end
  end

  ################
  # Autorequires #
  ################

  # Autorequire cisco_interface; do not fail if it is not present in the manifest
  autorequire(:cisco_interface) do |rel_catalog|
    reqs = []

    interface_title = self[:interface]

    dep = rel_catalog.catalog.resource('cisco_interface', interface_title)

    info "Cisco_interface[#{interface_title}] was not found in catalog. " \
         'Will obtain from device.' if dep.nil?
    reqs << dep
    reqs
  end

  # Autorequire cisco_ospf; do not fail if it is not present in the manifest
  autorequire(:cisco_ospf) do |rel_catalog|
    reqs = []

    ospf_title = self[:ospf]

    dep = rel_catalog.catalog.resource('cisco_ospf', ospf_title)

    info "Cisco_ospf[#{ospf_title}] was not found in catalog. " \
         'Will obtain from device.' if dep.nil?
    reqs << dep
    reqs
  end
end
