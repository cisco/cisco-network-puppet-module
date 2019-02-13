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
#
# See README-develop-beaker-scripts.md (Section: Test Script Variable Reference)
# for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_dhcp_relay_global',
  ensurable:        false,
}

skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    ipv4_information_option:           'default',
    ipv4_information_option_trust:     'default',
    ipv4_information_option_vpn:       'default',
    ipv4_information_trust_all:        'default',
    ipv4_relay:                        'default',
    ipv4_smart_relay:                  'default',
    ipv4_src_addr_hsrp:                'default',
    ipv4_src_intf:                     'default',
    ipv4_sub_option_circuit_id_custom: 'default',
    ipv4_sub_option_circuit_id_string: 'default',
    ipv4_sub_option_cisco:             'default',
    ipv6_option_cisco:                 'default',
    ipv6_option_vpn:                   'default',
    ipv6_relay:                        'default',
    ipv6_src_intf:                     'default',
  },
  code:           [0, 2],
  resource:       {
    ipv4_information_option:           'false',
    ipv4_information_option_trust:     'false',
    ipv4_information_option_vpn:       'false',
    ipv4_information_trust_all:        'false',
    ipv4_relay:                        'true',
    ipv4_smart_relay:                  'false',
    ipv4_src_addr_hsrp:                'false',
    ipv4_src_intf:                     'false',
    ipv4_sub_option_circuit_id_custom: 'false',
    ipv4_sub_option_circuit_id_string: 'false',
    ipv4_sub_option_cisco:             'false',
    ipv6_option_cisco:                 'false',
    ipv6_option_vpn:                   'false',
    ipv6_relay:                        'true',
    ipv6_src_intf:                     'false',
  },
}

# Per platform default values
resource = {
  n56k: {
    ipv4_relay: 'false',
    ipv6_relay: 'false',
  }
}

tests[:default][:resource].merge!(resource[:n56k]) if platform[/n(5|6)k/]

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  'default',
  manifest_props: {
    ipv4_information_option:           'true',
    ipv4_information_option_trust:     'true',
    ipv4_information_option_vpn:       'true',
    ipv4_information_trust_all:        'true',
    ipv4_relay:                        'false',
    ipv4_smart_relay:                  'true',
    ipv4_src_addr_hsrp:                'true',
    ipv4_src_intf:                     'port-channel200',
    ipv4_sub_option_circuit_id_custom: 'true',
    ipv4_sub_option_circuit_id_string: 'WORD',
    ipv4_sub_option_cisco:             'true',
    ipv6_option_cisco:                 'true',
    ipv6_option_vpn:                   'true',
    ipv6_relay:                        'false',
    ipv6_src_intf:                     'loopback1',
  },
}

# Per platform non default values
manifest = {
  n56k: {
    ipv4_relay: 'true',
    ipv6_relay: 'true',
  }
}

tests[:non_default][:manifest_props].merge!(manifest[:n56k]) if platform[/n(5|6)k/]

# class to contain the test_dependencies specific to this test case
class TestDhcpRelayGlobal < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    if ctx.platform[/n3k$/]
      unprops <<
        :ipv4_src_addr_hsrp
    elsif ctx.platform[/n(5|6)k/]
      unprops <<
        :ipv4_information_option_trust <<
        :ipv4_information_trust_all <<
        :ipv4_sub_option_circuit_id_string <<
        :ipv6_option_cisco
    elsif ctx.platform[/n7k/]
      unprops <<
        :ipv4_sub_option_circuit_id_custom <<
        :ipv4_sub_option_circuit_id_string
    elsif ctx.platform[/n(3|9)k-f/]
      unprops <<
        :ipv4_src_addr_hsrp <<
        :ipv4_sub_option_circuit_id_custom <<
        :ipv4_sub_option_circuit_id_string
    elsif ctx.platform[/n9k/]
      unprops <<
        :ipv4_src_addr_hsrp
    end
    unprops << :ipv4_sub_option_circuit_id_custom if ctx.nexus_image['I2']
    unprops
  end

  def self.version_unsupported_properties(ctx, _tests, _id)
    unprops = {}
    unprops[:ipv4_sub_option_circuit_id_string] = '7.0.3.I6.1' if ctx.platform[/n9k$/]
    unprops
  end
end

def cleanup(agent)
  test_set(agent, 'no feature dhcp')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, harness_class: TestDhcpRelayGlobal)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  cleanup(agent)
  test_harness_run(tests, :non_default, harness_class: TestDhcpRelayGlobal)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
