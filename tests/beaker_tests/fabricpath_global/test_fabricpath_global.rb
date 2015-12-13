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
# test-fabricpath_global.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet fabricpath_global resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This Tunnel resource test verifies default values for all properties.
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
testheader = 'Resource cisco_fabricpath_global'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

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
  master:   master,
  agent:    agent,
  show_cmd: 'show run fabricpath',
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
# tests[id][:af] - (Optional) defines the address-family values.
#   Must use :title_pattern if :af is not specified. Useful for testing mixed
#   title/af manifests
#
tests['default_properties'] = {
  title_pattern:  'default',
  manifest_props: "
    allocate_delay                 => 'default',
    graceful_merge                 => 'default',
    linkup_delay                   => 'default',
    loadbalance_unicast_layer      => 'default',
    loadbalance_unicast_has_vlan   => 'default',
    mode                           => 'default',
    transition_delay               => 'default',
  ",
  resource_props: {
    'allocate_delay'               => '10',
    'graceful_merge'               => 'enable',
    'linkup_delay'                 => '10',
    'loadbalance_unicast_layer'    => 'mixed',
    'loadbalance_unicast_has_vlan' => 'true',
    'mode'                         => 'normal',
    'transition_delay'             => '10',
  },
}

tests['default_properties_exclusive'] = {
  title_pattern:  'default',
  manifest_props: "
    aggregate_multicast_routes     => 'default',
    linkup_delay_always            => 'default',
    linkup_delay_enable            => 'default',
    loadbalance_multicast_rotate   => 'default',
    loadbalance_multicast_has_vlan => 'default',
    loadbalance_unicast_rotate     => 'default',
    ttl_multicast                  => 'default',
    ttl_unicast                    => 'default',
  ",
  resource_props: {
    'aggregate_multicast_routes'     => 'false',
    'linkup_delay_always'            => 'false',
    'linkup_delay_enable'            => 'true',
    'loadbalance_multicast_rotate'   => '1',
    'loadbalance_multicast_has_vlan' => 'true',
    'loadbalance_unicast_rotate'     => '1',
    'ttl_multicast'                  => '32',
    'ttl_unicast'                    => '32',
  },
}

tests['non_default_properties'] = {
  title_pattern:  'default',
  manifest_props: "
    allocate_delay                 => '30',
    graceful_merge                 => 'disable',
    linkup_delay                   => '20',
    loadbalance_unicast_layer      => 'layer4',
    loadbalance_unicast_has_vlan   => 'true',
    mode                           => 'transit',
    switch_id                      => '100',
    transition_delay               => '25',
  ",
  resource_props: {
    'allocate_delay'               => '30',
    'graceful_merge'               => 'disable',
    'linkup_delay'                 => '20',
    'loadbalance_unicast_layer'    => 'layer4',
    'loadbalance_unicast_has_vlan' => 'true',
    'mode'                         => 'transit',
    'switch_id'                    => '100',
    'transition_delay'             => '25',
  },
}

tests['non_default_properties_exclusive'] = {
  title_pattern:  'default',
  manifest_props: "
    aggregate_multicast_routes     => 'true',
    linkup_delay_always            => 'false',
    linkup_delay_enable            => 'false',
    loadbalance_multicast_rotate   => '3',
    loadbalance_multicast_has_vlan => 'true',
    loadbalance_unicast_rotate     => '5',
    ttl_multicast                  => '20',
    ttl_unicast                    => '20',
  ",
  resource_props: {
    'aggregate_multicast_routes'     => 'true',
    'linkup_delay_always'            => 'false',
    'linkup_delay_enable'            => 'false',
    'loadbalance_multicast_rotate'   => '3',
    'loadbalance_multicast_has_vlan' => 'true',
    'loadbalance_unicast_rotate'     => '5',
    'ttl_multicast'                  => '20',
    'ttl_unicast'                    => '20',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  UtilityLib::PUPPET_BINPATH + 'resource cisco_fabricpath_global'
end

def build_manifest_fabricpath_global(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_fabricpath_global :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_fabricpath_global { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_fabricpath_global(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_fabricpath_global(tests, id)

  # FUTURE
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
  #  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  #  tests[id][:desc] = '1.0 Cleanup using absent'
  #  tests[id][:ensure] = :absent
  #  test_harness_fabricpath_global(tests, id)
  device = device_type
  logger.info("#### This device is of type: #{device} #####")
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  node_featureset_cleanup(agent, 'fabricpath', 'cleanup', false)

  # -----------------------------------
  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_fabricpath_global(tests, id)

  tests[id][:desc] = '1.2 Default Properties (absent)'
  tests[id][:ensure] = :absent
  test_harness_fabricpath_global(tests, id)

  # -------------------------------------------------------------------
  if device == :N7K
    logger.info("\n#{'-' * 60}\nSection 2. Default Property Testing exclusive")

    # -----------------------------------
    id = 'default_properties_exclusive'
    tests[id][:desc] = '2.1 Default Properties exclusive to Platform'
    test_harness_fabricpath_global(tests, id)

    tests[id][:desc] = '2.2 Default Properties exclusive to Platform (absent)'
    tests[id][:ensure] = :absent
    test_harness_fabricpath_global(tests, id)
  else
    logger.info("\n#{'-' * 60}\n"\
                "Skipping for #{device} Section 2. Default Property exclusive")
  end
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Non Default Property Testing")

  # -----------------------------------
  id = 'non_default_properties'
  tests[id][:desc] = '3.1 Non Default Properties'
  test_harness_fabricpath_global(tests, id)

  tests[id][:desc] = '3.2 Non Default Properties (absent)'
  tests[id][:ensure] = :absent
  test_harness_fabricpath_global(tests, id)

  # -------------------------------------------------------------------
  if device == :N7K
    logger.info("\n#{'-' * 60}\nSection 4. Non Default Property Testing excl")

    # -----------------------------------
    id = 'default_properties_exclusive'
    tests[id][:desc] = '4.1 Non Default Properties exclusive to Platform'
    test_harness_fabricpath_global(tests, id)

    tests[id][:desc] = '4.2 Non Default Properties exclusive to Platform (abs)'
    tests[id][:ensure] = :absent
    test_harness_fabricpath_global(tests, id)
  else
    logger.info("\n#{'-' * 60}\n"\
                "Skipping for #{device} Section 4. Non Default Property excl")
  end

  # -------------------------------------------------------------------
  # FUTURE
  # logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  # node_featureset_cleanup(agent, 'fabricpath')

  # id = 'title_patterns'
  # tests[id][:desc] = '3.1 Title Patterns'
  # tests[id][:title_pattern] = '2'
  # tests[id][:af] = { :vrf => 'default', :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_fabricpath_global(tests, id)

  # id = 'title_patterns'
  # tests[id][:desc] = '3.2 Title Patterns'
  # tests[id][:title_pattern] = '2 blue'
  # tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_fabricpath_global(tests, id)
end

logger.info('TestCase :: # {testheader} :: End')
