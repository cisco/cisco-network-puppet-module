# The NXAPI provider for cisco ntp_server.
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

Puppet::Type.type(:ntp_server).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for ntp_server.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  NTP_SERVER_ALL_PROPS = [
    :prefer
  ]

  def initialize(value={})
    super(value)
    @ntpserver = Cisco::NtpServer.ntpservers[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of ntp_server'
  end

  def self.properties_get(ntpserver_ip, v)
    debug "Checking instance, ntpserver #{ntpserver_ip}"

    current_state = {
      name:   ntpserver_ip,
      ensure: :present,
    }

    NTP_SERVER_ALL_PROPS.each do |prop|
      current_state[prop] = v.send(prop) == true ? :true : :false
    end

    new(current_state)
  end # self.properties_get

  def self.instances
    ntpservers = []
    Cisco::NtpServer.ntpservers.each do |ntpserver_ip, v|
      ntpservers << properties_get(ntpserver_ip, v)
    end

    ntpservers
  end

  def self.prefetch(resources)
    ntpservers = instances

    resources.keys.each do |id|
      provider = ntpservers.find { |ntpserver| ntpserver.name == id }
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

  def flush
    if @property_flush[:ensure] == :absent
      @ntpserver.destroy
      @ntpserver = nil
    else
      # Create/Update
      @ntpserver = Cisco::NtpServer.new(@resource[:name], @resource[:prefer] == :true ? true : false)
    end
    # puts_config
  end
end # Puppet::Type
