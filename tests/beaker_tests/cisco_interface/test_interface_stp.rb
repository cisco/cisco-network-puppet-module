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
  resource_name:    'cisco_interface',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  intf_type:      'ethernet',
  preclean:       'cisco_interface',
  manifest_props: {
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
    'stp_bpdufilter'    => 'false',
    'stp_bpduguard'     => 'false',
    'stp_cost'          => 'auto',
    'stp_guard'         => 'false',
    'stp_link_type'     => 'auto',
    'stp_port_priority' => '128',
    'stp_port_type'     => 'false',
    # 'stp_mst_cost' is nil when default
    # 'stp_mst_port_priority' is nil when default
    # 'stp_vlan_cost' is nil when default
    # 'stp_vlan_port_priority' is nil when default
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

stp_mst_cost_ndp = Array[%w(0,2-4,6,8-12 1000), %w(1000 2568)]
stp_mst_port_priority_ndp = Array[%w(0,2-11,20-33 64), %w(1111 160)]
stp_vlan_cost_ndp = Array[%w(1-4,6,8-12 1000), %w(1000 2568)]
stp_vlan_port_priority_ndp = Array[%w(1-11,20-33 64), %w(1111 160)]
tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  intf_type:      'ethernet',
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
    stp_mst_cost:           "#{stp_mst_cost_ndp}",
    stp_mst_port_priority:  "#{stp_mst_port_priority_ndp}",
    stp_vlan_cost:          "#{stp_vlan_cost_ndp}",
    stp_vlan_port_priority: "#{stp_vlan_port_priority_ndp}",
  },
}

# Create actual manifest for a given test scenario.
def build_manifest_interface(tests, id)
  manifest = prop_hash_to_manifest(tests[id][:manifest_props])
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
  end
  create_interface_title(tests, id)

  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  \nnode default {
  cisco_interface { '#{tests[id][:title_pattern]}':
    #{state}\n#{manifest}
  }\n}\nEOF"

  cmd = PUPPET_BINPATH +
        "resource cisco_interface '#{tests[id][:title_pattern]}'"
  tests[id][:resource_cmd] = cmd
end

# Wrapper for interface specific settings prior to calling the
# common test_harness.
def test_harness_interface(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_interface(tests, id)

  tests[id][:code] = [0, 2]

  interface_cleanup(agent, tests[id][:title_pattern]) if tests[id][:preclean]

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  resource_absent_cleanup(agent, 'cisco_bridge_domain',
                          'bridge-domain CLEANUP :: ')
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_interface(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_interface(tests, :non_default)

  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
