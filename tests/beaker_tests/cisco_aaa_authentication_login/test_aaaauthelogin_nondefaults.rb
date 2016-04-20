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
# AaaAuthenticationLogin-Provider-Nondefaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet AAA Authetentication Login resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a AAA Authentication Login resource test that tests for non-default
# values of all attributes
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

# Require UtilityLib.rb and AaaAutheLogin.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../aaaautheloginlib.rb', __FILE__)

result = 'PASS'
testheader = 'AAA Authentication Login Resource :: Attribute Non-defaults'

id = 'default'
tests = {
  :master => master,
  :agent  => agent,
}

test_name "TestCase :: #{testheader}" do
  # aaa authentication login is a singleton, and requires no feature or setup
  tests[id] = {}

  # set each of the authentication methods to true, in turn
  vals = [:true, :false, :false, :false]
  ['ascii-authentication', 'chap', 'mschap', 'mschapv2'].each do |prop|
    ascii, chap, mschap, mschapv2 = vals

    tests[id] = {
      :manifest_props => {
        :ascii_authentication => ascii,
        :chap                 => chap,
        :error_display        => :true,
        :mschap               => mschap,
        :mschapv2             => mschapv2,
      },
      :resource => { # rubocop:disable Style/AlignHash
        'ascii_authentication' => ascii.to_s,
        'chap'                 => chap.to_s,
        'error_display'        => 'true',
        'mschap'               => mschap.to_s,
        'mschapv2'             => mschapv2.to_s,
      },
    }
    resource_cmd_str =
      PUPPET_BINPATH +
      "resource cisco_aaa_authentication_login 'default'"
    tests[id][:resource_cmd] = resource_cmd_str

    tests[id][:code] = [2]
    tests[id][:desc] =
      "1.1 Apply manifest with non-default #{prop}, and test harness"
    create_aaaauthelogin_manifest(tests, id)
    test_harness_common(tests, id)

    tests[id][:desc] =
      "1.2 Apply manifest with string format non-default #{prop}"
    tests[id][:manifest_props] = {
      :ascii_authentication => ascii.to_s,
      :chap                 => chap.to_s,
      :error_display        => 'true',
      :mschap               => mschap.to_s,
      :mschapv2             => mschapv2.to_s,
    }
    create_aaaauthelogin_manifest(tests, id)
    # In this case, nothing changed, we would expect the puppet run return 0,
    tests[id][:code] = [0]
    test_harness_common(tests, id)

    # rotate values to the right to set the next prop to :true
    vals.rotate!(-1)
  end
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
