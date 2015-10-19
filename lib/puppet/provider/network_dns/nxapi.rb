# The NXAPI provider for network_dns
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

Puppet::Type.type(:network_dns).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for network_dns.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @domain = Cisco::DomainName.domainnames || {}
    @searches = Cisco::DnsDomain.dnsdomains || {}
    @servers = Cisco::NameServer.nameservers || {}
    @network_dns = value
    @property_flush = {}
  end

  def self.properties_get(vrf=nil)
    # VRF support should pass the vrf to these calls
    domain = Cisco::DomainName.domainnames
    searches = Cisco::DnsDomain.dnsdomains || {}
    servers = Cisco::NameServer.nameservers || {}
    current_state = {
      name:    vrf.nil? ? 'settings' : vrf,
      ensure:  :present,
      domain:  domain.keys.first,
      search:  searches.keys.sort,
      servers: servers.keys.sort,
    }

    new(current_state)
  end

  def self.instances
    # VRF support should iterate over all VRFs here
    network_dns = []
    network_dns << properties_get

    network_dns
  end

  def self.prefetch(resources)
    network_dns = instances
    resources.keys.each do |name|
      provider = network_dns.find { |instance| instance.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def exists?
    true
  end

  def create
    true
  end

  def destroy
    fail ArgumentError, 'This provider does not support ensure => absent'
  end

  def domain=(value)
    @domain[value].destroy if @domain[value]
    Cisco::DomainName.new(value)
  end

  def search=(value)
    to_remove = @property_hash[:search] - Array(value)
    to_create = Array(value) - @property_hash[:search]
    to_remove.each do |search|
      @searches[search].destroy
    end
    to_create.each do |search|
      Cisco::DnsDomain.new(search)
    end
  end

  def servers=(value)
    to_remove = @property_hash[:servers] - Array(value)
    to_create = Array(value) - @property_hash[:servers]
    to_remove.each do |server|
      @servers[server].destroy
    end
    to_create.each do |server|
      Cisco::NameServer.new(server)
    end
  end

  def validate
    # VRF support should lift this requirement
    fail ArgumentError, "This provider only supports a namevar of 'settings'" \
      unless @resource[:name].to_s == 'settings'
  end

  def flush
    validate
  end
end
