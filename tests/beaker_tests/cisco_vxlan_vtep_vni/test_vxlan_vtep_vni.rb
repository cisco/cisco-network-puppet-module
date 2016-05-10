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
# test_cisco_vxlan_vtep_vni.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet cisco_vxlan_vtep_vni resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This cisco_vxlan_vtep_vni resource test verifies default and non-default values
# for all properties.
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
testheader = 'Resource cisco_vxlan_vtep_vni'

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
  platform:      'n(5|6|7|8|9)k',
  resource_name: 'cisco_vxlan_vtep_vni',
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
tests['default_properties_ingress_replication'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(8|9)k',
  manifest_props: "
    ingress_replication => 'default',
    suppress_arp        => 'default',
  ",
  resource_props: {
    # 'ingress_replication' not set.
    'suppress_arp' => 'false'
  },
}

tests['default_properties_multicast_group'] = {
  title_pattern:  'nve1 10000',
  manifest_props: "
    multicast_group => 'default',
    suppress_arp    => 'default',
  ",
  resource_props: {
    # 'multicast_group' not set.
    'suppress_arp' => 'false'
  },
}

# Suppress Unknown Unicast
if platform[/n(5|6)k/]
  tests['default_properties_multicast_group'][:manifest_props][:suppress_uuc] = 'default'
  tests['default_properties_multicast_group'][:resource_props][:suppress_uuc] = 'false'
end

tests['ingress_replication_static_peer_list_empty'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(8|9)k',
  manifest_props: "
    ingress_replication => 'static',
    peer_list           => [],
    suppress_arp        => 'default'
  ",
  resource_props: {
    'ingress_replication' => 'static',
    # 'peer_list' not set.
    'suppress_arp'        => 'false',
  },
}

tests['peer_list'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(8|9)k',
  manifest_props: "
    ingress_replication => 'static',
    peer_list           => ['1.1.1.1', '2.2.2.2', '3.3.3.3'],
    suppress_arp        => 'default'
  ",
  resource_props: {
    'ingress_replication' => 'static',
    'peer_list'           => "['1.1.1.1', '2.2.2.2', '3.3.3.3']",
    'suppress_arp'        => 'false',
  },
}

tests['peer_list_change_add'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(8|9)k',
  manifest_props: "
    ingress_replication => 'static',
    peer_list           => ['1.1.1.1', '6.6.6.6', '3.3.3.3', '4.4.4.4'],
    suppress_arp        => 'default'
  ",
  resource_props: {
    'ingress_replication' => 'static',
    'peer_list'           => "['1.1.1.1', '3.3.3.3', '4.4.4.4', '6.6.6.6']",
    'suppress_arp'        => 'false',
  },
}

tests['peer_list_default'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(8|9)k',
  manifest_props: "
    ingress_replication => 'static',
    peer_list           => 'default',
    suppress_arp        => 'default'
  ",
  resource_props: {
    'ingress_replication' => 'static',
    # 'peer_list' not set.
    'suppress_arp'        => 'false',
  },
}

tests['ingress_replication_bgp'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(8|9)k',
  manifest_props: "
    ingress_replication => 'bgp',
    suppress_arp        => 'default'
  ",
  resource_props: {
    'ingress_replication' => 'bgp',
    'suppress_arp'        => 'false',
  },
}

tests['multicast_group'] = {
  title_pattern:  'nve1 10000',
  manifest_props: "
    multicast_group => '224.1.1.1',
    suppress_arp    => 'default'
  ",
  resource_props: {
    'multicast_group' => '224.1.1.1',
    'suppress_arp'    => 'false',
  },
}

tests['suppress_arp_true'] = {
  title_pattern:  'nve1 10000',
  manifest_props: "
    suppress_arp => 'true'
  ",
  resource_props: {
    'suppress_arp' => 'true'
  },
}

tests['suppress_arp_false'] = {
  title_pattern:  'nve1 10000',
  manifest_props: "
    suppress_arp => 'false'
  ",
  resource_props: {
    'suppress_arp' => 'false'
  },
}

