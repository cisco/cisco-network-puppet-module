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
begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

# Implementation for the radius_server type using the Resource API.
class Puppet::Provider::RadiusServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:key] = resource[:key].gsub(/\A"|"\Z/, '') if resource[:key]
      resource[:key] = 'unset' if resource[:key].nil?
      resource[:timeout] = 'unset' if resource[:timeout].nil? || resource[:timeout] == (nil || -1)
      resource[:key_format] = 'unset' if resource[:key_format].nil? || resource[:key_format] == (nil || -1)
      resource[:retransmit_count] = 'unset' if resource[:retransmit_count].nil? || resource[:retransmit_count] == (nil || -1)
    end
    resources
  end

  RADIUS_SERVER_PROPS ||= {
    auth_port:           :auth_port,
    acct_port:           :acct_port,
    timeout:             :timeout,
    retransmit_count:    :retransmit_count,
    accounting_only:     :accounting,
    authentication_only: :authentication,
  }

  UNSUPPORTED_PROPS ||= [:group, :deadtime, :vrf, :source_interface]

  def get(context, _names=nil)
    require 'cisco_node_utils'

    radius_servers = []
    Cisco::RadiusServer.radiusservers.each_value do |v|
      radius_servers << {
        ensure:              'present',
        name:                v.name,
        auth_port:           v.auth_port ? v.auth_port : nil,
        acct_port:           v.acct_port ? v.acct_port : nil,
        timeout:             v.timeout ? v.timeout : 'unset',
        retransmit_count:    v.retransmit_count ? v.retransmit_count : 'unset',
        key:                 v.key ? v.key.gsub(/\A"|"\Z/, '') : 'unset',
        key_format:          v.key_format ? v.key_format.to_i : 'unset',
        accounting_only:     v.accounting,
        authentication_only: v.authentication
      }
    end

    PuppetX::Cisco::Utils.enforce_simple_types(context, radius_servers)
  end

  def munge_flush(val)
    if val.is_a?(String) && val.eql?('unset')
      nil
    elsif val.is_a?(Integer) && val.eql?(-1)
      nil
    elsif val.is_a?(Symbol)
      val.to_s
    else
      val
    end
  end

  def validate(should)
    raise Puppet::ResourceError,
          "This provider does not support the 'hostname' property. The namevar should be set to the IP of the Radius Server" \
          if should[:hostname]

    invalid = []
    UNSUPPORTED_PROPS.each do |prop|
      invalid << prop if should[prop]
    end

    raise Puppet::ResourceError, "This provider does not support the following properties: #{invalid}" unless invalid.empty?

    raise Puppet::ResourceError,
          "The 'key' property must be set when specifying 'key_format'." if should[:key_format] && !should[:key]

    raise Puppet::ResourceError,
          "The 'accounting_only' and 'authentication_only' properties cannot both be set to false." if munge_flush(should[:accounting_only]) == false && \
                                                                                                      munge_flush(should[:authentication_only]) == false
  end

  def create_update(name, should, create_bool)
    validate(should)
    radius_server = Cisco::RadiusServer.new(name, create_bool)
    RADIUS_SERVER_PROPS.each do |puppet_prop, cisco_prop|
      if !should[puppet_prop].nil? && radius_server.respond_to?("#{cisco_prop}=")
        radius_server.send("#{cisco_prop}=", munge_flush(should[puppet_prop]))
      end
    end

    # Handle key and keyformat setting
    return unless should[:key]
    radius_server.send('key_set', munge_flush(should[:key]), munge_flush(should[:key_format]))
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    create_update(name, should, true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    create_update(name, should, false)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    radius_server = Cisco::RadiusServer.new(name, false)
    radius_server.destroy
  end
end
