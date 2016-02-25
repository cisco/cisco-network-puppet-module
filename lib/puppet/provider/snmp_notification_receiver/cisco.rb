# The NXAPI provider for cisco snmp_notification_receiver.
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

Puppet::Type.type(:snmp_notification_receiver).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for snmp_notification_receiver.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  REQUIRED_PROPS = [:type, :version, :username]

  mk_resource_methods

  def initialize(value={})
    super(value)

    @snmpnotificationreceiver = Cisco::SnmpNotificationReceiver.receivers[name]
    @property_flush = {}
    debug 'Created provider instance of snmp_notification_receiver'
  end

  def self.properties_get(snmpnotificationreceiver_name, v)
    debug "Checking instance, SnmpNotificationReceiver #{snmpnotificationreceiver_name}"

    if v.version.eql?('1')
      version = 'v1'
    elsif v.version.eql?('2c')
      version = 'v2'
    elsif v.version.eql?('3')
      version = 'v3'
    else
      version = nil
    end

    current_state = {
      ensure:           :present,
      name:             snmpnotificationreceiver_name,
      port:             v.port,
      username:         v.username,
      version:          version,
      type:             v.type,
      security:         v.security,
      vrf:              v.vrf,
      source_interface: v.source_interface,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    snmpnotificationreceivers = []
    Cisco::SnmpNotificationReceiver.receivers.each do |snmpnotificationreceiver_name, v|
      snmpnotificationreceivers << properties_get(snmpnotificationreceiver_name, v)
    end

    snmpnotificationreceivers
  end

  def self.prefetch(resources)
    snmpnotificationreceivers = instances

    resources.keys.each do |id|
      provider = snmpnotificationreceivers.find { |snmpnotificationreceiver| snmpnotificationreceiver.name.to_s == id.to_s }
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
    required = []
    REQUIRED_PROPS.each do |prop|
      required << prop unless @resource[prop]
    end
    fail ArgumentError,
         "You must specify the following properties: #{required}" \
           unless required.empty?

    fail ArgumentError,
         "The 'type' property only supports a setting of 'traps' when 'version' is set to 'v1'" \
            if !@resource[:type].eql?(:traps) && @resource[:version].eql?(:v1)

    fail ArgumentError,
         "The 'security' property is only supported when 'version' is set to 'v3'" \
            if @resource[:security] && !@resource[:version].eql?(:v3)
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
    elsif val.is_a?(Integer)
      val.to_s
    else
      val
    end
  end

  def munge_version(_va)
    if @resource[:version].eql?(:v1)
      '1'
    elsif @resource[:version].eql?(:v2)
      '2c'
    elsif @resource[:version].eql?(:v3)
      '3'
    end
  end

  def flush # rubocop:disable Metrics/CyclomaticComplexity
    @snmpnotificationreceiver.destroy if @snmpnotificationreceiver
    @snmpnotificationreceiver = nil

    return if @property_flush[:ensure] == :absent

    validate

    # Handler for security depending on version
    if @resource[:version].eql?(:v3)
      security = munge_flush(@resource[:security]) || munge_flush(@property_hash[:security]) || ''
    else
      security = ''
    end

    @snmpnotificationreceiver = \
      Cisco::SnmpNotificationReceiver.new(@resource[:name],
                                          instantiate:      true,
                                          type:             munge_flush(@resource[:type]) || munge_flush(@property_hash[:type]) || '',
                                          version:          munge_version(@resource[:version]) || munge_version(@property_hash[:version]) || '',
                                          security:         security,
                                          username:         munge_flush(@resource[:username]) || munge_flush(@property_hash[:username]) || '',
                                          port:             munge_flush(@resource[:port]) || munge_flush(@property_hash[:port]) || '',
                                          vrf:              munge_flush(@resource[:vrf]) || munge_flush(@property_hash[:vrf]) || '',
                                          source_interface: munge_flush(@resource[:source_interface]) || munge_flush(@property_hash[:source_interface]) || '')
  end
end # Puppet::Type
