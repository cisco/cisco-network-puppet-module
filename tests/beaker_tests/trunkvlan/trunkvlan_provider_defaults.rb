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
# TrunkVlan-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet TRUNKVLAN resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a TRUNKVLAN resource test that tests for default values for
# access_vlan, description, ipv4_proxy_arp, ipv4_redirects,
# negotiate_auto, shutdown, switchport_autostate_exclude,
# switchport_mode and switchport_vtp attributes of a
# cisco_interface resource when created with 'ensure' => 'present'.
# Trunk Standard VLANs are in the VLAN ID range 2..1005.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# Steps 2-4 deal with cisco_interface resource creation and its
# verification using Puppet Agent and the switch running-config.
# Steps 5-7 deal with cisco_interface resource deletion and its
# verification using Puppet Agent and the switch running-config.
#
# The testcode checks for exit_codes from Puppet Agent, Vegas shell and
# Bash shell command executions. For Vegas shell and Bash shell command
# string executions, this is the exit_code convention:
# 0 - successful command execution, > 0 - failed command execution.
# For Puppet Agent command string executions, this is the exit_code convention:
# 0 - no changes have occurred, 1 - errors have occurred,
# 2 - changes have occurred, 4 - failures have occurred and
# 6 - changes and failures have occurred.
# 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
# The testcode also uses RegExp pattern matching on stdout or output IO
# instance attributes of Result object from on() method invocation.
#
###############################################################################

# Require UtilityLib.rb and TrunkVlanLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../trunkvlanlib.rb', __FILE__)

result = 'PASS'
testheader = 'TRUNKVLAN Resource :: All Attributes Defaults'

# @test_name [TestCase] Executes defaults testcase for TRUNKVLAN Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Define PUPPETMASTER_MANIFESTPATH constant using puppet config cmd.
    UtilityLib.set_manifest_path(master, self)

    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TrunkVlanLib.create_trunkvlan_manifest_absent)

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config interface eth1/4')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [%r{interface Ethernet1/4}],
                                          false, self, logger)
    end

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TrunkVlanLib.create_trunkvlan_manifest_present)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ensure'                       => 'present',
                                            'access_vlan'                  => '128',
                                            'ipv4_proxy_arp'               => 'false',
                                            'ipv4_redirects'               => 'true',
                                            'negotiate_auto'               => 'true',
                                            'shutdown'                     => 'false',
                                            'switchport_autostate_exclude' => 'false',
                                            'switchport_mode'              => 'trunk',
                                            'switchport_vtp'               => 'false' },
                                          false, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Checks interface instance on agent using switch show cli cmds.
  step 'TestStep :: Check interface instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config interface eth1/4')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          [/switchport access vlan 128/],
                                          false, self, logger)
    end

    logger.info("Check interface instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TrunkVlanLib.create_trunkvlan_manifest_absent)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource absent manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Presence of AccessVLAN 1 implies absence of TrunkVLAN 128.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ensure'                       => 'present',
                                            'access_vlan'                  => '1',
                                            'ipv4_proxy_arp'               => 'false',
                                            'ipv4_redirects'               => 'true',
                                            'negotiate_auto'               => 'true',
                                            'shutdown'                     => 'false',
                                            'switchport_autostate_exclude' => 'false',
                                            'switchport_mode'              => 'trunk',
                                            'switchport_vtp'               => 'false' },
                                          false, self, logger)
    end

    logger.info("Check cisco_interface resource absence on agent :: #{result}")
  end

  # @step [Step] Checks interface instance on agent using switch show cli cmds.
  step 'TestStep :: Check interface instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config interface eth1/4')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          [/switchport access vlan 128/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
