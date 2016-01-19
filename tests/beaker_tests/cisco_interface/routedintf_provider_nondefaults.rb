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
# RoutedIntf-Provider-NonDefaults.rb
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
# This is a ROUTEDINTF resource test that tests for nondefault values for
# ensure, shutdown, switchport_mode, ipv4_address,
# ipv4_netmask_length, ipv4_proxy_arp and ipv4_redirects attributes of a
# cisco_interface resource when created with 'ensure' => 'present'.
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

# Require UtilityLib.rb and RoutedIntfLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../routedintflib.rb', __FILE__)

result = 'PASS'
testheader = 'ROUTEDINTF Resource :: All Attributes NonDefaults'
test_intf = 'ethernet1/4'

# @test_name [TestCase] Executes nondefaults testcase for ROUTEDINTF Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Remove any stale interface IP addresses from testbed.
    interface_ip_cleanup(agent)

    # Remove any stale config from test interface
    interface_cleanup(agent, test_intf)

    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_switchport_access)

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd("show running-config interface #{test_intf}")
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, [/no switchport/],
                               true, self, logger)
    end

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] create acl non defaults manifest.
  step 'TestStep :: Create acl nondefaults manifest' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_acl_manifest_nondefaults)

    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource cisco_acl ', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [
                                 /ipv4 v4acl1/,
                                 /ipv4 v4acl2/,
                                 /ipv6 v6acl1/,
                                 /ipv6 v6acl2/,
                               ],
                               false, self, logger)
    end

    logger.info("create acl non defaults manifest :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource nondefaults manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_nondefaults)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource nondefaults manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_interface '#{test_intf}'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'                        => 'present',
                                 'ipv4_address'                  => '192.168.1.1',
                                 'ipv4_netmask_length'           => '16',
                                 'ipv4_address_secondary'        => '10.0.55.55',
                                 'ipv4_netmask_length_secondary' => '24',
                                 'ipv4_pim_sparse_mode'          => 'true',
                                 'ipv4_proxy_arp'                => 'true',
                                 'ipv4_redirects'                => 'false',
                                 'mtu'                           => '1556',
                                 'speed'                         => '100',
                                 'duplex'                        => 'full',
                                 'shutdown'                      => 'true',
                                 'switchport_autostate_exclude'  => 'false',
                                 'switchport_mode'               => 'disabled',
                                 'switchport_vtp'                => 'false',
                                 'vrf'                           => 'test1',
                                 'ipv4_acl_in'                   => 'v4acl1',
                                 'ipv4_acl_out'                  => 'v4acl2',
                                 'ipv6_acl_in'                   => 'v6acl1',
                                 'ipv6_acl_out'                  => 'v6acl2',
                               },
                               false, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Checks interface instance on agent using switch show cli cmds.
  step 'TestStep :: Check interface instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd("show running-config interface #{test_intf} all")
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [
                                 %r{ip address 192.168.1.1/16},
                                 /no switchport/,
                                 /no ip redirects/,
                                 /ip pim sparse-mode/,
                                 /ip proxy-arp/,
                                 /mtu 1556/,
                                 /speed 100/,
                                 /duplex full/,
                                 /vrf member test1/,
                               ],
                               false, self, logger)
    end

    logger.info("Check interface instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource nondefaults manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_subinterface)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource nondefaults manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_interface '#{test_intf}.1'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'              => 'present',
                                 'encapsulation_dot1q' => '30' },
                               false, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Checks interface instance on agent using switch show cli cmds.
  step 'TestStep :: Check interface instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd("show running-config interface #{test_intf}.1")
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, [/encapsulation dot1q 30/],
                               false, self, logger)
    end

    logger.info("Check interface instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource nondefaults manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       RoutedIntfLib.create_routedintf_manifest_switchport_trunk_nondefaults)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource nondefaults manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_interface '#{test_intf}'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'                        => 'present',
                                 'switchport_trunk_allowed_vlan' => '30,40',
                                 'switchport_trunk_native_vlan'  => '20' },
                               false, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Checks interface instance on agent using switch show cli cmds.
  step 'TestStep :: Check interface instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd("show running-config interface #{test_intf}")
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/switchport trunk allowed vlan 30,40/,
                                /switchport trunk native vlan 20/],
                               false, self, logger)
    end

    logger.info("Check interface instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RoutedIntfLib.create_routedintf_manifest_switchport_access)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource absent manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Presence of switchport_mode => 'access' implies absence of RoutedINTF.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_interface '#{test_intf}'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'                       => 'present',
                                 'access_vlan'                  => '1',
                                 'ipv4_pim_sparse_mode'         => 'false',
                                 'ipv4_proxy_arp'               => 'false',
                                 'ipv4_redirects'               => 'true',
                                 'shutdown'                     => 'false',
                                 'switchport_autostate_exclude' => 'false',
                                 'switchport_mode'              => 'access',
                                 'switchport_vtp'               => 'false' },
                               false, self, logger)
    end

    logger.info("Check cisco_interface resource absence on agent :: #{result}")
  end

  # @step [Step] Checks interface instance on agent using switch show cli cmds.
  step 'TestStep :: Check interface instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd("show running-config interface #{test_intf}")
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [
                                 %r{ip address 192.168.1.1/16},
                                 /no switchport/,
                                 /no ip redirects/,
                                 /ip pim sparse-mode/,
                                 /ip proxy-arp/,
                               ],
                               true, self, logger)
    end

    logger.info("Check interface instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       RoutedIntfLib.create_routedintf_manifest_channel_group)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_interface '#{test_intf}'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'        => 'present',
                                 'channel_group' => '200' },
                               false, self, logger)
    end
    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # Remove any stale config from test interface
  interface_cleanup(agent, test_intf)

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
