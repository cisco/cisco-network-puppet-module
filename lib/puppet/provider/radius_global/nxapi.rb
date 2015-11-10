# The NXAPI provider for radius_global.
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
begin
  require 'puppet_x/cisco/autogen'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:radius_global).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for radius_global.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  RADIUS_GLOBAL_PROPS = {
    timeout:          :timeout,
    retransmit_count: :retransmit_count,
  }

  def initialize(value={})
    super(value)
    @radius_global = Cisco::RadiusGlobal.radius_global['default']
    @property_flush = {}
    debug 'Created provider instance of radius_global'
  end

  def self.get_properties(name, v)
    debug "Checking instance, RadiusGlobal #{name}"

    current_state = {
      ensure:           :present,
      name:             v.name,
      timeout:          v.timeout ? v.timeout : -1,
      retransmit_count: v.retransmit_count ? v.retransmit_count : -1,
      key:              v.key ? v.key : 'unset',
      key_format:       v.key_format ? v.key_format : -1,
    }

    new(current_state)
  end # self.get_properties

  def self.instances
    radiusglobal = []
    Cisco::RadiusGlobal.radius_global.each do |name, v|
      radiusglobal << get_properties(name, v)
    end

    radiusglobal
  end

  def self.prefetch(resources)
    radius_global = instances

    resources.keys.each do |id|
      provider = radius_global.find { |instance| instance.name == id }
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
         "This provider does not support the 'enable' property." if @resource[:enable]
    fail ArgumentError,
         "The 'key' property must be set when specifying 'key_format'." if @resource[:key_format] && !resource[:key]
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def flush
    validate

    RADIUS_GLOBAL_PROPS.each do |puppet_prop, cisco_prop|
      if @resource[puppet_prop] && @radius_global.respond_to?("#{cisco_prop}=")
        @radius_global.send("#{cisco_prop}=", munge_flush(@resource[puppet_prop]))
      end
    end

    # Handle key and keyformat setting
    @radius_global.send('key_set', munge_flush(@resource[:key]), @resource[:key_format]) if @resource[:key]
  end
end # Puppet::Type
