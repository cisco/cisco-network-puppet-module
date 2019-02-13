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
  # Implementation for the banner type using the Resource API.
  class Puppet::Provider::Banner::CiscoNexus
    def canonicalize(_context, resources)
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        is = change[:is]
        should = change[:should]

        if should[:motd] != is[:motd]
          update(context, name, should)
        end
      end
    end

    def get(_context, _names=nil)
      require 'cisco_node_utils'
      @banner = Cisco::Banner.new('default')

      current_state = {
        name: 'default',
        motd: "#{@banner.motd}",
      }

      [current_state]
    end

    def update(context, name, should)
      validate_name(name)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @banner = Cisco::Banner.new('default')
      @banner.motd = should[:motd]
    end

    def validate_name(name)
      raise Puppet::ResourceError, '`name` must be `default`' if name != 'default'
    end
  end
end
