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
# RoutedIntf-Provider-Negatives.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet ROUTEDINTF resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a ROUTEDINTF resource test that tests for negative values for
# ensure, shutdown, switchport_mode, ipv4_address,
# ipv4_netmask_length, ipv4_proxy_arp and ipv4_redirects attributes of a
# cisco_interface resource when created with 'ensure' => 'present'.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# The next set of teststeps deal with attribute negative tests and their
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

# Require UtilityLib.rb and RoutedIntfLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../routedintflib.rb', __FILE__)

result = 'PASS'
testheader = 'ROUTEDINTF Resource :: All Attributes Negatives'

# @test_name [TestCase] Executes negatives testcase for ROUTEDINTF Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Define PUPPETMASTER_MANIFESTPATH constant using puppet config cmd.
    UtilityLib.set_manifest_path(master, self)

    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_switchport_access)

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config interface eth1/4')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/no switchport/],
                                          true, self, logger)
    end

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_ipv4addr_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ipv4_address' => RoutedIntfLib::IPV4ADDRESS_NEGATIVE },
                                          true, self, logger)
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
                                          [/^ *ip address #{RoutedIntfLib::IPV4ADDRESS_NEGATIVE}/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_ipv4masklen_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, \
                                          { 'ipv4_netmask_length' => RoutedIntfLib::IPV4MASKLEN_NEGATIVE },
                                          true, self, logger)
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
                                          [%r{^ *ip address 192.168.1.1/#{RoutedIntfLib::IPV4MASKLEN_NEGATIVE}}],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_shutdown_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'shutdown' => RoutedIntfLib::SHUTDOWN_NEGATIVE },
                                          true, self, logger)
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
                                          [/^ *shutdown/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_ipv4proxyarp_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ipv4_proxy_arp' => RoutedIntfLib::IPV4PROXYARP_NEGATIVE },
                                          true, self, logger)
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
                                          [/^ *ip proxy-arp/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_ipv4redir_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ipv4_redirects' => RoutedIntfLib::IPV4REDIR_NEGATIVE },
                                          true, self, logger)
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
                                          [/^ *ip redirects/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       RoutedIntfLib.create_routedintf_manifest_encap_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'encapsulation_dot1q' => RoutedIntfLib::ENCAP_DOT1Q_NEGATIVE },
                                          true, self, logger)
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
                                          [/encapsulation dot1q/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_mtu_negative)

    # Expected exit_code is 6 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'mtu' => RoutedIntfLib::MTU_NEGATIVE },
                                          true, self, logger)
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
                                          [/mtu/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       RoutedIntfLib.create_routedintf_manifest_trunk_allowed_negative)

    # Expected exit_code is 6 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'switchport_trunk_allowed_vlan' => RoutedIntfLib::TRUNK_ALLOWED_NEGATIVE },
                                          true, self, logger)
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
                                          [/switchport trunk allowed vlan/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       RoutedIntfLib.create_routedintf_manifest_trunk_native_negative)

    # Expected exit_code is 6 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'switchport_trunk_native_vlan' => RoutedIntfLib::TRUNK_NATIVE_NEGATIVE },
                                          true, self, logger)
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
                                          [/switchport trunk native vlan/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_vrf_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface 'ethernet1/4'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'vrf' => RoutedIntfLib::VRF_NEGATIVE },
                                          true, self, logger)
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
                                          [/vrf member/],
                                          true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
