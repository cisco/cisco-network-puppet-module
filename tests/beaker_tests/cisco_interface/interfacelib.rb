###############################################################################
# Copyright (c) 2016 Cisco and/or its affiliates.
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
###############################################################################
# Interface test library
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# class to contain the test_harness_dependencies
class Interfacelib < BaseHarness
  def self.test_harness_dependencies(ctx, tests, id)
    ctx.logger.info('  * Process test_harness_dependencies (interfacelib)')

    # System-level switchport dependencies
    if ctx.operating_system == 'nexus'
      ctx.config_system_default_switchport?(tests, id)
      ctx.config_system_default_switchport_shutdown?(tests, id)
    end

    # Misc dependencies
    ctx.config_acl?(tests, id)
    config_anycast_gateway_mac?(ctx, tests, id)
    ctx.config_bridge_domain?(tests, id)

    # Various Cleanups
    return unless tests[id][:preclean_intf]
    intf = tests[id][:title_pattern]
    if intf[/ethernet/i]
      ctx.interface_cleanup(ctx.agent, intf)
    else
      ctx.remove_interface(ctx.agent, intf)
    end
  end

  # A global 'anycast gateway mac' is required for some SVI properties
  def self.config_anycast_gateway_mac?(ctx, tests, id)
    return unless tests[id].key?(:anycast_gateway_mac)
    agent = tests[:agent]

    stdout = ctx.test_get(agent, 'incl fabric.forwarding')

    return if stdout && stdout[/anycast-gateway-mac/]
    cmd = ['cisco_overlay_global', 'default', 'anycast_gateway_mac', '1.1.1']
    ctx.resource_set(agent, cmd, 'fabric forwarding anycast-gateway-mac 1.1.1')
  end
end
