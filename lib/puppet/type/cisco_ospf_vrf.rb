# Manages a VRF for OSPF.
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

Puppet::Type.newtype(:cisco_ospf_vrf) do
  @doc = "Manages a VRF for an OSPF router.

  cisco_ospf_vrf {\"<ospf> <vrf>\":
    ..attributes..
  }

  <ospf> is the name of the ospf router instance. <vrf> is the name of the ospf vrf.

  Example:
    cisco_ospf_vrf {\"green test\":
      ensure                   => present,
      router_id                => \"192.168.1.1\",
      default_metric           => 2,
      log_adjancency           => log,
      timer_throttle_lsa_start => 0,
      timer_throttle_lsa_hold  => 5000,
      timer_throttle_lsa_max   => 5000,
      timer_throttle_spf_start => 200,
      timer_throttle_spf_hold  => 1000,
      timer_throttle_spf_max   => 5000,
      auto_cost                => 40000,
  }"

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
      /^(\S+) (\S+)$/,
      [
        [:ospf, identity],
        [:vrf, identity],
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:ospf]} #{self[:vrf]}"
  end

  newparam(:name) do
    desc 'Name of cisco_ospf_vrf, not used, but needed for puppet'
  end

  newparam(:vrf, namevar: true) do
    desc "Name of the resource instance. Valid values are string. The
          name 'default' is a valid VRF."
  end # param vrf

  newparam(:ospf, namevar: true) do
    desc 'Name of the ospf instance. Valid values are string.'
  end # param ospf

  ##############
  # Attributes #
  ##############

  newproperty(:router_id) do
    desc "Router Identifier (ID) of the OSPF router VRF instance. Valid
          values are string, keyword 'default'."

    validate do |id|
      begin
        IPAddr.new(id) unless id == :default || id.empty? || id == 'default'
      rescue
        raise 'Router ID is not a valid IP address.'
      end
    end

    munge do |id|
      begin
        id = :default if id == 'default'
      rescue
        raise 'Munge for default of router_id property failed'
      end
      id
    end
  end # property router id

  newproperty(:default_metric) do
    desc "Specify the default Metric value. Valid values are integer,
          keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'Metric value is not a number.'
      end # rescue
      value
    end
  end # property default metric

  newproperty(:log_adjacency) do
    desc "Controls the level of log messages generated whenever a
          neighbor changes state. "

    newvalues(
      :log,
      :detail,
      :none,
      :default)
  end # property log adjacency

  newproperty(:timer_throttle_lsa_start) do
    desc "Specify the start interval for rate-limiting Link-State
          Advertisement (LSA) generation. Valid values are integer, in
          milliseconds, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'LSA start value is not a number.'
      end # rescue
      value
    end
  end # property lsa start

  newproperty(:timer_throttle_lsa_hold) do
    desc "Specifies the hold interval for rate-limiting Link-State
          Advertisement (LSA) generation. Valid values are integer, in
          milliseconds, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'LSA hold value is not a number.'
      end # rescue
      value
    end
  end # property lsa hold

  newproperty(:timer_throttle_lsa_max) do
    desc "Specifies the max interval for rate-limiting Link-State
          Advertisement (LSA) generation. Valid values are integer, in
          milliseconds, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'LSA max value is not a number.'
      end # rescue
      value
    end
  end # property lsa max

  newproperty(:timer_throttle_spf_start) do
    desc "Specify initial Shortest Path First (SPF) schedule
          delay. Valid values are integer, in milliseconds, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'SPF start value is not a number.'
      end # rescue
      value
    end
  end # property spf start

  newproperty(:timer_throttle_spf_hold) do
    desc "Specify minimum hold time between Shortest Path First (SPF)
          calculations. Valid values are integer, in milliseconds,
          keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'SPF hold value is not a number.'
      end # rescue
      value
    end
  end # property spf hold

  newproperty(:timer_throttle_spf_max) do
    desc "Specify the maximum wait time between Shortest Path First
          (SPF) calculations. Valid values are integer, in milliseconds,
          keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'SPF max value is not a number.'
      end # rescue
      value
    end
  end # property spf max

  newproperty(:auto_cost) do
    desc "Specifies the reference bandwidth used to assign OSPF
          cost. Valid values are integer, in Mbps, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'Cost value is not a number.'
      end # rescue
      value
    end
  end # property auto cost
end # Type
