# The NXAPI provider for cisco ntp_config.
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

Puppet::Type.type(:ntp_config).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for ntp_config.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  NTP_CONFIG_PROPS = {
    source_interface: :source_interface
  }

  def initialize(value={})
    super(value)
    @ntpconfig = Cisco::NtpConfig.ntpconfigs[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of ntp_config'
  end

  def self.properties_get(ntpconfig_name, v)
    debug "Checking instance, NtpConfig #{ntpconfig_name}"

    current_state = {
      name:             'default',
      source_interface: v.source_interface.nil? ? 'unset' : v.source_interface,
      ensure:           :present,
    }

    new(current_state)
  end # self.properties_get

  def self.instances
    ntpconfigs = []
    Cisco::NtpConfig.ntpconfigs.each do |ntpconfig_name, v|
      ntpconfigs << properties_get(ntpconfig_name, v)
    end

    ntpconfigs
  end

  def self.prefetch(resources)
    ntpconfigs = instances

    resources.keys.each do |id|
      provider = ntpconfigs.find { |ntpconfig| ntpconfig.name.to_s == id.to_s }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def validate
    unless @resource[:name].to_s == 'default'
      fail ArgumentError, "This provider only supports a namevar of 'default'"
    end

    return unless @resource[:source_interface]

    if @resource[:source_interface] =~ /\s+/
      fail ArgumentError, "The parameter 'source_interface' must not contain" \
                          'any spaces'
    end

    return unless @resource[:source_interface] =~ /[A-Z]+/

    fail ArgumentError, "The parameter 'source_interface' must not contain" \
                        'any uppercase characters'
  end

  def munge_flush(val)
    if val.is_a?(String) && val.eql?('unset')
      nil
    elsif val.is_a?(Symbol)
      val.to_s
    else
      val
    end
  end

  def flush
    validate

    NTP_CONFIG_PROPS.each do |puppet_prop, cisco_prop|
      if @resource[puppet_prop]
        @ntpconfig.send("#{cisco_prop}=", munge_flush(@resource[puppet_prop])) if
        @ntpconfig.respond_to?("#{cisco_prop}=")
      end
    end
  end
end # Puppet::Type
