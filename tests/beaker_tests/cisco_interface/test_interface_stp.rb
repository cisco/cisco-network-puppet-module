###############################################################################
# Copyright (c) 2016-2017 Cisco and/or its affiliates.
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
#
# 'test_interface_stp' primarily tests STP interface properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
intf = find_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  code:           [0, 2],
  manifest_props: {
    description:            'Test default properties',
    switchport_mode:        'access',
    stp_bpdufilter:         'default',
    stp_bpduguard:          'default',
    stp_cost:               'default',
    stp_guard:              'default',
    stp_link_type:          'default',
    stp_port_priority:      'default',
    stp_port_type:          'default',
    stp_mst_cost:           'default',
    stp_mst_port_priority:  'default',
    stp_vlan_cost:          'default',
    stp_vlan_port_priority: 'default',
  },
  resource:       {
    'description'       => 'Test default properties',
    'stp_cost'          => 'auto',
    'stp_link_type'     => 'auto',
    'stp_port_priority' => '128',
    # 'stp_bpdufilter' is nil when default
    # 'stp_bpduguard' is nil when default
    # 'stp_guard' is nil when default
    # 'stp_mst_cost' is nil when default
    # 'stp_mst_port_priority' is nil when default
    # 'stp_port_type' is nil when default
    # 'stp_vlan_cost' is nil when default
    # 'stp_vlan_port_priority' is nil when default
  },
}

stp_mst_cost_ndp = Array[%w(0,2-4,6,8-12 1000), %w(1000 2568)]
stp_mst_port_priority_ndp = Array[%w(0,2-11,20-33 64), %w(1111 160)]
stp_vlan_cost_ndp = Array[%w(1-4,6,8-12 1000), %w(1000 2568)]
stp_vlan_port_priority_ndp = Array[%w(1-11,20-33 64), %w(1111 160)]
tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  intf,
  manifest_props: {
    switchport_mode:        'trunk',
    stp_bpdufilter:         'enable',
    stp_bpduguard:          'enable',
    stp_cost:               '2000',
    stp_guard:              'loop',
    stp_link_type:          'shared',
    stp_port_priority:      '64',
    stp_port_type:          'network',
    stp_mst_cost:           stp_mst_cost_ndp,
    stp_mst_port_priority:  stp_mst_port_priority_ndp,
    stp_vlan_cost:          stp_vlan_cost_ndp,
    stp_vlan_port_priority: stp_vlan_port_priority_ndp,
  },
  resource:       {
    switchport_mode:        'trunk',
    stp_bpdufilter:         'enable',
    stp_bpduguard:          'enable',
    stp_cost:               '2000',
    stp_guard:              'loop',
    stp_link_type:          'shared',
    stp_port_priority:      '64',
    stp_port_type:          'network',
    stp_mst_cost:           "#{stp_mst_cost_ndp}",
    stp_mst_port_priority:  "#{stp_mst_port_priority_ndp}",
    stp_vlan_cost:          "#{stp_vlan_cost_ndp}",
    stp_vlan_port_priority: "#{stp_vlan_port_priority_ndp}",
  },
}

def cleanup(agent, intf)
  remove_all_vlans(agent)
  interface_cleanup(agent, intf)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent, intf) }
  cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
