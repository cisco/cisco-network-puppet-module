# February, 2015
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

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_snmp_community).provide(:cisco) do
  desc 'The Cisco provider for cisco_snmp_community'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @snmp_community = Cisco::SnmpCommunity.communities[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_snmp_community'
  end

  def self.instances
    instances = []
    Cisco::SnmpCommunity.communities.each do |id, snmpc|
      debug "Checking instance of #{id}"
      instances << new(
        name:      id,
        community: id,
        ensure:    :present,
        group:     snmpc.group,
        acl:       snmpc.acl)
    end
    instances
  end

  def self.prefetch(resources)
    communities = instances
    resources.keys.each do |id|
      provider = communities.find { |snmpc| snmpc.community == id }
      resources[id].provider = provider unless provider.nil?
    end
  end

  def instance_name
    community
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def group
    return if @snmp_community.nil?
    value = @snmp_community.group
    value = :default if
      @resource[:group] == :default &&
      value == Cisco::SnmpCommunity.default_group
    @property_hash[:group] = value
  end

  def group=(set_value)
    return if set_value.nil?
    set_value = Cisco::SnmpCommunity.default_group if set_value == :default
    @snmp_community.group = set_value
    @property_hash[:group] = set_value
  end

  def acl
    value = @snmp_community.acl
    value = :default if
      @resource[:acl] == :default && value == Cisco::SnmpCommunity.default_acl
    @property_hash[:acl] = value
  end

  def acl=(set_value)
    return if set_value.nil?
    set_value = Cisco::SnmpCommunity.default_acl if set_value == :default
    @snmp_community.acl = set_value
    @property_hash[:acl] = set_value
  end

  def flush
    case @property_flush[:ensure]
    when :present
      @resource[:group] = Cisco::SnmpCommunity.default_group if
        @resource[:group] == :default
      @snmp_community = Cisco::SnmpCommunity.new(@resource[:community],
                                                 @resource[:group])

      self.acl = @resource[:acl] unless @resource[:acl] == acl
      @property_hash[:group] = @resource[:group]
      @property_hash[:community] = @resource[:community]

    when :absent
      @snmp_community.destroy
      @snmp_community = nil
    end
    put_snmp_community
  end

  def put_snmp_community
    debug 'Current state:'
    if @snmp_community.nil?
      debug 'No community'
      return
    end
    debug "
      name: #{@resource[:community]}
     group: #{@snmp_community.group}
       acl: #{@snmp_community.acl}
    "
  end
end
