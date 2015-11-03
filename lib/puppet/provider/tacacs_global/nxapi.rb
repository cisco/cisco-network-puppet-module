# The NXAPI provider for tacacs_global.
#
# October, 2015
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

Puppet::Type.type(:tacacs_global).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for tacacs_global.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # The following properties are only valid when 'enable' is set to true
  ENABLED_ONLY_PROPS = [:timeout, :key, :key_format]

  def initialize(value={})
    super(value)
    @tacacs_global = Cisco::TacacsServer.new(false)
    @property_flush = {}
    debug 'Created provider instance of tacacs_global'
  end

  def self.get_properties(name)
    debug "Checking instance, TacacsServer #{name}"

    v = Cisco::TacacsServer.new(false)

    current_state = {}
    current_state[:name] = name
    current_state[:enable] = Cisco::TacacsServer.enabled ? :true : :false

    if current_state[:enable].eql?(:true)
      current_state[:timeout] = v.timeout
      current_state[:key] = v.encryption_password
      current_state[:key_format] = v.encryption_type
    end

    new(current_state)
  end # self.get_properties

  def self.instances
    tacacsglobal = []
    tacacsglobal << get_properties('default')
    tacacsglobal
  end

  def self.prefetch(resources)
    tacacs_global = instances

    resources.keys.each do |id|
      provider = tacacs_global.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def munge_flush(val)
    if val.is_a?(String) && val.eql?('unset')
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

  def validate
    fail ArgumentError,
         "This provider only supports a namevar of 'default'" unless @resource[:name].to_s == 'default'

    fail ArgumentError,
         "This provider does not support the 'retransmit_count' property." if @resource[:retransmit_count]

    if @resource[:enable] && @resource[:enable].eql?(:false)
      invalid = []
      ENABLED_ONLY_PROPS.each do |prop|
        invalid << prop if @resource[prop]
      end
      fail ArgumentError, "The 'enable' property must be set to true when specifying the following properties: #{invalid}" unless invalid.empty?
    else
      fail ArgumentError,
           "The 'key' property must be set when specifying 'key_format'." if @resource[:key_format] && !resource[:key]
      fail ArgumentError,
           "The 'key_format' property must be set when specifying 'key'." if !@resource[:key_format] && resource[:key]
    end
  end

  def exists?
    true
  end

  def flush
    validate

    # Handle enable setting
    if @resource[:enable]
      if @resource[:enable].eql?(:true)
        @tacacs_global.enable
      elsif @resource[:enable].eql?(:false)
        @tacacs_global.destroy
      end
    end

    # Handle timeout setting
    @tacacs_global.timeout = @resource[:timeout] if @resource[:timeout]

    # Handle key and keyformat setting
    @tacacs_global.send('encryption_key_set', munge_flush(@resource[:key_format]), @resource[:key]) if @resource[:key]
  end
end # Puppet::Type
