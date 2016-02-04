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
# See README-beaker-script-ref.md for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

testheader = 'Resource cisco_vrf_af'

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

tests[:title_patterns] = {
  preclean:       'cisco_bgp',
  manifest_props: {},
  resource:       { 'ensure' => 'present' },
}
# Title Pattern Test Hash
titles = {}
titles['T.1'] = {
  title_pattern: 'red',
  title_params:  { afi: 'ipv4', safi: 'unicast' },
}
titles['T.2'] = {
  title_pattern: 'blue ipv4',
  title_params:  { safi: 'unicast' },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default_rt
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_def_rt)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  test_title_patterns(tests, :title_patterns, titles)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_vrf')
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{testheader} :: End")