tests['suppress_uuc_true'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(5|6)k',
  manifest_props: "
    suppress_uuc => 'true'
  ",
  resource_props: {
    'suppress_uuc' => 'true'
  },
}

tests['suppress_uuc_false'] = {
  title_pattern:  'nve1 10000',
  platform:       'n(5|6)k',
  manifest_props: "
    suppress_uuc => 'false'
  ",
  resource_props: {
    'suppress_uuc' => 'false'
  },
}

# Note: In the current implementation assciate-vrf is a namevar.
# It will be changed to a property in future. A correspoding test
# will be added here.

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  PUPPET_BINPATH + 'resource cisco_vxlan_vtep_vni'
end

def build_manifest_cisco_vxlan_vtep_vni(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_cisco_vxlan_vtep_vni :: title_pattern:\n" +
               tests[id][:title_pattern])

  # cisco_vxlan_vtep_vni needs cisco_vxlan_vtep as a prerequisite.
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_vxlan_vtep {'nve1':
      ensure => present,
      host_reachability  => 'evpn',
      shutdown           => 'false',
    }
    cisco_vxlan_vtep_vni { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_cisco_vxlan_vtep_vni(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  build_manifest_cisco_vxlan_vtep_vni(tests, id)

  test_manifest(tests, id)
  test_resource(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  skip_unless_supported(tests)

  #-------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_vxlan_vtep_vni',
                          'Setup switch for cisco_vxlan_vtep_vni provider test')
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  # -------------------------------------------------------------------
  id = 'default_properties_ingress_replication'
  tests[id][:desc] = '1.1 Default Properties Ingress Replication'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  tests[id][:desc] = '1.2 Default Properties Ingress Replication'
  tests[id][:ensure] = :absent
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  id = 'default_properties_multicast_group'
  tests[id][:desc] = '1.3 Default Properties Multicast Group'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  tests[id][:desc] = '1.4 Default Properties Multicast Group'
  tests[id][:ensure] = :absent
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  id = 'ingress_replication_static_peer_list_empty'
  tests[id][:desc] = '2.1 Ingress Replication Static'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  id = 'peer_list'
  tests[id][:desc] = '2.2 Peer List'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  id = 'peer_list_change_add'
  tests[id][:desc] = '2.3 Peer List Change Add'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  id = 'peer_list_default'
  tests[id][:desc] = '2.4 Peer List Default'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  id = 'ingress_replication_bgp'
  tests[id][:desc] = '2.5 Ingress Replication BGP'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  id = 'multicast_group'
  tests[id][:desc] = '2.6 Multicast Group'
  test_harness_cisco_vxlan_vtep_vni(tests, id)

  # TBD - The following tests will generate the following error.
  #  ERROR: Please configure TCAM region... Configuring the TCAM region
  # requires a switch reboot.  These tests will remain commented out
  # until we can design a solution.

  # id = 'suppress_arp_true'
  # tests[id][:desc] = '2.7 Suppress ARP'
  # test_harness_cisco_vxlan_vtep_vni(tests, id)

  # id = 'suppress_arp_false'
  # tests[id][:desc] = '2.8 Suppress ARP'
  # test_harness_cisco_vxlan_vtep_vni(tests, id)

  # id = 'suppress_uuc_true'
  # tests[id][:desc] = '2.9 Suppress Unknown Unicast'
  # test_harness_cisco_vxlan_vtep_vni(tests, id)
  #
  # id = 'suppress_uuc_false'
  # tests[id][:desc] = '2.10 Suppress Unknown Unicast'
  # test_harness_cisco_vxlan_vtep_vni(tests, id)

  resource_absent_cleanup(agent, 'cisco_vxlan_vtep_vni',
                          'Setup switch for cisco_vxlan_vtep_vni provider test')
end

logger.info('TestCase :: # {testheader} :: End')
