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
  agent:            agent,
  master:           master,
  ensurable:        false,
  operating_system: 'nexus',
  resource_name:    'cisco_command_config',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:bgp] = {
  desc:           '1.1 BGP',
  manifest_props: {
    # Command indentation is very important!
    # Make sure config appears exactly how it nvgens on the node.
    command: '
feature bgp
router bgp 55
  shutdown
  router-id 192.55.55.55
  cluster-id 172.5.5.5
  timers bgp 33 190
  timers bestpath-limit 44 always
  graceful-restart-helper
  graceful-restart restart-time 55
  graceful-restart stalepath-time 55
  confederation identifier 50
  confederation peers 327686 327685 200608 5000 6000 32 43
  bestpath as-path multipath-relax
  bestpath cost-community ignore
  bestpath compare-routerid
  bestpath med confed
  bestpath med non-deterministic
  bestpath always-compare-med
  suppress-fib-pending
  log-neighbor-changes
    '
  },
  resource:       {
    'ensure'                                 => 'present',
    'bestpath_always_compare_med'            => 'true',
    'bestpath_aspath_multipath_relax'        => 'true',
    'bestpath_compare_routerid'              => 'true',
    'bestpath_cost_community_ignore'         => 'true',
    'bestpath_med_confed'                    => 'true',
    'bestpath_med_non_deterministic'         => 'true',
    'cluster_id'                             => '172.5.5.5',
    'confederation_id'                       => '50',
    'confederation_peers'                    => %w(200608 32 327685 327686 43 5000 6000),
    'log_neighbor_changes'                   => 'true',
    'router_id'                              => '192.55.55.55',
    'graceful_restart_timers_restart'        => '55',
    'graceful_restart_timers_stalepath_time' => '55',
    'graceful_restart_helper'                => 'true',
    'shutdown'                               => 'true',
    'suppress_fib_pending'                   => 'true',
    'timer_bestpath_limit'                   => '44',
    'timer_bestpath_limit_always'            => 'true',
    'timer_bgp_keepalive'                    => '33',
    'timer_bgp_holdtime'                     => '190',
  },
}

tests[:bgp_af] = {
  desc:           '1.2 BGP_AF',
  manifest_props: {
    # Command indentation is very important!
    # Make sure config appears exactly how it nvgens on the node.
    command: '
feature bgp
router bgp 55
  address-family ipv4 unicast
    dampening
    '
  },
  resource:       {
    'ensure'                      => 'present',
    'dampening_state'             => 'true',
    'dampening_half_time'         => '15',
    'dampening_max_suppress_time' => '45',
    'dampening_reuse_time'        => '750',
    'dampening_suppress_time'     => '2000',
  },
}

tests[:bgp_neighbor] = {
  desc:           '1.3 BGP_NEIGHBOR',
  manifest_props: {
    # Command indentation is very important!
    # Make sure config appears exactly how it nvgens on the node.
    command: '
feature bgp
router bgp 55
  neighbor 1.1.1.1
    timers 90 270
    '
  },
  resource:       {
    'ensure'           => 'present',
    'timers_keepalive' => '90',
    'timers_holdtime'  => '270',
  },
}

tests[:bgp_neighbor_af] = {
  desc:           '1.4 BGP_NEIGHBOR_AF',
  manifest_props: {
    # Command indentation is very important!
    # Make sure config appears exactly how it nvgens on the node.
    command: '
feature bgp
router bgp 55
  neighbor 1.1.1.1
    address-family ipv6 unicast
      capability additional-paths send
    '
  },
  resource:       {
    'ensure'                => 'present',
    'additional_paths_send' => 'enable',
  },
}

tests[:loopback] = {
  desc:           '1.5 LOOPBACK',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the switch.
  manifest_props: {
    command: '
interface loopback1
  description configured_by_puppet
    '
  },
  resource:       {
    'description' => 'configured_by_puppet'
  },
}

tests[:control_characters] = {
  desc:           '1.6 CTRL_CHARS',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the switch.
  manifest_props: {
    command: "
feature bgp\r\n
router bgp 55\r\n
  neighbor 1.1.1.1\r\n
    address-family ipv6 unicast\r\n
      capability additional-paths send\t\r\n
    "
  },
  resource:       {
    'ensure'                => 'present',
    'additional_paths_send' => 'enable',
  },
}

def test_set_get
  stepinfo = 'Test test_get/test_set properties'
  logger.info("\n#{'-' * 60}\n#{stepinfo}")
  cmd_prefix = PUPPET_BINPATH + "resource cisco_command_config 'cc' "

  logger.info('* create config')
  on(agent, cmd_prefix + "test_set='interface loopback1'")

  logger.info('* check config')
  on(agent, cmd_prefix + "test_get='incl loopback1'")
  # The output of test_get has changed in Puppet5 and newer versions of Puppet.
  # Old output:
  # cisco_command_config { 'cc':
  #   test_get => '
  # interface loopback1
  # interface loopback10
  # ',
  # }
  # New output:
  # cisco_command_config { 'cc':
  #   test_get => "\ninterface loopback1\ninterface loopback10\n",
  # }
  # Modifying the below regular expression to make ^ and \n optional.
  fail_test("TestStep :: set/get :: FAIL\nstdout:\n#{stdout}") unless
    stdout[/^?\n?interface loopback1/]

  logger.info("#{stepinfo} :: PASS\n#{'-' * 60}\n")
end

def cleanup(agent)
  test_set(agent, 'no feature bgp')
  interfaces = get_current_resource_instances(agent, 'cisco_interface')
  interfaces.each do |interface|
    if interface =~ %r{(l|L)oopback\s*1$}
      test_set(agent, 'no interface loopback1')
    end
  end
end

def test_harness_run_cc(tests, id, res_cmd)
  tests[:resource_name] = 'cisco_command_config'
  create_manifest_and_resource(tests, id)
  test_manifest(tests, id)
  test_idempotence(tests, id)

  # Command_config can only "set" configs, it can't check them with
  # puppet resource, so use res_cmd to do that part of the test
  if agent
    tests[id][:resource_cmd] = PUPPET_BINPATH + 'resource ' + res_cmd
  else
    tests[id][:resource_cmd] = "#{agentless_command} --resource #{res_cmd}"
  end
  test_resource(tests, id)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Basic multi-level configs")

  test_harness_run_cc(tests, :bgp, 'cisco_bgp')
  test_harness_run_cc(tests, :bgp_af, 'cisco_bgp_af')
  test_harness_run_cc(tests, :bgp_neighbor, 'cisco_bgp_neighbor')
  test_harness_run_cc(tests, :bgp_neighbor_af, 'cisco_bgp_neighbor_af')
  test_harness_run_cc(tests, :loopback, 'cisco_interface')

  # Cleanup before next test.
  cleanup(agent)
  test_harness_run_cc(tests, :control_characters, 'cisco_bgp_neighbor_af')

  if agent
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 2. test_set / test_get")
    cleanup(agent)
    test_set_get
  end
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
