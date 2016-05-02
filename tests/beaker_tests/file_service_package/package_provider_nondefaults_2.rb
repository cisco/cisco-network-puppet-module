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
# Package-Provider-NonDefaults-2.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet PACKAGE resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a PACKAGE resource test that tests for nondefault values for
# name, ensure, provider and source attributes of a
# package resource when installed with 'ensure' => 'present'.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# Steps 2-3 deal with package resource installation and its
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

# Require UtilityLib.rb and FileSvcPkgLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../filesvcpkglib.rb', __FILE__)

result = 'PASS'
testheader = 'PACKAGE Resource :: All Attributes NonDefaults'

skipmsg = "\n\n*** WARNING ***\nThis test case relies on patches that are " \
  "built for specific image versions.\nMake sure the patch being tested is " \
  'compatible with the current image and then comment out this ' \
  "raise_skip_exception call to run the test.\n*** WARNING ***\n"
raise_skip_exception(skipmsg, self)

# @test_name [TestCase] Executes nondefaults testcase for PACKAGE Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    cmd_str =
      get_vshell_cmd('dir bootflash:n9000_sample-1.0.0-7.0.3.x86_64.rpm')
    on(agent, cmd_str, acceptable_exit_codes: [0])

    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, FileSvcPkgLib.create_package_sample_manifest_absent)

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # No change would imply that Sample package is uninstalled prior to test.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    # Change would imply that Sample package is installed prior to test.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, FileSvcPkgLib.create_package_sample_manifest_present)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    # Change would imply that Sample package is uninstalled prior to test and
    # installed after test.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks package resource on agent using resource cmd.
  step 'TestStep :: Check package resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    # Sample package state should not be purged.
    cmd_str = PUPPET_BINPATH + "resource package 'n9000_sample'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure' => 'purged' },
                               true, self, logger)
    end

    logger.info("Check package resource presence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
