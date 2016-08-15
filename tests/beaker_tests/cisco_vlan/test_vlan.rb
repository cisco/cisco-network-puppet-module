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
#
# 'test_vlan' tests standard and extended vlan properties.
#
# (See 'test_interface_private_vlan' for interface-related private-vlan tests)
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  resource_name:    'cisco_vlan',
  operating_system: 'nexus',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:default_standard] = {
  desc:           '1.1 Default standard vlan properties',
  title_pattern:  '128',
  manifest_props: {
    fabric_control: 'default',
    mapped_vni:     'default',
    shutdown:       'default',
    state:          'default',
    # vlan_name: Does not support default but resource displays default name.
  },
  resource:       {
    fabric_control: 'false',
    shutdown:       'false',
    state:          'active',
    vlan_name:      'VLAN0128',
  },
}

tests[:non_default_standard] = {
  desc:           '1.2 Non Default standard vlan properties',
  title_pattern:  '128',
  manifest_props: {
    fabric_control: 'true',
    mapped_vni:     '128000',
    shutdown:       'true',
    state:          'suspend',
    vlan_name:      'Standard_Configured_By_Puppet',
  },
}

tests[:default_extended] = {
  desc:           '1.3 Default extended vlan properties',
  title_pattern:  '2400',
  manifest_props: {
    fabric_control: 'default',
    mapped_vni:     'default',
    shutdown:       'default',
    state:          'default',
    # vlan_name: Does not support default but resource displays default name.
  },
  resource:       {
    fabric_control: 'false',
    shutdown:       'false',
    state:          'active',
    vlan_name:      'VLAN2400',
  },
}

tests[:non_default_extended] = {
  desc:           '1.4 Non Default extended vlan properties',
  title_pattern:  '2400',
  manifest_props: {
    fabric_control: 'true',
    mapped_vni:     '4096',
    shutdown:       'false',
    state:          'suspend',
    vlan_name:      'Extended_Configured_By_Puppet',
  },
}
# State cannot be modified for extended vlans on N5k and N6k platforms.
tests[:non_default_extended][:manifest_props].delete(:state) if platform[/n(5|6)k/]

if platform[/n3k/]
  tests[:vn_segment_unsupported] =
    resource_probe(agent,
                   'cisco_vlan 128 mapped_vni=128000',
                   'Hardware is not capable of supporting vn-segment-vlan-based feature')
end

def unsupported_properties(tests, _id)
  unprops = []

  unprops << :mapped_vni if platform[/n7k/] || tests[:vn_segment_unsupported]

  unprops << :fabric_control unless platform[/n7k/]

  logger.info("  unprops: #{unprops}") unless unprops.empty?
  unprops
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  vdc_limit_f3_no_intf_needed(:set)
  remove_all_vlans(agent)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Property Testing")
  test_harness_run(tests, :default_standard)
  test_harness_run(tests, :non_default_standard)

  # Cleanup between standard and extended vlan tests.
  remove_all_vlans(agent)
  test_harness_run(tests, :default_extended)
  test_harness_run(tests, :non_default_extended)

  remove_all_vlans(agent)
  vdc_limit_f3_no_intf_needed(:clear)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
