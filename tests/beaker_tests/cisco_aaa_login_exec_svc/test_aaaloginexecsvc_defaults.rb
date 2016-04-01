################################################################################
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
################################################################################
#
# TestCase Name:
# -------------
# AaaLoginExecSvc-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet AaaLoginExecSvc resource testcase for Puppet Agent on Nexus
# devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a AaaLoginExecSvc resource test that tests for attribute default values
# when created with 'ensure' => 'present'.
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
# rubocop:disable Style/HashSyntax,Style/ExtraSpacing

# Require UtilityLib.rb and AaaLoginExecSvcLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../aaaloginexecsvclib.rb', __FILE__)

result = 'PASS'
testheader = 'AaaLoginExecSvc Resource :: Attribute Defaults'
id = 'test_exec'
tests = {
  :master => master,
  :agent  => agent,
}

def create_aaaloginexecsvc_defaults(tests, id, title, string=false)
  val = string ? 'default' : :default

  tests[id][:manifest_props] = {
    :ensure => :present,
    :groups => val,
    :method => val,
    :name   => title,
  }

  tests[id][:resource] = {
    'ensure' => 'present',
    'method' => 'local',
  }

  create_aaaloginexecsvc_manifest_simple(tests, id)
  resource_cmd_str =
    PUPPET_BINPATH +
    "resource cisco_aaa_authorization_login_exec_svc '#{title}'"
  tests[id][:resource_cmd] = resource_cmd_str
end

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for provider test'
  resource_absent_cleanup(agent,
                          'cisco_aaa_authorization_login_exec_svc',
                          stepinfo)
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  tests[id] = {}
  %w(default console).each do |title|
    tests[id][:desc] =
      "1.1 Apply default manifest with 'default' as a string in attributes"
    create_aaaloginexecsvc_defaults(tests, id, title, true)
    # [0, 2] Tacacs server may or may not already be enabled
    tests[id][:code] = [0, 2]
    test_manifest(tests, id)

    tests[id][:desc] =
      '1.2 Check cisco_aaaloginexecsvc resource present on agent'
    test_resource(tests, id)

    tests[id][:desc] =
      "1.3 Apply default manifest with 'default' as a symbol in attributes"
    create_aaaloginexecsvc_defaults(tests, id, title, false)
    # should have no change, just reapplying defaults, exit code 0
    tests[id][:code] = [0]
    test_manifest(tests, id)

    tests[id][:desc] = '1.4 Test resource absent manifest'
    tests[id][:manifest_props] = {
      :ensure => :absent,
      :name   => title,
    }
    tests[id][:code] = nil
    # can't *actually* remove authorization, that would crater the box,
    # but check to see if defaults have been restored
    tests[id][:resource] = { 'ensure' => 'present', 'method' => 'local' }
    create_aaaloginexecsvc_manifest_simple(tests, id)
    test_manifest(tests, id)

    tests[id][:desc]  = '1.5 Verify resource absent on agent'
    test_resource(tests, id)
  end
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
