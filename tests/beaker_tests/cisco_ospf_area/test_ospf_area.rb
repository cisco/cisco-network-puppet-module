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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_ospf_area',
}

# Test hash test cases

rarray1 = Array[['10.3.0.0/16', 'not_advertise', '23'], ['10.3.3.0/24', '450']]
rarray2 = Array[['10.3.0.0/16', '4989'], ['10.3.1.1/32']]

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default
tests[:non_default_1] = {
  desc:           '1.1 Non_Defaults',
  title_pattern:  'dark_blue default 1.1.1.1',
  manifest_props: {
    authentication:  'md5',
    default_cost:    1000,
    filter_list_in:  'filter_in',
    filter_list_out: 'filter_out',
    range:           rarray1,
    stub_no_summary: 'true',
  },
  resource:       {
    range: "#{rarray1}"
  },
}

tests[:non_default_2] = {
  desc:           '1.2 Non_Defaults',
  title_pattern:  'dark_blue vrf1 2.2.2.2',
  manifest_props: {
    authentication:  'cleartext',
    default_cost:    4444,
    filter_list_in:  'fin',
    filter_list_out: 'fout',
    range:           rarray2,
    stub:            'true',
    stub_no_summary: 'false',
  },
  resource:       {
    range: "#{rarray2}"
  },
}

tests[:non_default_3] = {
  desc:           '1.3 Non_Defaults',
  title_pattern:  'dark_blue vrf1 3.3.3.3',
  manifest_props: {
    stub: 'true'
  },
}

tests[:non_default_4] = {
  desc:           '1.4 Non_Defaults',
  title_pattern:  'dark_blue vrf1 3.3.3.3',
  manifest_props: {
    stub_no_summary: 'true'
  },
}

tests[:non_default_5] = {
  desc:           '1.5 Non_Defaults',
  title_pattern:  'dark_blue vrf1 3.3.3.3',
  manifest_props: {
    stub_no_summary: 'false'
  },
  resource:       {
    stub: 'true'
  },
}

tests[:non_default_6] = {
  desc:           '1.6 Non_Defaults',
  title_pattern:  'dark_blue vrf2 4.4.4.4',
  manifest_props: {
    nssa:                   'true',
    nssa_default_originate: 'true',
    nssa_no_redistribution: 'true',
    nssa_no_summary:        'true',
    nssa_route_map:         'rmap',
    nssa_translate_type7:   'always_supress_fa',
  },
}

def cleanup(agent)
  test_set(agent, 'no feature ospf')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection Non Default Property Testing")

  test_harness_run(tests, :non_default_1)
  test_harness_run(tests, :non_default_2)
  test_harness_run(tests, :non_default_3)
  test_harness_run(tests, :non_default_4)
  test_harness_run(tests, :non_default_5)
  test_harness_run(tests, :non_default_6)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
