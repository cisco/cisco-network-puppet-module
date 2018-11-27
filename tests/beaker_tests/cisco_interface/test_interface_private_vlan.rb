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
# 'test_interface_private_vlan' tests private-vlan interface properties.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
# The platform: key below must use an end of string anchor '$' in order to
# distinguish between 'n9k' and 'n9k-f' platform flavors.
tests = {
  agent:            agent,
  master:           master,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  platform:         'n(3|5|6|7|9)k$',
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
  code:               [0, 2],
  sys_def_switchport: true,
  manifest_props:     {
    description:                         'Test default private vlan properties',
    switchport_pvlan_host:               'default',
    switchport_pvlan_host_association:   'default',
    switchport_pvlan_mapping:            'default',
    switchport_pvlan_mapping_trunk:      'default',
    switchport_pvlan_promiscuous:        'default',
    switchport_pvlan_trunk_native_vlan:  'default',
    switchport_pvlan_trunk_allowed_vlan: 'default',
    switchport_pvlan_trunk_association:  'default',
    switchport_pvlan_trunk_promiscuous:  'default',
    switchport_pvlan_trunk_secondary:    'default',
  },
  resource:           {
    description:                         'Test default private vlan properties',
    switchport_pvlan_host:               'false',
    # switchport_pvlan_host_association:  nil,
    # switchport_pvlan_mapping:           nil,
    # switchport_pvlan_mapping_trunk:     nil,
    switchport_pvlan_promiscuous:        'false',
    switchport_pvlan_trunk_native_vlan:  '1',
    switchport_pvlan_trunk_allowed_vlan: 'none',
    # switchport_pvlan_trunk_association: nil,
    switchport_pvlan_trunk_promiscuous:  'false',
    switchport_pvlan_trunk_secondary:    'false',
  },
}

tests[:host] = {
  desc:           '2.1 Host',
  title_pattern:  intf,
  preclean_intf:  true,
  manifest_props: {
    switchport_pvlan_host:               true,
    switchport_pvlan_host_association:   %w(2 12),
    switchport_pvlan_trunk_allowed_vlan: '6, 5, 2, 12',
    switchport_pvlan_trunk_native_vlan:  42,
  },
  resource:       {
    switchport_pvlan_host:               'true',
    switchport_pvlan_host_association:   %w(2 12),
    switchport_pvlan_trunk_allowed_vlan: '2,5-6,12',
    switchport_pvlan_trunk_native_vlan:  '42',
  },
  dependency:     %(
    cisco_vlan { '12': pvlan_type => 'community' }
    cisco_vlan {  '2': pvlan_type => 'primary', pvlan_association => '12' }
  ),
}

tests[:promiscuous] = {
  desc:           '2.2 Promiscuous',
  title_pattern:  intf,
  manifest_props: {
    switchport_pvlan_promiscuous: true
  },
}

tests[:trunk_secondary] = {
  desc:           '3.1 Trunk Secondary',
  platform:       'n(5|6|7|9)k',
  title_pattern:  intf,
  preclean_intf:  true,
  manifest_props: {
    switchport_pvlan_trunk_association: [%w(4 14), %w(3 13)],
    switchport_pvlan_trunk_secondary:   true,
    switchport_pvlan_mapping_trunk:     [%w(7 17,27,37), %w(5 15)],
  },
  resource:       {
    switchport_pvlan_trunk_association: [%w(3 13), %w(4 14)],
    switchport_pvlan_trunk_secondary:   'true',
    switchport_pvlan_mapping_trunk:     [%w(5 15), %w(7 17,27,37)],
  },
  dependency:     %(
    cisco_vlan { '13': pvlan_type => 'isolated' }
    cisco_vlan { '14': pvlan_type => 'isolated' }
    cisco_vlan {  '3': pvlan_type => 'primary', pvlan_association => '13' }
    cisco_vlan {  '4': pvlan_type => 'primary', pvlan_association => '14' }

    cisco_vlan { '15': pvlan_type => 'community' }
    cisco_vlan {  '5': pvlan_type => 'primary', pvlan_association => '15' }

    cisco_vlan { '17': pvlan_type => 'community' }
    cisco_vlan { '27': pvlan_type => 'community' }
    cisco_vlan { '37': pvlan_type => 'community' }
    cisco_vlan {  '7': pvlan_type => 'primary', pvlan_association => '17,27,37'}
  ),
}

tests[:trunk_promiscuous] = {
  desc:           '3.2 Trunk Promiscuous',
  platform:       'n(5|6|7|9)k',
  title_pattern:  intf,
  manifest_props: {
    switchport_pvlan_trunk_promiscuous: true
  },
}

svi = 'vlan13'
tests[:svi_mapping] = {
  desc:           '4.1 SVI Private-Vlan Mapping',
  platform:       'n(5|6|7|9)k',
  title_pattern:  svi,
  preclean_intf:  true,
  manifest_props: {
    pvlan_mapping: %w(108-109)
  },
}

# class to contain the test_dependencies specific to this test case
class TestInterfacePrivateVlan < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    if ctx.platform[/n3k$/]
      unprops <<
        :switchport_pvlan_mapping_trunk <<
        :switchport_pvlan_trunk_association <<
        :switchport_pvlan_trunk_promiscuous <<
        :switchport_pvlan_trunk_secondary
    end
    unprops
  end

  def self.dependency_manifest(_ctx, tests, id)
    tests[id][:dependency] if tests[id][:dependency]
  end
end

def vtp_cleanup(agent)
  return unless platform[/n6k/]
  logger.info("\n#{'-' * 60}\nVTP cleanup")
  resource_set(agent, %w(cisco_vtp default ensure absent))
end

# CSCuz58517 workaround: 'private-vlan association trunk' doesn't get
# removed by 'default interface' on some platforms.
def pvlan_assoc_cleanup(agent, intf)
  logger.info("\n#{'-' * 60}\nPrivate-vlan cleanup")
  resource_set(agent, ['cisco_interface', intf, 'switchport_mode', 'disabled'])
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    vtp_cleanup(agent)
    pvlan_assoc_cleanup(agent, intf)
    interface_cleanup(agent, intf)
    remove_interface(agent, svi)
  end
  vtp_cleanup(agent)
  pvlan_assoc_cleanup(agent, intf)
  interface_cleanup(agent, intf)
  # remove_interface(agent, svi)
  # this command fails on fresh VMs as
  # the interface does not exist, possibly
  # testbed environments were not cleaned
  # down properly, or remnants of an existing
  # test are left over - removing the step as
  # the cleanup in teardown should remove
  # the interface at end of the test

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Defaults")
  test_harness_run(tests, :default, harness_class: TestInterfacePrivateVlan)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Port Mode")
  test_harness_run(tests, :host, harness_class: TestInterfacePrivateVlan)
  test_harness_run(tests, :promiscuous, harness_class: TestInterfacePrivateVlan)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Trunk Mode")
  test_harness_run(tests, :trunk_secondary, harness_class: TestInterfacePrivateVlan)
  pvlan_assoc_cleanup(agent, intf)
  test_harness_run(tests, :trunk_promiscuous, harness_class: TestInterfacePrivateVlan)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. SVI Mapping")
  test_harness_run(tests, :svi_mapping, harness_class: TestInterfacePrivateVlan)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
