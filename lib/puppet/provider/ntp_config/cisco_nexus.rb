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
  # Implementation for the ntp_config type using the Resource API.
  class Puppet::Provider::NtpConfig::CiscoNexus
    def canonicalize(_context, resources)
      require 'cisco_node_utils'

      resources.each do |resource|
        resource[:trusted_key] = resource[:trusted_key].sort_by(&:to_i).map(&:to_s) if resource[:trusted_key]
      end
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        is = change[:is]
        should = change[:should]

        if should != is
          update(context, name, should)
        end
      end
    end

    def get(_context, _names=nil)
      require 'cisco_node_utils'

      @ntp_config = Cisco::NtpConfig.ntpconfigs['default']

      current_state = {
        name:             'default',
        authenticate:     @ntp_config.authenticate ? true : false,
        source_interface: @ntp_config.source_interface ? @ntp_config.source_interface : 'unset',
        trusted_key:      @ntp_config.trusted_key ? @ntp_config.trusted_key : ['unset'],
      }

      [current_state]
    end

    def update(context, name, should)
      validate_should(should)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @ntp_config = Cisco::NtpConfig.ntpconfigs[name]
      @ntp_config.authenticate = should[:authenticate] unless should[:authenticate].nil?
      @ntp_config.source_interface = should[:source_interface] == 'unset' ? nil : should[:source_interface]
      handle_trusted_keys(should[:trusted_key]) if should[:trusted_key]
    end

    def handle_trusted_keys(should_trusted_keys)
      @ntp_config = Cisco::NtpConfig.ntpconfigs['default']
      if should_trusted_keys == ['unset']
        remove = @ntp_config.trusted_key.map(&:to_s) if @ntp_config.trusted_key
      elsif @ntp_config.trusted_key
        # Otherwise calculate the delta
        remove = @ntp_config.trusted_key.map(&:to_s).sort -
                 should_trusted_keys.map(&:to_s).sort
        remove.delete('unset')
      end

      remove.each do |key|
        @ntp_config.trusted_key_set(false, key) unless key == 'unset'
      end if remove
      # Get array of keys to add
      return if should_trusted_keys == ['unset']
      if @ntp_config.trusted_key
        add = should_trusted_keys.map(&:to_s).sort -
              @ntp_config.trusted_key.map(&:to_s).sort
      else
        add = should_trusted_keys.map(&:to_s).sort
      end
      remove.delete('unset') if remove
      add.each do |key|
        @ntp_config.trusted_key_set(true, key)
      end
    end

    def validate_should(should)
      raise Puppet::ResourceError, 'Invalid name, `name` must be `default`' if should[:name] != 'default'
      raise Puppet::ResourceError, 'Invalid source interface, `source_interface` must not contain any spaces' if should[:source_interface] && should[:source_interface] =~ /\s+/
      raise Puppet::ResourceError, 'Invalid source interface, `source_interface` must not contain any uppercase characters' if should[:source_interface] && should[:source_interface] =~ /[A-Z]+/
    end
  end
end
