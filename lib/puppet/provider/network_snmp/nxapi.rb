# The NXAPI provider for network_snmp.
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

Puppet::Type.type(:network_snmp).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for network_snmp.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  NETWORK_SNMP_PROPS = {
    enable:   :protocol,
    contact:  :contact,
    location: :location,
  }

  def initialize(value={})
    super(value)
    @network_snmp = Cisco::SnmpServer.new
    @property_flush = {}
    debug 'Created provider instance of network_snmp'
  end

  def self.properties_get
    network_snmp = Cisco::SnmpServer.new

    current_state = {
      name:     'default',
      enable:   network_snmp.protocol? ? :true : :false,
      contact:  network_snmp.contact.empty? ? 'unset' : network_snmp.contact,
      location: network_snmp.location.empty? ? 'unset' : network_snmp.location,
    }

    new(current_state)
  end # self.properties_get

  def self.instances
    network_snmp = []
    network_snmp << properties_get

    network_snmp
  end

  def self.prefetch(resources)
    network_snmp = instances

    resources.keys.each do |id|
      provider = network_snmp.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def munge_flush(val)
    if val.is_a?(String) && val.eql?('unset')
      ''
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
         "This provider only supports a namevar of 'default'" unless @resource[:name].to_s == 'default'
  end

  def flush
    validate

    NETWORK_SNMP_PROPS.each do |puppet_prop, cisco_prop|
      if @resource[puppet_prop]
        @network_snmp.send("#{cisco_prop}=", munge_flush(@resource[puppet_prop])) \
          if @network_snmp.respond_to?("#{cisco_prop}=")
      end
    end
  end
end # Puppet::Type
