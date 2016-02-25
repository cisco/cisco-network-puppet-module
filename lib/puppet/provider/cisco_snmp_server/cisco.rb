# The NXAPI (cisco_snmp_server) provider.
#
# December, 2013
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_snmp_server).provide(:nxapi) do
  desc 'The nxapi provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @snmp_server = Cisco::SnmpServer.new
    debug 'Created provider instance of cisco_snmp_server.'
  end

  def self.instances
    snmp_servers = []
    server = Cisco::SnmpServer.new

    snmp_servers << new(
      ensure:                 :present,
      name:                   'default', # necessary for puppet resource cmd
      location:               server.location,
      contact:                server.contact,
      aaa_user_cache_timeout: server.aaa_user_cache_timeout,
      packet_size:            server.packet_size,
      global_enforce_priv:    server.global_enforce_priv? ? :true : :false,
      protocol:               server.protocol? ? :true : :false,
      tcp_session_auth:       server.tcp_session_auth? ? :true : :false)
    debug 'Created new resource type cisco_snmp_server'
    snmp_servers
  end

  def self.prefetch(resources)
    resources.values.first.provider = instances.first
  end

  def location
    value = @snmp_server.location
    value = :default if
      @resource[:location] == :default &&
      value == @snmp_server.default_location
    @property_hash[:location] = value
  end

  def location=(set_value)
    return if set_value.nil?
    set_value = @snmp_server.default_location if set_value == :default
    @snmp_server.location = set_value
  end

  def contact
    value = @snmp_server.contact
    value = :default if
      @resource[:contact] == :default && value == @snmp_server.default_contact
    @property_hash[:contact] = value
  end

  def contact=(set_value)
    return if set_value.nil?
    set_value = @snmp_server.default_contact if set_value == :default
    @snmp_server.contact = set_value
    @property_hash[:contact] = set_value
  end

  def aaa_user_cache_timeout
    value = @snmp_server.aaa_user_cache_timeout
    value = :default if
      @resource[:aaa_user_cache_timeout] == :default &&
      value == @snmp_server.default_aaa_user_cache_timeout
    @property_hash[:aaa_user_cache_timeout] = value
  end

  def aaa_user_cache_timeout=(set_value)
    return if set_value.nil?
    set_value = @snmp_server.default_aaa_user_cache_timeout if
      set_value == :default
    @snmp_server.aaa_user_cache_timeout = set_value
    @property_hash[:aaa_user_cache_timeout] = set_value
  end

  def packet_size
    value = @snmp_server.packet_size
    value = :default if
      @resource[:packet_size] == :default &&
      value == @snmp_server.default_packet_size
    @property_hash[:packet_size] = value
  end

  def packet_size=(set_value)
    return if set_value.nil?
    set_value = @snmp_server.default_packet_size if set_value == :default
    @snmp_server.packet_size = set_value
    @property_hash[:packet_size] = set_value
  end

  def global_enforce_priv
    value = @snmp_server.global_enforce_priv?
    if (value == @snmp_server.default_global_enforce_priv) &&
       (@resource[:global_enforce_priv] == :default)
      value = :default
    else
      value = value ? :true : :false
    end
    @property_hash[:global_enforce_priv] = value
  end

  def global_enforce_priv=(set_value)
    @property_hash[:global_enforce_priv] = set_value
    if set_value == :default
      @snmp_server.global_enforce_priv = @snmp_server.default_global_enforce_priv
    else
      @snmp_server.global_enforce_priv = (set_value == :true)
    end
  end

  def protocol
    value = @snmp_server.protocol?
    if (value == @snmp_server.default_protocol) &&
       (@resource[:protocol] == :default)
      value = :default
    else
      value = value ? :true : :false
    end
    @property_hash[:protocol] = value
  end

  def protocol=(set_value)
    @property_hash[:protocol] = set_value
    if set_value == :default
      @snmp_server.protocol = @snmp_server.default_protocol
    else
      @snmp_server.protocol = (set_value == :true)
    end
  end

  def tcp_session_auth
    value = @snmp_server.tcp_session_auth?
    if (value == @snmp_server.default_tcp_session_auth) &&
       (@resource[:tcp_session_auth] == :default)
      value = :default
    else
      value = value ? :true : :false
    end
    @property_hash[:tcp_session_auth] = value
  end

  def tcp_session_auth=(set_value)
    @property_hash[:tcp_session_auth] = set_value
    if set_value == :default
      @snmp_server.tcp_session_auth = @snmp_server.default_tcp_session_auth
    else
      @snmp_server.tcp_session_auth = (set_value == :true)
    end
  end

  def flush
    put_snmp_server
  end

  def put_snmp_server
    debug 'Current state:'
    return if @snmp_server.nil?

    debug "
               Location: #{@snmp_server.location}
                Contact: #{@snmp_server.contact}
             Packetsize: #{@snmp_server.packet_size}
      aaa_cache_timeout: #{@snmp_server.aaa_user_cache_timeout}
         global_privacy: #{@snmp_server.global_enforce_priv?}
        protocol_enable: #{@snmp_server.protocol?}
       tcp_session_auth: #{@snmp_server.tcp_session_auth?}
    "
  end
end
