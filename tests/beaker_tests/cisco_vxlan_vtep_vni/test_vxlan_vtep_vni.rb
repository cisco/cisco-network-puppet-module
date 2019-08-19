###############################################################################
# Copyright (c) 2015-2018 Cisco and/or its affiliates.
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
#
# See README-develop-beaker-scripts.md (Section: Test Script Variable Reference)
# for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  platform:      'n(3k-f|5k|6k|7k|9k)',
  resource_name: 'cisco_vxlan_vtep_vni',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)
skip_if_nv_overlay_rejected(agent) if platform[/n(5|6)k/]

# Skip -ALL- tests if being run on a non-default VDC
skip_non_default_vdc(agent)

# Test hash test cases
tests[:default_properties_ingress_replication] = {
  desc:           '1.1 Default Properties Ingress replication',
  title_pattern:  'nve1 10000',
  platform:       'n9k$',
  manifest_props: {
    ingress_replication:           'default',
    suppress_arp:                  'default',
    multisite_ingress_replication: 'default',
  },
  code:           [0, 2],
  resource:       {
    suppress_arp:                  'false',
    multisite_ingress_replication: 'false',
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
  platform:       'n9k$',
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
  platform:       'n9k$',
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
  platform:       'n9k$',
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
  platform:       'n9k$',
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
  platform:       'n9k$',
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

tests[:suppress_arp_disable_true] = {
  desc:           '2.9 Suppress ARP Disable True',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_arp_disable: 'true'
  },
  code:           [0, 2],
}

tests[:suppress_arp_disable_false] = {
  desc:           '2.10 Suppress ARP Disable False',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_arp_disable: 'false'
  },
  code:           [0, 2],
}

tests[:suppress_uuc_true] = {
  desc:           '2.11 Suppress UUC True',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_uuc: 'true'
  },
  code:           [0, 2],
}

tests[:suppress_uuc_false] = {
  desc:           '2.12 Suppress UUC False',
  title_pattern:  'nve1 10000',
  manifest_props: {
    suppress_uuc: 'false'
  },
  code:           [0, 2],
}

tests[:multisite_ingress_replication_true] = {
  desc:           '2.13 Multisite Ingress Replication True',
  title_pattern:  'nve1 10000',
  manifest_props: {
    multisite_ingress_replication: 'true'
  },
  resource:       {
    multisite_ingress_replication: 'true'
  },
  code:           [0, 2],
}

tests[:multisite_ingress_replication_false] = {
  desc:           '2.14 Multisite Ingress Replication False',
  title_pattern:  'nve1 10000',
  manifest_props: {
    multisite_ingress_replication: 'false'
  },
  resource:       {
    multisite_ingress_replication: 'false'
  },
  code:           [0, 2],
}

# Note: In the current implementation assciate-vrf is a namevar.
# It will be changed to a property in future. A correspoding test
# will be added here.

# class to contain the test_harness_dependencies
class TestVxLanVtepVni < BaseHarness
  def self.test_harness_dependencies(ctx, _tests, _id)
    ctx.test_set(ctx.agent, 'evpn multisite border 150') if ctx.platform[/ex/]
  end

  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    if ctx.platform[/n(3k-f|5k|6k|7k|9k-f)/]
      unprops <<
        :ingress_replication <<
        :peer_list
    end
    if ctx.platform[/n(3k-f|9k)/]
      unprops <<
        :suppress_uuc
    end
    unprops << :multisite_ingress_replication unless ctx.platform[/ex/]
    if ctx.platform[/n(3k-f|5k|6k|7k)/]
      unprops <<
        :suppress_arp_disable
    end
    unprops << :multisite_ingress_replication unless ctx.platform[/ex/]
    unprops
  end

  def self.version_unsupported_properties(ctx, _tests, _id)
    unprops = {}
    unprops[:suppress_uuc] = '8.1.1' if ctx.platform[/n7k/]
    unprops[:suppress_arp_disable] = '9.2' if ctx.platform[/n9k/]
    unprops
  end

  # Overridden to properly handle dependencies for this test file.
  def self.dependency_manifest(ctx, _tests, _id)
    if ctx.platform[/n7k/]
      "
        cisco_vxlan_vtep {'nve1':
          ensure => present,
          host_reachability => 'evpn',
          shutdown           => 'false',
        }
      "
    else
      "
        cisco_vxlan_vtep {'nve1':
          ensure => present,
          shutdown           => 'false',
        }
      "
    end
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    test_set(agent, 'no evpn multisite border 150') if platform[/ex/]
    resource_absent_cleanup(agent, 'cisco_vxlan_vtep_vni')
    vdc_limit_f3_no_intf_needed(:clear)
  end
  test_set(agent, 'no evpn multisite border 150') if platform[/ex/]
  resource_absent_cleanup(agent, 'cisco_vxlan_vtep_vni')
  vdc_limit_f3_no_intf_needed(:set)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default_properties_ingress_replication
  test_harness_run(tests, id, harness_class: TestVxLanVtepVni)
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestVxLanVtepVni)
  id = :default_properties_multicast_group
  test_harness_run(tests, id, harness_class: TestVxLanVtepVni)
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestVxLanVtepVni)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :ingress_replication_static_peer_list_empty, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :peer_list, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :peer_list_change_add, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :peer_list_default, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :ingress_replication_bgp, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :multicast_group, harness_class: TestVxLanVtepVni)

  # TBD - The suppress_arp tests will generate the following error.
  #  ERROR: Please configure TCAM region... Configuring the TCAM region
  # requires a switch reboot.  These tests will remain commented out
  # until we can design a solution.

  # test_harness_run(tests, :suppress_arp_true)
  # test_harness_run(tests, :suppress_arp_false)
  # test_harness_run(tests, :suppress_arp_disable_true)
  # test_harness_run(tests, :suppress_arp_disable_false)

  test_harness_run(tests, :suppress_uuc_true, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :suppress_uuc_false, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :multisite_ingress_replication_true, harness_class: TestVxLanVtepVni)
  test_harness_run(tests, :multisite_ingress_replication_false, harness_class: TestVxLanVtepVni)

  # -------------------------------------------------------------------
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
