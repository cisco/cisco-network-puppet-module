# Manages a Cisco ItdDeviceGroup.
#
# Feb 2016
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
Puppet::Type.newtype(:cisco_itd_device_group) do
  @doc = "Manages a Cisco ItdDeviceGroup.

  Any resource dependency should be run before the interface resource.

  cisco_itd_device_group {\"<name>\":
    ..attributes..
  }

  <name> is the complete name of the group.

  Example:
    cisco_itd_device_group {\"my_group\":
     ensure                       => present,
     probe_control                => false,
     probe_frequency              => 9,
     probe_port                   => 1000,
     probe_retry_down             => 2,
     probe_retry_up               => 2,
     probe_timeout                => 6,
     probe_type                   => \"udp\",
    }"

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
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  newparam(:name, namevar: :true) do
    desc "Name of the itd device group. Valid value is a string of
          non-whitespace characters. It is case-sensitive"
    munge(&:strip)
  end # param name

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:probe_control) do
    desc 'Enable control protocol.'

    newvalues(:true, :false, :default)
  end # property probe_control

  newproperty(:probe_dns_host) do
    desc 'DNS Target IP Address or Hostname.'

    validate do |dns_host|
      fail("dns_host property - #{dns_host} should be a string") unless
        dns_host.kind_of? String
    end
  end # property probe_dns_host

  newproperty(:probe_frequency) do
    desc 'Frequency in seconds'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'probe_frequency must be a valid integer, or default.'
      end
      value
    end
  end # property probe_frequency

  newproperty(:probe_port) do
    desc 'Port Number'

    munge do |value|
      begin
        value = Integer(value)
      rescue
        raise 'probe_port must be a valid integer'
      end
      value
    end
  end # property probe_port

  newproperty(:probe_retry_down) do
    desc 'Retry-count when node goes down'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'probe_retry_down must be a valid integer, or default.'
      end
      value
    end
  end # property probe_retry_down

  newproperty(:probe_retry_up) do
    desc 'Retry-count when node comes back up'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'probe_retry_up must be a valid integer, or default.'
      end
      value
    end
  end # property probe_retry_up

  newproperty(:probe_timeout) do
    desc 'Timeout in seconds'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'probe_timeout must be a valid integer, or default.'
      end
      value
    end
  end # property probe_timeout

  newproperty(:probe_type) do
    desc 'protocol type'

    newvalues(:dns, :tcp, :udp, :icmp, :default)
  end # property probe_type
end
