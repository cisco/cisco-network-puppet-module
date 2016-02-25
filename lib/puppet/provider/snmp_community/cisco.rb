# The NXAPI provider for snmp_community.
#
# October, 2015
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

begin
  require 'puppet_x/cisco/autogen'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:snmp_community).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for snmp_community.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  SNMP_COMMUNITY_PROPS = {
    group: :group,
    acl:   :acl,
  }

  def initialize(value={})
    super(value)
    @snmp_community = Cisco::SnmpCommunity.communities[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of snmp_community'
  end

  def self.get_properties(name, v)
    debug "Checking instance, SnmpCommunityHost #{name}"

    current_state = {
      ensure: :present,
      name:   name,
      group:  v.group,
      acl:    v.acl,
    }

    new(current_state)
  end # self.get_properties

  def self.instances
    snmp_communities = []
    Cisco::SnmpCommunity.communities.each do |name, v|
      snmp_communities << get_properties(name, v)
    end

    snmp_communities
  end

  def self.prefetch(resources)
    snmp_communities = instances

    resources.keys.each do |id|
      provider = snmp_communities.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_flush[:ensure] == :absent
      @snmp_community.destroy
      @snmp_community = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty?
        # create a new Snmp Community
        @snmp_community = Cisco::SnmpCommunity.new(@resource[:name], @resource[:group])
      end

      SNMP_COMMUNITY_PROPS.each do |puppet_prop, cisco_prop|
        if @resource[puppet_prop] && @snmp_community.respond_to?("#{cisco_prop}=")
          @snmp_community.send("#{cisco_prop}=", @resource[puppet_prop])
        end
      end
    end
  end
end # Puppet::Type
