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
# TacacsServerHost-Provider-Negatives.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet TACACSSERVERHOST testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a TACACSSERVERHOST resource test that tests for negative values for
# ensure, port, timeout, encryption_type and encryption_password attributes of a
# cisco_tacacs_server_host resource when created with 'ensure' => 'present'.
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

# Require UtilityLib.rb and TacacsServerHostLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../tacacsserverhostlib.rb', __FILE__)
require File.expand_path('../../cisco_tacacs_server/tacacsserverlib.rb', __FILE__)

result = 'PASS'
testheader = 'TACACSSERVERHOST Resource :: All Attributes Negatives'

# @test_name [TestCase] Executes negatives testcase for TACACSSERVERHOST.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerLib.create_tacacsserver_absent)

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    # Expected exit_code is 16 since this is a vegas shell cmd with exec error.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs')
    on(agent, cmd_str, acceptable_exit_codes: [16]) do
      search_pattern_in_output(stdout,
                               [/feature tacacs\+/],
                               true, self, logger)
    end

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerHostLib.create_tacacsserverhost_timeout_negative)

    # Expected exit_code is 6 since this is a puppet agent cmd with failure.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_tacacs_server_host on agent using resource cmd.
  step 'TestStep :: Check cisco_tacacs_server_host absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource cisco_tacacs_server_host'
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'timeout' => TacacsServerHostLib::TIMEOUT_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_tacacs_server_host absence on agent :: #{result}")
  end

  # @step [Step] Checks tacacsserverhost instance on agent using show cli cmds.
  step 'TestStep :: Check tacacsserverhost instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/timeout #{TacacsServerHostLib::TIMEOUT_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check tacacsserverhost instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerHostLib.create_tacacsserverhost_port_negative)

    # Expected exit_code is 6 since this is a puppet agent cmd with failure.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [6])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_tacacs_server_host on agent using resource cmd.
  step 'TestStep :: Check cisco_tacacs_server_host absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource cisco_tacacs_server_host'
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'port' => TacacsServerHostLib::PORT_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_tacacs_server_host absence on agent :: #{result}")
  end

  # @step [Step] Checks tacacsserverhost instance on agent using show cli cmds.
  step 'TestStep :: Check tacacsserverhost instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/port #{TacacsServerHostLib::PORT_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check tacacsserverhost instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerHostLib.create_tacacsserverhost_type_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_tacacs_server_host on agent using resource cmd.
  step 'TestStep :: Check cisco_tacacs_server_host absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource cisco_tacacs_server_host'
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'encryption_type' => TacacsServerHostLib::ENCRYPTYPE_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_tacacs_server_host absence on agent :: #{result}")
  end

  # @step [Step] Checks tacacsserverhost instance on agent using show cli cmds.
  step 'TestStep :: Check tacacsserverhost instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/samplehost1 key #{TacacsServerHostLib::ENCRYPTYPE_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check tacacsserverhost instance absence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsServerHostLib.create_tacacsserverhost_passwd_negative)

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_tacacs_server_host on agent using resource cmd.
  step 'TestStep :: Check cisco_tacacs_server_host absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource cisco_tacacs_server_host'
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'encryption_password' => TacacsServerHostLib::ENCRYPPASSWD_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_tacacs_server_host absence on agent :: #{result}")
  end

  # @step [Step] Checks tacacsserverhost instance on agent using show cli cmds.
  step 'TestStep :: Check tacacsserverhost instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config tacacs')
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               [/samplehost1 key 7 #{TacacsServerHostLib::ENCRYPPASSWD_NEGATIVE}/],
                               true, self, logger)
    end

    logger.info("Check tacacsserverhost instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
