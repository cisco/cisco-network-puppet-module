# September, 2017
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

Puppet::Type.type(:syslog_settings).provide(:cisco) do
  desc 'The Cisco provider for syslog_setting.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  SYSLOG_SETTINGS_ARRAY_PROPS = [
    :source_interface
  ]

  SYSLOG_SETTINGS_NON_BOOL_PROPS = [
    :console,
    :monitor,
    :time_stamp_units,
    :logfile_severity_level,
    :logfile_name,
    :logfile_size,
  ]

  SYSLOG_CONFIG_PROPS = SYSLOG_SETTINGS_ARRAY_PROPS + SYSLOG_SETTINGS_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@syslogsetting',
                                            SYSLOG_SETTINGS_ARRAY_PROPS)

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@syslogsetting',
                                            SYSLOG_SETTINGS_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @syslogsetting = Cisco::SyslogSettings.syslogsettings['default']
    @property_flush = {}
    debug 'Created provider instance of syslog_setting'
  end

  def self.properties_get(syslogsetting_name, v)
    debug "Checking instance, SyslogSetting #{syslogsetting_name}"

    current_state = {
      name:   'default',
      ensure: :present,
    }

    SYSLOG_SETTINGS_ARRAY_PROPS.each do |prop|
      val = v.send(prop)
      current_state[prop] = val ? [val] : ['unset']
    end

    SYSLOG_SETTINGS_NON_BOOL_PROPS.each do |prop|
      val = v.send(prop)
      current_state[prop] = val ? val : 'unset'
    end

    new(current_state)
  end # self.properties_get

  def self.instances
    syslogsettings = []
    Cisco::SyslogSettings.syslogsettings.each do |syslogsetting_name, v|
      syslogsettings << properties_get(syslogsetting_name, v)
    end

    syslogsettings
  end

  def self.prefetch(resources)
    syslogsettings = instances

    resources.keys.each do |id|
      provider = syslogsettings.find { |syslogsetting| syslogsetting.name.to_s == id.to_s }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def validate
    fail ArgumentError,
         "This provider only supports a namevar of 'default'" unless @resource[:name].to_s == 'default'
    fail ArgumentError,
         'This provider requires that a logfile_name and logfile_severity_level are both specified in order '\
         'to set logfile settings.' if (@resource[:logfile_name] && !@resource[:logfile_severity_level]) ||
                                       (@resource[:logfile_severity_level] && !@resource[:logfile_name])
    fail ArgumentError,
         'This provider requires that a logfile_name and logfile_severity_level are both specified in order '\
         'to set logfile size.' if @resource[:logfile_size] && !@resource[:logfile_name] && !@resource[:logfile_severity_level]
    fail ArgumentError,
         "This provider does not support the 'enable' property. "\
         'Syslog servers are enabled implicitly when using the syslog_server resource.' if @resource[:enable]
    fail ArgumentError,
         "This provider does not support the 'vrf' property. " if @resource[:vrf]
  end

  def tidy_up_syslog_logfile
    SYSLOG_CONFIG_PROPS.delete(:logfile_severity_level)
    SYSLOG_CONFIG_PROPS.delete(:logfile_name)
    SYSLOG_CONFIG_PROPS.delete(:logfile_size)

    if @property_flush[:logfile_severity_level] == 'unset'
      @property_flush[:logfile_severity_level] = nil
      @property_flush[:logfile_name] = nil
      @property_flush[:logfile_size] = nil
    else
      return unless @property_flush[:logfile_severity_level] && @property_flush[:logfile_name]
    end

    if @property_flush[:logfile_size]
      @property_flush[:logfile_size] = "size #{@property_flush[:logfile_size]}"
    else
      @property_flush[:logfile_size] = ''
    end

    @syslogsetting.send("#{:logfile_name}=",
                        @property_flush[:logfile_name],
                        @property_flush[:logfile_severity_level],
                        @property_flush[:logfile_size]) if
        @syslogsetting.respond_to?("#{:logfile_name}=")
  end

  def flush
    validate

    tidy_up_syslog_logfile

    SYSLOG_CONFIG_PROPS.each do |prop|
      next unless @resource[prop]
      next if @property_flush[prop].nil?
      # Other platforms require array for some types - Nexus does not
      @property_flush[prop] = @property_flush[prop][0] if @property_flush[prop].is_a?(Array)
      # Call the AutoGen setters for the @syslogsetting node_utils object.
      @property_flush[prop] = nil if @property_flush[prop] == 'unset'
      @syslogsetting.send("#{prop}=", @property_flush[prop]) if
        @syslogsetting.respond_to?("#{prop}=")
    end
  end
end # Puppet::Type
