# The NXAPI provider for radius_server.
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

Puppet::Type.type(:radius_server).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for radius_server.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  RADIUS_SERVER_PROPS = {
    auth_port:           :auth_port,
    acct_port:           :acct_port,
    timeout:             :timeout,
    retransmit_count:    :retransmit_count,
    accounting_only:     :accounting,
    authentication_only: :authentication,
  }

  UNSUPPORTED_PROPS = [:group, :deadtime, :vrf, :source_interface]

  def initialize(value={})
    super(value)
    @radius_server = Cisco::RadiusServer.radiusservers[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of radius_server'
  end

  def self.get_properties(name, v)
    debug "Checking instance, SyslogServer #{name}"

    current_state = {
      ensure:              :present,
      name:                v.name,
      auth_port:           v.auth_port ? v.auth_port : v.auth_port_default,
      acct_port:           v.acct_port ? v.acct_port : v.acct_port_default,
      timeout:             v.timeout ? v.timeout : -1,
      retransmit_count:    v.retransmit_count ? v.retransmit_count : -1,
      accounting_only:     v.accounting ? :true : :false,
      authentication_only: v.authentication ? :true : :false,
      key:                 v.key ? v.key : 'unset',
      key_format:          v.key_format ? v.key_format : -1,
    }

    new(current_state)
  end # self.get_properties

  def self.instances
    radiusservers = []
    Cisco::RadiusServer.radiusservers.each do |name, v|
      radiusservers << get_properties(name, v)
    end

    radiusservers
  end

  def self.prefetch(resources)
    radius_servers = instances

    resources.keys.each do |id|
      provider = radius_servers.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def munge_flush(val)
    if val.is_a?(String) && val.eql?('unset')
      nil
    elsif val.is_a?(Integer) && val.eql?(-1)
      nil
    elsif val.is_a?(Symbol) && val.eql?(:true)
      true
    elsif val.is_a?(Symbol) && val.eql?(:false)
      false
    elsif val.is_a?(Symbol)
      val.to_s
    else
      val
    end
  end

  def validate
    fail ArgumentError,
         "This provider does not support the 'hostname' property. The namevar should be set to the IP of the Radius Server" \
          if @resource[:hostname]

    invalid = []
    UNSUPPORTED_PROPS.each do |prop|
      invalid << prop if @resource[prop]
    end
    fail ArgumentError, "This provider does not support the following properties: #{invalid}" unless invalid.empty?

    fail ArgumentError,
         "The 'key' property must be set when specifying 'key_format'." if @resource[:key_format] && !resource[:key]

    fail ArgumentError,
         "The 'accounting_only' and 'authentication_only' properties cannot both be set to false." if @resource[:accounting_only] == :false && \
                                                                                                      resource[:authentication_only] == :false
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    validate

    if @property_flush[:ensure] == :absent
      @radius_server.destroy
      @radius_server = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty?
        # create a new Radius Server
        @radius_server = Cisco::RadiusServer.new(@resource[:name])
      end

      RADIUS_SERVER_PROPS.each do |puppet_prop, cisco_prop|
        if @resource[puppet_prop] && @radius_server.respond_to?("#{cisco_prop}=")
          @radius_server.send("#{cisco_prop}=", munge_flush(@resource[puppet_prop]))
        end
      end

      # Handle key and keyformat setting
      if @resource[:key]
        @radius_server.send('key_set', munge_flush(@resource[:key]), munge_flush(@resource[:key_format]))
      end
    end
  end
end   # Puppet::Type
