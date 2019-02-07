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

# Implementation for the tacacs_server type using the Resource API.
class Puppet::Provider::TacacsServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, hosts=nil)
    require 'cisco_node_utils'
    current_states = []
    # using = instead of ||= due to creation behaviour and having
    # to reevaluate the hosts upon creation
    @tacacs_server = Cisco::TacacsServerHost.hosts
    if hosts.nil? || hosts.empty?
      @tacacs_server.each do |host, instance|
        current_states << get_current_state(host, instance)
      end
    else
      hosts.each do |host|
        individual_host = @tacacs_server[host]
        next if individual_host.nil?
        current_states << get_current_state(host, individual_host)
      end
    end
    current_states
  end

  def get_current_state(host, instance)
    {
      ensure:     'present',
      name:       host,
      port:       instance.port,
      timeout:    instance.timeout,
      key_format: instance.encryption_type,
      key:        instance.encryption_password.gsub(/\A"|"\Z/, ''),
    }
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @tacacs_server = Cisco::TacacsServerHost.hosts
    @tacacs_server[name].destroy if @tacacs_server[name]
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    handle_update(name, should)
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    # need to create a new host if it does not exist
    Cisco::TacacsServerHost.new(name)
    handle_update(name, should)
  end

  def handle_update(name, should)
    @tacacs_server = Cisco::TacacsServerHost.hosts
    [:port, :timeout].each do |property|
      next unless should[property]
      @tacacs_server[name].send("#{property}=", should[property]) if @tacacs_server[name].respond_to?("#{property}=")
    end
    @tacacs_server[name].encryption_key_set(munge(should[:key_format]), munge(should[:key])) if should[:key]
  end

  def munge(value)
    if value.is_a?(String) && value.eql?('unset')
      nil
    elsif value.is_a?(Integer) && value.eql?(-1)
      nil
    else
      value
    end
  end
end
