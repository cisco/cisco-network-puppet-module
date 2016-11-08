# Manages the Cisco OSPF area virtual-link configuration resource.
#
# November 2016
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
      /^(\S+) (\S+) (\S+)$/,
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
  end # param iptype

  newparam(:group, namevar: true) do
    desc 'HSRP group ID. Valid values are integer.'
    munge(&:to_i)
  end # param group

  newparam(:interface, namevar: true) do
    desc 'Name of the interface instance. Valid values are string.'
  end # param interface

  ##############
  # Attributes #
  ##############

  newproperty(:authentication_auth_type) do
    desc 'Authentication type'

    newvalues(:cleartext, :md5, :default)
  end # property authentication_auth_type

  newproperty(:authentication_compatibility) do
    desc 'Operate in compatibility mode for MD5 type-7 authentication.
          Valid only for key-string'

    newvalues(:true, :false, :default)
  end # property authentication_compatibility

  newproperty(:authentication_enc_type) do
    desc 'Scheme used for encrypting authentication key string.'

    newvalues(:'0', :'7', :default)
  end # property authentication_enc_type

  newproperty(:authentication_key_type) do
    desc 'Authentication key type'

    newvalues(:'key-chain', :'key-string', :default)
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
        fail unless value.is_a?(Array)
        value
      end
    end
  end # property ipv6_vip

  newproperty(:ipv6_autoconfig) do
    desc 'Obtains ipv6 address using autoconfiguration'

    newvalues(:true, :false, :default)
  end # property ipv6_autoconfig

  newproperty(:mac_addr) do
    desc 'Virtual mac address.Valid values are in mac addresses format'
    newvalues(/^([0-9a-f]{2}[:]){5}([0-9a-f]{2})$/)
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

  # TODO: validations
end
