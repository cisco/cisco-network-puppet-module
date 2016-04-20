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

Puppet::Type.type(:snmp_notification).provide(:cisco) do
  desc 'The Cisco provider for snmp_notification.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @snmpnotification = Cisco::SnmpNotification.notifications[name]
    @property_flush = {}
    debug 'Created provider instance of snmp_notification'
  end

  def self.instances
    snmpnotification = []
    Cisco::SnmpNotification.notifications.each do |name, v|
      snmpnotification << new(
        name:   name,
        enable: v.enable.to_s,
      )
    end
    snmpnotification
  end

  def self.prefetch(resources)
    snmpnotification = instances

    resources.keys.each do |id|
      provider = snmpnotification.find do |instance|
        instance.name == resources[id][:name] &&
        instance.enable.to_s == resources[id][:enable].to_s
      end
      resources[id].provider = provider unless provider.nil?
    end
  end

  def flush
    enable = @resource[:enable] == :true ? true : false
    @snmpnotification.enable = enable if @resource[:enable]
  end
end
