# Manages VXLAN vtep nve interface configuration.
#
# June 2018
#
# Copyright (c) 2014-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_vxlan_vtep) do
  @doc = "Manages VXLAN vtep nve interface configuration.

  ~~~puppet
  cisco_vxlan_vtep { <interface>:
    ..attributes..
  }
  ~~~

  Example:

  ~~~puppet
    cisco_vxlan_vtep { 'nve1':
      ensure                          => present,
      description                     => 'nve interface',
      host_reachability               => 'evpn',
      shutdown                        => false,
      source_interface                => 'loopback1',
      source_interface_hold_down_time => '50',
    }
  ~~~
  "

  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)/,
      [
        [:interface, identity]
      ],
    ]
    patterns
  end

  ##############
  # Parameters #
  ##############

  apply_to_all
  ensurable

  newparam(:interface, namevar: :true) do
    desc 'Name of the nve interface on the network element.
          Valid values are string.'

    validate do |value|
      fail("'Interface name must be a string") unless value.is_a? String
    end

    munge(&:downcase)
  end

  ##############
  # Properties #
  ##############

  newproperty(:description) do
    desc "Description of the NVE interface. Valid values are string,
          and keyword 'default'."

    munge { |value| value == 'default' ? :default : value }
  end

  newproperty(:host_reachability) do
    desc "Specify mechanism for host reachability advertisement. Valid values
          are 'evpn', 'flood', or 'default'"

    newvalues(:evpn, :flood, :default)
  end

  newproperty(:shutdown) do
    desc "Administratively shutdown the NVE interface. Valid values are true,
          false, or 'default'"

    newvalues(:true, :false, :default)
  end

  newproperty(:source_interface) do
    desc "Specify loopback interface whose IP address should be set as the
          IP address for the NVE interface. Valid values are string,
          and keyword 'default'."

    munge do |value|
      value == 'default' ? :default : value.gsub(/\s+/, '').downcase
    end
  end

  newproperty(:multisite_border_gateway_interface) do
    desc "Specify loopback interface to be used as VxLAN Multisite
          Border-gateway interface. Valid values are string,
          and keyword 'default'."

    munge do |value|
      value == 'default' ? :default : value.gsub(/\s+/, '').downcase
    end
  end

  newproperty(:source_interface_hold_down_time) do
    desc "Suppress advertisement of the NVE loopback address until the overlay
          has converged. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'source_interface_hold_down_time must be an integer.'
      end
      value
    end
  end # source_interface_hold_down_time

  validate do
    # source_interface_hold_down_time can be set only if source_interface is set
    fail 'source_interface_hold_down_time can be used only when source_interface '\
         'is also used' if self[:source_interface_hold_down_time] &&
                           !self[:source_interface]
  end
end
