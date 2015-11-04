#
# The NXAPI provider for cisco_aaa_group_tacacs.
#
# October, 2015
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_aaa_group_tacacs).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_aaa_group_tacacs'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @aaa_group = Cisco::AaaServerGroup.groups(:tacacs)[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_aaa_group_tacacs'
  end

  def self.instances
    instances = []
    Cisco::AaaServerGroup.groups(:tacacs).each do |name, group|
      debug "Checking instance of #{name}"
      instances << new(
        ensure:           :present,
        name:             name,
        deadtime:         group.deadtime,
        vrf_name:         group.vrf,
        source_interface: group.source_interface,
        server_hosts:     group.servers.keys)
    end
    instances
  end

  def self.prefetch(resources)
    groups = instances
    resources.keys.each do |name|
      provider = groups.find { |group| group.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def instance_name
    group_tacacs
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

  # rubocop:disable GuardClause
  def properties_set(new_aaa_group=false)
    %i(deadtime source_interface).each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_aaa_group
      unless @property_flush[prop].nil?
        @aaa_group.send("#{prop}=", @property_flush[prop]) if
          @aaa_group.respond_to?("#{prop}=")
      end
    end

    # node utils is named vrf instead of vrf_name, can't auto this one
    if @resource[:vrf_name]
      self.vrf_name = @resource[:vrf_name] if new_aaa_group
      unless @property_flush[:vrf_name].nil?
        @aaa_group.vrf = @property_flush[:vrf_name]
      end
    end
    # node utils is named server= instead of server_hosts=
    if @resource[:server_hosts]
      self.server_hosts = @resource[:server_hosts] if new_aaa_group
      unless @property_flush[:server_hosts].nil?
        @aaa_group.servers = @property_flush[:server_hosts]
      end
    end
  end
  # rubocop:enable GuardClause

  # can't autogen getters and setters because the default_<prop>
  # functions are class functions
  def deadtime
    return :default if @resource[:deadtime] == :default &&
                       @property_hash[:deadtime] ==
                       Cisco::AaaServerGroup.default_deadtime
    @property_hash[:deadtime]
  end

  def deadtime=(set_value)
    set_value = Cisco::AaaServerGroup.default_deadtime if
      set_value == :default
    @property_flush[:deadtime] = set_value
  end

  def vrf_name
    return :default if @resource[:vrf_name] == :default &&
                       @property_hash[:vrf_name] ==
                       Cisco::AaaServerGroup.default_vrf
    @property_hash[:vrf_name]
  end

  def vrf_name=(set_value)
    set_value = Cisco::AaaServerGroup.default_vrf if set_value == :default
    @property_flush[:vrf_name] = set_value
  end

  def source_interface
    return :default if @resource[:source_interface] == :default &&
                       @property_hash[:source_interface] ==
                       Cisco::AaaServerGroup.default_source_interface
    @property_hash[:source_interface]
  end

  def source_interface=(set_value)
    if set_value == :default
      set_value = Cisco::AaaServerGroup.default_source_interface
    end
    @property_flush[:source_interface] = set_value
  end

  def server_hosts
    return [:default] if @resource[:server_hosts] &&
                         @resource[:server_hosts][0] == :default &&
                         @property_hash[:server_hosts] ==
                         Cisco::AaaServerGroup.default_servers
    @property_hash[:server_hosts]
  end

  def server_hosts=(set_value)
    if set_value.is_a?(Array) && set_value[0] == :default
      set_value = Cisco::AaaServerGroup.default_servers
    end
    @property_flush[:server_hosts] = set_value
  end

  def flush
    if @property_flush[:ensure] == :absent
      @aaa_group.destroy
      @aaa_group = nil
    else
      if @aaa_group.nil?
        new_aaa_group = true
        @aaa_group = Cisco::AaaServerGroup.new(@resource[:name], :tacacs)
      end
      properties_set(new_aaa_group)
    end
    put_aaa_group_tacacs
  end

  def put_aaa_group_tacacs
    debug 'Current state:'
    if @aaa_group.nil?
      debug 'No aaa group'
      return
    end
    debug "
                  name: #{@resource[:name]}
              deadtime: #{@aaa_group.deadtime}
              vrf_name: #{@aaa_group.vrf}
      source_interface: #{@aaa_group.source_interface}
          server_hosts: #{@aaa_group.servers.keys}
    "
  end
end
