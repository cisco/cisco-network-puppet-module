###############################################################################
# Copyright (c) 2016-2018 Cisco and/or its affiliates.
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
  intf_type:     'port-channel',
  platform:      'n(3|7|9)k',
  resource_name: 'cisco_interface_hsrp_group',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)
skip_nexus_image(%w(D1 8.3(2)), tests)

# Test hash test cases
tests[:default_v4] = {
  desc:               '1.1 IPv4 Default properties',
  title_pattern:      'port-channel100 500 ipv4',
  sys_def_switchport: false,
  manifest_props:     {
    authentication_compatibility:  'false',
    group_name:                    'default',
    ipv4_enable:                   'default',
    ipv4_vip:                      'default',
    mac_addr:                      'default',
    preempt:                       'default',
    preempt_delay_minimum:         'default',
    preempt_delay_reload:          'default',
    preempt_delay_sync:            'default',
    priority:                      'default',
    priority_forward_thresh_lower: 'default',
    priority_forward_thresh_upper: 'default',
    timers_hello:                  'default',
    timers_hello_msec:             'default',
    timers_hold:                   'default',
    timers_hold_msec:              'default',
  },
  code:               [0, 2],
  resource:           {
    authentication_compatibility: 'false',
    group_name:                   'false',
    ipv4_enable:                  'false',
    mac_addr:                     'false',
    preempt:                      'false',
    preempt_delay_minimum:        0,
    preempt_delay_reload:         0,
    preempt_delay_sync:           0,
    priority:                     100,
    timers_hello:                 3,
    timers_hello_msec:            'false',
    timers_hold:                  10,
    timers_hold_msec:             'false',
  },
}

tests[:default_v6] = {
  desc:               '1.2 IPv6 Default properties',
  title_pattern:      'port-channel200 510 ipv6',
  sys_def_switchport: false,
  manifest_props:     {
    authentication_compatibility:  'false',
    group_name:                    'default',
    ipv6_autoconfig:               'default',
    ipv6_vip:                      'default',
    mac_addr:                      'default',
    preempt:                       'default',
    preempt_delay_minimum:         'default',
    preempt_delay_reload:          'default',
    preempt_delay_sync:            'default',
    priority:                      'default',
    priority_forward_thresh_lower: 'default',
    priority_forward_thresh_upper: 'default',
    timers_hello:                  'default',
    timers_hello_msec:             'default',
    timers_hold:                   'default',
    timers_hold_msec:              'default',
  },
  code:               [0, 2],
  resource:           {
    authentication_compatibility: 'false',
    group_name:                   'false',
    ipv6_autoconfig:              'false',
    mac_addr:                     'false',
    preempt:                      'false',
    preempt_delay_minimum:        0,
    preempt_delay_reload:         0,
    preempt_delay_sync:           0,
    priority:                     100,
    timers_hello:                 3,
    timers_hello_msec:            'false',
    timers_hold:                  10,
    timers_hold_msec:             'false',
  },
}

tests[:non_default_v4] = {
  desc:               '2.1 IPv4 Non Default properties',
  title_pattern:      'port-channel100 500 ipv4',
  sys_def_switchport: false,
  manifest_props:     {
    authentication_auth_type:      'md5',
    authentication_compatibility:  'true',
    authentication_enc_type:       'encrypted',
    authentication_key_type:       'key-string',
    authentication_string:         '12345678901234567890',
    authentication_timeout:        200,
    group_name:                    'MyHsrpv4',
    ipv4_enable:                   'true',
    ipv4_vip:                      '2.2.2.2',
    mac_addr:                      '00:00:11:11:22:22',
    preempt:                       'true',
    preempt_delay_minimum:         '100',
    preempt_delay_reload:          '200',
    preempt_delay_sync:            '300',
    priority:                      '45',
    priority_forward_thresh_lower: '10',
    priority_forward_thresh_upper: '40',
    timers_hello:                  300,
    timers_hello_msec:             'true',
    timers_hold:                   1000,
    timers_hold_msec:              'true',
  },
}

tests[:non_default_v6] = {
  desc:               '2.2 IPv6 Non Default properties',
  title_pattern:      'port-channel200 510 ipv6',
  sys_def_switchport: false,
  manifest_props:     {
    authentication_auth_type:      'md5',
    authentication_compatibility:  'true',
    authentication_enc_type:       'encrypted',
    authentication_key_type:       'key-string',
    authentication_string:         '12345678901234567890',
    authentication_timeout:        200,
    group_name:                    'MyHsrpv6',
    ipv6_autoconfig:               'true',
    ipv6_vip:                      ['2000::11', '2000::22'],
    mac_addr:                      '00:00:11:11:22:22',
    preempt:                       'true',
    preempt_delay_minimum:         '100',
    preempt_delay_reload:          '200',
    preempt_delay_sync:            '300',
    priority:                      '45',
    priority_forward_thresh_lower: '10',
    priority_forward_thresh_upper: '40',
    timers_hello:                  300,
    timers_hello_msec:             'true',
    timers_hold:                   1000,
    timers_hold_msec:              'true',
  },
}

# class to contain the test_harness_dependencies
class TestInterfaceHsrpGroup < BaseHarness
  def self.cleanup(ctx)
    cmd = ['no interface port-channel 100',
           'no interface port-channel 200',
           'no feature hsrp',
          ].join(' ; ')
    ctx.test_set(ctx.agent, cmd)
  end

  def self.test_harness_dependencies(ctx, _tests, _id)
    cleanup(ctx)

    cmd = [
      'feature hsrp',
      'interface port-channel100 ; no switchport ; hsrp version 2',
      'interface port-channel200 ; no switchport ; hsrp version 2',
      'interface port-channel200 ; ipv6 address 2000::01/64',
    ].join(' ; ')

    ctx.test_set(ctx.agent, cmd)
  end
end

def cleanup
  TestInterfaceHsrpGroup.cleanup(self)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup }
  cleanup

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default_v4, harness_class: TestInterfaceHsrpGroup)
  test_harness_run(tests, :default_v6, harness_class: TestInterfaceHsrpGroup)

  id = :default_v4
  tests[id][:desc] = '1.3 IPv4 Defaults (absent)'
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestInterfaceHsrpGroup)

  id = :default_v6
  tests[id][:desc] = '1.4 IPv6 Defaults (absent)'
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestInterfaceHsrpGroup)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default_v4, harness_class: TestInterfaceHsrpGroup)
  test_harness_run(tests, :non_default_v6, harness_class: TestInterfaceHsrpGroup)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
