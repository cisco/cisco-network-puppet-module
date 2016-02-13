###############################################################################
# Copyright (c) 2016 Cisco and/or its affiliates.
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
# test_vdc.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet Interface resource testcase of vdc properties,
# for use with Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
###############################################################################
#
# TestCase:
# ---------
# This resource test verifies default values for all properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_vdc properties'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
#
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_vdc',
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#

tests['limit_resource_module_type'] = {
  # This property does not have a meaningful default state because the module
  # types depend on which linecards are installed. Simply set the list to
  # a single common mod type and ensure that is the only type shown.
  manifest_props: {
    limit_resource_module_type: 'm1'
  },
  resource:       {
    'limit_resource_module_type' => 'm1'
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

def build_manifest_vdc(tests, id)
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node default {
    cisco_vdc { '#{default_vdc_name}':\n
    #{prop_hash_to_manifest(tests[id][:manifest_props])}
  }\n      }\nEOF"

  cmd = PUPPET_BINPATH + "resource cisco_vdc '#{default_vdc_name}'"
  tests[id][:resource_cmd] = get_namespace_cmd(agent, cmd, options)
end

def test_harness_vdc(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_vdc(tests, id)

  # Workaround for (ioctl) facter bug on n7k ***
  tests[id][:code] = [0, 2] if platform[/n7k/]

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # Pre-test Cleanup
  raise_skip_exception('ONLY SUPPORTED ON N7K', self) unless platform == 'n7k'
  limit_resource_module_type_set(default_vdc_name, nil, true)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")

  id = 'limit_resource_module_type'
  tests[id][:desc] = '1.1 limit_resource_module_type non default'
  test_harness_vdc(tests, id)

  tests[id][:desc] = '1.2 limit_resource_module_type default'
  tests[id][:manifest_props] = { limit_resource_module_type: 'default' }
  build_manifest_vdc(tests, id)
  test_manifest(tests, id)

  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{testheader} :: End")
