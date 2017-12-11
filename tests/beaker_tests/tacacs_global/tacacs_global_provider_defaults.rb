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
# TacacsGlobal-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a tacacs_global resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a tacacs_global resource test that tests default attribute of
# tacacs_global resource.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# Steps 2+ deal with tacacs_global and its
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
require File.expand_path('../tacacs_globallib.rb', __FILE__)

result = 'PASS'
testheader = 'tacacs_global Resource :: All Attributes Defaults'

def cleanup
  logger.info('Testcase Cleanup:')
  command_config(agent, 'no feature tacacs+')
end

# @test_name [TestCase] Executes defaults testcase for tacacs_global Resource.
test_name "TestCase :: #{testheader}" do
  cleanup
  teardown { cleanup }

  # @step [Step] Checks tacacs_global resource on agent using resource cmd.
  step 'TestStep :: Check tacacs_global resource unconfigured' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource tacacs_global default'
    on(agent, cmd_str)
    output = stdout
    search_pattern_in_output(output, { 'key' => 'unset' },
                             false, self, logger)
    search_pattern_in_output(output, { 'source_interface' => "['unset']" },
                             false, self, logger)
    search_pattern_in_output(output, [/timeout/], true, self, logger)

    logger.info("Check tacacs_global resource unconfigured :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, TacacsGlobalLib.create_tacacs_global_default)

    # Expected exit_code is 0 or 2 depending on the state of the device.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks tacacs_global resource on agent using resource cmd.
  step 'TestStep :: Check tacacs_global resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + 'resource tacacs_global default'
    on(agent, cmd_str)
    output = stdout
    search_pattern_in_output(output, { 'key' => 'unset' },
                             false, self, logger)
    search_pattern_in_output(output, { 'timeout' => '5' },
                             false, self, logger)
    search_pattern_in_output(output, { 'source_interface' => "['unset']" },
                             false, self, logger)

    logger.info("Check tacacs_global resource presence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
