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
#
# TestCase Name:
# -------------
# <testcase-__PROVIDER__-testname>.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet <resource-name> resource testcase for Puppet Agent on Nexus
# devices.
#
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the NX-OS Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a PROVIDER resource test that tests for 'ensure' attribute with
# a state transition from 'present' to 'absent'.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
###############################################################################

# Require UtilityLib.rb and __PROVIDERLIB__.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../__PROVIDERLIB__.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
result = 'PASS'
testheader = '__PROVIDER__ Resource :: Ensurability'

# @test_name [TestCase] Executes ensurability testcase for __PROVIDER__ Resource.
test_name "TestCase :: #{testheader}" do
  # ------------------
  # List of Test Steps
  # ------------------
  step 'TestStep :: Setup switch for <PROVIDER> test' do
    # Define PUPPETMASTER_MANIFESTPATH constant using puppet config cmd.
    UtilityLib.set_manifest_path(master, self)

    # Expected exit_code depends on the feature for this vegas shell cmd.
    # Expected exit_code can be 0 or can be > 0 depending on feature.
    cmd_str = UtilityLib.get_vshell_cmd('conf t ; no feature <PROVIDER>')
    on(agent, cmd_str)

    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config section <PROVIDER>')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/feature <PROVIDER>/],
                                          true, self, logger)
    end

    logger.info("Setup switch for <PROVIDER> test :: #{result}")
  end

  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, __PROVIDERLIB__.create_<PROVIDER>_manifest_present)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  step 'TestStep :: Check <CISCO_PROVIDER> resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'resource <CISCO_PROVIDER> test', options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, { 'ensure' => 'present' },
                                          false, self, logger)
    end

    logger.info("Check <CISCO_PROVIDER> resource presence on agent :: #{result}")
  end

  step 'TestStep :: Check <PROVIDER> instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config section <PROVIDER>')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/<PROVIDER> test/],
                                          false, self, logger)
    end

    logger.info("Check <PROVIDER> instance presence on agent :: #{result}")
  end

  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, __PROVIDERLIB__.create_<PROVIDER>_manifest_absent)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource absent manifest from master :: #{result}")
  end

  step 'TestStep :: Check <CISCO_PROVIDER> resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'resource <CISCO_PROVIDER> test', options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, { 'ensure' => 'present' },
                                          true, self, logger)
    end

    logger.info("Check <CISCO_PROVIDER> resource absence on agent :: #{result}")
  end

  step 'TestStep :: Check <PROVIDER> instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config section <PROVIDER>')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/<PROVIDER> test/],
                                          true, self, logger)
    end

    logger.info("Check <PROVIDER> instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
