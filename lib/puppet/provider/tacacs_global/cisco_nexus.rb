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
  # Implementation for the tacacs_global type using the Resource API.
  class Puppet::Provider::TacacsGlobal::CiscoNexus
    def canonicalize(_context, resources)
      resources.each do |resource|
        if resource[:key]
          resource[:key] = resource[:key].gsub(/\A"|"\Z/, '')
        else
          resource[:key] = 'unset'
        end
        unless resource[:timeout]
          resource[:timeout] = 'unset'
        end
        resource.each do |k, v|
          unless k == :key_format
            resource[k] = 'unset' if v.nil? || v == (nil || -1)
          end
        end
      end
    end

    def munge(value)
      if value.nil?
        nil
      elsif value.is_a?(String) && value.eql?('unset')
        nil
      elsif value.is_a?(Integer) && value.eql?(-1)
        nil
      else
        value
      end
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

    def get(_context, _tacacs=nil)
      require 'cisco_node_utils'
      @tacacs_global = Cisco::TacacsGlobal.tacacs_global
      current_states = []
      @tacacs_global.each do |name, instance|
        current_states << {
          name:             name,
          timeout:          instance.timeout ? instance.timeout.to_i : 'unset',
          key:              instance.key.nil? || instance.key.empty? ? 'unset' : instance.key.gsub(/\A"|"\Z/, ''),
          # Only return the key format if there is a key configured
          key_format:       instance.key.nil? || instance.key.empty? || instance.key == 'unset' ? nil : instance.key_format,
          # source_interface for NXOS devices will be singular, type however is for an array
          source_interface: instance.source_interface.nil? || instance.source_interface.empty? ? ['unset'] : [instance.source_interface],
        }
      end
      current_states
    end

    def validate_should(should)
      raise Puppet::ResourceError, "This provider only supports namevar of 'default'." unless should[:name] == 'default'
      raise Puppet::ResourceError, "The 'key' property must be set when specifying 'key_format'." if should[:key_format] && !should[:key]
    end

    def update(context, name, should)
      validate_should(should)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @tacacs_global = Cisco::TacacsGlobal.tacacs_global
      [:timeout, :source_interface].each do |property|
        next unless should[property]
        should[property] = munge(should[property][0]) if should[property].is_a?(Array)
        @tacacs_global[name].send("#{property}=", should[property]) if @tacacs_global[name].respond_to?("#{property}=")
      end

      @tacacs_global[name].encryption_key_set(munge(should[:key_format]), munge(should[:key])) unless should[:key].nil?
    end
  end
end
