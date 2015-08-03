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
# Vrf-Provider-Defaults.rb
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
# This is a VRF resource test that tests for default values of all
# attributes when created with only 'ensure' => 'present'.
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
# 
# The testcode also uses RegExp pattern matching on stdout or output IO 
# instance attributes to verify resource properties.
#
###############################################################################

# Require UtilityLib.rb and VrfLib.rb paths.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)
require File.expand_path("../vrflib.rb", __FILE__)

result = 'PASS'
testheader = "VRF Resource :: All Attributes Defaults"
vrf_name = 'test_green'
UtilityLib.set_manifest_path(master, self)
puppet_agent_cmd = UtilityLib.get_namespace_cmd(agent,
                   UtilityLib::PUPPET_BINPATH + "agent -t", options)
puppet_resource_cmd =  UtilityLib.get_namespace_cmd(agent,
                       UtilityLib::PUPPET_BINPATH +
                       "resource cisco_vrf '#{vrf_name}'", options)
clear_vrf_cmd = UtilityLib.get_vshell_cmd("conf t ; no vrf context #{vrf_name}")
show_vrf_cmd = UtilityLib.get_vshell_cmd("show running | section \"vrf context #{vrf_name}\"")
# Flag is set to true to check for absence of RegExp pattern in stdout, set
# to false to check for the present of RegExp
test = {
  :present => false,
  :absent  => true,
}

test_name "TestCase :: #{testheader}" do

  stepinfo = 'Setup switch for provider test'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 or 2 depending on the switch status.
    on(agent, clear_vrf_cmd, {:acceptable_exit_codes => [0, 2]})

    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/],
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Get resource present manifest from master and apply on agent'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.create_vrf_manifest_default(vrf_name))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]}) 

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check cisco_vrf resource present on agent'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a puppet resource cmd.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "present",},
        test[:present], self, logger)
      # default setup won't have description entry in return
      UtilityLib.search_pattern_in_output(stdout, [/description/],
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check cisco_vrf instance present using show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    on(agent, show_vrf_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/vrf context #{vrf_name}/],
        test[:present], self, logger)
      # in show output there would be no "description" lines
      # for default vrf creation
      UtilityLib.search_pattern_in_output(stdout, [/description/],
        test[:absent], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Get resource absent manifest from master and apply on agent'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, VrfLib.create_vrf_manifest_default(vrf_name, false))

    # Expected exit_code is 2 since this is a puppet agent cmd with change.
    on(agent, puppet_agent_cmd, {:acceptable_exit_codes => [2]}) 

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check cisco_vrf resource absent on agent'
  step "TestStep :: #{stepinfo}" do 
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to true to check for absence of RegExp pattern in stdout.
    on(agent, puppet_resource_cmd) do
      UtilityLib.search_pattern_in_output(stdout,
        {"ensure" => "absent",},
        test[:present], self, logger)
    end

    logger.info("TestStep :: #{stepinfo} :: #{result}")
  end

  stepinfo = 'Check vrf instance absent using show cli'
  step "TestStep :: #{stepinfo}" do
    # Expected exit_code is 0 since this is a vegas shell cmd.
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

