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
# bgp-provider-title-patterns.rb
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
# This BGP resource test verifies cisco_bgp title patterns.
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
require File.expand_path("../../lib/utilitylib.rb", __FILE__)
require File.expand_path("../bgplib.rb", __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
result = 'PASS'
testheader = "Resource cisco_bgp:: Verify Title Patterns"

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)
# Create puppet agent command
puppet_cmd = UtilityLib.get_namespace_cmd(agent,
  UtilityLib::PUPPET_BINPATH + "agent -t", options)
# Create command to disable bgp feature
disable_bgp = UtilityLib.get_vshell_cmd("conf t ; no feature bgp")
# Create command to show the bgp running configuration
show_run_bgp = UtilityLib.get_vshell_cmd("show running-config section bgp")
# Create commands to issue the puppet resource command for cisco_bgp
resource_default = UtilityLib.get_namespace_cmd(agent,
  UtilityLib::PUPPET_BINPATH + "resource cisco_bgp '#{BgpLib::ASN} default'", options)
resource_vrf1 = UtilityLib.get_namespace_cmd(agent,
  UtilityLib::PUPPET_BINPATH +
  "resource cisco_bgp '#{BgpLib::ASN} #{BgpLib::VRF1}'", options)
resource_asdot = UtilityLib.get_namespace_cmd(agent,
  UtilityLib::PUPPET_BINPATH +
  "resource cisco_bgp '#{BgpLib::ASN_ASPLAIN} #{BgpLib::VRF1}'", options)

# Define expected default values for cisco_bgp resource
expected_default_values = {
  'ensure'                                 => 'present',
  'shutdown'                               => 'false',
  'suppress_fib_pending'                   => 'false',
  'log_neighbor_changes'                   => 'false',
  'bestpath_always_compare_med'            => 'false',
  'bestpath_aspath_multipath_relax'        => 'false',
  'bestpath_compare_routerid'              => 'false',
  'bestpath_cost_community_ignore'         => 'false',
  'bestpath_med_confed'                    => 'false',
  'bestpath_med_non_deterministic'         => 'false',
  'graceful_restart'                       => 'true',
  'graceful_restart_timers_restart'        => '120',
  'graceful_restart_timers_stalepath_time' => '300',
  'graceful_restart_helper'                => 'false',
  'timer_bgp_keepalive'                    => '60',
  'timer_bgp_holdtime'                     => '180',
  'timer_bestpath_limit'                   => '300',
  'timer_bestpath_limit_always'            => 'false',
}

# Used to clarify true/false values for UtilityLib args.
test = {
  :present => false,
  :absent  => true,
}

