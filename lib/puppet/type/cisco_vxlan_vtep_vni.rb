# Manages a Cisco Virtual Tunnel Endpoint (VTEP) to Virtual Network
# Identifier (VNI) binding.
#
# January 2016
#
# Copyright (c) 2013-2016 Cisco and/or its affiliates.
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
begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_vxlan_vtep_vni) do
  @doc = "Manages a Cisco Virtual Tunnel Endpoint (VTEP) to Virtual Network
  Identifier (VNI) mapping.

  cisco_vxlan_vtep_vni {'<title>':
    ..attributes..
  }

  <title> is the title of vxlan_vtep_vni resource.

  Example:
    cisco_vxlan_vtep_vni {'nve1 10000':
      ensure              => present,
      assoc_vrf           => false,
      ingress_replication => 'static',
      peer_list           => ['1.1.1.1', '2.2.2.2', '3.3.3.3'],
      suppress-arp        => false,
    }

    cisco_vxlan_vtep_vni {'nve1 20000':
      ensure              => present,
      assoc_vrf           => false,
      multicast_group     => '224.1.1.1'
      suppress-arp        => true,
    }
"

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
      /^(\S+)\s+(\d+)$/,
      [
        [:interface, identity],
        [:vni, identity],
      ],
    ]
    patterns
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of the nve interface on the network element.
          Valid values are string.'

    validate do |value|
      fail('Interface name must be a string') unless value.is_a? String
    end

    munge(&:downcase)
  end

  newparam(:vni, namevar: true) do
    desc 'ID of the Virtual Network Identifier. Valid values are integer.'
    munge do |value|
      begin
        value = Integer(value)
      rescue
        raise 'VNI is not a number.'
      end # rescue
      value
    end
  end

  newparam(:assoc_vrf, namevar: true) do
    desc 'Associate vrf with the vni. Valid values are true or false.'
    defaultto(:false)
    newvalues(:true, :false)
  end

  # param id

  ##############
  # Attributes #
  ##############

  ensurable

  # Overwrites the name method which by default returns only self[:name].
  def name
    "#{self[:interface]} #{self[:vni]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newproperty(:ingress_replication) do
    desc "Specify mechanism for host reachability advertisement. Valid values
          are 'bgp', 'static', or 'default'"

    newvalues(:bgp, :static, :default)
  end

  newproperty(:multicast_group) do
    desc "The multicast group (range) of the VNI. Valid values are string,
          keyword 'default'"
    munge do |multicast_group|
      multicast_group = :default if multicast_group == 'default'
      fail 'multicast_group is not a string.' unless
        multicast_group == :default || multicast_group.is_a?(String)
      multicast_group
    end
  end # property name

  newproperty(:peer_list, array_matching: :all) do
    desc 'Set the ingress-replication static peer list. Valid values are '\
         'an Array, a space-separated String of ip addresses, or the '\
         "keyword 'default'."

    match_error = 'must be specified as a valid ip address'
    validate do |peer_list|
      peer_list.split.each do |value|
        begin
          value == 'default' || value == :default ||
            PuppetX::Cisco::Utils.process_network_mask(value)
        rescue
          raise "Ingress-replication peer value '#{value}' #{match_error}"
        end
      end
    end

    munge do |peer_list|
      peer_list == 'default' ? :default : peer_list.split
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end

  newproperty(:suppress_arp) do
    desc "Suppress arp under layer 2 VNI. Valid values are true,
          false, or 'default'"

    newvalues(:true, :false, :default)
  end

  # Multicast-group and ingress-replication are mutually exclusive properties.
  validate do
    fail 'Only one of multicast-group or ingress-replication can be configured, '\
        'not both' if self[:multicast_group] && self[:ingress_replication]
    # peer_list applies only when ingress_replication is static.
    fail 'peer_list applies only for ingress replication static' if
        self[:peer_list] && self[:ingress_replication] != :static

    # If user configures assoc-vrf, ingress_replication, multicast_group,
    # peer_list and suppress_arp should be off.
    assoc_vrf_incompatible_props = self[:ingress_replication] ||
                                   self[:multicast_group] ||
                                   self[:suppress_arp] ||
                                   self[:peer_list]

    fail 'ingress_replication, multicast_group, peer_list & suppress_arp' \
          ' cannot be set when assoc_vrf is true.' if
           self[:assoc_vrf] == :true && assoc_vrf_incompatible_props
  end
end # Puppet::Type.newtype
