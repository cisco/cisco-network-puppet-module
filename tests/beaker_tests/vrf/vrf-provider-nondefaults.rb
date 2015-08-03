###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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
# Vrf-Provider-NonDefaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet VRF resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information. 
# B. SSH is enabled on the Agent. 
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a VRF resource test that tests for nondefault values of 
# description and shutdown attributes for cisco_vrf when created 
# or updated with 'ensure' => 'present'.
#
# The testcode checks for exit_codes from Puppet Agent, Vegas shell and
# Bash shell command executions. For Vegas shell and Bash shell command
# string executions, this is the exit_code convention: 
# 0 - successful command execution, > 0 - failed command execution.
# For Puppet Agent command string executions, this is the exit_code convention:
# 0 - no changes have occurred, 1 - errors have occurred, 
# 2 - changes have occurred, 4 - failures have occurred and 
# 6 - changes and failures have occurred.
#
# Note: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
# The testcode also uses RegExp pattern matching on stdout or output IO 
# instance attributes to verify resource properties.
#
###############################################################################

# Require UtilityLib.rb and VrfLib.rb paths.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)
require File.expand_path("../vrflib.rb", __FILE__)

result = 'PASS'
testheader = "VRF Resource :: All Attributes NonDefaults"
vrf_name = "test_green"
UtilityLib.set_manifest_path(master, self)
puppet_agent_cmd = UtilityLib.get_namespace_cmd(agent,
                   UtilityLib::PUPPET_BINPATH + "agent -t", options)
puppet_resource_cmd =  UtilityLib.get_namespace_cmd(agent,
                       UtilityLib::PUPPET_BINPATH + 
                       "resource cisco_vrf '#{vrf_name}'", options)
clear_vrf_cmd = UtilityLib.get_vshell_cmd("conf t ; no vrf context #{vrf_name}")
show_vrf_cmd = UtilityLib.get_vshell_cmd("show running | sec \"vrf context #{vrf_name}\"")
# Flag is set to true to check for absence of RegExp pattern in stdout, set
# to false to check for the present of RegExp
test = {
  :present => false,
  :absent  => true,
}

test_name "TestCase :: #{testheader}" do

  stepinfo = 'Set up switch for provider test'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code could be 0 or 2 depending on switch status.
    on(agent, clear_vrf_cmd, {:acceptable_exit_codes => [0, 2]}) 

    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/], 
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Get resource nondefault manifest from master and apply on agent'
  description = "tested by beaker"
  shutdown = true
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.create_vrf_manifest_nondefaults(vrf_name, description, 
       shutdown))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]}) 

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check cisco_vrf resource present on agent'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a puppet resource cmd.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",
        "description" => "#{description}",
        "shutdown"=> "#{shutdown}"},
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check vrf instance present using show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/,
        /description #{description}/, /shutdown/],
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Verify Idempotence on agent'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a puppet agent cmd with no change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [0]}) 

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check cisco_vrf resource not changed on agent'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a puppet resource cmd.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",
         "description" => "#{description}",
         "shutdown"=> "#{shutdown}"},
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check vrf instance not changed using show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/,
        /description #{description}/, /shutdown/],
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Get vrf update manifest from master and apply on agent'
  description = "updated by beaker"
  shutdown = false
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.create_vrf_manifest_nondefaults(vrf_name, 
       description, shutdown))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]})

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check and verify cisco_vrf resource present on agent'
  step "TestStep :: #{stepinfo}" do
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",
        "description" => "#{description}",
        "shutdown"=> "#{shutdown}"},
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Verify vrf instance update by show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/,
        /description #{description}/],
        test[:present], self, logger)
      # when shutdown is false, show cli should not have a line containing 
      # "shutdown"
      UtilityLib.search_pattern_in_output(stdout, [/shutdown/],
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Get vrf manifest that removes description and apply on agent'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.update_vrf_manifest_no_description(vrf_name))
    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]})

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check cisco_vrf resource update on agent'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",},
        test[:present], self, logger)
      # if description is removed, puppet resource won't have description 
      # entry in return
      UtilityLib.search_pattern_in_output(stdout, [/description/],
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check vrf instance updated using show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/],
        test[:present], self, logger)
      # in show outupt there would be no "description" line
      UtilityLib.search_pattern_in_output(stdout, [/description/],
        test[:absent], self, logger)
    end
    
    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = "Get vrf manifest that swaps cases in title and apply on agent"
  description = "update using #{vrf_name.swapcase}"
  shutdown = true
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.create_vrf_manifest_nondefaults(vrf_name.swapcase, 
       description, shutdown))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]})

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check and verify cisco_vrf resource on agent'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",
        "description" => "#{description}",
        "shutdown"=> "#{shutdown}"},
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check vrf instance updated by show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/,
        /#{description}/, /shutdown/],
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Get vrf manifest that uses name attribute and apply on agent'
  description = "update using name attribute"
  shutdown = true
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.update_vrf_manifest_by_name_attribute(vrf_name, 
       description, shutdown))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]})

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check and verify cisco_vrf resource updated on agent'
  step "TestStep :: Check cisco_vrf resource update on agent" do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",
        "description" => "#{description}",
        "shutdown"=> "#{shutdown}"},
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Verify vrf instance update using show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/,
        /#{description}/, /shutdown/],
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Clean up switch after provider test'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, clear_vrf_cmd) 

    # Expected exit_code is 0 since this is a vegas shell cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/], 
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
  
end

logger.info("TestCase :: #{testheader} :: End")

