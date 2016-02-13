# Manages the global overlay config of a Cisco Device. It includes
# Duplicate host IP address detection, duplicate host mac address
# detection and configuring anycast gateway mac address.
#
# November 2015
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_overlay_global) do
  @doc = "Manages the global overlay configuration of a Cisco device.

  ~~~puppet
  cisco_overlay_global { <title>:
    ..attributes..
  }
  ~~~

  There can only be one instance of the cisco_overlay_global.
  Example:

  ~~~puppet
    cisco_overlay_global { 'default':
      dup_host_ip_addr_detection_host_moves     => 200,
      dup_host_ip_addr_detection_timeout        => 20,
      anycast_gateway_mac                       => '1223.3445.5668',
      dup_host_mac_detection_host_moves         => 100,
      dup_host_mac_detection_timeout            => 10,
    }
  ~~~
  "

  newparam(:name, namevar: :true) do
    desc "Instance of overlay_global, only allow the value 'default'"
    validate do |name|
      if name != 'default'
        error "only 'default' is accepted as a valid overlay_global resource name"
      end
    end
  end

  ##############
  # Attributes #
  ##############

  newproperty(:dup_host_ip_addr_detection_host_moves) do
    desc "The number of host moves allowed in n seconds. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'dup_host_ip_addr_detection_host_moves must be an integer.'
      end
      value
    end
  end # property dup IP addr host_moves

  newproperty(:dup_host_ip_addr_detection_timeout) do
    desc "The duplicate detection timeout in seconds for the number of host moves.
          Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'dup_host_ip_addr_detection_timeout timeout must be an integer.'
      end
      value
    end
  end # property dup IP addr timeout

  newproperty(:anycast_gateway_mac) do
    desc "Distributed gateway virtual MAC address. Valid values are string, keyword 'default'."

    munge do |anycast_gateway_mac|
      anycast_gateway_mac = :default if anycast_gateway_mac == 'default'
      fail 'anycast_gateway_mac is not a string.' unless
        anycast_gateway_mac == :default || anycast_gateway_mac.is_a?(String)
      anycast_gateway_mac
    end
  end # property anycast gateway mac address

  newproperty(:dup_host_mac_detection_host_moves) do
    desc "The number of host moves allowed in n seconds. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'dup_host_mac_detection_host_moves must be an integer.'
      end
      value
    end
  end # property dup mac host_moves

  newproperty(:dup_host_mac_detection_timeout) do
    desc "The duplicate detection timeout in seconds for the number of host moves.
          Valid values are Integer, keyword 'default'."
    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'dup_host_mac_detection_timeout must be an integer.'
      end
      value
    end
  end # property dup mac timeout
end # type
