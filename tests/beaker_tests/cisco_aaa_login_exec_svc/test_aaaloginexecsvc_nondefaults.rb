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
# AaaLoginExecSvc-Provider-Nondefaults.rb
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
# This is a AaaLoginExecSvc resource test that tests for non-default values of all
# attributes except password and type when created with 'ensure' => 'present'.
# Password and type attributes will be tested in another test case as they
# don't support idempotent.
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
# rubocop:disable Style/HashSyntax

# Require UtilityLib.rb and AaaLoginExecLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../aaaloginexecsvclib.rb', __FILE__)

result = 'PASS'
testheader = 'AaaLoginExecSvc Resource :: Attribute Non-defaults'
id = 'test_exec'
tests = {
  :master => master,
  :agent  => agent,
}

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for provider test'
  resource_absent_cleanup(agent,
                          'cisco_aaa_authorization_login_exec_svc',
                          stepinfo)
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  tests[id] = {}
  %w(console default).each do |title|
    tests[id] = {
      :manifest_props => {
        :ensure => 'present',
        :groups => ['group1'],
        :method => 'local',
        :name   => title,
      },
      :resource       => {
        'ensure' => 'present',
        'groups' => "\\['group1'\\]",
        'method' => 'local',
      },
    }
    resource_cmd_str =
      PUPPET_BINPATH +
      "resource cisco_aaa_authorization_login_exec_svc '#{title}'"
    tests[id][:resource_cmd] =
      get_namespace_cmd(agent, resource_cmd_str, options)

    tests[id][:desc] =
      '1.1 Apply manifest with non-default attributes, and test'
    create_aaaloginexecsvc_manifest_full(tests, id)
    # can't test idempotence, tacacs_server password isn't idempotent
    test_manifest(tests, id)
    test_resource(tests, id)

    # configuring method unselected for default will lock us out, skip that
    next if title == 'default'

    tests[id][:desc] =
      '1.2 Apply manifest with symbol format non-default attributes'
    tests[id][:manifest_props] = {
      :ensure => :present,
      :groups => ['group1'],
      :method => :unselected,
      :name   => title,
    }
    tests[id][:resource]['method'] = 'unselected'

    create_aaaloginexecsvc_manifest_full(tests, id)
    tests[id][:code] = [2]
    test_manifest(tests, id)
    test_resource(tests, id)
  end

  resource_absent_cleanup(agent,
                          'cisco_aaa_authorization_login_exec_svc',
                          stepinfo)

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
