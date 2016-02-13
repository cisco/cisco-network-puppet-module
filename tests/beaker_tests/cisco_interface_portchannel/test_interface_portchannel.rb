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
# test-interface_portchannel.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet interface_portchannel resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This interface_portchannel resource test verifies default values for all
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
testheader = 'Resource cisco_interface_portchannel'

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

tests['default_properties_asym'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    lacp_graceful_convergence     => 'default',
    lacp_max_bundle               => 'default',
    lacp_min_links                => 'default',
    lacp_suspend_individual       => 'default',
    port_hash_distribution        => 'default',
    port_load_defer               => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'lacp_graceful_convergence' => 'true',
    'lacp_max_bundle'           => '16',
    'lacp_min_links'            => '1',
    'lacp_suspend_individual'   => 'true',
    'port_hash_distribution'    => 'false',
    'port_load_defer'           => 'false',
  },
}

tests['non_default_properties_asym'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    lacp_graceful_convergence     => 'false',
    lacp_max_bundle               => '10',
    lacp_min_links                => '3',
    lacp_suspend_individual       => 'false',
    port_hash_distribution        => 'fixed',
    port_load_defer               => 'true',
  ",
  resource_props: {
    'lacp_graceful_convergence' => 'false',
    'lacp_max_bundle'           => '10',
    'lacp_min_links'            => '3',
    'lacp_suspend_individual'   => 'false',
    'port_hash_distribution'    => 'fixed',
    'port_load_defer'           => 'true',
  },
}

tests['default_properties_sym'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    lacp_graceful_convergence     => 'default',
    lacp_max_bundle               => 'default',
    lacp_min_links                => 'default',
    lacp_suspend_individual       => 'default',
    port_hash_distribution        => 'default',
    port_load_defer               => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'lacp_graceful_convergence' => 'true',
    'lacp_max_bundle'           => '32',
    'lacp_min_links'            => '1',
    'lacp_suspend_individual'   => 'true',
    'port_hash_distribution'    => 'false',
    'port_load_defer'           => 'false',
  },
}

tests['non_default_properties_sym'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    lacp_graceful_convergence     => 'false',
    lacp_max_bundle               => '10',
    lacp_min_links                => '3',
    lacp_suspend_individual       => 'false',
    port_hash_distribution        => 'fixed',
    port_load_defer               => 'true',
  ",
  resource_props: {
    'lacp_graceful_convergence' => 'false',
    'lacp_max_bundle'           => '10',
    'lacp_min_links'            => '3',
    'lacp_suspend_individual'   => 'false',
    'port_hash_distribution'    => 'fixed',
    'port_load_defer'           => 'true',
  },
}

tests['default_properties_eth'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    lacp_graceful_convergence     => 'default',
    lacp_max_bundle               => 'default',
    lacp_min_links                => 'default',
    lacp_suspend_individual       => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'lacp_graceful_convergence' => 'true',
    'lacp_max_bundle'           => '16',
    'lacp_min_links'            => '1',
    'lacp_suspend_individual'   => 'true',
  },
}

tests['non_default_properties_eth'] = {
  title_pattern:  'port-channel100',
  manifest_props: "
    lacp_graceful_convergence     => 'false',
    lacp_max_bundle               => '10',
    lacp_min_links                => '3',
    lacp_suspend_individual       => 'false',
  ",
  resource_props: {
    'lacp_graceful_convergence' => 'false',
    'lacp_max_bundle'           => '10',
    'lacp_min_links'            => '3',
    'lacp_suspend_individual'   => 'false',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH +
        'resource cisco_interface_portchannel port-channel100'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_interface_portchannel(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_interface_portchannel :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_interface_portchannel { 'port-channel100':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_interface_portchannel(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_interface_portchannel(tests, id)

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
  resource_absent_cleanup(agent, 'cisco_interface_portchannel',
                          'Setup switch for interface_portchannel provider test')
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  case device
  when /n7k/
    id = 'default_properties_asym'
  when /n5k|n6k/
    id = 'default_properties_eth'
  when /n3k|n9k/
    id = 'default_properties_sym'
  end

  tests[id][:desc] = '1.1 Default Properties'
  test_harness_interface_portchannel(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_interface_portchannel(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  case device
  when /n7k/
    id = 'non_default_properties_asym'
  when /n5k|n6k/
    id = 'non_default_properties_eth'
  when /n3k|n9k/
    id = 'non_default_properties_sym'
  end
  tests[id][:desc] = '2.1 Non Default Properties'
  test_harness_interface_portchannel(tests, id)

  tests[id][:desc] = '2.2 Non Default Properties (absent)'
  tests[id][:ensure] = :absent
  test_harness_interface_portchannel(tests, id)
end

logger.info("TestCase :: #{testheader} :: End")
