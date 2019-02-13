# Copyright (c) 2018 Cisco and/or its affiliates.
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
module Puppet; end
module Puppet::ResourceApi
  # Implementation for the syslog_settings type using the Resource API.
  class Puppet::Provider::SyslogSettings::CiscoNexus
    SYSLOG_SETTINGS_ARRAY_PROPS ||= [
      :source_interface
    ]

    SYSLOG_SETTINGS_NON_BOOL_PROPS ||= [
      :time_stamp_units,
      :logfile_name,
    ]

    SYSLOG_SETTINGS_INTEGER_PROPS ||= [
      :console,
      :monitor,
      :logfile_severity_level,
      :logfile_size,
    ]

    SYSLOG_CONFIG_PROPS ||= SYSLOG_SETTINGS_ARRAY_PROPS + SYSLOG_SETTINGS_NON_BOOL_PROPS + SYSLOG_SETTINGS_INTEGER_PROPS

    def canonicalize(_context, resources)
      resources.each do |resource|
        resource.each do |k, v|
          resource[k] = 'unset' if v.nil? || v == (nil || -1)
        end
      end
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]
        is = change[:is]

        if should != is
          update(context, name, should)
        end
      end
    end

    def get(_context, _names=nil)
      require 'cisco_node_utils'
      @syslog_settings = Cisco::SyslogSettings.syslogsettings['default']
      current_state = {
        name: 'default',
      }

      SYSLOG_SETTINGS_ARRAY_PROPS.each do |property|
        value = @syslog_settings.send(property)
        current_state[property] = value ? [value] : ['unset']
      end

      SYSLOG_SETTINGS_NON_BOOL_PROPS.each do |property|
        value = @syslog_settings.send(property)
        current_state[property] = value ? value : 'unset'
      end

      SYSLOG_SETTINGS_INTEGER_PROPS.each do |property|
        value = @syslog_settings.send(property)
        if value != 'unset'
          current_state[property] = value ? value.to_i : 'unset'
        else
          current_state[property] = value
        end
      end

      [current_state]
    end

    def update(context, name, should)
      validate_should(should)
      validate_syslog_logfile(should)
      context.notice("Setting '#{name}' with #{should.inspect}")
      @syslog_settings = Cisco::SyslogSettings.syslogsettings['default']
      tidy_up_syslog_logfile(should)

      SYSLOG_CONFIG_PROPS.each do |property|
        next unless should[property]
        # Other platforms require array for some types - Nexus does not
        should[property] = should[property][0] if should[property].is_a?(Array)
        # Call the AutoGen setters for the @syslog_settings node_utils object.
        should[property] = nil if should[property] == 'unset' || should[property] == -1
        @syslog_settings.send("#{property}=", should[property]) if @syslog_settings.respond_to?("#{property}=")
      end
    end

    def validate_syslog_logfile(should)
      raise Puppet::ResourceError,
            'This provider requires that a logfile_name and logfile_severity_level are both specified in order '\
            'to set logfile settings.' if should[:logfile_name].to_s != 'unset' &&
                                         ((should[:logfile_name] && !should[:logfile_severity_level]) ||
                                         (should[:logfile_severity_level] && !should[:logfile_name]))
      raise Puppet::ResourceError,
            'This provider requires that a logfile_name is unset in order to unset logfile_severity_level' if should[:logfile_name].to_s != 'unset' &&
                                                                                                             (should[:logfile_severity_level].to_s == 'unset' ||
                                                                                                             should[:logfile_severity_level] == -1)
      raise Puppet::ResourceError,
            'This provider does not support setting the logfile_severity_level when logfile_name is unset' if should[:logfile_name].to_s == 'unset' &&
                                                                                                             (should[:logfile_severity_level] &&
                                                                                                             (should[:logfile_severity_level].to_s != 'unset' &&
                                                                                                             should[:logfile_severity_level] != -1))
      raise Puppet::ResourceError,
            'This provider requires that a logfile_name and logfile_severity_level are both specified in order '\
            'to set logfile_size.' if should[:logfile_size] && !should[:logfile_name] && !should[:logfile_severity_level]
    end

    def validate_should(should)
      raise Puppet::ResourceError,
            "This provider only supports a namevar of 'default'." unless should[:name].to_s == 'default'
      raise Puppet::ResourceError,
            "This provider does not support the 'enable' property. "\
            'Syslog servers are enabled implicitly when using the syslog_server resource.' if should[:enable]
      raise Puppet::ResourceError,
            "This provider does not support the 'vrf' property. " if should[:vrf]
    end

    def tidy_up_syslog_logfile(should)
      @syslog_settings = Cisco::SyslogSettings.syslogsettings['default']
      SYSLOG_CONFIG_PROPS.delete(:logfile_severity_level)
      SYSLOG_CONFIG_PROPS.delete(:logfile_name)
      SYSLOG_CONFIG_PROPS.delete(:logfile_size)

      # use the configured logfile name if logfile_name is not supplied
      unless should[:logfile_name]
        should[:logfile_name] = @syslog_settings.logfile_name
      end

      if should[:logfile_name] == 'unset'
        should[:logfile_severity_level] = nil
        should[:logfile_name] = nil
        should[:logfile_size] = nil
      else
        return unless (should[:logfile_severity_level] && should[:logfile_name]) || (@syslog_settings.logfile_severity_level && @syslog_settings.logfile_name)

        # use the configured logfile_severity_level name if logfile_severity_level is not supplied
        unless should[:logfile_severity_level]
          should[:logfile_severity_level] = @syslog_settings.logfile_severity_level
        end
      end

      if should[:logfile_size] && should[:logfile_size] != -1
        should[:logfile_size] = "size #{should[:logfile_size]}"
      else
        should[:logfile_size] = ''
      end

      @syslog_settings.send('logfile_name=',
                            should[:logfile_name],
                            should[:logfile_severity_level],
                            should[:logfile_size]) if @syslog_settings.respond_to?('logfile_name=')
    end
  end
end
