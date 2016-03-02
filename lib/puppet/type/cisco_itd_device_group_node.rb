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
Puppet::Type.newtype(:cisco_itd_device_group_node, parent: Puppet::Type.type(:cisco_itd_device_group)) do
  @doc = "Manages a Cisco ItdDeviceGroupNode.
  **Autorequires:** cisco_itd_device_group

  cisco_itd_device_group_node {\"<itddg> <node>\":
    ..attributes..
  }

  <itddg> is the name of the itd device-group, and <node> is the name of the node instance.

  Example:
    cisco_itd_device_group_node {\"my_group 1.1.1.1\":
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
    desc "Name of the itd device group. Valid value is a string of
          non-whitespace characters. It is case-sensitive"
    munge(&:strip)
  end

  newparam(:node, namevar: :true) do
    desc 'Name of the node resource. Valid values are string.'
    munge(&:strip)
  end

  newparam(:name) do
    desc 'dummy paramenter to support puppet resource command'
  end

  ##############
  # Attributes #
  ##############

  newproperty(:hot_standby) do
    desc 'Enable/disable hot_standby mode'

    newvalues(:true, :false, :default)
  end # property hot_standby

  newproperty(:node_type) do
    desc 'Type of the node'

    newvalues(:ip, :IPv6)
  end # property node_type

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

  ################
  # Autorequires #
  ################

  # Autorequire cisco_itd_device_group; do not fail if it is not present in the manifest
  autorequire(:cisco_itd_device_group) do |rel_catalog|
    reqs = []

    itddg_title = self[:itddg]

    dep = rel_catalog.catalog.resource('cisco_itd_device_group', itddg_title)

    info "Cisco_itd_device_group[#{itddg_title}] was not found in catalog. " \
         'Will obtain from device.' if dep.nil?
    reqs << dep
    reqs
  end
end
