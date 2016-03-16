# Manages a Cisco ItdDeviceGroupNode.
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
Puppet::Type.newtype(:cisco_itd_device_group_node) do
  @doc = "Manages a Cisco ItdDeviceGroupNode.

  cisco_itd_device_group_node {\"<node>\":
    ..attributes..
  }

  <itddg> is the name of the itd device-group, and <node> is the name of the node instance.

  Example:
    cisco_itd_device_group_node {\"mygroup 1.1.1.1\":
     ensure                       => present,
     hot_standby                  => false,
     node_type                    => \"ip\",
     probe_control                => false,
     probe_frequency              => 9,
     probe_port                   => 1000,
     probe_retry_down             => 2,
     probe_retry_up               => 2,
     probe_timeout                => 6,
     probe_type                   => \"udp\",
     weight                       => 200,
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
      /^(\S+) (\S+)$/,
      [
        [:itddg, identity],
        [:node, identity],
      ],
    ]
    patterns
  end

  newparam(:itddg, namevar: :true) do
    desc 'Name of the itd device group.
          Valid values are string.'

    validate do |value|
      fail('Itd device group name must be a string') unless value.is_a? String
    end

    munge(&:strip)
  end

  newparam(:node, namevar: :true) do
    desc 'Name of the node resource. Valid values are string.'
    munge(&:strip)
  end

  newparam(:node_type, namevar: true) do
    desc 'Type of node. Valid values are ip or IPv6.'
    defaultto(:ip)
    newvalues(:ip, :IPv6)
  end

  def name
    "#{self[:itddg]} #{self[:node]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:hot_standby) do
    desc 'Enable/disable hot_standby mode'

    newvalues(:true, :false, :default)
  end # property hot_standby

  newproperty(:itd_device_group) do
    desc 'Itd device group'

    validate do |grp|
      fail("itd_device_group property - #{grp} should be a string") unless
        grp.kind_of? String
    end
  end # property group

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

  newproperty(:weight) do
    desc 'Weight for traffic distribution'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'weight must be a valid integer, or default.'
      end
      value
    end
  end # property weight

  validate do
    return unless self[:probe_type]
    case self[:probe_type].to_sym
    when :icmp
      fail ArgumentError, 'control, dns_host, port are not applicable' if
        self[:probe_control] || self[:probe_dns_host] ||
        self[:probe_port]
    when :dns
      fail ArgumentError, 'control, port are not applicable' if
        self[:probe_control] || self[:probe_port]
      fail ArgumentError, 'dns_host MUST be specified' unless
        self[:probe_dns_host]
    when :tcp, :udp
      fail ArgumentError, 'dns_host is not applicable' if
        self[:probe_dns_host]
      fail ArgumentError, 'port MUST be specified' unless
        self[:probe_port]
    end
  end
end
