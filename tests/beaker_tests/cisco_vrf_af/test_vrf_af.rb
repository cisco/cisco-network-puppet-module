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
  resource_name: 'cisco_vrf_af',
}

# Test hash test cases
tests[:default_rt] = {
  desc:           'Default Properties, route-target',
  platform:       'n(7|9)k',
  preclean:       'cisco_vrf',
  title_pattern:  'blue ipv4 unicast',
  manifest_props: {
    route_target_both_auto:      'default',
    route_target_both_auto_evpn: 'default',
    route_target_import:         'default',
    route_target_import_evpn:    'default',
    route_target_export:         'default',
    route_target_export_evpn:    'default',
  },
  resource:       {
    'route_target_both_auto'      => 'false',
    'route_target_both_auto_evpn' => 'false',
  },
}

routetargetimport     = ['1.1.1.1:55', '1:33']
routetargetimportevpn = ['2.2.2.2:55', '2:33']
routetargetexport     = ['3.3.3.3:55', '3:33']
routetargetexportevpn = ['4.4.4.4:55', '4:33']
tests[:non_def_rt] = {
  desc:           'Non Default Properties, route-target',
  platform:       'n(7|9)k',
  title_pattern:  'blue ipv4 unicast',
  manifest_props: {
    route_target_both_auto:      true,
    route_target_both_auto_evpn: true,
    route_target_import:         routetargetimport,
    route_target_import_evpn:    routetargetimportevpn,
    route_target_export:         routetargetexport,
    route_target_export_evpn:    routetargetexportevpn,
  },
  resource:       {
    'route_target_both_auto'      => 'true',
    'route_target_both_auto_evpn' => 'true',
    'route_target_import'         => "#{routetargetimport}",
    'route_target_import_evpn'    => "#{routetargetimportevpn}",
    'route_target_export'         => "#{routetargetexport}",
    'route_target_export_evpn'    => "#{routetargetexportevpn}",
  },
}

tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  preclean:      'cisco_vrf',
  title_pattern: 'new_york',
  title_params:  { vrf: 'red', afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: 'blue',
  title_params:  { afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_3] = {
  desc:          'T.3 Title Pattern',
  title_pattern: 'cyan ipv4',
  title_params:  { safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default_rt
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_def_rt)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  test_harness_run(tests, :title_patterns_3)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_vrf')
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
