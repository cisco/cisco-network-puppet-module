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

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_bgp_neighbor_af',
}

# Overridden to properly handle unsupported properties.
def unsupported_properties(_, _)
  return [] if operating_system == 'nexus'

  [
    :additional_paths_receive,
    :additional_paths_send,
    :default_originate_route_map,
    :disable_peer_as_check,
    :filter_list_in,
    :filter_list_out,
    :next_hop_third_party,
    :prefix_list_in,
    :prefix_list_out,
    :suppress_inactive,
    :unsuppress_map,
  ]
end

# Overridden to properly handle dependencies for this test file.
def dependency_manifest(tests, id)
  af = puppet_resource_title_pattern_munge(tests, id)
  remote_as = tests[id][:remote_as]
  remote_as = 1 if remote_as.nil? && operating_system == 'ios_xr'

  extra_config = ''
  if operating_system[/ios_xr/]
    extra_config += "
      cisco_command_config { 'policy_config':
        command => '
          route-policy rm_in
            end-policy
          route-policy rm_out
            end-policy
        '
      }
    "
    # XR requires the following before a vrf AF can be configured:
    #   1. a global router_id
    #   2. a global address family
    #   3. route_distinguisher configured on the vrf
    #   4. remote-as is required for neighbor
    if af[:vrf] != 'default'
      global_afi = (af[:afi] == 'ipv6') ? 'vpnv6' : 'vpnv4'
      extra_config += "
        cisco_bgp { '#{af[:asn]}':
          ensure              => present,
          router_id           => '1.2.3.4',
        }
        cisco_bgp_af { '#{af[:asn]} default #{global_afi} #{af[:safi]}':
          ensure              => present,
        }
        cisco_bgp { '#{af[:asn]} #{af[:vrf]}':
          ensure              => present,
          route_distinguisher => auto,
        }
      "
    end
    extra_config += "
      cisco_bgp_af { '#{af[:asn]} #{af[:vrf]} #{af[:afi]} #{af[:safi]}':
        ensure                => present,
      }
    "
  end # if ios_xr

  if remote_as
    extra_config += "
      cisco_bgp_neighbor { '#{af[:asn]} #{af[:vrf]} #{af[:neighbor]}':
        ensure               => present,
        remote_as            => #{remote_as},
      }
    "
  end
  extra_config
end

tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  '2 default 1.1.1.1 ipv4 unicast',
  preclean:       'cisco_bgp',
  manifest_props: {
    allowas_in:                  'default',
    allowas_in_max:              'default',
    default_originate:           'default',
    default_originate_route_map: 'default',
    disable_peer_as_check:       'default',
    max_prefix_limit:            'default',
    max_prefix_threshold:        'default',
    max_prefix_interval:         'default',
    next_hop_self:               'default',
    next_hop_third_party:        'default',
    route_reflector_client:      'default',
    send_community:              'default',
    suppress_inactive:           'default',
    unsuppress_map:              'default',
    weight:                      'default',
  },
  resource:       {
    'additional_paths_receive' => 'inherit',
    'additional_paths_send'    => 'inherit',
    'allowas_in'               => 'false',
    'allowas_in_max'           => '3',
    'as_override'              => 'false',
    'default_originate'        => 'false',
    'disable_peer_as_check'    => 'false',
    'next_hop_self'            => 'false',
    'next_hop_third_party'     => 'true',
    'route_reflector_client'   => 'false',
    'send_community'           => 'none',
    'soft_reconfiguration_in'  => 'inherit',
    'suppress_inactive'        => 'false',
  },
}

tests[:non_def_A1] = {
  desc:           'Non Default: (A1) allowas-in',
  manifest_props: {
    allowas_in:     'true',
    allowas_in_max: '5',
  },
}

tests[:non_def_A2] = {
  desc:             'Non Default: (A2) additional-paths (disable)',
  operating_system: 'nexus',
  manifest_props:   {
    additional_paths_receive: 'disable',
    additional_paths_send:    'disable',
  },
}

tests[:non_def_A3] = {
  desc:             'Non Default: (A3) additional-paths (enable)',
  operating_system: 'nexus',
  manifest_props:   {
    additional_paths_receive: 'enable',
    additional_paths_send:    'enable',
  },
}

tests[:non_def_D1] = {
  desc:           'Non Default: (D1) default_originate',
  manifest_props: {
    default_originate:           'true',
    default_originate_route_map: 'my_def_map',
  },
}

tests[:non_def_D2] = {
  desc:             'Non Default: (D2) disable_peer_as_check',
  operating_system: 'nexus',
  manifest_props:   {
    disable_peer_as_check: 'true'
  },
}

tests[:non_def_M] = {
  desc:           'Non Default: (M) max-prefix',
  manifest_props: {
    max_prefix_limit:     '100',
    max_prefix_threshold: '50',
    max_prefix_interval:  '30',
  },
}

tests[:non_def_N] = {
  desc:           'Non Default (N) next-hop',
  title_pattern:  '2 blue 1.1.1.1 ipv4 unicast',
  manifest_props: {
    next_hop_self:        'true',
    next_hop_third_party: 'false',
  },
}

tests[:non_def_S1] = {
  desc:           'Non Default: (S1) send-community',
  manifest_props: {
    send_community: 'extended'
  },
}

