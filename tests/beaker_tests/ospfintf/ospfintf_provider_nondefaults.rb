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
# OspfIntf-Provider-NonDefaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet OSPFINTF resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a OSPFINTF resource test that tests for nondefault values for
# cost, dead_interval, hello_interval, message_digest, message_digest_key_id
# and passive_interface attributes of a
# cisco_interface_ospf resource when created with 'ensure' => 'present'.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# Steps 2-4 deal with cisco_interface_ospf resource creation and its
# verification using Puppet Agent and the switch running-config.
# Steps 5-7 deal with cisco_interface_ospf resource deletion and its
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

# Require UtilityLib.rb and OspfIntfLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../ospfintflib.rb', __FILE__)

result = 'PASS'
testheader = 'OSPFINTF Resource :: All Attributes NonDefaults'

# @test_name [TestCase] Executes nondefaults testcase for OSPFINTF Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Define PUPPETMASTER_MANIFESTPATH constant using puppet config cmd.
    UtilityLib.set_manifest_path(master, self)

    # Expected exit_code is 0 since this is a vegas shell cmd.
    cmd_str = UtilityLib.get_vshell_cmd('conf t ; no feature ospf')
    on(agent, cmd_str)

    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config section ospf')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/feature ospf/],
                                          true, self, logger)
    end

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource nondefaults manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, OspfIntfLib.create_ospfintf_manifest_nondefaults)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource nondefaults manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_intf_ospf resource on agent using resource cmd.
  step 'TestStep :: Check cisco_intf_ospf resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface_ospf 'ethernet1/4 test'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ensure'                => 'present',
                                            'cost'                  => '100',
                                            'dead_interval'         => '80',
                                            'hello_interval'        => '20',
                                            'message_digest'        => 'false',
                                            'message_digest_key_id' => '0',
                                            'passive_interface'     => 'true' },
                                          false, self, logger)
    end

    logger.info("Check cisco_intf_ospf resource presence on agent :: #{result}")
  end

  # @step [Step] Checks ospfintf instance on agent using switch show cli cmds.
  step 'TestStep :: Check ospfintf instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config ospf')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          [
                                            /router ospf test/,
                                            %r{interface Ethernet1/4},
                                            /ip ospf cost 100/,
                                            /ip ospf dead-interval 80/,
                                            /ip ospf hello-interval 20/,
                                            /ip ospf passive-interface/,
                                            /ip router ospf test area 0.0.0.100/,
                                          ],
                                          false, self, logger)
    end

    logger.info("Check ospfintf instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, OspfIntfLib.create_ospfintf_manifest_absent)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource absent manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_intf_ospf resource on agent using resource cmd.
  step 'TestStep :: Check cisco_intf_ospf resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface_ospf 'ethernet1/4 test'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
                                          { 'ensure'                => 'present',
                                            'cost'                  => '100',
                                            'dead_interval'         => '80',
                                            'hello_interval'        => '20',
                                            'message_digest'        => 'false',
                                            'message_digest_key_id' => '0',
                                            'passive_interface'     => 'true' },
                                          true, self, logger)
    end

    logger.info("Check cisco_intf_ospf resource absence on agent :: #{result}")
  end

  # @step [Step] Checks ospfintf instance on agent using switch show cli cmds.
  step 'TestStep :: Check ospfintf instance absence on agent' do
    # Expected exit_code is 16 since this is a vegas shell cmd with exec error.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config ospf')
    on(agent, cmd_str, acceptable_exit_codes: [16]) do
      UtilityLib.search_pattern_in_output(stdout,
                                          [
                                            /router ospf test/,
                                            %r{interface Ethernet1/4},
                                            /ip ospf cost 100/,
                                            /ip ospf dead-interval 80/,
                                            /ip ospf hello-interval 20/,
                                            /ip ospf passive-interface/,
                                            /ip router ospf test area 0.0.0.100/,
                                          ],
                                          true, self, logger)
    end

    logger.info("Check ospfintf instance absence on agent :: #{result}")
  end

  # @step [Step] Verify ability to configure and update ospf area
  step 'TestStep :: Check ospfintf area change on agent' do
    area1 = '0.0.0.5'
    area2 = '0.0.0.6'
    on(master, OspfIntfLib.create_ospfintf_area_manifest(area1))
    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])
    # check for successfull configured area
    cmd_str = UtilityLib.get_vshell_cmd('show running-config ospf')
    on(agent, cmd_str, acceptable_exit_codes: [0]) do
      UtilityLib.search_pattern_in_output(stdout,
                                          [
                                            /router ospf test/,
                                            %r{interface Ethernet1/4},
                                            /ip router ospf test area #{area1}/,
                                          ],
                                          false, self, logger)
    end
    # update area to area2
    on(master, OspfIntfLib.create_ospfintf_area_manifest(area2))
    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])
    # check for successfull configured area
    cmd_str = UtilityLib.get_vshell_cmd('show running-config ospf')
    on(agent, cmd_str, acceptable_exit_codes: [0]) do
      UtilityLib.search_pattern_in_output(stdout,
                                          [
                                            /router ospf test/,
                                            %r{interface Ethernet1/4},
                                            /ip router ospf test area #{area2}/,
                                          ],
                                          false, self, logger)
    end
    # cleanup
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource cisco_interface_ospf 'ethernet1/4 test' ensure=absent", options)
    on(agent, cmd_str)

    logger.info("Check ospfintf area change on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
