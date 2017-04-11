# rubocop:disable Style/FileName
###############################################################################
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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
# 'test_interface_L2' primarily tests layer 2 interface properties.
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

# TBD: Consider adding switchport_mode => 'default' tests.

# Test hash test cases
tests[:default_access] = {
  desc:               "1.1 Default 'access' Properties",
  title_pattern:      intf,
  code:               [0, 2],
  preclean_intf:      true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:                     'default',
    switchport_autostate_exclude: 'default',
    switchport_mode:              'access',
  },
  resource:           {
    shutdown:                     'true',
    switchport_autostate_exclude: 'false',
    switchport_mode:              'access',
  },
}

tests[:non_default_access] = {
  desc:               "1.2 Non Default 'access' Properties",
  title_pattern:      intf,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    access_vlan:                  '128',
    shutdown:                     'false',
    switchport_autostate_exclude: 'true',
    switchport_mode:              'access',
  },
}

tests[:default_trunk] = {
  desc:               "2.1 Default 'trunk' Properties",
  title_pattern:      intf,
  preclean_intf:      true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:                      'default',
    load_interval_counter_1_delay: 'default',
    load_interval_counter_2_delay: 'default',
    load_interval_counter_3_delay: 'default',
    storm_control_broadcast:       'default',
    storm_control_multicast:       'default',
    storm_control_unicast:         'default',
    switchport_autostate_exclude:  'default',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: 'default',
    switchport_trunk_native_vlan:  'default',

  },
  resource:           {
    shutdown:                      'true',
    load_interval_counter_1_delay: '30',
    load_interval_counter_2_delay: '300',
    load_interval_counter_3_delay: 'false',
    storm_control_broadcast:       '100.00',
    storm_control_multicast:       '100.00',
    storm_control_unicast:         '100.00',
    switchport_autostate_exclude:  'false',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: '1-4094',
    switchport_trunk_native_vlan:  '1',
  },
}

tests[:non_default_trunk] = {
  desc:               "2.2 Non Default 'trunk' Properties",
  title_pattern:      intf,
  preclean_intf:      true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:                      'false',
    load_interval_counter_1_delay: '200',
    load_interval_counter_2_delay: '100',
    load_interval_counter_3_delay: '150',
    storm_control_broadcast:       '22.22',
    storm_control_multicast:       '44.44',
    storm_control_unicast:         '66.66',
    switchport_autostate_exclude:  'true',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: '30-33,40,100',
    switchport_trunk_native_vlan:  '20',
    switchport_vtp:                'false',
  },
}

tests[:purge] = {
  desc:           '2.3 Purge Properties',
  title_pattern:  intf,
  manifest_props: {
    purge_config: 'true'
  },
}

def unsupported_properties(_tests, _id)
  unprops = []
  unprops <<
    :storm_control_broadcast <<
    :storm_control_multicast if platform == 'n7k'
  unprops
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    interface_cleanup(agent, intf)
    system_default_switchport(agent, false)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. 'access' Property Testing")
  test_harness_run(tests, :default_access)
  test_harness_run(tests, :non_default_access)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. 'trunk' Property Testing")
  test_harness_run(tests, :default_trunk)
  test_harness_run(tests, :non_default_trunk)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2.3 Purge_config Testing")
  test_harness_run(tests, :purge)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
