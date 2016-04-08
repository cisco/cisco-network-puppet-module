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
  master:        master,
  agent:         agent,
  resource_name: 'cisco_evpn_vni',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  preclean:       'cisco_evpn_vni',
  title_pattern:  '4096',
  manifest_props: {
    route_distinguisher: 'default',
    route_target_both:   'default',
    route_target_export: 'default',
    route_target_import: 'default',
  },
  resource:       {}, # no output expected when all defaults
}

#
# non_default_properties
#
routetargetboth = ['1.2.3.4:55', '2:2', '55:33', 'auto']
routetargetexport = ['1.2.3.4:55', '2:2', '55:33', 'auto']
routetargetimport = ['1.2.3.4:55', '2:2', '55:33', 'auto']
tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  '4096',
  manifest_props: {
    route_distinguisher: 'auto',
    route_target_both:   routetargetboth,
    route_target_export: routetargetexport,
    route_target_import: routetargetimport,
  },
  resource:       {
    route_distinguisher: 'auto',
    route_target_both:   "#{routetargetboth}",
    route_target_export: "#{routetargetexport}",
    route_target_import: "#{routetargetimport}",
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  # -----------------------------------
  id = :default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_evpn_vni')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
