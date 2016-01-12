# Manages a Cisco PortChannel Interface.
#
# Dec 2015
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

Puppet::Type.newtype(:cisco_interface_portchannel) do
  @doc = %q(
    "Manages a Cisco PortChannel Interface.

     cisco_interface_portchannel {\"<interface>\":
       ..attributes..
     }

     <interface> is the complete name of the interface.

     Example:
     cisco_interface_portchannel {"port-channel100":
       ensure                       => 'present',
       lacp_graceful_convergence    => false,
       lacp_max_bundle              => 10,
       lacp_min_links               => 2,
       lacp_suspend_individual      => false,
       port_hash_distribution       => "adaptive",
       port_load_defer              => true,
     }
  )

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

    munge(&:downcase)
  end # param name

  #######################################
  # Attributes #
  #######################################

  ensurable

  newproperty(:lacp_graceful_convergence) do
    desc "port-channel lacp graceful convergence. Disable this only with lacp
          ports connected to Non-Nexus peer. Disabling this with Nexus peer
          can lead to port suspension"

    newvalues(:true, :false, :default)
  end # property lacp_graceful_convergence

  newproperty(:lacp_max_bundle) do
    desc "port-channel max-bundle. Valid values are
          integer, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'lacp_max_bundle must be a valid integer, or default.'
      end
      value
    end
  end # property lacp_max_bundle

  newproperty(:lacp_min_links) do
    desc "port-channel min-links. Valid values are
          integer, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'lacp_min_links must be a valid integer, or default.'
      end
      value
    end
  end # property lacp_min_links

  newproperty(:lacp_suspend_individual) do
    desc "lacp port-channel state. Disabling this will cause lacp to put the
          port to individual state and not suspend the port in case it does
          not get LACP BPDU from the peer ports in the port-channel"

    newvalues(:true, :false, :default)
  end # property lacp_suspend_individual

  newproperty(:port_hash_distribution) do
    desc 'port-channel port hash-distribution.'

    newvalues(:adaptive, :fixed, :default)
  end # property port_hash_distribution

  newproperty(:port_load_defer) do
    desc 'port-channel port load-defer.'

    newvalues(:true, :false, :default)
  end # property port_load_defer
end # Puppet::Type.newtype
