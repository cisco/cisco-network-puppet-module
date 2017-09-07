###############################################################################
# Copyright (c) 2014-2017 Cisco and/or its affiliates.
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
# RadiusGlobal-Provider-NonDefaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a radius_global resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a radius_global resource test that tests non-default attributes of
# tacacs_global resource.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# Steps 2+ deal with radius_global and its
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

# Require UtilityLib.rb and SnmpGroupLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../radius_globallib.rb', __FILE__)

result = 'PASS'
testheader = 'radius_global Resource :: All Attributes Defaults'

def cleanup
  logger.info('Testcase Cleanup:')

  command_config(agent, 'radius-server timeout 5')
  command_config(agent, 'radius-server retransmit 1')
  command_config(agent, 'no ip radius source-interface')

  # To remove a configured key we have ot know the key value
  on(agent, get_vshell_cmd('show running-config radius | include key'))
  key = stdout.match('^radius-server key (\d+)\s+(.*)')
  command_config(agent, "no radius-server key #{key[1]} #{key[2]}", "removing key #{key[2]}") if key
end

# @test_name [TestCase] Executes non-defaults testcase for radius_global Resource.
test_name "TestCase :: #{testheader}" do
  cleanup
  teardown { cleanup }

  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider' do
    logger.info('Setup switch for provider')
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RadiusGlobalLib.create_radius_global_manifest)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks radius_global resource on agent using resource cmd.
  step 'TestStep :: Check radius_global resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource radius_global default'
    on(agent, cmd_str)
    output = stdout
    search_pattern_in_output(output, { 'key' => add_quotes('44444444') },
                             false, self, logger)
    search_pattern_in_output(output, { 'key_format' => '7' },
                             false, self, logger)
    search_pattern_in_output(output, { 'retransmit_count' => '4' },
                             false, self, logger)
    search_pattern_in_output(output, { 'source_interface' => 'loopback0' },
                             false, self, logger)
    search_pattern_in_output(output, { 'timeout' => '2' },
                             false, self, logger)

    logger.info("Check radius_global resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RadiusGlobalLib.create_radius_global_manifest_change)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks radius_global resource on agent using resource cmd.
  step 'TestStep :: Check radius_global resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource radius_global default'
    on(agent, cmd_str)
    output = stdout
    search_pattern_in_output(output, { 'key' => add_quotes('55555555') },
                             false, self, logger)
    search_pattern_in_output(output, { 'key_format' => '7' },
                             false, self, logger)
    search_pattern_in_output(output, { 'retransmit_count' => '2' },
                             false, self, logger)
    search_pattern_in_output(output, { 'source_interface' => 'loopback1' },
                             false, self, logger)
    search_pattern_in_output(output, { 'timeout' => '2' },
                             false, self, logger)

    logger.info("Check radius_global resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, RadiusGlobalLib.create_radius_global_default)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks radius_global resource on agent using resource cmd.
  step 'TestStep :: Check radius_global resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource radius_global default'
    on(agent, cmd_str)
    output = stdout
    search_pattern_in_output(output, { 'key' => 'unset' },
                             false, self, logger)
    search_pattern_in_output(output, { 'retransmit_count' => '1' },
                             false, self, logger)
    search_pattern_in_output(output, { 'source_interface' => 'unset' },
                             false, self, logger)
    search_pattern_in_output(output, { 'timeout' => '5' },
                             false, self, logger)

    logger.info("Check radius_global resource presence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
