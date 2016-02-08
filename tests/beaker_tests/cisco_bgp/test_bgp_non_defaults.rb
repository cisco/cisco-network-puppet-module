###############################################################################
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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
# bgp-provider-non-defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This BGP resource test verifies non-default values for all properties.
#
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

# Require UtilityLib.rb and BgpLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../bgplib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
result = 'PASS'
testheader = 'Resource cisco_bgp:: All non-default property values'

# Create puppet agent command
puppet_cmd = get_namespace_cmd(agent,
                               PUPPET_BINPATH + 'agent -t', options)
# Create commands to issue the puppet resource command for cisco_bgp
resource_default = get_namespace_cmd(agent,
                                     PUPPET_BINPATH + "resource cisco_bgp '#{BgpLib::ASN} default'", options)
resource_vrf1 = get_namespace_cmd(agent,
                                  PUPPET_BINPATH +
                                  "resource cisco_bgp '#{BgpLib::ASN} #{BgpLib::VRF1}'", options)
resource_vrf2 = get_namespace_cmd(agent,
                                  PUPPET_BINPATH +
                                  "resource cisco_bgp '#{BgpLib::ASN} #{BgpLib::VRF2}'", options)
platform = fact_on(agent, 'os.name')

# Define expected default values for cisco_bgp resource
expected_values = {
  'ensure'                                 => 'present',
  'router_id'                              => '192.168.0.55',
  'cluster_id'                             => '10.0.0.1',
  'confederation_id'                       => '99',
  'confederation_peers'                    => "['200.1', '23.4', '55', '88']",
  'enforce_first_as'                       => 'true',
  'fast_external_fallover'                 => 'false',
  'bestpath_always_compare_med'            => 'true',
  'bestpath_aspath_multipath_relax'        => 'true',
  'bestpath_compare_routerid'              => 'true',
  'bestpath_cost_community_ignore'         => 'true',
  'bestpath_med_confed'                    => 'true',
  'bestpath_med_missing_as_worst'          => 'true',
  'graceful_restart'                       => 'true',
  'graceful_restart_timers_restart'        => '130',
  'graceful_restart_timers_stalepath_time' => '310',
  'timer_bgp_keepalive'                    => '45',
  'timer_bgp_holdtime'                     => '110',
}
if platform != 'ios_xr'
  expected_values['bestpath_med_non_deterministic'] = 'true'
  expected_values['disable_policy_batching']        = 'true'
  expected_values['disable_policy_batching_ipv4']   = 'xx'
  expected_values['disable_policy_batching_ipv6']   = 'yy'
  expected_values['event_history_cli']              = 'size_medium'
  expected_values['event_history_detail']           = 'size_large'
  expected_values['event_history_events']           = 'size_disable'
  expected_values['event_history_periodic']         = 'false'
  expected_values['flush_routes']                   = 'true'
  expected_values['graceful_restart_helper']        = 'true'
  expected_values['isolate']                        = 'true'
  expected_values['log_neighbor_changes']           = 'true'
  expected_values['maxas_limit']                    = '50'
  expected_values['neighbor_down_fib_accelerate']   = 'true'
  expected_values['shutdown']                       = 'true'
  expected_values['suppress_fib_pending']           = 'true'
  expected_values['timer_bestpath_limit']           = '255'
  expected_values['timer_bestpath_limit_always']    = 'true'
else
  expected_values['nsr'] = 'true'
end

