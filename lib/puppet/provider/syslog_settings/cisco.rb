# The NXAPI provider for cisco syslog_setting.
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

Puppet::Type.type(:syslog_settings).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for syslog_setting.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  SYSLOG_SETTINGS_PROPS = {
    time_stamp_units: :timestamp
  }

  def initialize(value={})
    super(value)
    @syslogsetting = Cisco::SyslogSettings.syslogsettings['default']
    @property_flush = {}
    debug 'Created provider instance of syslog_setting'
  end

  def self.properties_get(syslogsetting_name, v)
    debug "Checking instance, SyslogSetting #{syslogsetting_name}"

    current_state = {
      name:             'default',
      time_stamp_units: v.timestamp,
      ensure:           :present,
    }

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
    true
  end

  def validate
    fail ArgumentError,
         "This provider only supports a namevar of 'default'" unless @resource[:name].to_s == 'default'

    fail ArgumentError,
         "This provider does not support the 'enable' property. "\
         'Syslog servers are enabled implicitly when using the syslog_server resource.' if @resource[:enable]
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

    SYSLOG_SETTINGS_PROPS.each do |puppet_prop, cisco_prop|
      if @resource[puppet_prop]
        @syslogsetting.send("#{cisco_prop}=", munge_flush(@resource[puppet_prop])) \
          if @syslogsetting.respond_to?("#{cisco_prop}=")
      end
    end
  end
end # Puppet::Type
