begin
  require 'puppet/resource_api/transport/wrapper'
rescue LoadError
  require 'puppet_x/cisco_nexus/transport_shim'
end
# Copyright (c) 2013-2019 Cisco and/or its affiliates.
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
module Puppet::Util::NetworkDevice::Cisco_nexus # rubocop:disable Style/ClassAndModuleCamelCase
  # Wrapper class for `lib/puppet/transport/cisco_nexus.rb` to allow backwards compatiblity
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def backwards_compatible_schema_load(url_or_config)
      if url_or_config.is_a? String
        url = URI.parse(url_or_config)
        raise "Unexpected url '#{url_or_config}' found. Only file:/// URLs for configuration supported at the moment." unless url.scheme == 'file'
        raise "Trying to load config from '#{url.path}, but file does not exist." if url && !File.exist?(url.path)
        config = self.class.deep_symbolize(Hocon.load(url.path, syntax: Hocon::ConfigSyntax::HOCON) || {})
      elsif url_or_config.is_a? Hash
        config = url_or_config
      end

      # Allow for backwards compatibility with the fields
      # - address  (map to host)
      # - username (map to user)
      if config[:address]
        unless config[:host]
          config[:host] = config[:address]
        end
        config.delete(:address)
      end

      if config[:username]
        unless config[:user]
          config[:user] = config[:username]
        end
        config.delete(:username)
      end
      config
    end

    def initialize(url_or_config, _options={})
      super('cisco_nexus', backwards_compatible_schema_load(url_or_config))
    end
  end
end
