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
# 'test_interface_private_vlan' tests private_vlan interface properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  platform:         'n(3|5|6|7|9)k',
  resource_name:    'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Assign a test interface.
intf = find_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:               '1.1 Default Properties',
  title_pattern:      intf,
  code:               [0],
  preclean_intf:      true,
  sys_def_switchport: true,
  manifest_props:     {
    # switchport_mode_private_vlan_host:             no default
    switchport_mode_private_vlan_host_association:  'default',
    switchport_mode_private_vlan_trunk_promiscuous: 'default',
    switchport_mode_private_vlan_trunk_secondary:   'default',
    # TBD: BROKEN. Should support 'default' but sends literal 'default'
    # instead of doing default behavior.
    # switchport_private_vlan_trunk_allowed_vlan:     'default',
    switchport_private_vlan_association_trunk:      'default',
    switchport_private_vlan_mapping_trunk:          'default',
    switchport_private_vlan_trunk_native_vlan:      'default',
  },
  resource:           {
    switchport_mode_private_vlan_host:              'disabled',
    # switchport_mode_private_vlan_host_association: nil,
    switchport_mode_private_vlan_trunk_promiscuous: 'false',
    switchport_mode_private_vlan_trunk_secondary:   'false',
    # switchport_private_vlan_trunk_allowed_vlan:    nil,
    # switchport_private_vlan_association_trunk:     nil,
    # switchport_private_vlan_mapping_trunk:         nil,
    switchport_private_vlan_trunk_native_vlan:      '1',
  },
}

# allowed = ['100', '102-103', '105']
assoc = %w(106 107)
tests[:port_mode_host] = {
  desc:               '2.1 Port Mode Host',
  title_pattern:      intf,
  preclean_intf:      true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_host:             :host,
    switchport_mode_private_vlan_host_association: assoc,
    switchport_private_vlan_trunk_native_vlan:     100,
    # switchport_private_vlan_trunk_allowed_vlan:    allowed,
  },
  resource:           {
    switchport_mode_private_vlan_host:             'host',
    switchport_mode_private_vlan_host_association: "#{assoc}",
    switchport_private_vlan_trunk_native_vlan:     '100',
    # TBD: BROKEN: Idempotence issues. This implementation is broken:
    #   ['100', '102-103', '105'] vs '100 102-103 105'
    # Why does it transform from multi-member list to string???
    # switchport_private_vlan_trunk_allowed_vlan:    "#{allowed}",
  },
}

# Clone the test hash above to retest using 'promiscuous' mode
t = tests[:port_mode_promiscuous] = tests[:port_mode_host].clone
t[:desc] = '2.2 Port Mode Promiscuous'
t[:manifest_props][:switchport_mode_private_vlan_host] = :promiscuous
t[:resource][:switchport_mode_private_vlan_host] = :promiscuous

tests[:trunk_secondary] = {
  desc:               '3.1 Trunk Secondary',
  platform:           'n(5|6|7|9)k',
  title_pattern:      intf,
  preclean_intf:      true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_trunk_secondary: true,
    switchport_private_vlan_association_trunk:    %w(100 102),
    switchport_private_vlan_mapping_trunk:        ['100', '101,104-105'],
  },
  resource:           {
    switchport_mode_private_vlan_trunk_secondary: 'true',
    # TBD: BROKEN. It inputs a multi-member list but normalizes to a
    # single index? ['100 102'] is wrong but we will keep this temporarily to
    # show the broken behavior.
    switchport_private_vlan_association_trunk:    "['100 102']",
    # TBD: BROKEN. Same as above.
    switchport_private_vlan_mapping_trunk:        "['100 101,104-105']",
  },
}
tests[:trunk_promiscuous] = {
  desc:               '3.2 Trunk Promiscuous',
  platform:           'n(5|6|7|9)k',
  title_pattern:      intf,
  preclean_intf:      true,
  sys_def_switchport: true,
  manifest_props:     {
    switchport_mode_private_vlan_trunk_promiscuous: true,
    switchport_private_vlan_association_trunk:      %w(100 102),
    switchport_private_vlan_mapping_trunk:          ['100', '101,104-105'],
  },
  resource:           {
    switchport_mode_private_vlan_trunk_promiscuous: 'true',
    # TBD: BROKEN. It inputs a multi-member list but normalizes to a
    # single index? ['100 102'] is wrong but we will keep this temporarily to
    # show the broken behavior.
    switchport_private_vlan_association_trunk:      "['100 102']",
    # TBD: BROKEN. Same as above.
    switchport_private_vlan_mapping_trunk:          "['100 101,104-105']",
  },
}

svi = 'vlan13'
mapping = %w(108-109)
tests[:svi_mapping] = {
  desc:           '4.1 SVI Private-Vlan Mapping',
  platform:       'n(5|6|7|9)k',
  title_pattern:  svi,
  preclean_intf:  true,
  manifest_props: {
    private_vlan_mapping: mapping
  },
  resource:       {
    private_vlan_mapping: "#{mapping}"
  },
}

# CSCuz58517 workaround: 'private-vlan association trunk' doesn't get
# removed by 'default interface' on some platforms.
def pvlan_assoc_cleanup(agent, intf)
  resource_set(agent,
               { name:     'cisco_interface',
                 title:    intf,
                 property: 'switchport_mode',
                 value:    'disabled',
               },
               "  * Remove stale private-vlan configs from #{intf}")
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  pvlan_assoc_cleanup(agent, intf)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Defaults")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Port Mode")
  test_harness_run(tests, :port_mode_host)
  test_harness_run(tests, :port_mode_promiscuous)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Trunk Mode")
  test_harness_run(tests, :trunk_secondary)
  pvlan_assoc_cleanup(agent, intf)
  test_harness_run(tests, :trunk_promiscuous)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. SVI Mapping")
  test_harness_run(tests, :svi_mapping)

  # -------------------------------------------------------------------
  pvlan_assoc_cleanup(agent, intf)
  interface_cleanup(agent, intf)
  remove_interface(agent, svi)
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
