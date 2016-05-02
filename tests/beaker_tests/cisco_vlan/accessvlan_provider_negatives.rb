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
# AccessVlan-Provider-Negatives.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet ACCESSVLAN resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a ACCESSVLAN resource test that tests for negative values for
# access_vlan, description, ipv4_proxy_arp, ipv4_redirects,
# negotiate_auto, shutdown, switchport_autostate_exclude,
# switchport_mode and switchport_vtp attributes of a
# cisco_interface resource when created with 'ensure' => 'present'.
# Access Standard VLANs are in the VLAN ID range 2..1005.
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

# Require UtilityLib.rb and AccessVlanLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../accessvlanlib.rb', __FILE__)

result = 'PASS'
testheader = 'ACCESSVLAN Resource :: All Attributes Negatives'

# Local tests hash and helper method used to dynamically find an available
# interface for tests that require an interface.
tests = { intf_type: 'ethernet', agent: agent, testheader: testheader }
def find_ospf_interface(tests)
  if tests[:ethernet]
    intf = tests[:ethernet]
  else
    intf = find_interface(tests)
    # cache for later tests
    tests[:ethernet] = intf
  end
  intf
end
int = find_ospf_interface(tests)

# @test_name [TestCase] Executes negatives testcase for ACCESSVLAN Resource.
test_name "TestCase :: #{testheader}" do
  resource_absent_cleanup(agent, 'cisco_vlan', 'VLAN CLEAN :: ')

  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AccessVlanLib.create_accessvlan_manifest_absent(int))

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [0, 2])

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AccessVlanLib.create_accessvlan_manifest_ipv4proxyarp_negative(int))

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource cisco_interface '#{int}'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ipv4_proxy_arp' => AccessVlanLib::IPV4PROXYARP_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AccessVlanLib.create_accessvlan_manifest_ipv4redir_negative(int))

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource cisco_interface '#{int}'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ipv4_redirects' => AccessVlanLib::IPV4REDIRECTS_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # Negotiate Auto: TBD: Needs plat awareness
  # @step [Step] Requests manifest from the master server to the agent.
  # step 'TestStep :: Get negative test resource manifest from master' do
  #  # Expected exit_code is 0 since this is a bash shell cmd.
  #  on(master, AccessVlanLib.create_accessvlan_manifest_negoauto_negative(int))
  #
  #  # Expected exit_code is 1 since this is a puppet agent cmd with error.
  #  cmd_str = PUPPET_BINPATH + 'agent -t'
  #  on(agent, cmd_str, acceptable_exit_codes: [1])
  #
  #  logger.info("Get negative test resource manifest from master :: #{result}")
  # end

  # Negotiate Auto: TBD: Needs plat awareness
  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  # step 'TestStep :: Check cisco_interface resource absence on agent' do
  #  # Expected exit_code is 0 since this is a puppet resource cmd.
  #  # Flag is set to true to check for absence of RegExp pattern in stdout.
  #  cmd_str = PUPPET_BINPATH + "resource cisco_interface '#{int}'"
  #  on(agent, cmd_str) do
  #    search_pattern_in_output(stdout,
  #                             { 'negotiate_auto' => AccessVlanLib::NEGOTIATEAUTO_NEGATIVE },
  #                             true, self, logger)
  #  end
  #
  #  logger.info("Check cisco_interface resource presence on agent :: #{result}")
  # end

  # Negotiate Auto: TBD: Needs plat awareness
  # @step [Step] Requests manifest from the master server to the agent.
  # step 'TestStep :: Get negative test resource manifest from master' do
  #  # Expected exit_code is 0 since this is a bash shell cmd.
  #  on(master, AccessVlanLib.create_accessvlan_manifest_shutdown_negative(int))
  #
  #  # Expected exit_code is 1 since this is a puppet agent cmd with error.
  #  cmd_str = PUPPET_BINPATH + 'agent -t'
  #  on(agent, cmd_str, acceptable_exit_codes: [1])
  #
  #  logger.info("Get negative test resource manifest from master :: #{result}")
  # end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource cisco_interface '#{int}'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'shutdown' => AccessVlanLib::SHUTDOWN_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AccessVlanLib.create_accessvlan_manifest_autostate_negative(int))

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource cisco_interface '#{int}'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'switchport_autostate_exclude' => AccessVlanLib::AUTOSTATE_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get negative test resource manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, AccessVlanLib.create_accessvlan_manifest_vtp_negative(int))

    # Expected exit_code is 1 since this is a puppet agent cmd with error.
    cmd_str = PUPPET_BINPATH + 'agent -t'
    on(agent, cmd_str, acceptable_exit_codes: [1])

    logger.info("Get negative test resource manifest from master :: #{result}")
  end

  # @step [Step] Checks cisco_interface resource on agent using resource cmd.
  step 'TestStep :: Check cisco_interface resource absence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = PUPPET_BINPATH + "resource cisco_interface '#{int}'"
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'switchport_vtp' => AccessVlanLib::SWITCHPORTVTP_NEGATIVE },
                               true, self, logger)
    end

    logger.info("Check cisco_interface resource presence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
