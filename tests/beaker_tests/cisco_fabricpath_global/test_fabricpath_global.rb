###############################################################################
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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
  agent:         agent,
  master:        master,
  platform:      'n(5|6|7)k',
  resource_name: 'cisco_fabricpath_global',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Skip -ALL- tests if being run on a non-default VDC
skip_non_default_vdc(agent)

tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    allocate_delay:               'default',
    graceful_merge:               'default',
    linkup_delay:                 'default',
    loadbalance_unicast_layer:    'default',
    loadbalance_unicast_has_vlan: 'default',
    transition_delay:             'default',
  },
  resource:       {
    'allocate_delay'               => '10',
    'graceful_merge'               => 'enable',
    'linkup_delay'                 => '10',
    'loadbalance_unicast_layer'    => 'mixed',
    'loadbalance_unicast_has_vlan' => 'true',
    'transition_delay'             => '10',
  },
}

tests[:default_exclusive] = {
  desc:           '1.2 Default Properties (Exclusive)',
  title_pattern:  'default',
  platform:       'n7k',
  manifest_props: {
    aggregate_multicast_routes:     'default',
    linkup_delay_always:            'default',
    linkup_delay_enable:            'default',
    loadbalance_algorithm:          'default',
    loadbalance_multicast_has_vlan: 'default',
    mode:                           'default',
    ttl_multicast:                  'default',
    ttl_unicast:                    'default',
  },
  resource:       {
    'aggregate_multicast_routes'     => 'false',
    'linkup_delay_always'            => 'false',
    'linkup_delay_enable'            => 'true',
    'loadbalance_algorithm'          => 'symmetric',
    'loadbalance_multicast_has_vlan' => 'true',
    'mode'                           => 'normal',
    'ttl_multicast'                  => '32',
    'ttl_unicast'                    => '32',
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  'default',
  manifest_props: {
    allocate_delay:               '30',
    graceful_merge:               'disable',
    linkup_delay:                 '20',
    loadbalance_algorithm:        'source',
    loadbalance_unicast_layer:    'layer4',
    loadbalance_unicast_has_vlan: 'true',
    switch_id:                    '100',
    transition_delay:             '25',
  },
}

tests[:non_default_exclusive] = {
  desc:           '2.2 Non Default Properties (Exclusive)',
  title_pattern:  'default',
  platform:       'n7k',
  manifest_props: {
    aggregate_multicast_routes:     'true',
    linkup_delay_always:            'false',
    linkup_delay_enable:            'false',
    loadbalance_multicast_rotate:   '3',
    loadbalance_multicast_has_vlan: 'true',
    loadbalance_unicast_rotate:     '5',
    ttl_multicast:                  '20',
    ttl_unicast:                    '20',
  },
}

def testbed_cleanup(agent)
  cmds = ['feature nv overlay', 'feature-set fabricpath']
  config_find_remove(agent, cmds, 'incl ^feature')
  remove_all_vlans(agent)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    testbed_cleanup(agent)
    vdc_limit_f3_no_intf_needed(:clear)
  end
  vdc_limit_f3_no_intf_needed(:set)
  testbed_cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)
  tests[:default][:ensure] = :absent
  test_harness_run(tests, :default)

  test_harness_run(tests, :default_exclusive)
  tests[:default_exclusive][:ensure] = :absent
  test_harness_run(tests, :default_exclusive)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
  test_harness_run(tests, :non_default_exclusive)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
