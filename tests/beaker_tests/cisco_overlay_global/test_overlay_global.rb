###############################################################################
# Copyright (c) 2015-2018 Cisco and/or its affiliates.
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
  platform:      'n(3|5|6|7|9)k',
  resource_name: 'cisco_overlay_global',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Skip -ALL- tests if being run on a non-default VDC
skip_non_default_vdc(agent)

tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  # Feature disablement does not reset the detection properties on some images
  code:           [0, 2],
  manifest_props: {
    dup_host_ip_addr_detection_host_moves: 'default',
    dup_host_ip_addr_detection_timeout:    'default',
    anycast_gateway_mac:                   'default',
    dup_host_mac_detection_host_moves:     'default',
    dup_host_mac_detection_timeout:        'default',
  },
  resource:       {
    'dup_host_ip_addr_detection_host_moves' => '5',
    'dup_host_ip_addr_detection_timeout'    => '180',
    'dup_host_mac_detection_host_moves'     => '5',
    'dup_host_mac_detection_timeout'        => '180',
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  'default',
  manifest_props: {
    anycast_gateway_mac:                   '1234.3456.5678',
    dup_host_ip_addr_detection_host_moves: '200',
    dup_host_ip_addr_detection_timeout:    '20',
    dup_host_mac_detection_host_moves:     '200',
    dup_host_mac_detection_timeout:        '20',
  },
  resource:       {
    'anycast_gateway_mac'                   => '1234.3456.5678',
    'dup_host_ip_addr_detection_host_moves' => '200',
    'dup_host_ip_addr_detection_timeout'    => '20',
    'dup_host_mac_detection_host_moves'     => '200',
    'dup_host_mac_detection_timeout'        => '20',
  },
}

# class to contain the test_dependencies specific to this test case
class TestOverlayGlobal < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    if ctx.platform[/n3k$/]
      unprops <<
        :anycast_gateway_mac <<
        :dup_host_ip_addr_detection_host_moves <<
        :dup_host_ip_addr_detection_timeout
    end
    unprops
  end

  def self.version_unsupported_properties(ctx, _tests, _id)
    unprops = {}
    if ctx.platform[/n3k$/]
      unprops[:dup_host_mac_detection_host_moves] = '7.0.3.I6.1'
      unprops[:dup_host_mac_detection_timeout] = '7.0.3.I6.1'
    end
    unprops
  end
end

def cleanup(agent)
  config_find_remove(agent, 'nv overlay evpn', 'incl ^nv')
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
  vdc_limit_f3_no_intf_needed(:set)

  # -------------------------------------------------------------------
  test_harness_run(tests, :default, harness_class: TestOverlayGlobal)
  test_harness_run(tests, :non_default, harness_class: TestOverlayGlobal)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
