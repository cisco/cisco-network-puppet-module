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
# AaaAutheLogin-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet Aaa Authentication Login resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a Aaa Authentication Login resource test that tests for attribute
# default values.
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

# Require UtilityLib.rb and aaaauthelogin.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../aaaautheloginlib.rb', __FILE__)

result = 'PASS'
testheader = 'AAA Authentication Login:: Attribute Defaults'
id = 'default'
tests = {
  :master => master,
  :agent  => agent,
}

def create_aaaauthelogin_defaults(tests, id, string=false)
  val = string ? 'default' : :default
  title = 'default' # only allowed

  tests[id][:manifest_props] = {
    :name                 => title,
    :ascii_authentication => val,
    :chap                 => val,
    :error_display        => val,
    :mschap               => val,
    :mschapv2             => val,
  }

  tests[id][:resource] = {
    'ascii_authentication' => 'false',
    'chap'                 => 'false',
    'error_display'        => 'false',
    'mschap'               => 'false',
    'mschapv2'             => 'false',
  }

  create_aaaauthelogin_manifest(tests, id)
  resource_cmd_str =
    PUPPET_BINPATH +
    "resource cisco_aaa_authentication_login '#{title}'"
  tests[id][:resource_cmd] = resource_cmd_str
end

test_name "TestCase :: #{testheader}" do
  # aaa authentication login is a singleton, and requires no feature or setup
  tests[id] = {}
  # may or may not already be default
  tests[id][:code] = [0, 2]
  tests[id][:desc] =
    "1.1 Apply default manifest with 'default' as a string in attributes"
  create_aaaauthelogin_defaults(tests, id, true)
  test_manifest(tests, id)

  tests[id][:desc] =
    '1.2 Check cisco_aaa_authentication_login resource present on agent'
  test_resource(tests, id)

  tests[id][:desc] =
    "1.3 Apply default manifest with 'default' as a symbol in attributes"
  create_aaaauthelogin_defaults(tests, id, false)
  # In this case, nothing changed, we would expect the puppet run return 0,
  # It also verified idempotent of the provider.
  tests[id][:code] = [0]
  test_manifest(tests, id)

  # aaa authentication login is not ensurable, so no need to test present/absent
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
