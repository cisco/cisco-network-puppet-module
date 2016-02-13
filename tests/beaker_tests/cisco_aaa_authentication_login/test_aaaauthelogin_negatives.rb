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
# AaaAutheLogin-Provider-negative.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet Aaa Authentication Login resource testcase to test negative
# values in the manifest
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a Aaa Authentication Login resource test that tests for various negative
# values when created with 'ensure' => 'present' to make sure the type validation
# is working
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

# Require UtilityLib.rb and AaaAutheLoginLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../aaaautheloginlib.rb', __FILE__)

result = 'PASS'
testheader = 'Aaa Authentication Login Resource :: Negative Value Test'

tests = {
  :master => master,
  :agent  => agent,
}

test_name "TestCase :: #{testheader}" do
  # only 'default' title pattern is allowed so this should fail
  id = 'not_default'
  tests[id] = {
    :desc           => '1.1 Apply id pattern of resource name',
    :code           => [0],
    :manifest_props => {},
  }
  create_aaaauthelogin_manifest(tests, id)
  # search for error pattern in puppet agent cmd output
  tests[id][:stderr_pattern] = /only 'default' is accepted as a valid name/
  test_manifest(tests, id)

  id = 'default'
  # setting 2 authentication methods at once should fail
  tests[id] = {
    :desc           => '1.2 Attempt to set multiple auth login methods',
    :code           => [1],
    :manifest_props => {
      :ascii_authentication => :true,
      :chap                 => :true,
    },
  }
  create_aaaauthelogin_manifest(tests, id)
  test_manifest(tests, id)

  # anything besides boolean properties should fail
  [:ascii_authentication, :chap, :mschap, :mschapv2].each do |prop|
    tests[id] = {
      :desc           => "1.3 Apply non-bool value to #{prop} property",
      :code           => [1],
      :manifest_props => {
        prop => 42
      },
    }
    create_aaaauthelogin_manifest(tests, id)
    test_manifest(tests, id)

    tests[id] = {
      :desc           => "1.3 Apply invalid symbol to #{prop} property",
      :code           => [1],
      :manifest_props => {
        prop => :invalid
      },
    }
    create_aaaauthelogin_manifest(tests, id)
    test_manifest(tests, id)
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
