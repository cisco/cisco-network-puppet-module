# The NXAPI provider for cisco syslog_server.
#
# November, 2014
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

Puppet::Type.type(:syslog_server).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for syslog_server.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @syslogserver = Cisco::SyslogServer.syslogservers[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of syslog_server'
  end

  def self.properties_get(syslogserver_name, v)
    debug "Checking instance, SyslogServer #{syslogserver_name}"

    current_state = {
      ensure:         :present,
      name:           syslogserver_name,
      severity_level: v.level,
      vrf:            v.vrf,
    }

    new(current_state)
  end # self.properties_get

  def self.instances
    syslogservers = []
    Cisco::SyslogServer.syslogservers.each do |syslogserver_name, v|
      syslogservers << properties_get(syslogserver_name, v)
    end

    syslogservers
  end

  def self.prefetch(resources)
    syslogservers = instances

    resources.keys.each do |id|
      provider = syslogservers.find { |syslogserver| syslogserver.name.to_s == id.to_s }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def validate
    fail ArgumentError,
         "This provider does not support the 'source_interface' property. " if @resource[:source_interface]
  end

  def flush
    validate
    if @property_flush[:ensure] == :absent
      @syslogserver.destroy
      @syslogserver = nil
    else
      @syslogserver = Cisco::SyslogServer.new(@resource[:name], @resource[:severity_level], @resource[:vrf])
    end
  end
end # Puppet::Type
