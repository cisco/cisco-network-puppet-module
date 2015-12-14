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
# Presuite-Certcheck.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet presuite testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a presuite test that tests for Puppet Agent certificate
# on the master server.
#
# There is a single section to the test: Setup.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

result = 'PASS'
testheader = 'Resource :: Presuite'
puppetagentcert = nil

# @test_name [TestCase] Executes presuite testcase for provider resource.
test_name "TestCase :: #{testheader}" do
  # @step [Setup] Checks for Puppet Agent Cert on master.
  step 'TestStep :: Check for Puppet Agent cert on master' do
    # Expected exit_code is 0 since this is a puppet config cmd with no change.
    cmd_str = PUPPET_BINPATH + 'config print certname'
    on(agent, cmd_str) do
      puppetagentcert = stdout.strip
    end

    # Expected exit_code is 0 since this is a puppet cert cmd with no change.
    cmd_str = PUPPET_BINPATH + 'cert --list ' + puppetagentcert
    on(master, cmd_str) do
      search_pattern_in_output(stdout, \
                               [Regexp.new(puppetagentcert)], false, self, logger)
    end

    logger.info("Check for Puppet Agent cert on master :: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
