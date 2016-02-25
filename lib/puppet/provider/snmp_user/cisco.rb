# The NXAPI provider for cisco snmp_user.
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

Puppet::Type.type(:snmp_user).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for snmp_user.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  REQUIRES_AUTH_PROPS = [:password, :privacy, :private_key, :localized_key, :engine_id]

  def initialize(value={})
    super(value)

    if @property_hash[:engine_id] && !@property_hash[:engine_id].empty?
      key = "#{@property_hash[:name]} #{@property_hash[:engine_id]}"
    else
      key = @property_hash[:name]
    end

    @snmpuser = Cisco::SnmpUser.users[key]
    @property_flush = {}
    debug 'Created provider instance of snmp_user'
  end

  def self.properties_get(snmpuser_name, v)
    debug "Checking instance, SnmpUser #{snmpuser_name}"

    current_state = {
      ensure:      :present,
      name:        snmpuser_name,
      engine_id:   v.engine_id,
      roles:       v.groups,
      auth:        v.auth_protocol,
      password:    v.auth_password,
      privacy:     v.priv_protocol,
      private_key: v.priv_password,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    snmpusers = []
    Cisco::SnmpUser.users.each do |snmpuser_name, v|
      snmpusers << properties_get(snmpuser_name.split(' ')[0], v)
    end

    snmpusers
  end

  def self.prefetch(resources)
    snmpusers = instances

    resources.keys.each do |id|
      provider = snmpusers.find { |snmpuser| snmpuser.name.to_s == id.to_s }
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
    unless @resource[:auth]
      invalid = []
      REQUIRES_AUTH_PROPS.each do |prop|
        invalid << prop if @resource[prop]
      end
      fail ArgumentError,
           "You must specify the 'auth' property when specifying any of the following properties: #{invalid}" \
             unless invalid.empty?
    end

    fail ArgumentError,
         "The 'password' property must be set when specifying 'auth'" \
            if @resource[:password].nil? && @resource[:auth]

    fail ArgumentError,
         "The 'private_key' property must be set when specifying 'privacy'" \
            if @resource[:private_key].nil? && @resource[:privacy]

    fail ArgumentError,
         "The 'engine_id' and 'roles' properties are mutually exclusive" \
            if @resource[:engine_id] && @resource[:roles]

    fail ArgumentError,
         "The 'enforce_privacy' property is not supported by this provider" \
            if @resource[:enforce_privacy]
  end

  def flush
    validate
    @snmpuser.destroy if @snmpuser
    @snmpuser = nil

    return if @property_flush[:ensure] == :absent

    if @resource[:localized_key].eql?(:true)
      localized_key = true
    else
      localized_key = false
    end

    # Needed due to NXOS issue regarding removing and adding resources too quickly
    sleep 2

    @snmpuser = Cisco::SnmpUser.new(@resource[:name],
                                    @resource[:roles] || [],
                                    @resource[:auth] || @property_hash[:auth] || :none,
                                    @resource[:password] || @property_hash[:password] || '',
                                    @resource[:privacy] || @property_hash[:privacy] || :none,
                                    @resource[:private_key] || @property_hash[:private_key] || '',
                                    localized_key,
                                    @resource[:engine_id] || '')
  end
end # Puppet::Type
