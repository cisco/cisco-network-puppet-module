###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  platform:         'n(5|6|7|9)k',
  resource_name:    'cisco_vxlan_vtep',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  title_pattern:  'nve1',
  manifest_props: {
    description:                     'default',
    host_reachability:               'default',
    shutdown:                        'default',
    source_interface:                'default',
    source_interface_hold_down_time: 'default',
  },
  resource:       {
    'host_reachability' => 'flood',
    'shutdown'          => 'true',
  },
}

tests[:non_default] = {
  title_pattern:  'nve1',
  manifest_props: {
    description:                     'Puppet test',
    host_reachability:               'evpn',
    shutdown:                        'false',
    source_interface:                'loopback55',
    source_interface_hold_down_time: '100',
  },
}

def unsupported_properties(*)
  unprops = []
  unprops << :source_interface_hold_down_time if platform[/n(5|6)k/]
  unprops
end

def version_unsupported_properties(_tests, _id)
  unprops = {}
  unprops[:source_interface_hold_down_time] = '8.1.1' if platform[/n7k/]
  unprops
end

# Overridden to properly handle dependencies for this test file.
def test_harness_dependencies(*)
  return unless platform[/n(5|6)k/]
  skip_if_nv_overlay_rejected(agent)

  # Vxlan has a hard requirement to disable feature fabricpath on n5/6k
  cmd = 'no feature-set fabricpath'
  command_config(agent, cmd, cmd)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    resource_absent_cleanup(agent, 'cisco_vxlan_vtep')
    vdc_limit_f3_no_intf_needed(:clear)
  end
  resource_absent_cleanup(agent, 'cisco_vxlan_vtep')
  vdc_limit_f3_no_intf_needed(:set)

  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
