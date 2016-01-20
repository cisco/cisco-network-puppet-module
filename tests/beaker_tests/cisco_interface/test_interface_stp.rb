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
# TestCase Name:
# -------------
# test-interface_stp.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet interface spanning-tree resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This interface resource test verifies default values for all spanning-tree
# properties.
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
testheader = 'Resource cisco_interface'

# Define PUPPETMASTER_MANIFESTPATH.

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
#
tests = {
  master: master,
  agent:  agent,
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:show_pattern] - array of regexp patterns to use with test_show_cmd
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
#   Can be used with :af for mixed title/af testing. If mixing, :af values will
#   be merged with title values and override any duplicates. If omitted,
#   :title_pattern will be set to 'id'.
#

tests['default_properties'] = {
  title_pattern:  'ethernet1/4',
  manifest_props: "
    stp_bpdufilter       => 'default',
    stp_bpduguard        => 'default',
    stp_cost             => 'default',
    stp_guard            => 'default',
    stp_link_type        => 'default',
    stp_port_priority    => 'default',
    stp_port_type        => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'stp_bpdufilter'    => 'false',
    'stp_bpduguard'     => 'false',
    'stp_cost'          => 'auto',
    'stp_guard'         => 'false',
    'stp_link_type'     => 'auto',
    'stp_port_priority' => '128',
    'stp_port_type'     => 'false',
  },
}

tests['non_default_properties'] = {
  title_pattern:  'ethernet1/4',
  manifest_props: "
    stp_bpdufilter       => 'enable',
    stp_bpduguard        => 'enable',
    stp_cost             => '2000',
    stp_guard            => 'loop',
    stp_link_type        => 'shared',
    stp_port_priority    => '64',
    stp_port_type        => 'network',
  ",
  resource_props: {
    'stp_bpdufilter'    => 'enable',
    'stp_bpduguard'     => 'enable',
    'stp_cost'          => '2000',
    'stp_guard'         => 'loop',
    'stp_link_type'     => 'shared',
    'stp_port_priority' => '64',
    'stp_port_type'     => 'network',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH +
        'resource cisco_interface ethernet1/4'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_interface_stp(tests, id)
  manifest = tests[id][:manifest_props]
  tests[id][:resource] = tests[id][:resource_props]

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_interface_stp :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_interface { 'ethernet1/4':
      #{manifest}
    }
  }
EOF"
end

def test_harness_interface_stp(tests, id)
  tests[id][:resource_cmd] = puppet_resource_cmd

  # Build the manifest for this test
  build_manifest_interface_stp(tests, id)

  # test_harness_common(tests, id)
  test_manifest(tests, id)
  test_resource(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  if device == 'n7k'
    id = 'default_properties'
    tests[id][:desc] = '1.1 Default Properties'
    test_harness_interface_stp(tests, id)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  if device == 'n7k'
    id = 'non_default_properties'
    tests[id][:desc] = '2.1 Non Default Properties'
    test_harness_interface_stp(tests, id)
  end
end

logger.info("TestCase :: #{testheader} :: End")
