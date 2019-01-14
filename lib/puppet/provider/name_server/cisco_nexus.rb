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

# Resource API provider for NameServer
class Puppet::Provider::NameServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, servers=nil)
    require 'cisco_node_utils'
    nameserver_instances = []
    @name_servers = Cisco::NameServer.nameservers
    if servers.nil? || servers.empty?
      @name_servers.each do |server, instance|
        nameserver_instances << get_current_state(server, instance)
      end
    else
      servers.each do |server|
        individual_server = @name_servers[server]
        next if individual_server.nil?
        nameserver_instances << get_current_state(server, individual_server)
      end
    end
    nameserver_instances
  end

  def get_current_state(server, _instance)
    {
      ensure: 'present',
      name:   server,
    }
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    Cisco::NameServer.new(name)
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @name_servers = Cisco::NameServer.nameservers
    @name_servers[name].destroy
  end
end
