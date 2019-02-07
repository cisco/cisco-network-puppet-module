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
  # Implementation for the radius_global type using the Resource API.
  class Puppet::Provider::RadiusGlobal::CiscoNexus
    def canonicalize(_context, resources)
      require 'cisco_node_utils'
      resources.each do |resource|
        resource[:key] = resource[:key].gsub(/\A"|"\Z/, '') if resource[:key]
        resource.each do |k, v|
          unless k == :key_format
            resource[k] = 'unset' if v.nil? || v == (nil || -1)
          end
          if k == :timeout && (v == 'unset' || v == -1)
            resource[k] = 5
          end
          if k == :retransmit_count && (v == 'unset' || v == -1)
            resource[k] = 1
          end
        end
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
      @radius_global = Cisco::RadiusGlobal.new('default')

      current_state = {
        name:             'default',
        timeout:          @radius_global.timeout ? @radius_global.timeout : 'unset',
        retransmit_count: @radius_global.retransmit_count ? @radius_global.retransmit_count : 'unset',
        key:              @radius_global.key ? @radius_global.key.gsub(/\A"|"\Z/, '') : 'unset',
        # Only return the key format if there is a key configured
        key_format:       @radius_global.key.nil? || @radius_global.key.empty? ? nil : @radius_global.key_format,
        source_interface: @radius_global.source_interface.nil? || @radius_global.source_interface.empty? ? ['unset'] : [@radius_global.source_interface],
      }

      [current_state]
    end

    def update(context, name, should)
      validate_should(should)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @radius_global = Cisco::RadiusGlobal.new('default')
      [:retransmit_count, :source_interface, :timeout].each do |property|
        next unless should[property]
        # Other platforms require array for some types - Nexus does not
        should[property] = should[property][0] if should[property].is_a?(Array)
        should[property] = nil if should[property] == 'unset'
        @radius_global.send("#{property}=", should[property]) if @radius_global.respond_to?("#{property}=")
      end

      # Handle key and keyformat setting
      @radius_global.key_set(munge(should[:key]), should[:key_format])
    end

    def munge(value)
      if value.eql?('unset')
        nil
      else
        value
      end
    end

    def validate_should(should)
      raise Puppet::ResourceError, '`name` must be `default`' if should[:name] != 'default'
      raise Puppet::ResourceError, 'This provider does not support the `enable` property.' if should[:enable]
      raise Puppet::ResourceError, 'The `key` property must be set when specifying `key_format`.' if should[:key_format] && (!should[:key] || should[:key] == 'unset')
      raise Puppet::ResourceError, 'This provider does not support the `vrf` property.' if should[:vrf]
    end
  end
end
