# November, 2014
#
# Copyright (c) 2014-2017 Cisco and/or its affiliates.
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

Puppet::Type.type(:ntp_config).provide(:cisco) do
  desc 'The Cisco provider for ntp_config.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  NTP_CONFIG_NON_BOOL_PROPS = [
    :source_interface,
    :trusted_key,
  ]

  NTP_CONFIG_BOOL_PROPS = [
    :authenticate
  ]

  NTP_CONFIG_PROPS = NTP_CONFIG_NON_BOOL_PROPS + NTP_CONFIG_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@ntpconfig',
                                            NTP_CONFIG_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@ntpconfig',
                                            NTP_CONFIG_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @ntpconfig = Cisco::NtpConfig.ntpconfigs[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of ntp_config'
  end

  def self.properties_get(ntpconfig_name, v)
    debug "Checking instance, NtpConfig #{ntpconfig_name}"

    current_state = {
      name:   'default',
      ensure: :present,
    }

    # Call node_utils getter for each property
    NTP_CONFIG_NON_BOOL_PROPS.each do |prop|
      val = v.send(prop)
      if prop == :trusted_key
        current_state[prop] = val ? val : ['unset']
      else
        current_state[prop] = val ? val : 'unset'
      end
    end
    NTP_CONFIG_BOOL_PROPS.each do |prop|
      val = v.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    debug current_state
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
      fail ArgumentError, "The parameter 'source_interface' must not contain " \
                          'any spaces'
    end

    return unless @resource[:source_interface] =~ /[A-Z]+/

    fail ArgumentError, "The parameter 'source_interface' must not contain " \
                        'any uppercase characters'
  end

  # Custom setters.
  # The following properties are setters and cannot be handled
  # by PuppetX::Cisco::AutoGen.mk_puppet_methods.
  def ntp_trusted_keys
    return unless @property_flush[:trusted_key]
    # Get array of keys to remove
    # If unset - remove all configured keys
    if @property_flush[:trusted_key] == ['unset']
      remove = @property_hash[:trusted_key].map(&:to_s)
    else
      # Otherwise calculate the delta
      remove = @property_hash[:trusted_key].map(&:to_s).sort -
               @property_flush[:trusted_key].map(&:to_s).sort
      remove.delete('unset')
    end
    remove.each do |key|
      @ntpconfig.trusted_key_set(false, key) unless key == 'unset'
    end
    # Get array of keys to add
    return if @property_flush[:trusted_key] == ['unset']
    add = @property_flush[:trusted_key].map(&:to_s).sort -
          @property_hash[:trusted_key].map(&:to_s).sort
    remove.delete('unset')
    add.each do |key|
      @ntpconfig.trusted_key_set(true, key)
    end
  end

  def flush
    validate
    NTP_CONFIG_PROPS.each do |prop|
      next unless @resource[prop]
      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the @ntpconfig
      # node_utils object.
      @property_flush[prop] = nil if @property_flush[prop] == 'unset'
      @ntpconfig.send("#{prop}=", @property_flush[prop]) if
        @ntpconfig.respond_to?("#{prop}=")
    end
    # Set methods that are not autogenerated follow.
    ntp_trusted_keys
  end
end # Puppet::Type
