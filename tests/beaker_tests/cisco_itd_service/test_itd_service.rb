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
# The platform: key below must use an end of string anchor '$' in order to
# distinguish between 'n9k' and 'n9k-f' platform flavors.
tests = {
  master:        master,
  agent:         agent,
  intf_type:     'ethernet',
  platform:      'n(7|9)k$',
  resource_name: 'cisco_itd_service',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)
skip_nexus_image('I2', tests)

def find_ingress_ethernet_interface(tests)
  if tests[:ethernet]
    intf = tests[:ethernet]
  else
    int = find_interface(tests)
    # make sure the interface name is like 'ethernet 1/1'
    intf = int.dup
    intf.insert(8, ' ')
    # cache for later tests
    tests[:ethernet] = intf
  end
  intf
end
@ingress_eth_int = find_ingress_ethernet_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Common Defaults',
  title_pattern:  'myService',
  manifest_props: {
    access_list:         'default',
    device_group:        'default',
    exclude_access_list: 'default',
    fail_action:         'default',
    ingress_interface:   'default',
    load_bal_enable:     'default',
    shutdown:            'default',
    virtual_ip:          'default',
  },
  code:           [0, 2],
  resource:       {
    fail_action:     'false',
    load_bal_enable: 'false',
    shutdown:        'true',
  },
}

tests[:default_plat_1] = {
  desc:           '1.2 Defaults for n7k',
  platform:       'n7k',
  title_pattern:  'myService',
  manifest_props: {
    device_group:      'udpGroup',
    ingress_interface: 'default',
    nat_destination:   'default',
    peer_vdc:          'default',
  },
  code:           [0, 2],
  resource:       {
    'nat_destination' => 'false'
  },
}

tests[:default_plat_2] = {
  desc:           '1.3 Defaults for n9k',
  platform:       'n9k',
  title_pattern:  'myService',
  manifest_props: {
    fail_action: 'default',
    peer_local:  'default',
  },
  code:           [0, 2],
  resource:       {
    fail_action: 'false'
  },
}

# The next-hop setting as part of the ingress_interface
# is not needed for n9k and in the latest images is not
# even supported by the cli.
next_hop1 = '4.4.4.4'
next_hop2 = '5.5.5.5'
next_hop3 = '6.6.6.6'
if nexus_image[/9\.\d+/]
  next_hop1 = ''
  next_hop2 = ''
  next_hop3 = ''
end
ingress_intf = [['vlan 2', next_hop1], [@ingress_eth_int, next_hop2], ['port-channel 100', next_hop3]]
vip = ['ip 3.3.3.3 255.0.0.0 tcp 500 advertise enable']
pv = %w(myVdc1 pvservice)

tests[:non_default] = {
  desc:           '2.1 Common Non Defaults',
  title_pattern:  'myService',
  manifest_props: {
    access_list:                   'iap',
    device_group:                  'udpGroup',
    exclude_access_list:           'eap',
    fail_action:                   'true',
    ingress_interface:             ingress_intf,
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
  desc:           '2.2 Non Defaults for n7k',
  platform:       'n7k',
  title_pattern:  'myService',
  manifest_props: {
    device_group:                  'udpGroup',
    ingress_interface:             ingress_intf,
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
  desc:           '2.3 Non Defaults for n9k',
  platform:       'n9k',
  title_pattern:  'myService',
  manifest_props: {
    device_group:                  'udpGroup',
    ingress_interface:             ingress_intf,
    load_bal_buckets:              '32',
    load_bal_enable:               'true',
    load_bal_mask_pos:             '10',
    load_bal_method_bundle_hash:   'ip',
    load_bal_method_bundle_select: 'dst',
    peer_local:                    'plservice',
    shutdown:                      'false',
  },
}

next_hop = nexus_image[/9\.\d+/] ? '' : '2.2.2.2'
tests[:non_default_shut] = {
  desc:           '3.1 Common create service and turn it on',
  title_pattern:  'myService',
  manifest_props: {
    device_group:      'udpGroup',
    ingress_interface: [[@ingress_eth_int, next_hop]],
    shutdown:          'false',
  },
}

next_hop = nexus_image[/9\.\d+/] ? '' : '3.3.3.3'
tests[:non_default_shut_2] = {
  desc:           '3.2 Common change params and turn off service',
  title_pattern:  'myService',
  manifest_props: {
    device_group:      'udpGroup',
    ingress_interface: [[@ingress_eth_int, next_hop]],
    shutdown:          'true',
  },
}

next_hop = nexus_image[/9\.\d+/] ? '' : '4.4.4.4'
tests[:non_default_shut_3] = {
  desc:           '3.3 Common change params and leave service off',
  title_pattern:  'myService',
  manifest_props: {
    device_group:      'udpGroup',
    ingress_interface: [[@ingress_eth_int, next_hop]],
    shutdown:          'true',
  },
}

next_hop = nexus_image[/9\.\d+/] ? '' : '5.5.5.5'
tests[:non_default_shut_4] = {
  desc:           '3.4 Common change params and turn service back on',
  title_pattern:  'myService',
  manifest_props: {
    device_group:      'udpGroup',
    ingress_interface: [[@ingress_eth_int, next_hop]],
    shutdown:          'false',
  },
}

# class to contain the test_harness_dependencies
class TestItdService < BaseHarness
  def self.cleanup(ctx, ignore_errors: false)
    cmds = ['no ip access-list iap',
            'no ip access-list eap',
            'no vlan 2',
            'no interface port-channel 100',
            'no feature interface-vlan',
            'no feature itd',
           ].join(' ; ')
    ctx.test_set(ctx.agent, cmds, ignore_errors: ignore_errors)
    ctx.interface_cleanup(ctx.agent, ctx.instance_variable_get(:@ingress_eth_int))
  end

  def self.test_harness_dependencies(ctx, _tests, _id)
    cleanup(ctx, ignore_errors: true)

    cmd = [
      'feature itd',
      'feature interface-vlan',
      'ip access-list iap ; permit ip any any',
      'ip access-list eap ; permit ip any any',
      "interface #{ctx.instance_variable_get(:@ingress_eth_int)} ; no switchport",
      'vlan 2 ; interface vlan 2',
      'interface port-channel 100 ; no switchport',
      'itd device-group udpGroup ; node ip 1.1.1.1',
    ].join(' ; ')
    ctx.test_set(ctx.agent, cmd)
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { TestItdService.cleanup(self) }
  TestItdService.cleanup(self, ignore_errors: true)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default, harness_class: TestItdService)
  test_harness_run(tests, :default_plat_1, harness_class: TestItdService)
  test_harness_run(tests, :default_plat_2, harness_class: TestItdService)

  id = :default
  tests[id][:desc] = '1.4 Common Defaults (absent)'
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestItdService)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default, harness_class: TestItdService)
  test_harness_run(tests, :non_default_plat_1, harness_class: TestItdService)
  test_harness_run(tests, :non_default_plat_2, harness_class: TestItdService)
  test_harness_run(tests, :non_default_shut, harness_class: TestItdService)
  test_harness_run(tests, :non_default_shut_2, harness_class: TestItdService)
  test_harness_run(tests, :non_default_shut_3, harness_class: TestItdService)
  test_harness_run(tests, :non_default_shut_4, harness_class: TestItdService)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
