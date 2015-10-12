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
# network_vlan.rb
#
###############################################################################

# Require UtilityLib.rb and VlanLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../vlanlib.rb', __FILE__)

result = 'PASS'
testheader = 'network_vlan Resource :: All Attributes Defaults'

# @test_name [TestCase] Executes defaults testcase for network_vlan Resource.
test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # Define PUPPETMASTER_MANIFESTPATH constant using puppet config cmd.
    UtilityLib.set_manifest_path(master, self)

    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VlanLib.create_networkvlan_manifest_absent())

    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    # Or expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, { :acceptable_exit_codes => [0, 2]}) 

    logger.info("Setup switch for provider test :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource present manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VlanLib.create_networkvlan_manifest_present())

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, { :acceptable_exit_codes => [2]}) 

    logger.info("Get resource present manifest from master :: #{result}")
  end

  # @step [Step] Checks network_vlan resource on agent using resource cmd.
  step "TestStep :: Check network_vlan resource presence on agent" do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource network_vlan '128'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
        {'ensure'    => 'present',
         'shutdown'  => 'false',
         'vlan_name' => 'VLAN0128'},
        false, self, logger)
    end

    logger.info("Check  resource presence on agent :: #{result}")
  end

  # @step [Step] Checks vlan instance on agent using switch show cli cmds.
  step "TestStep :: Check vlan instance presence on agent" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd("show running-config vlan")
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/vlan 1,(.*)128/],
        false, self, logger)
    end

    logger.info("Check vlan instance presence on agent :: #{result}")
  end

  # @step [Step] Requests manifest from the master server to the agent.
  step 'TestStep :: Get resource absent manifest from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VlanLib.create_networkvlan_manifest_absent())

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, { :acceptable_exit_codes => [2]}) 

    logger.info("Get resource absent manifest from master :: #{result}")
  end

  # @step [Step] Checks network_vlan resource on agent using resource cmd.
  step "TestStep :: Check network_vlan resource absence on agent" do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource network_vlan '128'", options)
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout,
        {'ensure'    => 'present',
         'shutdown'  => 'false',
         'vlan_name' => 'VLAN0128'},
        true, self, logger)
    end

    logger.info("Check network_vlan resource absence on agent :: #{result}")
  end

  # @step [Step] Checks vlan instance on agent using switch show cli cmds.
  step 'TestStep :: Check vlan instance absence on agent' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    cmd_str = UtilityLib.get_vshell_cmd('show running-config vlan')
    on(agent, cmd_str) do
      UtilityLib.search_pattern_in_output(stdout, [/vlan 1,(.*)128/],
        true, self, logger)
    end

    logger.info("Check vlan instance absence on agent :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")

