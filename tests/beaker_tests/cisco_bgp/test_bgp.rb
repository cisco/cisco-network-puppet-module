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
asn = '1'
tests = {
  master:        master,
  agent:         agent,
  asn:           asn,
  resource_name: 'cisco_bgp',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  "#{asn} default",
  preclean:       'cisco_bgp',
  manifest_props: {
    bestpath_always_compare_med:            'default',
    bestpath_aspath_multipath_relax:        'default',
    bestpath_compare_routerid:              'default',
    bestpath_cost_community_ignore:         'default',
    bestpath_med_confed:                    'default',
    bestpath_med_missing_as_worst:          'default',
    bestpath_med_non_deterministic:         'default',
    disable_policy_batching:                'default',
    enforce_first_as:                       'default',
    event_history_cli:                      'default',
    event_history_detail:                   'default',
    event_history_events:                   'default',
    event_history_periodic:                 'default',
    fast_external_fallover:                 'default',
    flush_routes:                           'default',
    graceful_restart:                       'default',
    graceful_restart_helper:                'default',
    graceful_restart_timers_restart:        'default',
    graceful_restart_timers_stalepath_time: 'default',
    isolate:                                'default',
    log_neighbor_changes:                   'default',
    maxas_limit:                            'default',
    shutdown:                               'default',
    suppress_fib_pending:                   'default',
    timer_bestpath_limit:                   'default',
    timer_bestpath_limit_always:            'default',
    timer_bgp_holdtime:                     'default',
    timer_bgp_keepalive:                    'default',
  },
  resource:       {
    'bestpath_always_compare_med'            => 'false',
    'bestpath_aspath_multipath_relax'        => 'false',
    'bestpath_compare_routerid'              => 'false',
    'bestpath_cost_community_ignore'         => 'false',
    'bestpath_med_confed'                    => 'false',
    'bestpath_med_missing_as_worst'          => 'false',
    'bestpath_med_non_deterministic'         => 'false',
    'disable_policy_batching'                => 'false',
    'enforce_first_as'                       => 'true',
    'event_history_cli'                      => 'size_small',
    'event_history_detail'                   => 'size_disable',
    'event_history_events'                   => 'size_small',
    'event_history_periodic'                 => 'size_small',
    'fast_external_fallover'                 => 'true',
    'flush_routes'                           => 'false',
    'graceful_restart'                       => 'true',
    'graceful_restart_helper'                => 'false',
    'graceful_restart_timers_restart'        => '120',
    'graceful_restart_timers_stalepath_time' => '300',
    'isolate'                                => 'false',
    'log_neighbor_changes'                   => 'false',
    'maxas_limit'                            => 'false',
    'shutdown'                               => 'false',
    'suppress_fib_pending'                   => 'false',
    'timer_bestpath_limit'                   => '300',
    'timer_bestpath_limit_always'            => 'false',
    'timer_bgp_holdtime'                     => '180',
    'timer_bgp_keepalive'                    => '60',
  },
}

tests[:default_plat_1] = {
  desc:           '1.2 Default Properties Platform-specific Part 1',
  platform:       'n(3|9)k',
  title_pattern:  "#{asn} red",
  manifest_props: {
    neighbor_down_fib_accelerate: 'default'
  },
  resource:       {
    neighbor_down_fib_accelerate: 'false'
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

tests[:non_def_1] = {
  desc:           '2.1 Non Defaults Part 1',
  title_pattern:  "#{asn} default",
  manifest_props: {
    # These properties are only configurable in default vrf
    disable_policy_batching: 'true',
    event_history_cli:       'size_medium',
    event_history_detail:    'size_large',
    event_history_events:    'size_disable',
    event_history_periodic:  'false',
  },
}

tests[:non_def_2] = {
  desc:           '2.2 Non Defaults Part 2',
  title_pattern:  "#{asn} default",
  manifest_props: {
    bestpath_always_compare_med:     'true',
    bestpath_aspath_multipath_relax: 'true',
    bestpath_compare_routerid:       'true',
    bestpath_cost_community_ignore:  'true',
    bestpath_med_confed:             'true',
    bestpath_med_missing_as_worst:   'true',
    bestpath_med_non_deterministic:  'true',
  },
}

tests[:non_def_3] = {
  desc:           '2.3 Non Defaults Part 3',
  title_pattern:  "#{asn} default",
  manifest_props: {
    cluster_id:                             '10.0.0.1',
    confederation_id:                       '99',
    confederation_peers:                    '55 23.4 88 200.1',
    enforce_first_as:                       'true',
    fast_external_fallover:                 'true',
    flush_routes:                           'false',
    graceful_restart:                       'true',
    graceful_restart_helper:                'true',
    graceful_restart_timers_restart:        '130',
    graceful_restart_timers_stalepath_time: '310',
  },
}

tests[:non_def_4] = {
  desc:           '2.4 Non Defaults Part 4',
  title_pattern:  "#{asn} default",
  manifest_props: {
    isolate:                     'false',
    log_neighbor_changes:        'true',
    maxas_limit:                 '50',
    router_id:                   '192.168.0.66',
    shutdown:                    'true',
    suppress_fib_pending:        'true',
    timer_bestpath_limit:        '255',
    timer_bestpath_limit_always: 'true',
    timer_bgp_holdtime:          '110',
    timer_bgp_keepalive:         '45',
  },
}

# Platform-specific tests
tests[:non_def_plat_1] = {
  desc:           '3.1 Default Properties Platform-specific Part 1',
  platform:       'n(3|9)k',
  title_pattern:  "#{asn} default",
  manifest_props: {
    neighbor_down_fib_accelerate: 'true'
  },
}

tests[:title_patterns] = {
  preclean:       'cisco_bgp',
  manifest_props: {},
  resource:       { 'ensure' => 'present' },
}

tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  preclean:      'cisco_bgp',
  title_pattern: 'new_york',
  title_params:  { asn: '11.4', vrf: 'red' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: '11.4',
  title_params:  { vrf: 'blue' },
  resource:      { 'ensure' => 'present' },
}

# This helper tests a test case in vrf context. This allows for testing a vrf
# while an existing config is present in vrf default.
def test_harness_bgp_vrf(tests, id, vrf)
  orig_desc = tests[id][:desc]
  tests[id][:desc] += " (vrf #{vrf})"
  tests[id][:title_pattern] = "#{tests[:asn]} #{vrf}"

  test_harness_run(tests, id)
  tests[id][:desc] = orig_desc
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  # -----------------------------------
  test_harness_run(tests, :default)
  test_harness_run(tests, :default_plat_1)

  id = :default
  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_def_1)

  id = :non_def_2
  test_harness_run(tests, id)
  test_harness_bgp_vrf(tests, id, 'blue')

  id = :non_def_3
  test_harness_run(tests, id)
  test_harness_bgp_vrf(tests, id, 'blue')

  id = :non_def_4
  test_harness_run(tests, id)
  test_harness_bgp_vrf(tests, id, 'blue')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Non Default, Platform Specific")

  test_harness_run(tests, :non_def_plat_1)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)

  # -------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_bgp')
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
