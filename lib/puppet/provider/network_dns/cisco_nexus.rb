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

# Implementation for the network_dns type using the Resource API.
class Puppet::Provider::NetworkDns::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    require 'cisco_node_utils'
    resources.each do |resource|
      resource[:search] = resource[:search].sort if resource[:search]
      resource[:servers] = resource[:servers].sort if resource[:servers]
    end
    resources
  end

  def get(_context, vrf=nil)
    require 'cisco_node_utils'
    @domain = Cisco::DomainName.domainnames
    @searches = Cisco::DnsDomain.dnsdomains || {}
    @servers = Cisco::NameServer.nameservers || {}
    @hostname = Cisco::HostName.hostname || {}

    current_state = {
      name:     (vrf.nil? || vrf.empty?) ? 'settings' : vrf.first,
      ensure:   'present',
      domain:   @domain.keys.first,
      hostname: @hostname.keys.first,
      search:   @searches.keys.sort,
      servers:  @servers.keys.sort,
    }

    [current_state]
  end

  def update(context, name, should)
    validate_name(name)

    context.notice("Updating '#{name}' with #{should.inspect}")
    @domain = Cisco::DomainName.domainnames
    @searches = Cisco::DnsDomain.dnsdomains || {}
    @servers = Cisco::NameServer.nameservers || {}
    @hostname = Cisco::HostName.hostname || {}

    handle_hostname(should[:hostname]) if should[:hostname]
    handle_domain(should[:domain]) if should[:domain]
    handle_servers(should[:servers]) if should[:servers]
    handle_searches(should[:search]) if should[:search]
  end

  def delete(_context, _name)
    raise Puppet::ResourceError, 'This provider does not support ensure => absent'
  end

  def handle_servers(values)
    @servers = Cisco::NameServer.nameservers || {}
    to_remove = @servers.keys - values
    to_create = values - @servers.keys
    to_remove.each do |server|
      @servers[server].destroy
    end
    to_create.each do |server|
      Cisco::NameServer.new(server)
    end
  end

  def handle_searches(values)
    @searches = Cisco::DnsDomain.dnsdomains || {}
    to_remove = @searches.keys - values
    to_create = values - @searches.keys
    to_remove.each do |search|
      @searches[search].destroy
    end
    to_create.each do |search|
      Cisco::DnsDomain.new(search)
    end
  end

  # handle the hostname, i.e. if '' then destroy
  # all hostnames and do not create one
  def handle_hostname(value)
    @hostname = Cisco::HostName.hostname || {}
    if value == ''
      @hostname[@hostname.keys.first].destroy if @hostname[@hostname.keys.first]
    else
      @hostname[value].destroy if @hostname[value]
      Cisco::HostName.new(value)
    end
  end

  # handle the domain, i.e. if '' then destroy
  # all domains and do not create one
  def handle_domain(value)
    @domain = Cisco::DomainName.domainnames
    if value == ''
      @domain[@domain.keys.first].destroy if @domain[@domain.keys.first]
    else
      @domain[value].destroy if @domain[value]
      Cisco::DomainName.new(value)
    end
  end

  def validate_name(name)
    raise Puppet::ResourceError, '`name` must be `settings`' if name != 'settings'
  end
end
