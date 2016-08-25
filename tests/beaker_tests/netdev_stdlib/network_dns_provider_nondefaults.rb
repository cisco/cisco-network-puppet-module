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
# NetworkDns-Provider-NonDefaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet network_dns resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a network_dns resource test that tests for nondefault values for
# domain, search, and servers of a network_dns resource.
#
# There is 2 section to the testcase: Setup, group of teststeps. The 1st step is
# the Setup teststep that cleans up the switch state.
# Steps 2-8 deal with network_dns resource declarations and
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

# Require UtilityLib.rb and NetworkDnsLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../network_dnslib.rb', __FILE__)

result = 'PASS'
testheader = 'network_dns Resource :: All Attributes NonDefaults'

def check_dns_warning
  return unless operating_system == 'ios_xr'
  dns_warning = "
    *****************************************************************
    ***                    WARNING WARNING WARNING                ***
    ***                                                           ***
    *** This test will remove all DNS settings from the testbed   ***
    *** running-config.                                           ***
    ***                                                           ***
    *** Please save the DNS settings before executing this test.  ***
    ***                                                           ***
    *** Comment out the 'fail dns_warning' command below to       ***
    *** execute this test.                                        ***
    ***                                                           ***
    ***                    WARNING WARNING WARNING                ***
    *****************************************************************"
  fail dns_warning if dns_warning
end

# Helper for XR testbed cleanup
def xr_dns_clean(agent)
  return unless operating_system == 'ios_xr'
  # remove any existing resources that we will be testing against
  resource_titles(agent, :domain_name, :clean)
  ['no domain list test.com',
   'no domain list test.net',
   'no domain name switch1.test.com',
   'no domain name switch2.test.com',
   'no domain name-server 2001:4860:4860::8888',
   'no domain name-server 8.8.8.8'].each { |cmd| command_config(agent, cmd) }
end

def dns_find_and_remove(agent)
  return if operating_system == 'ios_xr'

  # Find DNS commands affected by this test & remove them
  cmds = test_get(agent, "i '^ip (domain-list|domain-name|name-server)'",
                  :array)
  return nil unless cmds

  no_cmds = cmds.map { |cmd| "no #{cmd}" }.join(' ; ')
  test_set(agent, no_cmds)
  # return original commands as str
  cmds.join(' ; ')
end

def dns_save(agent)
  # Save any existing DNS commands from switch in case they're "real" configs.
  if operating_system == 'ios_xr'
    xr_dns_clean
    return nil
  end

  dns_find_and_remove(agent)
end

def dns_restore(agent, dns_orig)
  return if dns_orig.nil? || operating_system == 'ios_xr'
  test_set(agent, dns_orig)
end

# @test_name [TestCase] Executes nondefaults testcase for network_dns Resource.
test_name "TestCase :: #{testheader}" do
  check_dns_warning

  # Keep track of the original dns cmds so that they can be restored at the end
  dns_orig = dns_save(agent)
  teardown do
    dns_find_and_remove(agent)
    dns_restore(agent, dns_orig)
  end

  #----------------------------------------------------------------------
  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Set the properties in a manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, NetworkDnsLib.create_network_dns_manifest('switch1.test.com',
                                                         ['test.com', 'test.net'],
                                                         ['2001:4860:4860::8888', '8.8.8.8'],
                                                        ))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Set the domain property in a manifest from master :: #{result}")
  end

  #----------------------------------------------------------------------
  # @step [Step] Checks network_dns resource on agent using resource cmd.
  step 'TestStep :: Check network_dns resource on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource network_dns 'settings'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'  => 'present',
                                 'domain'  => 'switch1.test.com',
                                 'search'  => "\\['test.com', 'test.net'\\]",
                                 'servers' => "\\['2001:4860:4860::8888', '8.8.8.8'\\]" },
                               false, self, logger)
    end

    logger.info("Check network_dns resource on agent :: #{result}")
  end

  #----------------------------------------------------------------------
  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Set the properties in a manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, NetworkDnsLib.create_network_dns_manifest('switch2.test.com',
                                                         ['test.net'],
                                                         ['2001:4860:4860::8888', '8.8.4.4'],
                                                        ))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Set the domain property in a manifest from master :: #{result}")
  end

  #----------------------------------------------------------------------
  # @step [Step] Checks network_dns resource on agent using resource cmd.
  step 'TestStep :: Check network_dns resource on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource network_dns 'settings'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure'  => 'present',
                                 'domain'  => 'switch2.test.com',
                                 'search'  => "\\['test.net'\\]",
                                 'servers' => "\\['2001:4860:4860::8888', '8.8.4.4'\\]" },
                               false, self, logger)
    end

    logger.info("Check network_dns resource on agent :: #{result}")
  end

  #----------------------------------------------------------------------
  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Set the properties in a manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, NetworkDnsLib.create_network_dns_manifest('switch2.test.com',
                                                         ['test.com'],
                                                         [],
                                                        ))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Set the domain property in a manifest from master :: #{result}")
  end

  #----------------------------------------------------------------------
  # @step [Step] Checks network_dns resource on agent using resource cmd.
  step 'TestStep :: Check network_dns resource on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource network_dns 'settings'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure' => 'present',
                                 'domain' => 'switch2.test.com',
                                 'search' => "\\['test.com'\\]" },
                               false, self, logger)
    end

    logger.info("Check network_dns resource on agent :: #{result}")
  end

  #----------------------------------------------------------------------
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
