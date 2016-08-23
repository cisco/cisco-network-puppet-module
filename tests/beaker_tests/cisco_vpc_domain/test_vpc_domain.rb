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

tests = {
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_vpc_domain',
  platform:         'n(3|6|7|9)k',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:default_properties] = {
  title_pattern:  '200',
  desc:           '1.1 Default Properties on All Nexus Platforms',
  manifest_props: {
    delay_restore:                'default',
    delay_restore_interface_vlan: 'default',
    graceful_consistency_check:   'default',
    peer_gateway:                 'default',
    role_priority:                'default',
    system_priority:              'default',

  },
  code:           [0, 2],
  resource:       {
    'delay_restore'                => '30',
    'delay_restore_interface_vlan' => '10',
    'graceful_consistency_check'   => 'true',
    'peer_gateway'                 => 'false',
    'role_priority'                => '32667',
    'system_priority'              => '32667',
  },
}

tests[:non_default_properties] = {
  desc:           '2.1 Non Default Properties on All Nexus Platforms',
  title_pattern:  '200',
  manifest_props: {
    auto_recovery_reload_delay:                       '300',
    delay_restore:                                    '250',
    delay_restore_interface_vlan:                     '300',
    dual_active_exclude_interface_vlan_bridge_domain: '10-30, 500',
    graceful_consistency_check:                       'true',
    peer_keepalive_dest:                              '1.1.1.1',
    peer_keepalive_hold_timeout:                      5,
    peer_keepalive_interval:                          1000,
    peer_keepalive_interval_timeout:                  3,
    peer_keepalive_precedence:                        5,
    peer_keepalive_src:                               '1.1.1.2',
    peer_keepalive_udp_port:                          3200,
    peer_keepalive_vrf:                               'management',
    peer_gateway:                                     'true',
    role_priority:                                    '1024',
    system_mac:                                       '00:0c:0d:11:22:33',
    system_priority:                                  '3000',

  },
  code:           [0, 2],
  resource:       {
    'auto_recovery_reload_delay'                       => '300',
    'delay_restore'                                    => '250',
    'delay_restore_interface_vlan'                     => '300',
    'dual_active_exclude_interface_vlan_bridge_domain' => '10-30,500',
    'graceful_consistency_check'                       => 'true',
    'peer_keepalive_dest'                              => '1.1.1.1',
    'peer_keepalive_hold_timeout'                      => '5',
    'peer_keepalive_interval'                          => '1000',
    'peer_keepalive_interval_timeout'                  => '3',
    'peer_keepalive_precedence'                        => '5',
    'peer_keepalive_src'                               => '1.1.1.2',
    'peer_keepalive_udp_port'                          => '3200',
    'peer_keepalive_vrf'                               => 'management',
    'peer_gateway'                                     => 'true',
    'role_priority'                                    => '1024',
    'system_mac'                                       => '00:0c:0d:11:22:33',
    'system_priority'                                  => '3000',
  },
}

tests[:default_properties_n6k7k] = {
  desc:           '1.2 Default Properties exclusive to N6K and N7K',
  title_pattern:  '200',
  platform:       'n(6|7)k',
  manifest_props: {
    layer3_peer_routing: 'default',
    shutdown:            'default',
  },
  code:           [0, 2],
  resource:       {
    'layer3_peer_routing' => 'false',
    'shutdown'            => 'false',
  },
}

tests[:non_default_properties_n6k7k] = {
  desc:           '2.2 Non Default Properties exclusive to N6K and N7K',
  title_pattern:  '200',
  platform:       'n(6|7)k',
  manifest_props: {
    layer3_peer_routing:       'true',
    peer_gateway_exclude_vlan: '500-510, 1100, 1120',
    shutdown:                  'true',

  },
  code:           [0, 2],
  resource:       {
    'layer3_peer_routing'       => 'true',
    'peer_gateway_exclude_vlan' => '500-510,1100,1120',
    'shutdown'                  => 'true',
  },
}

tests[:default_properties_n7k] = {
  desc:           '1.3 Default Properties exclusive to N7K',
  title_pattern:  '200',
  platform:       'n7k',
  manifest_props: {
    auto_recovery:  'default',
    self_isolation: 'default',
  },
  code:           [0, 2],
  resource:       {
    'auto_recovery'  => 'true',
    'self_isolation' => 'false',
  },
}

tests[:non_default_properties_n7k] = {
  desc:           '2.3 Non Default Properties exclusive to N7K',
  title_pattern:  '200',
  platform:       'n7k',
  manifest_props: {
    auto_recovery:  'false',
    self_isolation: 'true',
  },
  code:           [0, 2],
  resource:       {
    'auto_recovery'  => 'false',
    'self_isolation' => 'true',
  },
}

tests[:vpc_plus_non_default_properties_n7k] = {
  desc:           '3.1 vPC+ Non Default Properties on N7K',
  title_pattern:  '200',
  platform:       'n7k',
  manifest_props: {
    fabricpath_emulated_switch_id:     '1015',
    fabricpath_multicast_load_balance: 'true',
    port_channel_limit:                'false',
  },
  code:           [0, 2],
  resource:       {
    'fabricpath_emulated_switch_id'     => '1015',
    'fabricpath_multicast_load_balance' => 'true',
    'port_channel_limit'                => 'false',
  },
}

def cleanup(agent)
  remove_all_vlans(agent)
  resource_absent_cleanup(agent, 'cisco_vpc_domain')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    cleanup(agent)
    vdc_limit_f3_no_intf_needed(:clear)
  end
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default_properties)
  test_harness_run(tests, :default_properties_n6k7k)
  test_harness_run(tests, :default_properties_n7k)

  # Resource absent test
  tests[:default_properties][:ensure] = :absent
  test_harness_run(tests, :default_properties)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default_properties)
  test_harness_run(tests, :non_default_properties_n6k7k)
  test_harness_run(tests, :non_default_properties_n7k)

  # Resource absent test
  tests[:non_default_properties][:ensure] = :absent
  test_harness_run(tests, :non_default_properties)

  # ------------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. vPC+ Non Default Property Testing")
  # Need to setup fabricapth env for vPC+
  # setup_fabricpath_env(tests, self)
  vdc_limit_f3_no_intf_needed(:set)
  test_harness_run(tests, :vpc_plus_non_default_properties_n7k)

  # Resource absent test
  tests[:vpc_plus_non_default_properties_n7k][:ensure] = :absent
  test_harness_run(tests, :vpc_plus_non_default_properties_n7k)

  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
