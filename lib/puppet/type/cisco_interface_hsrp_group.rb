# Manages the Cisco HSRP interface group configuration resource.
#
# August 2018
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

Puppet::Type.newtype(:cisco_interface_hsrp_group) do
  @doc = "Manages an interface hsrp group.

    cisco_interface_hsrp_group {\"<interface> <group> <iptype>\":
      ..attributes..
    }

    <interface> is the name of the interface.
    <group> is the group id.
    <iptype> is ipv4 or ipv6.

    Examples:
    cisco_interface_hsrp_group {'Ethernet1/1 100 ipv4':
      ensure                        => 'present',
      authentication_auth_type      => 'md5',
      authentication_compatibility  => 'default',
      authentication_enc_type       => 'default',
      authentication_key_type       => 'key-chain',
      authentication_string         => 'MyKeyChain',
      authentication_timeout        => 'default',
      ipv4_enable                   => true,
      ipv4_vip                      => '10.10.10.10',
      ipv6_vip                      => 'default',
      ipv6_autoconfig               => 'default',
      mac_addr                      => '00:00:11:11:22:22',
      group_name                    => 'MyHsrpGroup',
      preempt                       => true,
      preempt_delay_minimum         => 100,
      preempt_delay_reload          => 200,
      preempt_delay_sync            => 300,
      priority                      => 50,
      priority_forward_thresh_lower => 20,
      priority_forward_thresh_upper => 30,
      timers_hello                  => 500,
      timers_hello_msec             => true,
      timers_hold                   => 1500,
      timers_hold_msec              => true,
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
      /^(\S+) (\d+) (\S+)$/,
      [
        [:interface, identity],
        [:group, identity],
        [:iptype, identity],
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:interface]} #{self[:group]} #{self[:iptype]}"
  end

  newparam(:name) do
    desc 'Name of cisco_interface_hsrp_group, not used, but needed for puppet'
  end

  newparam(:iptype, namevar: true) do
    desc 'Ip Type. Valid values are ipv4 or ipv6.'
    munge(&:to_s)
    newvalues(:ipv4, :ipv6)
  end # param iptype

  newparam(:group, namevar: true) do
    desc 'HSRP group ID. Valid values are integer.'
  end # param group

  newparam(:interface, namevar: true) do
    desc 'Name of the interface instance. Valid values are string.'
    munge(&:downcase)
  end # param interface

  ##############
  # Attributes #
  ##############

  newproperty(:authentication_auth_type) do
    desc 'Authentication type'

    newvalues(:cleartext, :md5)
  end # property authentication_auth_type

  newproperty(:authentication_compatibility) do
    desc 'Operate in compatibility mode for MD5 type-7 authentication.
          Valid only for key-string'

    newvalues(:true, :false)
  end # property authentication_compatibility

  newproperty(:authentication_enc_type) do
    desc 'Scheme used for encrypting authentication key string.'

    newvalues(:clear, :encrypted)
  end # property authentication_enc_type

  newproperty(:authentication_key_type) do
    desc 'Authentication key type'

    newvalues(:'key-chain', :'key-string')
  end # property authentication_key_type

  newproperty(:authentication_string) do
    desc "Specifies password or key chain name or key string name. Valid
          values are string, keyword 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property authentication_string

  newproperty(:authentication_timeout) do
    desc "Specifies authentication timeout. Valid only for key-string.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property authentication_timeout

  newproperty(:ipv4_enable) do
    desc 'Enables HSRP ipv4'

    newvalues(:true, :false, :default)
  end # property ipv4_enable

  newproperty(:ipv4_vip) do
    desc "Sets HSRP IPv4 virtual IP addressing name. Valid
          values are string, keyword 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property ipv4_vip

  newproperty(:ipv6_vip, array_matching: :all) do
    desc "Enables HSRP IPv6 and sets an array of virtual IPv6 addresses.
          Valid values are array of ipv6 addresses, keyword 'default'"

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        value
      end
    end
  end # property ipv6_vip

  newproperty(:ipv6_autoconfig) do
    desc 'Obtains ipv6 address using autoconfiguration'

    newvalues(:true, :false, :default)
  end # property ipv6_autoconfig

  newproperty(:mac_addr) do
    desc "Virtual mac address. Valid values are string, keyword 'default'"
    munge { |value| value == 'default' ? :default : value }
  end # property mac_addr

  newproperty(:group_name) do
    desc "Redundancy name string. Valid values are string, keyword 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property group_name

  newproperty(:preempt) do
    desc 'Overthrow lower priority Active routers'

    newvalues(:true, :false, :default)
  end # property preempt

  newproperty(:preempt_delay_minimum) do
    desc "Specifies time to wait at least this long before pre-empting.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property preempt_delay_minimum

  newproperty(:preempt_delay_reload) do
    desc "Specifies time to wait after reload.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property preempt_delay_reload

  newproperty(:preempt_delay_sync) do
    desc "Specifies time to wait for IP redundancy clients.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property preempt_delay_sync

  newproperty(:priority) do
    desc "Sets Priority value for this hsrp group.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property priority

  newproperty(:priority_forward_thresh_lower) do
    desc "Sets Priority forwarding lower threshold value.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property priority_forward_thresh_lower

  newproperty(:priority_forward_thresh_upper) do
    desc "Sets Priority forwarding upper threshold value.
          Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property priority_forward_thresh_upper

  newproperty(:timers_hello_msec) do
    desc 'Specify hello interval in milliseconds'

    newvalues(:true, :false, :default)
  end # property timers_hello_msec

  newproperty(:timers_hold_msec) do
    desc 'Specify hold interval in milliseconds'

    newvalues(:true, :false, :default)
  end # property timers_hold_msec

  newproperty(:timers_hello) do
    desc "Sets hello interval. Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property timers_hello

  newproperty(:timers_hold) do
    desc "Sets hold interval. Valid values are integer, keyword 'default'"

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property timers_hold

  def my_atype
    self[:authentication_auth_type].nil? ||
      self[:authentication_auth_type] == :cleartext
  end

  def my_enc
    self[:authentication_enc_type].nil? ||
      self[:authentication_enc_type] == :'0'
  end

  def my_key
    self[:authentication_key_type].nil?
  end

  def my_compat
    self[:authentication_compatibility].nil? ||
      self[:authentication_compatibility] == :false
  end

  def my_str
    self[:authentication_string].nil? ||
      self[:authentication_string] == :default ||
      self[:authentication_string].empty?
  end

  def my_timeout
    self[:authentication_timeout].nil? ||
      self[:authentication_timeout].zero?
  end

  def check_auth_str
    if self[:authentication_string].nil?
      fail ArgumentError,
           'Authentication properties auth_type, enc_type, key_type, compatibility, timeout MUST be default or undef when authentication_string is not set' unless
        my_atype && my_compat && my_enc && my_key && my_timeout
    else
      fail ArgumentError, 'authentication_auth_type MUST be set when authentication_string is set' if self[:authentication_auth_type].nil?
    end
  end

  def check_auth_type
    fail ArgumentError,
         'authentication_key_type and authentication_enc_type MUST be set when authentication_enc_type is md5' if !my_atype &&
                                                                                                                  (my_key || self[:authentication_enc_type].nil?)
  end

  def check_auth_key
    return if my_compat && my_timeout
    fail ArgumentError, 'authentication_compatibility and authentication_timeout MUST be default or undef unless authentication_key_type is key-string' unless
      self[:authentication_key_type].to_s == 'key-string'
  end

  def check_ipv4
    ena = self[:ipv4_enable].nil? || self[:ipv4_enable] == :default || self[:ipv4_enable] == :false
    vip = self[:ipv4_vip].nil? || self[:ipv4_vip] == :default || self[:ipv4_vip] == ''
    fail ArgumentError, 'ipv4 parameters MUST be default for ipv6 type' if self[:iptype] == 'ipv6' && (!ena || !vip)
    return unless ena
    fail ArgumentError, 'ipv4_enable MUST be default when ipv4_vip is default' unless vip
  end

  def check_ipv6
    return if self[:iptype] == 'ipv6'
    auto = self[:ipv6_autoconfig].nil? || self[:ipv6_autoconfig] == :default || self[:ipv6_autoconfig] == :false
    vip = self[:ipv6_vip].nil? || self[:ipv6_vip] == [:default] || self[:ipv6_vip].empty?
    fail ArgumentError, 'ipv6 parameters MUST be default for ipv4 type' if !auto || !vip
  end

  def check_preempt
    pre = self[:preempt].nil? || self[:preempt] == :default || self[:preempt] == :false
    return unless pre
    min = self[:preempt_delay_minimum].nil? || self[:preempt_delay_minimum] == :default || self[:preempt_delay_minimum].zero?
    rel = self[:preempt_delay_reload].nil? || self[:preempt_delay_reload] == :default || self[:preempt_delay_reload].zero?
    sync = self[:preempt_delay_sync].nil? || self[:preempt_delay_sync] == :default || self[:preempt_delay_sync].zero?
    fail ArgumentError, 'Preempt properties delay_minimum, delay_reload, delay_sync MUST be default when preempt is default' unless
      min && rel && sync
  end

  validate do
    check_auth_str
    check_auth_type
    check_auth_key
    check_ipv4
    check_ipv6
    check_preempt
  end
end
