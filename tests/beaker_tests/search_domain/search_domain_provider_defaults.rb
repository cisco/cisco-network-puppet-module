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
# SearchDomain-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a search_domain resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a search_domain resource test that tests for default value for
# 'ensure' attribute of a search_domain resource.
#
# There are 2 sections to the testcase: Setup, group of teststeps.  The 1st
# step is the Setup teststep that cleans up the switch state.  Steps 2-4 deal
# with the search_domain resource and its verification using Puppet Agent and the
# switch running-config.
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

# Require UtilityLib.rb and SearchDomainLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../search_domainlib.rb', __FILE__)

result = 'PASS'
testheader = 'DOMAIN_NAME Resource :: All Attributes Defaults'

# Helper for testbed cleanup
def dns_clean(agent)
  # remove any existing resources that we will be testing against
  resource_titles(agent, :domain_name, :clean)

  # These resources currently do not support ensure=absent; they can use
  # resource_titles above if they're ever updated.
  on(agent, get_vshell_cmd('show run | i domain-list|name-server'))
  stdout.scan(/ip domain-list \S+|ip name-server .*/).each do |cli|
    command_config(agent, "no #{cli}", "removing #{cli}")
  end
end

# @test_name [TestCase] Executes defaults testcase for NAME_SERVER Resource.
test_name "TestCase :: #{testheader}" do
  step 'TestStep :: Testbed pre-test cleanup' do
    dns_clean(agent)
    resource_absent_cleanup(agent, 'cisco_vrf')
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SearchDomainLib.create_search_domain_manifest_present)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks search_domain resource on agent using resource cmd.
  step 'TestStep :: Check search_domain resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource search_domain test.xyz', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
    end

    logger.info("Check search_domain resource presence on agent :: #{result}")
  end

  # @step [Step] Checks search_domain instance on agent using switch show cli
  # cmds.
  step 'TestStep :: Check search_domain instance presence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config all')

    on(agent, cmd_str) do
      search_pattern_in_output(stdout, [/domain-name test\.xyz/],
                               false, self, logger)
    end

    logger.info("Check search_domain instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SearchDomainLib.create_search_domain_manifest_absent)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
                                           'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource absent manifest from master :: #{result}")
  end

  # @step [Step] Checks search_domain resource on agent using resource cmd.
  step 'TestStep :: Check search_domain resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource search_domain test.xyz', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               true, self, logger)
    end

    logger.info("Check search_domain resource absence on agent :: #{result}")
  end

  # @step [Step] Checks search_domain instance on agent using switch show cli
  # cmds.
  step 'TestStep :: Check search_domain instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = get_vshell_cmd('show running-config all')

    on(agent, cmd_str) do
      search_pattern_in_output(stdout, [/domain-name test\.xyz/],
                               true, self, logger)
    end

    logger.info("Check search_domain instance absence on agent :: #{result}")
  end

  step 'TestStep :: Testbed post-test cleanup' do
    dns_clean(agent)
    resource_absent_cleanup(agent, 'cisco_vrf')
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
