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
require File.expand_path('../bgplib.rb', __FILE__)

# Test hash top-level keys
asn = '1'
tests = {
  agent:         agent,
  master:        master,
  asn:           asn,
  resource_name: 'cisco_bgp',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  "#{asn} default",
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
    fast_external_fallover:                 'default',
    flush_routes:                           'default',
    graceful_restart:                       'default',
    graceful_restart_helper:                'default',
    graceful_restart_timers_restart:        'default',
    graceful_restart_timers_stalepath_time: 'default',
    isolate:                                'default',
    log_neighbor_changes:                   'default',
    maxas_limit:                            'default',
    neighbor_down_fib_accelerate:           'default',
    nsr:                                    'default',
    reconnect_interval:                     'default',
    shutdown:                               'default',
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
    'fast_external_fallover'                 => 'true',
    'flush_routes'                           => 'false',
    'graceful_restart'                       => 'true',
    'graceful_restart_helper'                => 'false',
    'graceful_restart_timers_restart'        => '120',
    'graceful_restart_timers_stalepath_time' => '300',
    'isolate'                                => 'false',
    'log_neighbor_changes'                   => 'false',
    'maxas_limit'                            => 'false',
    'neighbor_down_fib_accelerate'           => 'false',
    'nsr'                                    => 'false',
    'reconnect_interval'                     => '60',
    'shutdown'                               => 'false',
    'timer_bestpath_limit'                   => '300',
    'timer_bestpath_limit_always'            => 'false',
    'timer_bgp_holdtime'                     => '180',
    'timer_bgp_keepalive'                    => '60',
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default
tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  "#{asn} default",
  manifest_props: {
    bestpath_always_compare_med:            'true',
    bestpath_aspath_multipath_relax:        'true',
    bestpath_compare_routerid:              'true',
    bestpath_cost_community_ignore:         'true',
    bestpath_med_confed:                    'true',
    bestpath_med_missing_as_worst:          'true',
    bestpath_med_non_deterministic:         'true',
    cluster_id:                             '10.0.0.1',
    confederation_id:                       '99',
    confederation_peers:                    ['200.1', '23.4', '55', '88'],
    disable_policy_batching:                'true',
    enforce_first_as:                       'false',
    event_history_cli:                      'size_large',
    event_history_detail:                   'size_large',
    event_history_errors:                   'size_large',
    event_history_events:                   'size_medium',
    event_history_objstore:                 'size_medium',
    event_history_periodic:                 '100000',
    fast_external_fallover:                 'false',
    flush_routes:                           'true',
    graceful_restart:                       'false',
    graceful_restart_helper:                'true',
    graceful_restart_timers_restart:        '130',
    graceful_restart_timers_stalepath_time: '310',
    isolate:                                'false',
    log_neighbor_changes:                   'true',
    maxas_limit:                            '50',
    neighbor_down_fib_accelerate:           'true',
    nsr:                                    'true',
    reconnect_interval:                     '55',
    router_id:                              '192.168.0.66',
    shutdown:                               'true',
    suppress_fib_pending:                   'true',
    timer_bestpath_limit:                   '255',
    timer_bestpath_limit_always:            'true',
    timer_bgp_holdtime:                     '110',
    timer_bgp_keepalive:                    '45',
  },
}

tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
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

# class to contain the test_dependencies specific to this test case
class TestBgp < BaseHarness
  def self.unsupported_properties(ctx, tests, id)
    unprops = []

    vrf = ctx.vrf(tests[id])

    if ctx.operating_system == 'ios_xr'
      unprops << unsupp_prop_xr(ctx, tests, id)
    else
      # NX-OS does not support these properties
      unprops << :nsr

      unprops <<
        :event_history_errors <<
        :event_history_objstore if ctx.platform[/n5|n6/]

      if vrf != 'default'
        # NX-OS does not support these properties under a non-default vrf
        unprops <<
          :disable_policy_batching <<
          :enforce_first_as <<
          :event_history_cli <<
          :event_history_detail <<
          :event_history_errors <<
          :event_history_events <<
          :event_history_objstore <<
          :event_history_periodic <<
          :fast_external_fallover <<
          :flush_routes <<
          :neighbor_down_fib_accelerate <<
          :suppress_fib_pending
      end

      if ctx.platform[/n(5|6)k/]
        unprops <<
          :disable_policy_batching_ipv4 <<
          :disable_policy_batching_ipv6 <<
          :neighbor_down_fib_accelerate <<
          :reconnect_interval
      end
    end
    unprops
  end

  def self.version_unsupported_properties(ctx, _tests, _id)
    unprops = {}
    if ctx.platform[/n7k/]
      unprops[:disable_policy_batching_ipv4] = '8.1.1'
      unprops[:disable_policy_batching_ipv6] = '8.1.1'
      unprops[:neighbor_down_fib_accelerate] = '8.1.1'
      unprops[:reconnect_interval] = '8.1.1'
      unprops[:event_history_errors] = '8.0'
      unprops[:event_history_objstore] = '8.0'
    elsif ctx.platform[/n3k$|n9k$/]
      unprops[:event_history_errors] = '7.0.3.I5.1'
      unprops[:event_history_objstore] = '7.0.3.I5.1'
    elsif ctx.platform[/n(3|9)k-f/]
      unprops[:event_history_errors] = '7.0.3.F3.2'
      unprops[:event_history_objstore] = '7.0.3.F3.2'
    end
    unprops
  end

  def self.unsupp_prop_xr(ctx, tests, id)
    unprops = []
    vrf = ctx.vrf(tests[id])

    unprops <<
      :bestpath_med_non_deterministic <<
      :disable_policy_batching <<
      :event_history_cli <<
      :event_history_detail <<
      :event_history_events <<
      :event_history_errors <<
      :event_history_objstore <<
      :event_history_periodic <<
      :flush_routes <<
      :graceful_restart_helper <<
      :isolate <<
      :log_neighbor_changes <<
      :maxas_limit <<
      :neighbor_down_fib_accelerate <<
      :shutdown <<
      :suppress_fib_pending <<
      :timer_bestpath_limit <<
      :timer_bestpath_limit_always

    if vrf != 'default'
      # IOS-XR does not support these properties under a non-default vrf
      unprops <<
        :bestpath_med_confed <<
        :cluster_id <<
        :confederation_id <<
        :confederation_peers <<
        :graceful_restart <<
        :graceful_restart_timers_restart <<
        :graceful_restart_timers_stalepath_time <<
        :nsr
    end
    unprops
  end
end

def cleanup(agent)
  if operating_system == 'nexus'
    test_set(agent, 'no feature bgp')
  else
    resource_absent_cleanup(agent, 'cisco_bgp')
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  # -----------------------------------
  id = :default
  test_harness_run(tests, id, harness_class: TestBgp)

  # test removal of bgp instance
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestBgp)

  # now test the defaults under a non-default vrf
  cleanup(agent)
  tests[id][:ensure] = :present
  tests[id][:desc] = '1.1.a. Default Properties (vrf blue)'
  test_harness_bgp_vrf(tests, id, 'blue', harness_class: TestBgp)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  id = :non_default
  test_harness_run(tests, id, harness_class: TestBgp)
  tests[id][:desc] = '2.1.a. Default Properties (vrf blue)'
  test_harness_bgp_vrf(tests, id, 'blue', harness_class: TestBgp)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  cleanup(agent)
  test_harness_run(tests, :title_patterns_1, harness_class: TestBgp)
  test_harness_run(tests, :title_patterns_2, harness_class: TestBgp)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
