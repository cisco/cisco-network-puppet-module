################################################
# The nxapi provider for cisco_tacacs_server.
#
# January, 2015
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
#################################################

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_tacacs_server).provide(:nxapi) do
  desc 'The nxapi provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @tacacs_server = Cisco::TacacsServer.new if Cisco::TacacsServer.enabled
    @property_flush = {}
  end

  def self.enc_type_to_sym(type)
    case type
    when Cisco::TACACS_SERVER_ENC_UNKNOWN
      :none
    when Cisco::TACACS_SERVER_ENC_NONE
      :clear
    when Cisco::TACACS_SERVER_ENC_CISCO_TYPE_7
      :encrypted
    end
  end

  def self.enc_sym_to_type(sym)
    case sym
    when :none
      Cisco::TACACS_SERVER_ENC_UNKNOWN
    when :clear, :default
      Cisco::TACACS_SERVER_ENC_NONE
    when :encrypted
      Cisco::TACACS_SERVER_ENC_CISCO_TYPE_7
    end
  end

  def self.instances
    tacacs_servers = []

    return tacacs_servers unless Cisco::TacacsServer.enabled

    tacacs_server = Cisco::TacacsServer.new

    # source interface
    src_intf = tacacs_server.source_interface
    if src_intf == Cisco::TacacsServer.default_source_interface
      src_intf = :default
    end

    tacacs_servers << new(
      ensure:              :present,
      name:                'default', # necessary for puppet resource cmd
      timeout:             tacacs_server.timeout,
      directed_request:    tacacs_server.directed_request? ? :true : :false,
      deadtime:            tacacs_server.deadtime,
      encryption_type:     enc_type_to_sym(tacacs_server.encryption_type),
      encryption_password: tacacs_server.encryption_password,
      source_interface:    src_intf)
    debug 'Found a tacacs server on the device.'
    tacacs_servers
  end # self.instances

  def self.prefetch(resources)
    resources.values.first.provider = instances.first unless instances.first.nil?
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end # exists

  def create
    debug 'Creating tacacs server.'

    @tacacs_server = Cisco::TacacsServer.new

    debug "Created a tacacs server on #{@resource[:name]}"

    # Call all property setters
    self.timeout = @resource[:timeout] unless
      @resource[:timeout].nil?
    self.directed_request = @resource[:directed_request] unless
      @resource[:directed_request].nil?
    self.deadtime = @resource[:deadtime] unless
      @resource[:deadtime].nil?
    self.source_interface = @resource[:source_interface] unless
      @resource[:source_interface].nil?

    tacacs_server_encryption_key_set
  end # create

  def destroy
    debug 'Removing a tacacs server.'
    @tacacs_server.destroy
    @tacacs_server = nil
  end # destroy

  def timeout
    debug 'Getting timeout.'
    if @resource[:timeout] == :default &&
       @property_hash[:timeout] == Cisco::TacacsServer.default_timeout
      timeout = :default
    else
      timeout = @property_hash[:timeout]
    end
    timeout
  end # timeout

  def timeout=(should_value)
    if should_value == :default
      timeout_value = Cisco::TacacsServer.default_timeout
    else
      timeout_value = should_value
    end

    @tacacs_server.timeout = timeout_value
  end # timeout=

  def directed_request=(should_value)
    @tacacs_server.directed_request = (should_value == :true)
  end # directed_request=

  def deadtime
    if @resource[:deadtime] == :default &&
       @property_hash[:deadtime] == Cisco::TacacsServer.default_deadtime
      debug "Default value is #{deadtime_value}."
      deadtime = :default
    else
      deadtime = @property_hash[:deadtime]
    end
    deadtime
  end # deadtime

  def deadtime=(should_value)
    debug "Setting deadtime to #{should_value}."

    if should_value == :default
      deadtime_value = Cisco::TacacsServer.default_deadtime
    else
      deadtime_value = should_value
    end

    @tacacs_server.deadtime = deadtime_value
  end # deadtime=

  def source_interface=(should_value)
    if should_value == :default
      source_interface_value = Cisco::TacacsServer.default_source_interface
    else
      source_interface_value = should_value
    end

    @tacacs_server.source_interface = source_interface_value
  end # source_interface=

  def encryption_password=(should_value)
    @property_flush[:encryption_password] = should_value
  end

  def tacacs_server_encryption_key_set
    # encryption type update
    if @resource[:encryption_type] == :default
      encryption_type_value = Cisco::TacacsServer.default_encryption_type
    else
      if resource[:encryption_type] &&
         resource[:encryption_type] != @property_hash[:encryption_type]
        # If manifest has updated value and it is not default
        encryption_type_value =
          self.class.enc_sym_to_type(@resource[:encryption_type])
      else
        # If manifest doesn't have it or no change
        if @property_hash[:encryption_type]
          # If it is an update action
          encryption_type_value =
            self.class.enc_sym_to_type(@property_hash[:encryption_type])
        else
          # If it is a create action
          encryption_type_value = Cisco::TacacsServer.default_encryption_type
        end
      end
    end

    # encryption password
    if @resource[:encryption_password]
      encryption_pw_value = @resource[:encryption_password]
    end
    debug "type: #{encryption_type_value}, value #{encryption_pw_value}"

    return unless encryption_pw_value
    @tacacs_server.encryption_key_set(encryption_type_value,
                                      encryption_pw_value)
  end

  def flush
    tacacs_server_encryption_key_set if @property_flush[:encryption_password]
  end
end # provider