tests[:non_def_S3] = {
  desc:           'Non Default: (S3) soft-reconfig enable',
  manifest_props: { soft_reconfiguration_in: 'enable' },
}

tests[:non_def_S4] = {
  desc:             'Non Default: (S4) suppress*',
  operating_system: 'nexus',
  manifest_props:   {
    suppress_inactive: 'true',
    unsuppress_map:    'unsup_map',
  },
}

tests[:non_def_W] = {
  desc:           'Non Default: (W) weight',
  manifest_props: { weight: '30' },
}

tests[:non_def_vrf_only] = {
  desc:             'Non Default: (vrf-only) soo',
  operating_system: 'nexus',
  manifest_props:   { soo: '3:3' },
}

tests[:non_def_misc_maps_1] = {
  desc:           'Non Default: (Misc Maps 1)',
  manifest_props: {
    filter_list_in:  'flin',
    filter_list_out: 'flout',
    prefix_list_in:  'pfx_in',
    prefix_list_out: 'pfx_out',
    route_map_in:    'rm_in',
    route_map_out:   'rm_out',
  },
}

ad_map_exist = %w(admap_e exist_map)
ad_map_non_exist = %w(admap_ne non_exist)
tests[:non_def_misc_maps_2] = {
  desc:             'Non Default: (Misc Maps 2) advertise-map exist',
  operating_system: 'nexus',
  manifest_props:   { advertise_map_exist: ad_map_exist },
  resource:         { advertise_map_exist: "#{ad_map_exist}" },
}

tests[:non_def_misc_maps_3] = {
  desc:             'Non Default: (Misc Maps 3) advertise-map non-exist',
  operating_system: 'nexus',
  manifest_props:   { advertise_map_non_exist: ad_map_non_exist },
  resource:         { advertise_map_non_exist: "#{ad_map_non_exist}" },
}

tests[:non_def_ebgp_only] = {
  desc:           'Non Default: (ebgp-only) as-override',
  preclean:       'cisco_bgp',
  title_pattern:  '2 yellow 3.3.3.3 ipv4 unicast',
  remote_as:      3,
  manifest_props: { as_override: 'true' },
}

tests[:non_def_ibgp_only] = {
  desc:           'Non Default: (ibgp-only) route-reflector-client',
  preclean:       'cisco_bgp',
  title_pattern:  '2 default 2.2.2.2 ipv4 unicast',
  remote_as:      2,
  manifest_props: { route_reflector_client: 'true' },
}

tests[:title_patterns_1] = {
  desc:           'T.1 Title Pattern',
  preclean:       'cisco_bgp',
  title_pattern:  'new_york',
  manifest_props: {},
  title_params:   { asn: '11.4', vrf: 'red', neighbor: '1.1.1.1',
                    afi: 'ipv4', safi: 'unicast' },
  resource:       { 'ensure' => 'present' },
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: '11.4',
  title_params:  { vrf: 'blue', neighbor: '1.1.1.1',
                   afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_3] = {
  desc:          'T.3 Title Pattern',
  title_pattern: '11.4 cyan 1.1.1.1',
  title_params:  { afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

tests[:title_patterns_4] = {
  desc:          'T.4 Title Pattern',
  title_pattern: '11.4 magenta 1.1.1.1 ipv4',
  title_params:  { safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  tests[:default][:ensure] = :absent
  tests[:default].delete(:preclean)
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  resource_absent_cleanup(agent, 'cisco_bgp', 'BGP CLEAN :: ')
  title = '2 blue 1.1.1.1 ipv4 unicast'
  [
    :non_def_A1,
    :non_def_A2,
    :non_def_A3,
    :non_def_D1,
    :non_def_D2,
    :non_def_M,
    :non_def_N,
    :non_def_S1,
    :non_def_S3,
    :non_def_S4,
    :non_def_W,
    :non_def_vrf_only,
    :non_def_misc_maps_1,
    :non_def_misc_maps_2,
    :non_def_misc_maps_3,
  ].each do |id|
    tests[id][:title_pattern] = title
    test_harness_run(tests, id)
  end

  test_harness_run(tests, :non_def_ebgp_only)
  test_harness_run(tests, :non_def_ibgp_only)

  # -------------------------------------------------------------------
  unless platform[/n3k/]
    logger.info("\n#{'-' * 60}\nSection 3. L2VPN Property Testing")
    resource_absent_cleanup(agent, 'cisco_bgp', 'BGP CLEAN :: ')
    title = '2 default 1.1.1.1 l2vpn evpn'
    array = [
      :non_def_A1,
      :non_def_D2,
      :non_def_M,
      :non_def_S1,
      :non_def_misc_maps_1,
    ]
    array << :non_def_S3 if operating_system == 'ios_xr'

    array.each do |id|
      tests[id][:title_pattern] = title
      test_harness_run(tests, id)
    end

    id = :non_def_ibgp_only
    tests[id][:title_pattern].gsub!(/ipv4 unicast/, 'l2vpn evpn')
    test_harness_run(tests, id)
  end
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  test_harness_run(tests, :title_patterns_3)
  test_harness_run(tests, :title_patterns_4)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_bgp')
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
