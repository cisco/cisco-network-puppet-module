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
# test-stp_global.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet stp_global resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This stp_global resource test verifies default values for all
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
testheader = 'Resource cisco_stp_global'

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

tests['default_properties_domain'] = {
  title_pattern:  'default',
  manifest_props: "
    bpdufilter         => 'default',
    bpduguard          => 'default',
    bridge_assurance   => 'default',
    domain             => 'default',
    loopguard          => 'default',
    mode               => 'default',
    mst_forward_time   => 'default',
    mst_hello_time     => 'default',
    mst_max_age        => 'default',
    mst_max_hops       => 'default',
    mst_name           => 'default',
    mst_revision       => 'default',
    pathcost           => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'bpdufilter'       => 'false',
    'bpduguard'        => 'false',
    'bridge_assurance' => 'true',
    'domain'           => 'false',
    'loopguard'        => 'false',
    'mode'             => 'rapid-pvst',
    'mst_forward_time' => '15',
    'mst_hello_time'   => '2',
    'mst_max_age'      => '20',
    'mst_max_hops'     => '20',
    'mst_name'         => 'false',
    'mst_revision'     => '0',
    'pathcost'         => 'short',
  },
}

tests['non_default_properties_domain'] = {
  title_pattern:  'default',
  manifest_props: "
    bpdufilter         => 'true',
    bpduguard          => 'true',
    bridge_assurance   => 'false',
    domain             => '100',
    loopguard          => 'true',
    mode               => 'mst',
    mst_forward_time   => '25',
    mst_hello_time     => '5',
    mst_max_age        => '35',
    mst_max_hops       => '200',
    mst_name           => 'nexus',
    mst_revision       => '34',
    pathcost           => 'long',
  ",
  resource_props: {
    'bpdufilter'       => 'true',
    'bpduguard'        => 'true',
    'bridge_assurance' => 'false',
    'domain'           => '100',
    'loopguard'        => 'true',
    'mode'             => 'mst',
    'mst_forward_time' => '25',
    'mst_hello_time'   => '5',
    'mst_max_age'      => '35',
    'mst_max_hops'     => '200',
    'mst_name'         => 'nexus',
    'mst_revision'     => '34',
    'pathcost'         => 'long',
  },
}

tests['default_properties_fcoe'] = {
  title_pattern:  'default',
  manifest_props: "
    bpdufilter         => 'default',
    bpduguard          => 'default',
    bridge_assurance   => 'default',
    fcoe               => 'default',
    loopguard          => 'default',
    mode               => 'default',
    mst_forward_time   => 'default',
    mst_hello_time     => 'default',
    mst_max_age        => 'default',
    mst_max_hops       => 'default',
    mst_name           => 'default',
    mst_revision       => 'default',
    pathcost           => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'bpdufilter'       => 'false',
    'bpduguard'        => 'false',
    'bridge_assurance' => 'true',
    'fcoe'             => 'true',
    'loopguard'        => 'false',
    'mode'             => 'rapid-pvst',
    'mst_forward_time' => '15',
    'mst_hello_time'   => '2',
    'mst_max_age'      => '20',
    'mst_max_hops'     => '20',
    'mst_name'         => 'false',
    'mst_revision'     => '0',
    'pathcost'         => 'short',
  },
}

tests['non_default_properties_fcoe'] = {
  title_pattern:  'default',
  manifest_props: "
    bpdufilter         => 'true',
    bpduguard          => 'true',
    bridge_assurance   => 'false',
    fcoe               => 'false',
    loopguard          => 'true',
    mode               => 'mst',
    mst_forward_time   => '25',
    mst_hello_time     => '5',
    mst_max_age        => '35',
    mst_max_hops       => '200',
    mst_name           => 'nexus',
    mst_revision       => '34',
    pathcost           => 'long',
  ",
  resource_props: {
    'bpdufilter'       => 'true',
    'bpduguard'        => 'true',
    'bridge_assurance' => 'false',
    'fcoe'             => 'false',
    'loopguard'        => 'true',
    'mode'             => 'mst',
    'mst_forward_time' => '25',
    'mst_hello_time'   => '5',
    'mst_max_age'      => '35',
    'mst_max_hops'     => '200',
    'mst_name'         => 'nexus',
    'mst_revision'     => '34',
    'pathcost'         => 'long',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH +
        'resource cisco_stp_global'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_stp_global(tests, id)
  manifest = tests[id][:manifest_props]
  tests[id][:resource] = tests[id][:resource_props]

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_stp_global :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_stp_global { 'default':
      #{manifest}
    }
  }
EOF"
end

def test_harness_stp_global(tests, id)
  tests[id][:resource_cmd] = puppet_resource_cmd

  # Build the manifest for this test
  build_manifest_stp_global(tests, id)

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

  case device
  when /n5k|n6k|n7k/
    id = 'default_properties_domain'
  when /n3k|n9k/
    id = 'default_properties_fcoe'
  end

  tests[id][:desc] = '1.1 Default Properties'
  test_harness_stp_global(tests, id)

  # no absent test for stp_global

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  case device
  when /n5k|n6k|n7k/
    id = 'non_default_properties_domain'
  when /n3k|n9k/
    id = 'non_default_properties_fcoe'
  end

  tests[id][:desc] = '2.1 Non Default Properties'
  test_harness_stp_global(tests, id)

  # no absent test for stp_global
end

logger.info("TestCase :: #{testheader} :: End")
