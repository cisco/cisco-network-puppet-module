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
# SnmpNotificationReceiver-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a snmp_notification_receiver resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a snmp_notification_receiver resource test that tests for default value for
# 'ensure' attribute of a snmp_notification_receiver resource.
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

# Require rb and SnmpGroupLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../snmp_notification_receiverlib.rb', __FILE__)

result = 'PASS'
testheader = 'snmp_notification_receiver Resource :: All Attributes Defaults'

# @test_name [TestCase] Executes defaults testcase for snmp_notification_receiver Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider' do
    # # Define PUPPETMASTER_MANIFESTPATH constant using puppet config cmd.
    # set_manifest_path(master, self)

    # Ensure that resource is removed beforehand
    resource_absent_cleanup(agent, 'snmp_notification_receiver', \
                            'Remove snmp_notification_receiver')

    add_vrf = get_vshell_cmd('conf t ; vrf context red')
    on(agent, add_vrf, acceptable_exit_codes: [0, 2])

    logger.info('Setup switch for provider')
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_v3)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/3' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'traps' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'jj' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v3' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'security' => 'priv' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_change_v3)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/4' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'traps' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'ab' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v3' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'security' => 'auth' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_change_v3_2)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/4' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'traps' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'ab' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v3' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'security' => 'noauth' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_change_v3_3)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/4' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'informs' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'ab' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v3' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'security' => 'noauth' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_v2)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/4' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'traps' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'ab' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v2' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_change_v2)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/4' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'informs' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'ab' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v2' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present (with changes)manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_present_v1)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver 2.3.4.5', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'source_interface' => 'ethernet1/4' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'port' => '47' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'type' => 'traps' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'username' => 'ab' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'version' => 'v1' },
                               false, self, logger)
      search_pattern_in_output(stdout, { 'vrf' => 'red' },
                               false, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpNotificationReceiverLib.create_snmp_notification_receiver_manifest_absent)

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [2])

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks snmp_notification_receiver resource on agent using resource cmd.
  step 'TestStep :: Check snmp_notification_receiver resource presence on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'resource snmp_notification_receiver test_snmp_notification_receiver', options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout, { 'ensure' => 'present' },
                               true, self, logger)
    end

    logger.info("Check snmp_notification_receiver resource presence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
