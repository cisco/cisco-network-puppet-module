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

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  platform:         'n(5|6|7)k',
  resource_name:    'cisco_fabricpath_topology',
  operating_system: 'nexus',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Skip -ALL- tests if being run on a non-default VDC
skip_non_default_vdc(agent)

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  '10',
  manifest_props: {
    member_vlans: '10-20, 30, 14, 31, 100-110',
    topo_name:    'Topo-1',
  },
  resource:       {
    member_vlans: '10-20,30-31,100-110',
    topo_name:    'Topo-1',
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
    vdc_limit_f3_no_intf_needed(:clear)
    testbed_cleanup(agent)
  end
  testbed_cleanup(agent)
  vdc_limit_f3_no_intf_needed(:set)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")

  id = :non_default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  test_harness_run(tests, id)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
