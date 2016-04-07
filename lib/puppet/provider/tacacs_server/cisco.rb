# October, 2015
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:tacacs_server).provide(:cisco) do
  desc 'The Cisco provider for tacacs_server.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  TACACS_SERVER_PROPS = {
    port:    :port,
    timeout: :timeout,
  }

  UNSUPPORTED_PROPS = [:group, :vrf, :single_connection]

  def initialize(value={})
    super(value)
    @tacacs_server = Cisco::TacacsServerHost.hosts[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of tacacs_server'
  end

  def self.get_properties(name, v)
    debug "Checking instance, TacacsServerHost #{name}"

    current_state = {
      ensure:     :present,
      name:       v.name,
      port:       v.port,
      timeout:    v.timeout,
      key_format: v.encryption_type,
      key:        v.encryption_password,
    }

    new(current_state)
  end # self.get_properties

  def self.instances
    tacacs_servers = []
    Cisco::TacacsServerHost.hosts.each do |name, v|
      tacacs_servers << get_properties(name, v)
    end

    tacacs_servers
  end

  def self.prefetch(resources)
    tacacs_servers = instances

    resources.keys.each do |id|
      provider = tacacs_servers.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def validate
    fail ArgumentError,
         "This provider does not support the 'hostname' property." \
         'The namevar should be set to the IP of the Tacacs Server' if @resource[:hostname]

    invalid = []
    UNSUPPORTED_PROPS.each do |prop|
      invalid << prop if @resource[prop]
    end
    fail ArgumentError, "This provider does not support the following properties: #{invalid}" unless invalid.empty?

    fail ArgumentError,
         "The 'key' property must be set when specifying 'key_format'." if @resource[:key_format] && !resource[:key]

    fail ArgumentError,
         "The 'key_format' property must be set when specifying 'key'." if !@resource[:key_format] && resource[:key]
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def create_new
    if Facter.value('operatingsystem').eql?('ios_xr')
      @tacacs_server = Cisco::TacacsServerHost.new(@resource[:name], true, @resource[:port])
    else
      @tacacs_server = Cisco::TacacsServerHost.new(@resource[:name], true)
    end
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

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

  def flush
    validate

    if @property_flush[:ensure] == :absent
      @tacacs_server.destroy
      @tacacs_server = nil
      @property_hash[:ensure] = :absent
    else
      # On IOS XR, if the port values change, the entity has to be re-created as the ports
      # form part of the uniquiness of the item on the device. This is opposed to using
      # the setters on other platforms for the changing of port values.
      if @property_hash.empty? ||
         (Facter.value('operatingsystem').eql?('ios_xr') &&
          @resource[:port] != @tacacs_server.port.to_i)

        # create a new Tacacs Server
        create_new
      end

      if Facter.value('operatingsystem').eql?('ios_xr')
        TACACS_SERVER_PROPS.delete(:port)
      end

      TACACS_SERVER_PROPS.each do |puppet_prop, cisco_prop|
        if @resource[puppet_prop] && @tacacs_server.respond_to?("#{cisco_prop}=")
          @tacacs_server.send("#{cisco_prop}=", munge_flush(@resource[puppet_prop]))
        end
      end

      # Handle key and keyformat setting
      if @resource[:key]
        @tacacs_server.send('encryption_key_set', munge_flush(@resource[:key_format]), munge_flush(@resource[:key]))
      end
    end
  end
end   # Puppet::Type
