###############################################################################
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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
require File.expand_path('../../cisco_bgp/bgplib.rb', __FILE__)

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_bgp_af',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  preclean:       'cisco_bgp',
  title_pattern:  '2 default ipv4 unicast',
  manifest_props: {
    additional_paths_install:      'default',
    additional_paths_receive:      'default',
    additional_paths_selection:    'default',
    additional_paths_send:         'default',
    advertise_l2vpn_evpn:          'default',
    client_to_client:              'default',
    dampen_igp_metric:             'default',
    dampening_state:               'default',
    dampening_half_time:           'default',
    dampening_max_suppress_time:   'default',
    dampening_reuse_time:          'default',
    dampening_suppress_time:       'default',
    default_information_originate: 'default',
    default_metric:                'default',
    distance_ebgp:                 'default',
    distance_ibgp:                 'default',
    distance_local:                'default',
    inject_map:                    'default',
    maximum_paths:                 'default',
    maximum_paths_ibgp:            'default',
    next_hop_route_map:            'default',
    networks:                      'default',
    redistribute:                  'default',
    suppress_inactive:             'default',
    table_map:                     'default',
    table_map_filter:              'default',
  },
  resource:       {
    'additional_paths_install'      => 'false',
    'additional_paths_receive'      => 'false',
    'additional_paths_send'         => 'false',
    'advertise_l2vpn_evpn'          => 'true',
    'client_to_client'              => 'true',
    'dampen_igp_metric'             => '600',
    'dampening_state'               => 'true',
    'dampening_half_time'           => '15',
    'dampening_max_suppress_time'   => '45',
    'dampening_reuse_time'          => '750',
    'dampening_suppress_time'       => '2000',
    'default_information_originate' => 'false',
    'distance_ebgp'                 => '20',
    'distance_ibgp'                 => '200',
    'distance_local'                => '220',
    'maximum_paths'                 => '1',
    'maximum_paths_ibgp'            => '1',
    'suppress_inactive'             => 'false',
    'table_map_filter'              => 'false',
  },
}

# Special case: When dampening_routemap is set to default
# it means that dampening is enabled without routemap.
tests[:default_dampening_routemap] = {
  desc:           '1.2 Default dampening_routemap',
  title_pattern:  '2 default ipv4 unicast',
  manifest_props: {
    dampening_routemap: 'default'
  },
  resource:       {
    'dampening_state'             => 'true',
    'dampening_half_time'         => '15',
    'dampening_max_suppress_time' => '45',
    'dampening_reuse_time'        => '750',
    'dampening_suppress_time'     => '2000',
  },
}

#
# non_default_properties
#
tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  preclean:       'cisco_bgp',
  title_pattern:  '2 default ipv4 unicast',
  manifest_props: {
    additional_paths_install:      'true',
    additional_paths_receive:      'true',
    additional_paths_selection:    'RouteMap',
    additional_paths_send:         'true',
    advertise_l2vpn_evpn:          'true',
    client_to_client:              'false',
    dampen_igp_metric:             '200',
    dampening_half_time:           '1',
    dampening_max_suppress_time:   '4',
    dampening_reuse_time:          '2',
    dampening_suppress_time:       '3',
    default_information_originate: 'true',
    default_metric:                '50',
    distance_ebgp:                 '30',
    distance_ibgp:                 '60',
    distance_local:                '90',
    maximum_paths:                 '9',
    maximum_paths_ibgp:            '9',
    next_hop_route_map:            'RouteMap',
    suppress_inactive:             'true',
    table_map:                     'RouteMap',
    table_map_filter:              'true',
  },
}

injectmap = Array[%w(nyc sfo), %w(sjc sfo copy-attributes)]
networks = Array[%w(192.168.5.0/24 RouteMap), %w(192.168.6.0/32)]
redistribute = Array[%w(lisp RouteMap), %w(static RouteMap)]
tests[:non_default_arrays] = {
  desc:           '2.2 Non Default Properties: Arrays',
  title_pattern:  '2 default ipv4 unicast',
  manifest_props: {
    inject_map:   injectmap,
    networks:     networks,
    redistribute: redistribute,
  },
  resource:       {
    inject_map:   "#{injectmap}",
    networks:     "#{networks}",
    redistribute: "#{redistribute}",
  },
}

# Special case: When dampening_routemap is mutually exclusive
# with other dampening properties.
tests[:non_default_dampening_routemap] = {
  desc:           '2.3 Non-Default dampening_routemap',
  title_pattern:  '2 default ipv4 unicast',
  manifest_props: { dampening_routemap: 'RouteMap' },
}

tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  preclean:      'cisco_bgp',
  title_pattern: 'new_york',
  title_params:  { asn: '2', vrf: 'red', afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: '2',
  title_params:  { vrf: 'blue', afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_3] = {
  desc:          'T.3 Title Pattern',
  title_pattern: '2 cyan ipv4',
  title_params:  { safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

# Overridden to properly handle dependencies for this test file.
def dependency_manifest(tests, id)
  extra_config = ''
  if operating_system == 'ios_xr'
    vrf = vrf(tests[id])

    # XR requires the following before a vrf AF can be configured:
    #   1. a global router_id
    #   2. a global address family
    #   3. route_distinguisher configured on the vrf
    extra_config = "
      cisco_bgp { '2 default':
        ensure              => present,
        router_id           => '1.2.3.4',
      }"

    parent_title = '2 default vpnv4 unicast'
    if parent_title != tests[id][:title_pattern]
      extra_config += "
        cisco_bgp_af { '#{parent_title}':
          ensure            => present,
        }"
    end

    # Ensure any needed route-policies are present.
    # TODO: Replace this with cisco_route_policy config,
    # when/if that is available.
    extra_config += "
      cisco_command_config { 'policy_config':
        command => '
          route-policy RouteMap
            end-policy'
      }"

    if vrf != 'default'
      extra_config += "
      cisco_bgp { '2 #{vrf}':
        ensure              => present,
        route_distinguisher => auto,
      }"
    end
  end
  extra_config
end

# Overridden to properly handle unsupported properties for this test file.
def unsupported_properties(tests, id)
  unprops = []

  vrf = vrf(tests[id])
  if operating_system == 'ios_xr'
    # IOS-XR does not support these properties
    unprops <<
      :additional_paths_install <<
      :advertise_l2vpn_evpn <<
      :dampen_igp_metric <<
      :default_information_originate <<
      :default_metric <<
      :inject_map <<
      :next_hop_route_map <<
      :suppress_inactive <<
      :table_map_filter

    if vrf != 'default'
      # IOS-XR does not support these properties under a non-default vrf
      unprops <<
        :client_to_client <<
        :dampening_state <<
        :dampening_half_time <<
        :dampening_max_suppress_time <<
        :dampening_reuse_time <<
        :dampening_routemap <<
        :dampening_suppress_time
    end
  else
    unprops << :advertise_l2vpn_evpn if
      vrf == 'default' || platform[/n(3|6)k/]

    unprops << :additional_paths_install if platform[/n(3|8|9)k/]
  end
  unprops
end

def test_harness_bgp_af_run(tests, id)
  test_harness_run(tests, id) # test in default vrf
  test_harness_bgp_vrf(tests, id, 'blue') # test in non-default vrf
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  # -----------------------------------
  id = :default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)
  test_harness_run(tests, :default_dampening_routemap)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_bgp_af_run(tests, :non_default)
  test_harness_bgp_af_run(tests, :non_default_arrays)
  test_harness_bgp_af_run(tests, :non_default_dampening_routemap)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  test_harness_run(tests, :title_patterns_3)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_bgp')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
