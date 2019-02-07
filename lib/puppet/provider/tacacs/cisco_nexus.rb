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
  # Implementation for the tacacs type using the Resource API.
  class Puppet::Provider::Tacacs::CiscoNexus
    def canonicalize(_context, resources)
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]

        if should[:enable]
          update(context, name, should)
        else
          delete(context, name)
        end
      end
    end

    def get(_context, _tacacs=nil)
      require 'cisco_node_utils'
      current_state = {
        name:   'default',
        enable: Cisco::TacacsServer.enabled,
      }

      [current_state]
    end

    def delete(context, name)
      context.notice("Disabling tacacs '#{name}' service")
      @tacacs = Cisco::TacacsServer.new(false)
      @tacacs.destroy
    end

    def update(context, name, should)
      context.notice("Enabling tacacs '#{name}' with #{should.inspect}")
      @tacacs = Cisco::TacacsServer.new(false)
      @tacacs.enable
    end
  end
end
