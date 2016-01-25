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
# test_interface_channel_group.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet cisco_interface_channel_group testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
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
testheader = 'Resource cisco_interface_channel_group'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:platform] - a regexp pattern to match against supported platforms.
#                    This key can be overridden by a tests[id][:platform] key
#
tests = {
  master: master,
  agent:  agent,
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:platform] - a regexp pattern to match against supported platforms.
#                        This key overrides a tests[:platform] key
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#
intf = 'ethernet1/1'
tests['default_properties'] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  code:           [0, 2],
  manifest_props: {
    channel_group: 'default',
    description:   'default',
    shutdown:      'default',
  },
  resource:       {
    'channel_group' => 'false',
    'shutdown'      => 'true',
  },
}

tests['non_default_properties'] = {
  desc:           '2.1 Non Default Properties commands',
  title_pattern:  intf,
  manifest_props: {
    channel_group: 201,
    description:   'chan group desc',
    shutdown:      'false',
  },
  resource:       {
    'channel_group' => '201',
    'description'   => 'chan group desc',
    'shutdown'      => 'false',
  },
}

# Create actual manifest for a given test scenario.
def build_manifest_interface_channel_group(tests, id)
  manifest = prop_hash_to_manifest(tests[id][:manifest_props])
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  \nnode default {
  cisco_interface_channel_group { '#{tests[id][:title_pattern]}':
    #{state}\n#{manifest}
  }\n}\nEOF"

  cmd = PUPPET_BINPATH +
        "resource cisco_interface_channel_group '#{tests[id][:title_pattern]}'"
  tests[id][:resource_cmd] = get_namespace_cmd(agent, cmd, options)
end

# Wrapper for interface_channel_group specific settings prior to calling the
# common test_harness.
def test_harness_interface_channel_group(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_interface_channel_group(tests, id)

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  interface_cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = 'default_properties'
  test_harness_interface_channel_group(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_interface_channel_group(tests, 'non_default_properties')

  # -------------------------------------------------------------------
  interface_cleanup(agent, intf)
end
logger.info("TestCase :: #{testheader} :: End")
