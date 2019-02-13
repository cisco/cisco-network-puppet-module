# Copyright (c) 2018 Cisco and/or its affiliates.
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
require 'puppet/resource_api/simple_provider'

# Implementation for the snmp_community type using the Resource API.
class Puppet::Provider::SnmpCommunity::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, communities=nil)
    require 'cisco_node_utils'
    current_states = []
    if communities.nil? || communities.empty?
      @snmp_communities = Cisco::SnmpCommunity.communities
      @snmp_communities.each do |community, instance|
        current_states << get_current_state(community, instance)
      end
    else
      communities.each do |community|
        @snmp_communities = Cisco::SnmpCommunity.communities
        individual_community = @snmp_communities[community]
        next if individual_community.nil?
        current_states << get_current_state(community, individual_community)
      end
    end
    current_states
  end

  def get_current_state(name, instance)
    {
      name:   name,
      ensure: 'present',
      acl:    instance.acl,
      group:  instance.group,
    }
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @snmp_communities = Cisco::SnmpCommunity.communities
    @snmp_communities[name].destroy
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    @snmp_communities = Cisco::SnmpCommunity.communities
    snmp_community = @snmp_communities[name]
    should_apply(snmp_community, should)
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    snmp_community = Cisco::SnmpCommunity.new(name, should[:group])
    should_apply(snmp_community, should)
  end

  def should_apply(snmp_community, should)
    [:acl, :group].each do |property|
      snmp_community.send("#{property}=", should[property]) if should[property] && snmp_community.respond_to?("#{property}=")
    end
  end
end
