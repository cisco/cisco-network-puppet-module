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
  agent:         agent,
  master:        master,
  ensurable:     false,
  resource_name: 'cisco_snmp_server',
}

# for fretta running F3.2 or later, this is fixed
# for n7k running 8.3.1 or later, this is fixed
# it will fail if older versions are run
@def_pkt_size = platform[/n(3|7|9)k/] ? '1500' : '0'

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  code:           [0, 2],
  title_pattern:  'default',
  manifest_props: {
    aaa_user_cache_timeout: 'default',
    contact:                'default',
    global_enforce_priv:    'default',
    location:               'default',
    packet_size:            'default',
    protocol:               'default',
    tcp_session_auth:       'default',
  },
  resource:       {
    'aaa_user_cache_timeout' => '3600',
    # 'contact'              => n/a,
    'global_enforce_priv'    => 'false',
    # 'location'             => n/a,
    'packet_size'            => @def_pkt_size,
    'protocol'               => 'true',
    'tcp_session_auth'       => 'true',
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  'default',
  manifest_props: {
    aaa_user_cache_timeout: 1000,
    contact:                'beaker',
    global_enforce_priv:    true,
    location:               'beaker',
    packet_size:            2500,
    protocol:               false,
    tcp_session_auth:       false,
  },
}

def cleanup(agent)
  # Restore testbed to default state
  cmds = [
    'no snmp-server aaa-user cache-timeout 3600',
    'no snmp-server contact',
    'no snmp-server globalEnforcePriv',
    'no snmp-server location',
    'no snmp-server packetsize 3600',
    'snmp-server protocol enable',
    'snmp-server tcp-session',
  ].join(' ; ')
  test_set(agent, cmds)
end

# class to contain the test_dependencies specific to this test case
class TestSnmpServer < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    unprops << :packet_size if ctx.image?[/7.0.3.I2|I3/] # CSCuz14217
    unprops
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, harness_class: TestSnmpServer)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default, harness_class: TestSnmpServer)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
