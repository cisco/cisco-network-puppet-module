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
  resource_name:    'cisco_ospf_vrf',
}

# Test hash test cases
tests[:default_1] = {
  desc:           '1.1 Defaults',
  title_pattern:  'test default',
  manifest_props: {
    auto_cost:                'default',
    bfd:                      'default',
    default_metric:           'default',
    log_adjacency:            'default',
    redistribute:             'default',
    timer_throttle_lsa_hold:  'default',
    timer_throttle_lsa_max:   'default',
    timer_throttle_lsa_start: 'default',
    timer_throttle_spf_hold:  'default',
    timer_throttle_spf_max:   'default',
    timer_throttle_spf_start: 'default',
  },
  code:           [0, 2],
  resource:       {
    auto_cost:                '40000',
    bfd:                      'false',
    default_metric:           '0',
    log_adjacency:            'none',
    # 'redistribute' is nil when default
    timer_throttle_lsa_hold:  '5000',
    timer_throttle_lsa_max:   '5000',
    timer_throttle_lsa_start: '0',
    timer_throttle_spf_hold:  '1000',
    timer_throttle_spf_max:   '5000',
    timer_throttle_spf_start: '200',
  },
}

# Test hash test cases
tests[:default_2] = {
  desc:           '1.2 Defaults',
  title_pattern:  'test green',
  manifest_props: {
    auto_cost:                'default',
    bfd:                      'default',
    default_metric:           'default',
    log_adjacency:            'default',
    timer_throttle_lsa_hold:  'default',
    timer_throttle_lsa_max:   'default',
    timer_throttle_lsa_start: 'default',
    timer_throttle_spf_hold:  'default',
    timer_throttle_spf_max:   'default',
    timer_throttle_spf_start: 'default',
  },
  code:           [0, 2],
  resource:       {
    auto_cost:                '40000',
    bfd:                      'false',
    default_metric:           '0',
    log_adjacency:            'none',
    timer_throttle_lsa_hold:  '5000',
    timer_throttle_lsa_max:   '5000',
    timer_throttle_lsa_start: '0',
    timer_throttle_spf_hold:  '1000',
    timer_throttle_spf_max:   '5000',
    timer_throttle_spf_start: '200',
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

tests[:non_default_1] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  'test default',
  manifest_props: {
    auto_cost:                '80000',
    bfd:                      'true',
    default_metric:           '1',
    log_adjacency:            'log',
    timer_throttle_lsa_hold:  '2000',
    timer_throttle_lsa_max:   '10000',
    timer_throttle_lsa_start: '1',
    timer_throttle_spf_hold:  '2000',
    timer_throttle_spf_max:   '10000',
    timer_throttle_spf_start: '400',
  },
}

tests[:non_default_2] = {
  desc:           '2.2 Non Defaults',
  title_pattern:  'test green',
  manifest_props: {
    auto_cost:                '70000',
    bfd:                      'true',
    default_metric:           '2',
    log_adjacency:            'log',
    timer_throttle_lsa_hold:  '1500',
    timer_throttle_lsa_max:   '11000',
    timer_throttle_lsa_start: '1',
    timer_throttle_spf_hold:  '2200',
    timer_throttle_spf_max:   '11000',
    timer_throttle_spf_start: '430',
  },
}
redistribute = [
  ['bgp 5',   'rm_bgp'],
  ['direct',  'rm_direct'],
  ['eigrp 1', 'rm_eigrp'],
  ['isis 2',  'rm_isis'],
  ['lisp',    'rm_lisp'],
  ['ospf 3',  'rm_ospf'],
  ['rip 4',   'rm_rip'],
  ['static',  'rm_static'],
]
# rubocop:enable Style/WordArray
tests[:non_default_arrays] = {
  desc:           '2.3 Non Default Properties: Arrays',
  title_pattern:  'test green',
  manifest_props: {
    redistribute: redistribute
  },
  resource:       {
    redistribute: "#{redistribute}"
  },
}
redistribute = [
  ['bgp 5',   'rm_bgp'],
  ['direct',  'rm_direct'],
  ['eigrp 1', 'rm_eigrp'],
  ['isis 2',  'rm_isis'],
  ['lisp',    'rm_lisp'],
  ['ospf 3',  'rm_ospf'],
  ['rip 4',   'rm_rip'],
  ['static',  'rm_static'],
]
# rubocop:enable Style/WordArray
tests[:non_default_arrays] = {
  desc:           '2.3 Non Default Properties: Arrays',
  title_pattern:  'test green',
  manifest_props: {
    redistribute: redistribute
  },
  resource:       {
    redistribute: "#{redistribute}"
  },
}

def cleanup(agent)
  test_set(agent, 'no feature ospf ; no feature bfd')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default_1)
  test_harness_run(tests, :default_2)

  id = :default_2
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default_1)
  test_harness_run(tests, :non_default_2)
  test_harness_run(tests, :non_default_arrays)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
