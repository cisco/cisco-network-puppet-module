# Manages a Cisco Network Interface.
#
# May 2013
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_interface_port_channel) do
  @doc = "Manages a Cisco Port-channel Interface.

  **Autorequires:** cisco_interface

  cisco_interface {\"<interface>\":
    ..attributes..
  }

  <interface> is the complete name of the interface.

  Example:
    cisco_interface {\"port-channe1\":
      per_port_hash_distribution                     => 'fixed',
      lacp_graceful_convergence                      => true,
      lacp_min_links                                 => 2,
      lacp_max_bundle                                => 7,
      lacp_suspend_individual                        => true,
      per_port_load_defer                            => false,
      system_hash_modulo                             => true,
      system_port_channel_load_balance_asymmetric    => false,
      system_port_channel_load_balance_bundle_hash   => 'ip',
      system_port_channel_load_balance_bundle_select => 'dst',
      system_port_channel_load_balance_rotate        => 4,
      system_port_channel_load_balance_asymmetric    => false,
      system_port_channel_load_balance_bundle_hash   => 'ip',
      system_port_channel_load_balance_bundle_select => 'dst',
      system_port_channel_load_balance_rotate        => 4,
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
      /^(\S+)/,
      [
        [:interface, identity]
      ],
    ]
    patterns
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of the interface on the network element. Valid values are string.'

    validate do |name|
      unless name.downcase.start_with?('port-channel')
        fail('Name of the interface should srat with port-channel')
      end # if
    end

    munge(&:downcase)
  end # param name

  ###########################
  # Port-Channel attributes #
  ###########################

  newproperty(:system_hash_modulo) do
    desc 'Configure port-channel load-balance hash-modulo'

    newvalues(:true, :false)
  end # property system_hash_modulo

  newproperty(:lacp_graceful_convergence) do
    desc 'Configure port-channel lacp graceful convergence.'

    newvalues(:true, :false)
  end # property lacp_graceful_convergence

  newproperty(:lacp_max_bundle) do
    desc "Configure the port-channel max-bundle. Valid values
          are 1-16 and default is 16."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property lacp_max_bundle

  newproperty(:lacp_min_links) do
    desc "Configure the port-channel min-links. Valid values
          are 1-16 and default is 1."

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property lacp_min_links

  newproperty(:lacp_suspend_individual) do
    desc 'Configure lacp port-channel state.'

    newvalues(:true, :false)
  end # property lacp_suspend_individual

  newproperty(:per_port_load_defer) do
    desc 'Configure lacp port-channel load-defer.'

    newvalues(:true, :false)
  end # property per_port_load_defer

  newproperty(:per_port_hash_distribution) do
    desc "Configure hash distribution at the port channel level.
          Default value is no form of command"

    newvalues(:fixed, :adaptive, :default)
  end # property per_port_hash_distribution

  newproperty(:system_port_channel_load_balance_asymmetric) do
    desc 'Configure port-channel load-balance asymmetric.'

    newvalues(:true, :false)
  end # property system_port_channel_load_balance_asymmetric

  newproperty(:system_port_channel_load_balance_bundle_hash) do
    desc 'Configure port-channel load-balance bndl_hash.'

    newvalues(:default, :ip, :'ip-l4port', :'ip-l4port-vlan', :'ip-vlan', :l4port, :mac)
  end # property system_port_channel_load_balance_bundle_hash

  newproperty(:system_port_channel_load_balance_bundle_select) do
    desc 'Configure port-channel load-balance bndl_sel.'

    newvalues(:default, :src, :'src-dst', :dst)
  end # property system_port_channel_load_balance_bundle_select

  newproperty(:system_port_channel_load_balance_rotate) do
    desc 'Configure port-channel load-balance rotate
          Valid values are from 0 to 15'

    munge { |value| value == 'default' ? :default : value.to_i }
  end # property system_port_channel_load_balance_rotate
end # Puppet::Type.newtype
