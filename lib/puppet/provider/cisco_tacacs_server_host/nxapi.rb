########################################################################
# The NXAPI provider for cisco_tacacs_server_host.
#
# March 2015
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
########################################################################

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_tacacs_server_host).provide(:nxapi) do
  desc 'The NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)

    @tacacs_server_host = Cisco::TacacsServerHost.hosts[@property_hash[:host]]
    @property_flush = {}
  end

  def self.instances
    tacacs_server_hosts = []
    Cisco::TacacsServerHost.hosts.each do |host_name, tacacs_server_host|
      tacacs_server_hosts << new(
        host:                host_name,
        name:                host_name,
        ensure:              :present,
        port:                tacacs_server_host.port,
        timeout:             tacacs_server_host.timeout,
        encryption_type:     tacacs_server_host.encryption_type,
        encryption_password: tacacs_server_host.encryption_password)
    end
    tacacs_server_hosts
  end

  def self.prefetch(resources)
    ts_hosts = instances

    resources.keys.each do |name|
      provider = ts_hosts.find { |ts_host| ts_host.name == name }
      resources[name].provider = provider unless provider.nil?
    end
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

  def port
    if @resource[:port] == :default &&
       @property_hash[:port] == Cisco::TacacsServerHost.default_port
      port = :default
    else
      port = @property_hash[:port]
    end
    port
  end

  def port=(should_value)
    if should_value == :default
      port_value = Cisco::TacacsServerHost.default_port
    else
      port_value = should_value
    end
    @property_flush[:port] = port_value
  end

  def timeout
    if @resource[:timeout] == :default &&
       @property_hash[:timeout] == Cisco::TacacsServerHost.default_timeout
      timeout = :default
    else
      timeout = @property_hash[:timeout]
    end
    timeout
  end

  def timeout=(should_value)
    if should_value == :default
      timeout_value = Cisco::TacacsServerHost.default_timeout
    else
      timeout_value = should_value
    end
    @property_flush[:timeout] = timeout_value
  end

  def tacacs_server_host_encryption_key_set
    # encryption type update
    if @resource[:encryption_type] == :default
      encryption_type_value = Cisco::TacacsServerHost.default_encryption_type
    else
      if resource[:encryption_type] &&
         resource[:encryption_type] != @property_hash[:encryption_type]
        # If manifest has updated value and it is not default
        encryption_type_value = @resource[:encryption_type]
      else
        # If manifest doesn't have it or no change
        if @property_hash[:encryption_type]
          # If it is an update action
          encryption_type_value = @property_hash[:encryption_type]
        else
          # If it is a create action
          encryption_type_value =
            Cisco::TacacsServerHost.default_encryption_type
        end
      end
    end

    # encryption password update
    # Currently we cannot really compare the password, just set it.
    if @resource[:encryption_password]
      encryption_pw_value = @resource[:encryption_password]
    end

    # call the setter
    return unless encryption_pw_value
    debug "type #{encryption_type_value}, value #{encryption_pw_value}"
    @tacacs_server_host.encryption_key_set(encryption_type_value,
                                           encryption_pw_value)
  end

  def update_port_or_timeout_attribute(attribute)
    return unless @resource[attribute] && @resource[attribute] != :default
    # The attribute is specified in the manifest and not the default.
    # Default values are no-op when creating a new host.
    @property_flush[attribute] = @resource[attribute]
  end

  def flush
    if @property_flush[:ensure] == :absent
      @tacacs_server_host.destroy
      @tacacs_server_host = nil
      return
    elsif @property_flush[:ensure] == :present
      @tacacs_server_host = Cisco::TacacsServerHost.new(@resource[:host])
      update_port_or_timeout_attribute(:port)
      update_port_or_timeout_attribute(:timeout)
    end

    @tacacs_server_host.port = @property_flush[:port] if
      @property_flush[:port]
    @tacacs_server_host.timeout = @property_flush[:timeout] if
      @property_flush[:timeout]

    tacacs_server_host_encryption_key_set
  end
end
