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
# --------------
# AaaGroup-Provider-Negatives.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet AAAGROUP resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a AAAGROUP resource test that tests for negative values for
# ensure, group and acl attributes of a
# cisco_aaa_group_tacacs resource when created with 'ensure' => 'present'.
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

# Require UtilityLib.rb and AaaGroupLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../aaagrouplib.rb', __FILE__)
# Require TacacsServer because vsh can't enable/disable feature tacacs
require File.expand_path('../../cisco_tacacs_server/tacacsserverlib.rb', __FILE__)

result = 'PASS'
testheader = 'AAAGROUP Resource :: All Attributes Negatives'

# Check platform type and skip if necessary.
unless /n(3|9)k/.match(platform)
  msg = "Test not supported on this platform: #{platform}"
  prereq_skip(testheader, self, msg)
end

# @test_name [TestCase] Executes negatives testcase for AAAGROUP Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerLib.create_tacacsserver_absent)

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    # Expected exit_code is 16 since this is a vegas shell cmd with exec error.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs')
    on(agent, cmd_str, acceptable_exit_codes: [16]) do
      search_pattern_in_output(stdout,
                               [/feature tacacs\+/],
                               true, self, logger)
    end

    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerLib.create_tacacsserver_present)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AaaGroupLib.create_aaagroup_manifest_deadtime_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_aaa_group resource on agent using resource cmd.
  step 'TestStep :: Check cisco_aaa_group resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_aaa_group_tacacs 'test'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        { 'deadtime' => AaaGroupLib::DEADTIME_NEGATIVE },
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group resource absence on agent :: #{result}")
  end

  # @step [Step] Checks aaagroup instance on agent using switch show cli cmds.
  step 'TestStep :: Check cisco_aaa_group instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs all')
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        [/aaa group server tacacs\+ test/,
         /^\s+deadtime #{AaaGroupLib::DEADTIME_NEGATIVE}/],
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AaaGroupLib.create_aaagroup_manifest_vrf_name_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_aaa_group resource on agent using resource cmd.
  step 'TestStep :: Check cisco_aaa_group resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_aaa_group_tacacs 'test'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        { 'vrf_name' => AaaGroupLib::VRF_NAME_NEGATIVE },
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group resource absence on agent :: #{result}")
  end

  # @step [Step] Checks aaagroup instance on agent using switch show cli cmds.
  step 'TestStep :: Check cisco_aaa_group instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs all')
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        [/aaa group server tacacs\+ test/,
         /^\s+use-vrf #{AaaGroupLib::VRF_NAME_NEGATIVE}/],
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       AaaGroupLib.create_aaagroup_manifest_source_interface_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_aaa_group resource on agent using resource cmd.
  step 'TestStep :: Check cisco_aaa_group resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_aaa_group_tacacs 'test'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        { 'source_interface' => AaaGroupLib::SOURCE_INTERFACE_NEGATIVE },
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group resource absence on agent :: #{result}")
  end

  # @step [Step] Checks aaagroup instance on agent using switch show cli cmds.
  step 'TestStep :: Check cisco_aaa_group instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs all')
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        [/aaa group server tacacs\+ test/,
         /^\s+source-interface #{AaaGroupLib::SOURCE_INTERFACE_NEGATIVE}/],
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master,
       AaaGroupLib.create_aaagroup_manifest_server_hosts_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_aaa_group resource on agent using resource cmd.
  step 'TestStep :: Check cisco_aaa_group resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_aaa_group_tacacs 'test'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        { 'server_hosts' => AaaGroupLib::SERVER_HOSTS_NEGATIVE },
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group resource absence on agent :: #{result}")
  end

  # @step [Step] Checks aaagroup instance on agent using switch show cli cmds.
  step 'TestStep :: Check cisco_aaa_group instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs all')
    on(agent, cmd_str) do
      search_pattern_in_output(
        stdout,
        [/aaa group server tacacs\+ test/,
         /^\s+server #{AaaGroupLib::SERVER_HOSTS_NEGATIVE}/],
        true, self, logger)
    end

    logger.info("Check cisco_aaa_group instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
