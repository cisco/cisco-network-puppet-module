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

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  platform:      'n(5|6|7|9)k',
  resource_name: 'cisco_vxlan_vtep_vni',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default_properties_ingress_replication] = {
  desc:           '1.1 Default Properties Ingress replication',
  title_pattern:  'nve1 10000',
  platform:       'n(7|9)k',
  manifest_props: {
    ingress_replication: 'default',
    suppress_arp:        'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:default_properties_multicast_group] = {
  desc:           '1.2 Default Properties Multicast Group',
  title_pattern:  'nve1 10000',
  manifest_props: {
    multicast_group: 'default',
    suppress_arp:    'default',
    suppress_uuc:    'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false',
    suppress_uuc: 'false',
  },
}

tests[:ingress_replication_static_peer_list_empty] = {
  desc:           '2.1 Ingress Replication Static Peer List Empty',
  title_pattern:  'nve1 10000',
  platform:       'n(7|9)k',
  manifest_props: {
    ingress_replication: 'static',
    peer_list:           [],
    suppress_arp:        'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:peer_list] = {
  desc:           '2.2 Peer List',
  title_pattern:  'nve1 10000',
  platform:       'n(7|9)k',
  manifest_props: {
    ingress_replication: 'static',
    peer_list:           ['1.1.1.1', '2.2.2.2', '3.3.3.3'],
    suppress_arp:        'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:peer_list_change_add] = {
  desc:           '2.3 Peer List Change Add',
  title_pattern:  'nve1 10000',
  platform:       'n(7|9)k',
  manifest_props: {
    ingress_replication: 'static',
    peer_list:           ['1.1.1.1', '6.6.6.6', '3.3.3.3', '4.4.4.4'],
    suppress_arp:        'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:peer_list_default] = {
  desc:           '2.4 Peer List Default',
  title_pattern:  'nve1 10000',
  platform:       'n(7|9)k',
  manifest_props: {
    ingress_replication: 'static',
    peer_list:           'default',
    suppress_arp:        'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:ingress_replication_bgp] = {
  desc:           '2.5 Ingress replication BGP',
  title_pattern:  'nve1 10000',
  platform:       'n(7|9)k',
  manifest_props: {
    ingress_replication: 'bgp',
    suppress_arp:        'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:multicast_group] = {
  desc:           '2.6 Multicast Group',
  title_pattern:  'nve1 10000',
  manifest_props: {
    multicast_group: '224.1.1.1',
    suppress_arp:    'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp: 'false'
  },
}

tests[:suppress_arp_true] = {
  desc:           '2.7 Suppress ARP True',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_arp: 'true'
  },
  code:           [0, 2],
}

tests[:suppress_arp_false] = {
  desc:           '2.8 Suppress ARP False',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_arp: 'false'
  },
  code:           [0, 2],
}

tests[:suppress_uuc_true] = {
  desc:           '2.9 Suppress UUC True',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_uuc: 'true'
  },
  code:           [0, 2],
}

tests[:suppress_uuc_false] = {
  desc:           '2.10 Suppress UUC False',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_uuc: 'false'
  },
  code:           [0, 2],
}

# Note: In the current implementation assciate-vrf is a namevar.
# It will be changed to a property in future. A correspoding test
# will be added here.

def test_harness_dependencies(*)
  return unless platform[/n(5|6)k/]
  skip_if_nv_overlay_rejected(agent)
end

# Overridden to properly handle dependencies for this test file.
def dependency_manifest(_tests, _id)
  "
    cisco_vxlan_vtep {'nve1':
      ensure => present,
      host_reachability  => 'evpn',
      shutdown           => 'false',
    }
  "
end

def unsupported_properties(_tests, _id)
  unprops = []
  if platform[/n(5|6)k/]
    unprops <<
      :ingress_replication <<
      :peer_list
  elsif platform[/n9k/]
    unprops <<
      :suppress_uuc
  end
  unprops
end

def version_unsupported_properties(_tests, _id)
  unprops = {}
  if platform[/n7k/]
    unprops[:ingress_replication] = '8.1.1'
    unprops[:peer_list] = '8.1.1'
    unprops[:suppress_uuc] = '8.1.1'
  end
  unprops
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    resource_absent_cleanup(agent, 'cisco_vxlan_vtep_vni')
    vdc_limit_f3_no_intf_needed(:clear)
  end
  resource_absent_cleanup(agent, 'cisco_vxlan_vtep_vni')
  vdc_limit_f3_no_intf_needed(:set)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default_properties_ingress_replication
  test_harness_run(tests, id)
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)
  id = :default_properties_multicast_group
  test_harness_run(tests, id)
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :ingress_replication_static_peer_list_empty)
  test_harness_run(tests, :peer_list)
  test_harness_run(tests, :peer_list_change_add)
  test_harness_run(tests, :peer_list_default)
  test_harness_run(tests, :ingress_replication_bgp)
  test_harness_run(tests, :multicast_group)

  # TBD - The suppress_arp tests will generate the following error.
  #  ERROR: Please configure TCAM region... Configuring the TCAM region
  # requires a switch reboot.  These tests will remain commented out
  # until we can design a solution.

  # test_harness_run(tests, :suppress_arp_true)
  # test_harness_run(tests, :suppress_arp_false)

  test_harness_run(tests, :suppress_uuc_true)
  test_harness_run(tests, :suppress_uuc_false)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