expected_values_vrf1 = {
  'ensure'                          => 'present',
  'route_distinguisher'             => 'auto',
  'router_id'                       => '192.168.0.66',
  'log_neighbor_changes'            => 'false',
  'bestpath_always_compare_med'     => 'true',
  'bestpath_aspath_multipath_relax' => 'true',
  'bestpath_compare_routerid'       => 'true',
  'bestpath_cost_community_ignore'  => 'true',
  'bestpath_med_missing_as_worst'   => 'true',
  'timer_bgp_keepalive'             => '46',
  'timer_bgp_holdtime'              => '111',
}
if platform != 'ios_xr'
  expected_values_vrf1['bestpath_med_confed']                    = 'true'
  expected_values_vrf1['bestpath_med_non_deterministic']         = 'true'
  expected_values_vrf1['cluster_id']                             = '55'
  expected_values_vrf1['confederation_id']                       = '33'
  expected_values_vrf1['confederation_peers']                    = "['200.1', '88', '99']"
  expected_values_vrf1['graceful_restart']                       = 'false'
  expected_values_vrf1['graceful_restart_timers_restart']        = '131'
  expected_values_vrf1['graceful_restart_timers_stalepath_time'] = '311'
  expected_values_vrf1['graceful_restart_helper']                = 'true'
  expected_values_vrf1['maxas_limit']                            = '55'
  expected_values_vrf1['neighbor_down_fib_accelerate']           = 'true'
  expected_values_vrf1['shutdown']                               = 'true'
  expected_values_vrf1['suppress_fib_pending']                   = 'false'
  expected_values_vrf1['timer_bestpath_limit']                   = '255'
  expected_values_vrf1['timer_bestpath_limit_always']            = 'true'
end

expected_values_vrf2 = {
  'ensure'                          => 'present',
  'route_distinguisher'             => '1.1.1.1:1',
  'router_id'                       => '192.168.0.77',
  'bestpath_always_compare_med'     => 'false',
  'bestpath_aspath_multipath_relax' => 'false',
  'bestpath_compare_routerid'       => 'false',
  'bestpath_cost_community_ignore'  => 'false',
  'bestpath_med_missing_as_worst'   => 'false',
  'log_neighbor_changes'            => 'false',
  'timer_bgp_keepalive'             => '48',
  'timer_bgp_holdtime'              => '114',
}
if platform != 'ios_xr'
  expected_values_vrf2['bestpath_med_confed']                    = 'false'
  expected_values_vrf2['bestpath_med_non_deterministic']         = 'false'
  expected_values_vrf2['cluster_id']                             = '10.0.0.2'
  expected_values_vrf2['confederation_id']                       = '32.88'
  expected_values_vrf2['confederation_peers'] = "['200.1', '23.4', '55', '88']"
  expected_values_vrf2['graceful_restart']                       = 'false'
  expected_values_vrf2['graceful_restart_timers_restart']        = '132'
  expected_values_vrf2['graceful_restart_timers_stalepath_time'] = '312'
  expected_values_vrf2['graceful_restart_helper']                = 'false'
  expected_values_vrf2['maxas_limit']                            = '60'
  expected_values_vrf2['neighbor_down_fib_accelerate']           = 'true'
  expected_values_vrf2['shutdown']                               = 'true'
  expected_values_vrf2['suppress_fib_pending']                   = 'false'
  expected_values_vrf2['timer_bestpath_limit']                   = '115'
  expected_values_vrf2['timer_bestpath_limit_always']            = 'false'
end