test_name "TestCase :: #{testheader}" do

  stepinfo = "Setup switch for cisco_bgp provider test"
  step "TestStep :: #{stepinfo}" do

    # TODO: This currently hangs and never complete - file bug
    #cmd_str = UtilityLib.get_vshell_cmd("conf t ; no feature bgp")
    #on(agent, cmd_str)

    on(agent, show_run_bgp) do
      UtilityLib.search_pattern_in_output(stdout, [/feature bgp/],
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  # Validate manifests that create a cisco_bgp resource with the following
  # attributes using various title patterns.
  #
  # asn => #{BgpLib::ASN}
  # vrf => 'default
  # (all_other_attributes => default values)

  method_list = [
    'create_bgp_manifest_title_pattern1',
    'create_bgp_manifest_title_pattern2',
    'create_bgp_manifest_title_pattern3',
    'create_bgp_manifest_title_pattern4',
    'create_bgp_manifest_title_pattern5',
  ]

  method_list.each do |m|

    current_manifest = BgpLib.send("#{m}")

    stepinfo = "Apply title patterns manifest: #{m}"
    step "TestStep :: #{stepinfo}" do
      on(master, current_manifest)
      on(agent, puppet_cmd, {:acceptable_exit_codes => [2]})
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Check cisco_bgp resource using 'puppet resource' comand"
    step "TestStep :: #{stepinfo}" do
      on(agent, resource_default) do
        UtilityLib.search_pattern_in_output(stdout, expected_default_values,
          test[:present], self, logger)
      end
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Apply title patterns manifest: ensure => absent"
    step "TestStep :: #{stepinfo}" do
      on(master, BgpLib.create_bgp_manifest_absent())
      on(agent, puppet_cmd, {:acceptable_exit_codes => [2]})
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Verify resource is absent using puppet"
    step "TestStep :: #{stepinfo})" do
      on(agent, resource_default) do
        UtilityLib.search_pattern_in_output(stdout, expected_default_values,
          test[:absent], self, logger)
      end
      logger.info("#{stepinfo} :: #{result}")
    end

  end

  # Validate manifests that create a cisco_bgp resource with the following
  # attributes using various title patterns.
  #
  # asn => #{BgpLib::ASN}
  # vrf => #{BgpLib::VRF1}
  # (all_other_attributes => default values)

  method_present_list = [
    'create_bgp_manifest_title_pattern6',
    'create_bgp_manifest_title_pattern7',
    'create_bgp_manifest_title_pattern8',
  ]

  method_absent_list = [
    'create_bgp_manifest_title_pattern6_remove',
    'create_bgp_manifest_title_pattern7_remove',
    'create_bgp_manifest_title_pattern8_remove',
  ]

  method_present_list.zip(method_absent_list) do |mp,ma|

    current_manifest_present = BgpLib.send("#{mp}")
    current_manifest_absent = BgpLib.send("#{ma}")

    stepinfo = "Apply title patterns manifest: #{mp}"
    step "TestStep :: #{stepinfo}" do
      on(master, current_manifest_present)
      on(agent, puppet_cmd, {:acceptable_exit_codes => [2]})
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Check cisco_bgp resource using 'puppet resource' comand"
    step "TestStep :: #{stepinfo}" do
      on(agent, resource_vrf1) do
        UtilityLib.search_pattern_in_output(stdout, expected_default_values,
          test[:present], self, logger)
      end
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Apply title patterns manifest: #{ma}"
    step "TestStep :: #{stepinfo}" do
      on(master, current_manifest_absent)
      on(agent, puppet_cmd, {:acceptable_exit_codes => [2]})
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Verify resource is absent using puppet"
    step "TestStep :: #{stepinfo})" do
      on(agent, resource_vrf1) do
        UtilityLib.search_pattern_in_output(stdout, expected_default_values,
          test[:absent], self, logger)
      end
      logger.info("#{stepinfo} :: #{result}")
    end

  end

  # Validate manifests that create a cisco_bgp resource with the following
  # attributes using various title patterns.
  #
  # asn => #{BgpLib::ASN_ASDOT}
  # vrf => #{BgpLib::VRF1}
  # (all_other_attributes => default values)

  method_present_list = [
    'create_bgp_manifest_title_pattern9',
    'create_bgp_manifest_title_pattern10',
    'create_bgp_manifest_title_pattern11',
  ]

  method_absent_list = [
    'create_bgp_manifest_title_pattern9_remove',
    'create_bgp_manifest_title_pattern10_remove',
    'create_bgp_manifest_title_pattern11_remove',
  ]

  method_present_list.zip(method_absent_list) do |mp,ma|

    current_manifest_present = BgpLib.send("#{mp}")
    current_manifest_absent = BgpLib.send("#{ma}")

    stepinfo = "Apply title patterns manifest: #{mp}"
    step "TestStep :: #{stepinfo}" do
      on(master, current_manifest_present)
      on(agent, puppet_cmd, {:acceptable_exit_codes => [2]})
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Check cisco_bgp resource using 'puppet resource' comand"
    step "TestStep :: #{stepinfo}" do
      on(agent, resource_asdot) do
        UtilityLib.search_pattern_in_output(stdout, expected_default_values,
          test[:present], self, logger)
      end
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Apply title patterns manifest: #{ma}"
    step "TestStep :: #{stepinfo}" do
      on(master, current_manifest_absent)
      on(agent, puppet_cmd, {:acceptable_exit_codes => [2]})
      logger.info("#{stepinfo} :: #{result}")
    end

    stepinfo = "Verify resource is absent using puppet"
    step "TestStep :: #{stepinfo})" do
      on(agent, resource_asdot) do
        UtilityLib.search_pattern_in_output(stdout, expected_default_values,
          test[:absent], self, logger)
      end
      logger.info("#{stepinfo} :: #{result}")
    end

  end

end

logger.info("TestCase :: #{testheader} :: End")
