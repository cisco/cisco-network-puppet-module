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
      multicast_group     => '224.1.1.1 224.1.1.200',
      peer_list            => ['1.1.1.1', '2.2.2.2', '3.3.3.3'],
      suppress-arp        => true,
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
    desc 'A list of static ip addresses for ingress-replication static' \
         "valid values are an array of strings and keyword 'default'."
=begin
    validate do |value|
      fail "peer_list #{value} must be string" unless
        value.kind_of?(String) || value == :default
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
=end
    validate do |value|
      begin
        puts "value = #{value}, class = #{value.class}"
        value = PuppetX::Cisco::Utils.process_network_mask(value.to_s)
        value
      rescue
        raise "'peer-ip' must be a valid ip address"
      end
    end

    munge do |value|
      value == 'default' ? :default : value
    end

#    def insync?(is)
 #     (is.size == should.flatten.size && is.sort == should.flatten.sort)
  #  end
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
    # peer_list apply only when ingress_replication is static. Disable them
    # otherwise so that the config succeeds
    self[:peer_list] = [:default] unless self[:ingress_replication] == :static

    # If user configures assoc-vrf, make sure ingress_replication,
    # multicast_group, peer_list and suppress_arp are off so that the config
    # succeeds
    if self[:assoc_vrf] == :true
      self[:ingress_replication] = :default
      self[:multicast_group] = :default
      self[:suppress_arp] = :default
      self[:peer_list] = [:default]
    end
  end
end # Puppet::Type.newtype
