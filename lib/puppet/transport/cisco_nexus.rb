
require 'cisco_node_utils'
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
module Puppet::Transport
  # Translates from puppet's credential store to nodeutil's environment
  class CiscoNexus
    def initialize(_context, config)
      unless Cisco::Environment.environments.empty?
        Cisco::Node.reset_instance # Clears the previous environment from nodeutil caches
      end
      Cisco::Environment.add_env('default',
                                 host:        config[:host],
                                 port:        config[:port],
                                 transport:   config[:transport],
                                 verify_mode: config[:verify_mode],
                                 username:    config[:user],
                                 password:    config[:password].unwrap,
                                )
    end

    def facts(_context)
      @facts ||= parse_device_facts
    end

    def parse_device_facts
      require 'facter/cisco_nexus'
      facts = {}

      facts['operatingsystem'] = 'nexus'
      facts['cisco_node_utils'] = CiscoNodeUtils::VERSION

      facts['cisco'] = Facter::CiscoNexus.platform_facts

      facts['hostname'] = Cisco::NodeUtil.node.host_name
      facts['operatingsystemrelease'] = facts['cisco']['images']['full_version']

      facts
    end

    def verify(_context)
      # This is a stub method
    end

    def close(_context)
      # This is a stub method
    end
  end
end
