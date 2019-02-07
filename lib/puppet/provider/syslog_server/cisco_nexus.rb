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

# Implementation for the syslog_server type using the Resource API.
class Puppet::Provider::SyslogServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, servers=nil)
    require 'cisco_node_utils'
    current_states = []
    @syslog_servers = Cisco::SyslogServer.syslogservers
    if servers.nil? || servers.empty?
      @syslog_servers.each do |server, instance|
        current_states << get_current_state(server, instance)
      end
    else
      servers.each do |server|
        individual_server = @syslog_servers[server]
        next if individual_server.nil?
        current_states << get_current_state(server, individual_server)
      end
    end
    current_states
  end

  def get_current_state(server, instance)
    {
      name:           server,
      ensure:         'present',
      severity_level: instance.severity_level.nil? ? instance.severity_level : instance.severity_level.to_i,
      port:           instance.port.nil? ? instance.port : instance.port.to_i,
      vrf:            instance.vrf,
      facility:       instance.facility,
    }
  end

  def update(context, name, should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    options = { 'name' => name }
    [:severity_level, :port, :vrf, :facility].each do |property|
      next unless should[property]
      options[property.to_s] = should[property].to_s
    end
    Cisco::SyslogServer.new(options)
  end

  alias create update

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @syslog_servers = Cisco::SyslogServer.syslogservers
    @syslog_servers[name].destroy if @syslog_servers[name]
  end
end
