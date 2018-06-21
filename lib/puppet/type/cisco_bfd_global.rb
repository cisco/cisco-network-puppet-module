# Manages the Cisco Bfd Global configuration resource.
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

Puppet::Type.newtype(:cisco_bfd_global) do
  @doc = "
    Manages the Cisco Bfd Global configuration resource.
    cisco_bfd_global {'default':
      ..attributes..
    }
    'default' is only acceptable name for this global config object.
    Example:
    cisco_bfd_global { 'default':
      ensure                => 'present',
      echo_interface        => 'loopback10',
      echo_rx_interval      => 300,
      fabricpath_interval   => ['750', '350', '45'],
      fabricpath_slow_timer => 15000,
      fabricpath_vlan       => 100,
      interval              => ['100', '100', '25'],
      ipv4_echo_rx_interval => 100,
      ipv4_interval         => ['200', '200', '50'],
      ipv4_slow_timer       => 10000,
      ipv6_echo_rx_interval => 200,
      ipv6_interval         => ['500', '500', '30'],
      ipv6_slow_timer       => 25000,
      slow_timer            => 5000,
      startup_timer         => 25,
    }
  "

  apply_to_all
  ensurable

  ###################
  # Resource Naming #
  ###################

  newparam(:name, namevar: :true) do
    inputs = "The name of the bfd_global instance. Valid values are 'default' only"
    desc inputs

    validate { |name| error inputs unless name == 'default' }
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:echo_interface) do
    desc "Loopback interface used for echo frames. Valid values are
          string (e.g. 'loopback42'), or keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property echo_interface

  newproperty(:echo_rx_interval) do
    desc "Echo receive interval in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property echo_rx_interval

  newproperty(:fabricpath_interval, array_matching: :all) do
    desc "Valid values are an array of  [fabricpath_interval, fabricpath_min_rx, fabricpath_multiplier]
      or keyword 'default'"

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge { |value| value == 'default' ? :default : value }
  end # property fabricpath_interval

  newproperty(:fabricpath_slow_timer) do
    desc "Fabricpath slow rate timer in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property fabricpath_slow_timer

  newproperty(:fabricpath_vlan) do
    desc "Fabricpath control vlan. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property fabricpath_vlan

  newproperty(:interval, array_matching: :all) do
    desc "Valid values are an array of  [interval, min_rx, multiplier]
      or keyword 'default'"

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge { |value| value == 'default' ? :default : value }
  end # property interval

  newproperty(:ipv4_echo_rx_interval) do
    desc "Ipv4 session echo receive interval in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property ipv4_echo_rx_interval

  newproperty(:ipv4_interval, array_matching: :all) do
    desc "Valid values are an array of  [ipv4_interval, ipv4_min_rx, ipv4_multiplier]
      or keyword 'default'"

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge { |value| value == 'default' ? :default : value }
  end # property ipv4_interval

  newproperty(:ipv4_slow_timer) do
    desc "Ipv4 session slow rate timer in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property ipv4_slow_timer

  newproperty(:ipv6_echo_rx_interval) do
    desc "Ipv6 session echo receive interval in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property ipv6_echo_rx_interval

  newproperty(:ipv6_interval, array_matching: :all) do
    desc "Valid values are an array of  [ipv6_interval, ipv6_min_rx, ipv6_multiplier]
      or keyword 'default'"

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge { |value| value == 'default' ? :default : value }
  end # property ipv6_interval

  newproperty(:ipv6_slow_timer) do
    desc "Ipv6 session slow rate timer in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property ipv6_slow_timer

  newproperty(:slow_timer) do
    desc "Slow rate timer in msec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property slow_timer

  newproperty(:startup_timer) do
    desc "Delayed startup timer in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property startup_timer
end