# Used to clarify true/false values for UtilityLib args.
test = {
  present: false,
  absent:  true,
}

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for cisco_bgp provider test'
  step "TestStep :: #{stepinfo}" do
    on(master, BgpLib.create_cleanup_bgp)
    on(agent, puppet_cmd, acceptable_exit_codes: [0, 2, 6])
    logger.info("#{stepinfo} :: #{result}")
  end

  # ----------------------
  # Default VRF Test Cases
  # ----------------------

  stepinfo = 'Apply resource ensure => present manifest'
  step "TestStep :: #{stepinfo}" do
    on(master, BgpLib.create_bgp_manifest_present_non_default(platform))
    on(agent, puppet_cmd, acceptable_exit_codes: [2])
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Check cisco_bgp resource using 'puppet resource' comand"
  step "TestStep :: #{stepinfo}" do
    on(agent, resource_default) do
      search_pattern_in_output(stdout, expected_values,
                               test[:present], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = 'Verify Idempotence'
  step "TestStep :: #{stepinfo}" do
    on(agent, puppet_cmd, acceptable_exit_codes: [0])
    logger.info("#{stepinfo} :: #{result}")
  end

  # --------------------------
  # Non-Default VRF Test Cases
  # --------------------------

  context = "vrf #{BgpLib::VRF1}"

  stepinfo = "Apply resource ensure => present manifest (#{context})"
  step "TestStep :: #{stepinfo}" do
    on(master, BgpLib.create_bgp_manifest_present_non_default_vrf1(platform))
    on(agent, puppet_cmd, acceptable_exit_codes: [2])
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Check cisco_bgp resource output on agent (#{context}"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_vrf1) do
      search_pattern_in_output(stdout, expected_values_vrf1,
                               test[:present], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Verify Idempotence (#{context})"
  step "TestStep :: #{stepinfo}" do
    on(agent, puppet_cmd, acceptable_exit_codes: [0])
    logger.info("#{stepinfo} :: #{result}")
  end

  context = "vrf #{BgpLib::VRF2}"

  stepinfo = "Apply resource ensure => present manifest (#{context})"
  step "TestStep :: #{stepinfo}" do
    on(master, BgpLib.create_bgp_manifest_present_non_default_vrf2(platform))
    on(agent, puppet_cmd, acceptable_exit_codes: [2])
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Check cisco_bgp resource output on agent (#{context}"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_vrf2) do
      search_pattern_in_output(stdout, expected_values_vrf2,
                               test[:present], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Verify Idempotence (#{context})"
  step "TestStep :: #{stepinfo}" do
    on(agent, puppet_cmd, acceptable_exit_codes: [0])
    logger.info("#{stepinfo} :: #{result}")
  end

  # ------------------
  # Verify coexistence
  # ------------------

  stepinfo = 'Verify default vrf remains unchanged'
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_default) do
      search_pattern_in_output(stdout, expected_values,
                               test[:present], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Verify vrf #{BgpLib::VRF1} remains unchanged"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_vrf1) do
      search_pattern_in_output(stdout, expected_values_vrf1,
                               test[:present], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Verify vrf #{BgpLib::VRF2} remains unchanged"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_vrf2) do
      search_pattern_in_output(stdout, expected_values_vrf2,
                               test[:present], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  # ---------------------------
  # Remove Resources and Verify
  # ---------------------------

  context = "vrf #{BgpLib::VRF1}"

  stepinfo = "Apply resource ensure => absent manifest (#{context})"
  step "TestStep :: #{stepinfo}" do
    on(master, BgpLib.create_bgp_manifest_absent_vrf1)
    on(agent, puppet_cmd, acceptable_exit_codes: [2])
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Verify resource is absent using puppet (#{context}"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_vrf1) do
      search_pattern_in_output(stdout, expected_values_vrf1,
                               test[:absent], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  context = "vrf #{BgpLib::VRF2}"

  stepinfo = "Apply resource ensure => absent manifest (#{context})"
  step "TestStep :: #{stepinfo}" do
    on(master, BgpLib.create_bgp_manifest_absent_vrf2)
    on(agent, puppet_cmd, acceptable_exit_codes: [2])
    logger.info("#{stepinfo} :: #{result}")
  end

  stepinfo = "Verify resource is absent using puppet (#{context}"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_vrf2) do
      search_pattern_in_output(stdout, expected_values_vrf2,
                               test[:absent], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end

  context = 'vrf default'

  stepinfo = "Verify resource is absent using puppet (#{context}"
  step "TestStep :: #{stepinfo})" do
    on(agent, resource_default) do
      search_pattern_in_output(stdout, expected_values,
                               test[:absent], self, logger)
    end
    logger.info("#{stepinfo} :: #{result}")
  end
end

logger.info("TestCase :: #{testheader} :: End")
