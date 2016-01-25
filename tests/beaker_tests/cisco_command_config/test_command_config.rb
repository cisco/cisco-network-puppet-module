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
# TestCase Name:
# -------------
# test_command_config.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet cisco_command_config resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_command_config'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
#
tests = {
  master: master,
  agent:  agent,
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:code] - (Optional) override the default exit code in some tests.
#
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:puppet_resource] - Puppet resource used to verify the configuration
#   applied by the cisco_command_config resource.
#
tests['configure_bgp'] = {
  puppet_resource: 'cisco_bgp',
  platform:        'n(3|5|6|7|9)k',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the node.
  manifest_props:  "
    command                  => '
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
        log-neighbor-changes',
  ",
  resource_props:  {
    'ensure'                                 => 'present',
    'bestpath_always_compare_med'            => 'true',
    'bestpath_aspath_multipath_relax'        => 'true',
    'bestpath_compare_routerid'              => 'true',
    'bestpath_cost_community_ignore'         => 'true',
    'bestpath_med_confed'                    => 'true',
    'bestpath_med_non_deterministic'         => 'true',
    'cluster_id'                             => '172.5.5.5',
    'confederation_id'                       => '50',
    'confederation_peers'                    => '327686 327685 200608 5000 6000 32 43',
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

tests['configure_bgp_af'] = {
  puppet_resource: 'cisco_bgp_af',
  platform:        'n(3|5|6|7|9)k',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the node.
  manifest_props:  "
    command                  => '
      feature bgp
      router bgp 55
        address-family ipv4 unicast
          dampening',
  ",
  resource_props:  {
    'ensure'                      => 'present',
    'dampening_state'             => 'true',
    'dampening_half_time'         => '15',
    'dampening_max_suppress_time' => '45',
    'dampening_reuse_time'        => '750',
    'dampening_suppress_time'     => '2000',
  },
}

tests['configure_bgp_neighbor'] = {
  puppet_resource: 'cisco_bgp_neighbor',
  platform:        'n(3|5|6|7|9)k',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the node.
  manifest_props:  "
    command                  => '
      feature bgp
      router bgp 55
        neighbor 1.1.1.1
          timers 90 270',
  ",
  resource_props:  {
    'ensure'           => 'present',
    'timers_keepalive' => '90',
    'timers_holdtime'  => '270',
  },
}

tests['configure_bgp_neighbor_af'] = {
  puppet_resource: 'cisco_bgp_neighbor_af',
  platform:        'n(3|5|6|7|9)k',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the node.
  manifest_props:  "
    command                  => '
      feature bgp
      router bgp 55
        neighbor 1.1.1.1
          address-family ipv6 unicast
            capability additional-paths send',
  ",
  resource_props:  {
    'ensure'                => 'present',
    'additional_paths_send' => 'enable',
  },
}

tests['configure_loopback_interface'] = {
  puppet_resource: 'cisco_interface',
  # Command indentation is very important!
  # Make sure config appears exactly how it nvgens on the switch.
  manifest_props:  "
    command                  => '
      interface loopback1
        description configured_by_puppet',
  ",
  resource_props:  {
    'description' => 'configured_by_puppet'
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command used to verify
# the configuration applied by the cisco_command_config resource.
def puppet_resource_cmd(tests, id)
  cmd = PUPPET_BINPATH + "resource #{tests[id][:puppet_resource]}"
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_cisco_command_config(tests, id)
  manifest = tests[id][:manifest_props]
  tests[id][:resource] = tests[id][:resource_props]

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_cisco_command_config :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_command_config { '#{tests[id][:title_pattern]}':
      #{manifest}
    }
  }
EOF"
end

def test_harness_cisco_command_config(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:resource_cmd] = puppet_resource_cmd(tests, id)

  # Build the manifest for this test
  build_manifest_cisco_command_config(tests, id)

  test_harness_common(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nApply cisco_command_config test.")

  # Cleanup any existing resources.
  tests.keys.each do |id|
    resource_absent_cleanup(agent, tests[id][:puppet_resource]) unless
      tests[id][:puppet_resource].nil?
  end

  # -----------------------------------
  id = 'configure_bgp'
  tests[id][:desc] = '1.1 Apply BGP Config'
  test_harness_cisco_command_config(tests, id)

  id = 'configure_bgp_af'
  tests[id][:desc] = '1.2 Apply BGP AF Config'
  test_harness_cisco_command_config(tests, id)

  id = 'configure_bgp_neighbor'
  tests[id][:desc] = '1.3 Apply BGP Neighbor Config'
  test_harness_cisco_command_config(tests, id)

  id = 'configure_bgp_neighbor_af'
  tests[id][:desc] = '1.4 Apply BGP Neighbor AF Config'
  test_harness_cisco_command_config(tests, id)

  id = 'configure_loopback_interface'
  tests[id][:desc] = '1.5 Apply INTERFACE Config'
  test_harness_cisco_command_config(tests, id)
end

logger.info('TestCase :: # {testheader} :: End')
