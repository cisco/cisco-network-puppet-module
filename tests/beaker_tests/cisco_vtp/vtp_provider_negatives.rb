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
# Vtp-Provider-Negatives.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet VTP resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a VTP resource test that tests for negatives values for
# ensure, domain, filename, password and version attributes of a
# cisco_vtp resource when created with 'ensure' => 'present'.
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

# Require UtilityLib.rb and VtpLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../vtplib.rb', __FILE__)

result = 'PASS'
testheader = 'VTP Resource :: All Attributes Negatives'

# @test_name [TestCase] Executes negatives testcase for VTP Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Expected exit_code is 0 since this is a vegas shell cmd with no change.
    cmd_str = get_vshell_cmd('conf t ; no feature vtp')
    on(agent, cmd_str)

    # Expected exit_code is 16 since this is a vegas shell cmd with exec error.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config vtp')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/feature vtp/],
                               true, self, logger)
    end

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VtpLib.create_vtp_manifest_domain_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_vtp resource on agent using resource cmd.
  step 'TestStep :: Check cisco_vtp resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource cisco_vtp', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'domain' => VtpLib::DOMAIN_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_vtp resource absence on agent :: #{result}")
  end

  # @step [Step] Checks vtp instance on agent using switch show cli cmds.
  step 'TestStep :: Check vtp instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config vtp')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/vtp domain #{VtpLib::DOMAIN_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check vtp instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VtpLib.create_vtp_manifest_filename_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_vtp resource on agent using resource cmd.
  step 'TestStep :: Check cisco_vtp resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource cisco_vtp', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'filename' => VtpLib::FILENAME_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_vtp resource absence on agent :: #{result}")
  end

  # @step [Step] Checks vtp instance on agent using switch show cli cmds.
  step 'TestStep :: Check vtp instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config vtp')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/vtp filename #{VtpLib::FILENAME_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check vtp instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VtpLib.create_vtp_manifest_password_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_vtp resource on agent using resource cmd.
  step 'TestStep :: Check cisco_vtp resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource cisco_vtp', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'password' => VtpLib::PASSWORD_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_vtp resource absence on agent :: #{result}")
  end

  # @step [Step] Checks vtp instance on agent using switch show cli cmds.
  step 'TestStep :: Check vtp instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config vtp')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/vtp password #{VtpLib::PASSWORD_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check vtp instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VtpLib.create_vtp_manifest_version_negative)

    # Expected exit_code is 6 since this is a puppet agent cmd with failure.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_vtp resource on agent using resource cmd.
  step 'TestStep :: Check cisco_vtp resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource cisco_vtp', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'version' => VtpLib::VERSION_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_vtp resource absence on agent :: #{result}")
  end

  # @step [Step] Checks vtp instance on agent using switch show cli cmds.
  step 'TestStep :: Check vtp instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config vtp')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/vtp version #{VtpLib::VERSION_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check vtp instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
