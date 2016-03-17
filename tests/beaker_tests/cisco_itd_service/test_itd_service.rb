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
  master:        master,
  agent:         agent,
  platform:      'n(7|9)k',
  resource_name: 'cisco_itd_service',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Defaults',
  title_pattern:  'myService',
  preclean:       'cisco_itd_service',
  manifest_props: {
    access_list:         'default',
    device_group:        'default',
    exclude_access_list: 'default',
    failaction:          'default',
    ingress_interface:   'default',
    load_bal_enable:     'default',
    shutdown:            'default',
    virtual_ip:          'default',
  },
  code:           [0, 2],
  resource:       {
    access_list:         'false',
    device_group:        'false',
    exclude_access_list: 'false',
    failaction:          'false',
    load_bal_enable:     'false',
    shutdown:            'true',
  },
}

tests[:default_plat_1] = {
  desc:           '1.2 Defaults for platform specific part 1',
  platform:       'n7k',
  title_pattern:  'myService',
  preclean:       'cisco_itd_service',
  manifest_props: {
    device_group:    'udpGroup',
    nat_destination: 'default',
    peer_vdc:        'default',
  },
  code:           [0, 2],
  resource:       {
    'nat_destination' => 'false'
  },
}

tests[:default_plat_2] = {
  desc:           '1.3 Defaults for platform specific part 2',
  platform:       'n9k',
  title_pattern:  'myService',
  preclean:       'cisco_itd_service',
  manifest_props: {
    peer_local: 'default'
  },
  code:           [0, 2],
  resource:       {
    'peer_local' => 'false'
  },
}

ing_intf = [['vlan 2', '4.4.4.4'], ['ethernet 1/1', '5.5.5.5'], ['port-channel 100', '6.6.6.6']]
vip = ['ip 3.3.3.3 255.0.0.0 tcp 500 advertise enable', 'ip 2.2.2.2 255.0.0.0 udp 1000 device-group icmpGroup']
pv = %w(myVdc1 pvservice)

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  'myService',
  preclean:       'cisco_itd_service',
  manifest_props: {
    access_list:                   'ial',
    device_group:                  'udpGroup',
    exclude_access_list:           'eal',
    failaction:                    'true',
    ingress_interface:             ing_intf,
    load_bal_buckets:              '16',
    load_bal_enable:               'true',
    load_bal_mask_pos:             '5',
    load_bal_method_bundle_hash:   'ip-l4port',
    load_bal_method_bundle_select: 'dst',
    load_bal_method_end_port:      '100',
    load_bal_method_proto:         'udp',
    load_bal_method_start_port:    '50',
    shutdown:                      'true',

  },
}

tests[:non_default_plat_1] = {
  desc:           '2.2 Non Defaults for platform specific part 1',
  platform:       'n7k',
  title_pattern:  'myService',
  preclean:       'cisco_itd_service',
  manifest_props: {
    device_group:                  'udpGroup',
    ingress_interface:             ing_intf,
    load_bal_buckets:              '32',
    load_bal_enable:               'true',
    load_bal_mask_pos:             '10',
    load_bal_method_bundle_hash:   'ip',
    load_bal_method_bundle_select: 'src',
    nat_destination:               'true',
    peer_vdc:                      pv,
    shutdown:                      'false',
    virtual_ip:                    vip,
  },
}

tests[:non_default_plat_2] = {
  desc:           '2.3 Non Defaults for platform specific part 2',
  platform:       'n9k',
  title_pattern:  'myService',
  preclean:       'cisco_itd_service',
  manifest_props: {
    device_group:                  'udpGroup',
    ingress_interface:             ing_intf,
    load_bal_buckets:              '32',
    load_bal_enable:               'true',
    load_bal_mask_pos:             '10',
    load_bal_method_bundle_hash:   'ip',
    load_bal_method_bundle_select: 'dst',
    peer_local:                    'plservice',
    shutdown:                      'false',
  },
}

# Overridden to properly handle dependencies for this test file.
def test_harness_dependencies(_tests, _id)
  cmd = 'ip acess-list iap ; ip access-list eap ; interface ethernet 1/1 ; no switchport ; exit'
  command_config(agent, cmd, cmd)
  cmd = 'feature interface-vlan ; vlan 2; interface vlan 2; interface port-channel 100 ; feature itd'
  command_config(agent, cmd, cmd)
  cmd = 'itd device-group udpGroup ; itd device-group icmpGroup ; node ip 2.2.2.2 ; exit ; node ip 3.3.3.3'
  command_config(agent, cmd, cmd)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default)
  test_harness_run(tests, :default_plat_1)
  test_harness_run(tests, :default_plat_2)

  id = :default
  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default)
  test_harness_run(tests, :non_default_plat_1)
  test_harness_run(tests, :non_default_plat_2)
  resource_absent_cleanup(agent, 'cisco_itd_service')
  resource_absent_cleanup(agent, 'cisco_itd_service')
  resource_absent_cleanup(agent, 'cisco_itd_device_group_node')
  resource_absent_cleanup(agent, 'cisco_itd_device_group')
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
