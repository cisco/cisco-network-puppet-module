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

<<<<<<< HEAD
# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bgp_neighbor_af'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
#
tests = {
  :master => master,
  :agent  => agent,
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
# tests[id][:remote_as] - (Optional) allows explicit remote-as configuration
#   for some ebgp/ibgp-only testing
#
def remove_property(test, prop_symbol)
  test[:manifest_props].delete(prop_symbol)
  test[:resource_props].delete(prop_symbol.to_s)
end

def remove_unsupported_properties(test, platform)
  return if platform == 'nexus'
  remove_property(test, :additional_paths_receive)
  remove_property(test, :additional_paths_send)
  remove_property(test, :advertise_map_exist)
  remove_property(test, :advertise_map_non_exist)
  remove_property(test, :default_originate_route_map)
  remove_property(test, :disable_peer_as_check)
  remove_property(test, :filter_list_in)
  remove_property(test, :filter_list_out)
  remove_property(test, :next_hop_third_party)
  remove_property(test, :prefix_list_in)
  remove_property(test, :prefix_list_out)
  remove_property(test, :soo)
  remove_property(test, :suppress_inactive)
  remove_property(test, :unsuppress_map)
end

tests['default_properties'] = {
  :desc           => '1.1 Default Properties',
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :allowas_in                  => 'default',
    :allowas_in_max              => 'default',
    :default_originate           => 'default',
    :default_originate_route_map => 'default',
    :disable_peer_as_check       => 'default',
    :max_prefix_limit            => 'default',
    :max_prefix_threshold        => 'default',
    :max_prefix_interval         => 'default',
    :next_hop_self               => 'default',
    :next_hop_third_party        => 'default',
    :route_reflector_client      => 'default',
    :send_community              => 'default',
    :suppress_inactive           => 'default',
    :unsuppress_map              => 'default',
    :weight                      => 'default',
  },

  # default_properties
  :resource_props => {
=======
# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_bgp_neighbor_af',
}

# Test hash test cases
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
>>>>>>> develop
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

<<<<<<< HEAD
tests['default_properties_l2vpn'] = {
  :desc           => '4.1 Default Properties',
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :allowas_in             => 'default',
    :allowas_in_max         => 'default',
    :disable_peer_as_check  => 'default',
    :max_prefix_limit       => 'default',
    :max_prefix_threshold   => 'default',
    :max_prefix_interval    => 'default',
    :route_reflector_client => 'default',
    :send_community         => 'default',
  },

  # default_properties
  :resource_props => {
    'allowas_in'              => 'false',
    'allowas_in_max'          => '3',
    'disable_peer_as_check'   => 'false',
    'route_reflector_client'  => 'false',
    'send_community'          => 'none',
    'soft_reconfiguration_in' => 'inherit',
  },
}

tests['non_default_properties_A1'] = {
  :desc           => "2.1.1 Non Default Properties: 'A1' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :allowas_in     => true,
    :allowas_in_max => 5,
  },
  :resource_props => {
    'ensure'         => 'present',
    'allowas_in'     => 'true',
    'allowas_in_max' => '5',
  },
}

tests['non_default_properties_A1_l2vpn'] = {
  :desc           => "5.1.1 Non Default Properties: 'A1' commands",
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :allowas_in     => true,
    :allowas_in_max => 5,
  },
  :resource_props => {
    'ensure'         => 'present',
    'allowas_in'     => 'true',
    'allowas_in_max' => '5',
  },
}

tests['non_default_properties_A2'] = {
  :desc           => "2.1.2 Non Default Properties: 'A2' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :additional_paths_receive => 'disable',
    :additional_paths_send    => 'disable',
  },
  :resource_props => {
    'ensure'                   => 'present',
    'additional_paths_receive' => 'disable',
    'additional_paths_send'    => 'disable',
  },
}

tests['non_default_properties_A3'] = {
  :desc           => "2.1.3 Non Default Properties: 'A3' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :additional_paths_receive => 'enable',
    :additional_paths_send    => 'enable',
  },
  :resource_props => {
    'ensure'                   => 'present',
    'additional_paths_receive' => 'enable',
    'additional_paths_send'    => 'enable',
  },
}

tests['non_default_properties_D'] = {
  :desc           => "2.3 Non Default Properties: 'D' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :default_originate           => true,
    :default_originate_route_map => 'my_def_map',
    :disable_peer_as_check       => true,
  },
  :resource_props => {
    'ensure'                      => 'present',
    'default_originate'           => 'true',
    'default_originate_route_map' => 'my_def_map',
    'disable_peer_as_check'       => 'true',
  },
}

tests['non_default_properties_M'] = {
  :desc           => "2.4 Non Default Properties: 'M' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :max_prefix_limit     => 100,
    :max_prefix_threshold => 50,
    :max_prefix_interval  => 30,
  },
  :resource_props => {
    'ensure'               => 'present',
    'max_prefix_interval'  => '30',
    'max_prefix_limit'     => '100',
    'max_prefix_threshold' => '50',
  },
}

tests['non_default_properties_M_l2vpn'] = {
  :desc           => "5.4 Non Default Properties: 'M' commands",
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :max_prefix_limit     => 100,
    :max_prefix_threshold => 50,
    :max_prefix_interval  => 30,
  },
  :resource_props => {
    'ensure'               => 'present',
    'max_prefix_interval'  => '30',
    'max_prefix_limit'     => '100',
    'max_prefix_threshold' => '50',
  },
}

tests['non_default_properties_N'] = {
  :desc           => "2.5 Non Default Properties: 'N' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :next_hop_self        => true,
    :next_hop_third_party => false,
  },
  :resource_props => {
    'ensure'               => 'present',
    'next_hop_self'        => 'true',
    'next_hop_third_party' => 'false',
  },
}

tests['non_default_properties_S1'] = {
  :desc           => "2.6.1 Non Default Properties: 'S1' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :send_community    => 'extended',
    :suppress_inactive => true,
    :unsuppress_map    => 'unsup_map',
  },
  :resource_props => {
    'ensure'            => 'present',
    'send_community'    => 'extended',
    'suppress_inactive' => 'true',
    'unsuppress_map'    => 'unsup_map',
  },
}

tests['non_default_properties_S1_l2vpn'] = {
  :desc           => "5.6.1 Non Default Properties: 'S1' commands",
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :send_community => 'extended'
  },
  :resource_props => {
    'ensure'         => 'present',
    'send_community' => 'extended',
  },
}

tests['non_default_properties_S2'] = {
  :desc           => "2.6.2 Non Default Properties: 'S2' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :soft_reconfiguration_in => 'always'
  },
  :resource_props => {
    'ensure'                  => 'present',
    'soft_reconfiguration_in' => 'always',
  },
}

tests['non_default_properties_S2_l2vpn'] = {
  :desc           => "5.6.2 Non Default Properties: 'S2' commands",
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :soft_reconfiguration_in => 'always'
  },
  :resource_props => {
    'ensure'                  => 'present',
    'soft_reconfiguration_in' => 'always',
  },
}

tests['non_default_properties_S3'] = {
  :desc           => "2.6.3 Non Default Properties: 'S3' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :soft_reconfiguration_in => 'enable'
  },
  :resource_props => {
    'ensure'                  => 'present',
    'soft_reconfiguration_in' => 'enable',
  },
}

tests['non_default_properties_S3_l2vpn'] = {
  :desc           => "5.6.3 Non Default Properties: 'S3' commands",
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :soft_reconfiguration_in => 'enable'
  },
  :resource_props => {
    'ensure'                  => 'present',
    'soft_reconfiguration_in' => 'enable',
  },
}

tests['non_default_properties_W'] = {
  :desc           => "2.7 Non Default Properties: 'W' commands",
  :title_pattern  => "#{BgpLib::ASN} blue 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :weight => 30
  },
  :resource_props => {
    'ensure' => 'present',
    'weight' => '30',
  },
}

tests['non_default_properties_ebgp_only'] = {
  :desc           => "2.9 Non Default Properties: 'ebgp' commands",
  :title_pattern  => "#{BgpLib::ASN} yellow 3.3.3.3 ipv4 unicast",
  :remote_as      => 3,
  :manifest_props => {
    :as_override => true
  },
  :resource_props => {
    'as_override' => 'true'
  },
}

tests['non_default_properties_ibgp_only'] = {
  :desc           => "2.10 Non Default Properties: 'ibgp' commands",
  :title_pattern  => "#{BgpLib::ASN} green 2.2.2.2 ipv4 unicast",
  :remote_as      => "#{BgpLib::ASN}",
  :manifest_props => {
    :route_reflector_client => true
  },
  :resource_props => {
    'route_reflector_client' => 'true'
  },
}

tests['non_default_properties_ibgp_only_l2vpn'] = {
  :desc           => "5.10 Non Default Properties: 'ibgp' commands",
  :title_pattern  => "#{BgpLib::ASN} default 2.2.2.2 l2vpn evpn",
  :remote_as      => "#{BgpLib::ASN}",
  :manifest_props => {
    :route_reflector_client => true
  },
  :resource_props => {
    'route_reflector_client' => 'true'
  },
}

tests['non_default_properties_vrf_only'] = {
  :desc           => "2.11 Non Default Properties: 'vrf only' commands",
  :title_pattern  => "#{BgpLib::ASN} purple 4.4.4.4 ipv4 unicast",
  :manifest_props => {
    :soo => '3:3'
  },
  :resource_props => {
    'soo' => '3:3'
  },
}

tests['non_default_misc_maps_part_1'] = {
  :desc           => '2.12.1 Non Default Misc Map commands Part 1',
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 ipv4 unicast",
  :manifest_props => {
    :advertise_map_exist => %w(admap exist_map),
    :filter_list_in      => 'flin',
    :filter_list_out     => 'flout',
    :prefix_list_in      => 'pfx_in',
    :prefix_list_out     => 'pfx_out',
    :route_map_in        => 'rm_in',
    :route_map_out       => 'rm_out',
  },
  :resource_props => {
    'advertise_map_exist' => '..admap., .exist_map..',
    'filter_list_in'      => 'flin',
    'filter_list_out'     => 'flout',
    'prefix_list_in'      => 'pfx_in',
    'prefix_list_out'     => 'pfx_out',
    'route_map_in'        => 'rm_in',
    'route_map_out'       => 'rm_out',
  },
}

tests['non_default_misc_maps_part_1_l2vpn'] = {
  :desc           => '5.12.1 Non Default Misc Map commands Part 1',
  :title_pattern  => "#{BgpLib::ASN} default 1.1.1.1 l2vpn evpn",
  :manifest_props => {
    :filter_list_in  => 'flin',
    :filter_list_out => 'flout',
    :prefix_list_in  => 'pfx_in',
    :prefix_list_out => 'pfx_out',
    :route_map_in    => 'rm_in',
    :route_map_out   => 'rm_out',
  },
  :resource_props => {
    'filter_list_in'  => 'flin',
    'filter_list_out' => 'flout',
    'prefix_list_in'  => 'pfx_in',
    'prefix_list_out' => 'pfx_out',
    'route_map_in'    => 'rm_in',
    'route_map_out'   => 'rm_out',
  },
}

tests['non_default_misc_maps_part_2'] = {
  :desc           => '2.12.2 Non Default Misc Map commands Part 2',
  :title_pattern  => "#{BgpLib::ASN} default 2.2.2.2 ipv4 unicast",
  :manifest_props => {
    :advertise_map_non_exist => %w(admap non_exist_map)
  },
  :resource_props => {
    'advertise_map_non_exist' => '..admap., .non_exist_map..'
  },
=======
tests[:non_def_A1] = {
  desc:           'Non Default: (A1) allowas-in',
  manifest_props: {
    allowas_in:     'true',
    allowas_in_max: '5',
  },
}

tests[:non_def_A2] = {
  desc:           'Non Default: (A2) additional-paths (disable)',
  manifest_props: {
    additional_paths_receive: 'disable',
    additional_paths_send:    'disable',
  },
}

tests[:non_def_A3] = {
  desc:           'Non Default: (A3) additional-paths (enable)',
  manifest_props: {
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
  desc:           'Non Default: (D2) disable_peer_as_check',
  manifest_props: {
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

tests[:non_def_S2] = {
  desc:           'Non Default: (S2) soft-reconfig always',
  platform:       'n(3|9)k',
  manifest_props: { soft_reconfiguration_in: 'always' },
}

tests[:non_def_S3] = {
  desc:           'Non Default: (S3) soft-reconfig enable',
  platform:       'n(3|9)k',
  manifest_props: { soft_reconfiguration_in: 'enable' },
}

tests[:non_def_S4] = {
  desc:           'Non Default: (S4) suppress*',
  manifest_props: {
    suppress_inactive: 'true',
    unsuppress_map:    'unsup_map',
  },
}

tests[:non_def_W] = {
  desc:           'Non Default: (W) weight',
  manifest_props: { weight: '30' },
}

tests[:non_def_vrf_only] = {
  desc:           'Non Default: (vrf-only) soo',
  manifest_props: { soo: '3:3' },
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
  desc:           'Non Default: (Misc Maps 2) advertise-map exist',
  manifest_props: { advertise_map_exist: ad_map_exist },
  resource:       { advertise_map_exist: "#{ad_map_exist}" },
}

tests[:non_def_misc_maps_3] = {
  desc:           'Non Default: (Misc Maps 3) advertise-map non-exist',
  manifest_props: { advertise_map_non_exist: ad_map_non_exist },
  resource:       { advertise_map_non_exist: "#{ad_map_non_exist}" },
}

tests[:non_def_ebgp_only] = {
  desc:           'Non Default: (ebgp-only) as-override',
  preclean:       'cisco_bgp',
  title_pattern:  '2 yellow 3.3.3.3 ipv4 unicast',
  remote_as:      '2 yellow  3.3.3.3 3',
  manifest_props: { as_override: 'true' },
}

tests[:non_def_ibgp_only] = {
  desc:           'Non Default: (ibgp-only) route-reflector-client',
  preclean:       'cisco_bgp',
  title_pattern:  '2 default 2.2.2.2 ipv4 unicast',
  remote_as:      '2 default 2.2.2.2 2',
  manifest_props: { route_reflector_client: 'true' },
}

tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  preclean:      'cisco_bgp',
  title_pattern: 'new_york',
  title_params:  { asn: '11.4', vrf: 'red', neighbor: '1.1.1.1',
                   afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
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
>>>>>>> develop
}

tests[:title_patterns_4] = {
  desc:          'T.4 Title Pattern',
  title_pattern: '11.4 magenta 1.1.1.1 ipv4',
  title_params:  { safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
}

#################################################################
<<<<<<< HEAD
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource with neighbor AF
def puppet_resource_cmd(af)
  cmd = PUPPET_BINPATH + \
        "resource cisco_bgp_neighbor_af '#{af.values.join(' ')}'"
  get_namespace_cmd(agent, cmd, options)
end

def get_dependency_manifest(platform, af, remote_as)
  extra_config = ''
  # XR requires the following before a vrf AF can be configured:
  #   1. a global router_id
  #   2. a global address family
  #   3. route_distinguisher configured on the vrf
  #   4. remote-as is required for neightbor
  remote_as = 2 if remote_as.nil? && platform == 'ios_xr'
  if af[:vrf] != 'default'
    if af[:afi] == 'ipv6'
      global_afi = 'vpnv6'
    else
      global_afi = 'vpnv4'
    end
    extra_config = "
    cisco_bgp { '#{af[:asn]}':
      ensure                                 => present,
      router_id                              => '1.2.3.4',
    }
    cisco_bgp_af { '#{af[:asn]} default #{global_afi} #{af[:safi]}':
      ensure                                 => present,
    }
    cisco_bgp { '#{af[:asn]} #{af[:vrf]}':
      ensure                                 => present,
      route_distinguisher                    => auto,
    }"
  end
  extra_config += "
    cisco_bgp_af { '#{af[:asn]} #{af[:vrf]} #{af[:afi]} #{af[:safi]}':
        ensure                                 => present,
    }"
  if remote_as
    extra_config += "
    cisco_bgp_neighbor { '#{af[:asn]} #{af[:vrf]} #{af[:neighbor]}':
      ensure                                 => present,
      remote_as                              => #{remote_as},
    }"
  end
  if platform == 'ios_xr'
    extra_config += "
    cisco_command_config { 'policy_config':
      command => '
        route-policy rm_in
          end-policy
        route-policy rm_out
          end-policy'
    }"
  end
  extra_config
end

# Create actual manifest for a given test scenario.
def build_manifest_bgp_nbr_af(tests, id, af, platform)
  remove_unsupported_properties(tests[id], platform)
  manifest_props = tests[id][:manifest_props]

  # optionally merge properties from :af
  manifest_props.merge!(tests[id][:af]) unless tests[id][:af].nil?

  manifest = prop_hash_to_manifest(manifest_props)

  extra_config = ''
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
    tests[id][:resource] = tests[id][:resource_props]
    extra_config = get_dependency_manifest(platform, af, tests[id][:remote_as])
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_bgp_nbr_af :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    #{extra_config}

    cisco_bgp_neighbor_af { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

# Wrapper for bgp_nbr_af specific settings prior to calling the
# common test_harness.
def test_harness_bgp_nbr_af(tests, id, platform)
  af = af_title_pattern_munge(tests, id, 'bgp_neighbor_af')
  logger.info("\n--------\nTest Case Address-Family ID: #{af}")

  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd(af)

  # Build the manifest for this test
  build_manifest_bgp_nbr_af(tests, id, af, platform)

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  platform = fact_on(agent, 'os.name')
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  init_bgp(master, agent)

  # -----------------------------------
  id = 'default_properties'
  test_harness_bgp_nbr_af(tests, id, platform)

  tests[id][:ensure] = :absent
  test_harness_bgp_nbr_af(tests, id, platform)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  init_bgp(master, agent)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A1', platform)
  cleanup_bgp(master, agent)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A2', platform)
  cleanup_bgp(master, agent)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A3', platform)
  cleanup_bgp(master, agent)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_D', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_M', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_N', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S1', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S2', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S3', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_W', platform)

  # Special Cases
  test_harness_bgp_nbr_af(tests, 'non_default_properties_ebgp_only', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_ibgp_only', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_vrf_only', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_misc_maps_part_1', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_misc_maps_part_2', platform)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  init_bgp(master, agent)

  id = 'title_patterns'
  tests[id][:desc] = '3.1 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN}"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :neighbor => '1.1.1.1',
                     :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '3.2 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} blue"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :neighbor => '2.2.2.2', :afi => 'ipv4',
                     :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '3.3 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} green 3.3.3.3"
  tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  tests[id][:manifest_props] = {}
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '3.4 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} red 4.4.4.4 ipv4"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '3.5 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} yellow 5.5.5.5 ipv4 unicast"
  tests[id][:manifest_props] = {}
  tests[id].delete(:af)
  test_harness_bgp_nbr_af(tests, id, platform)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. L2VPN Default Property Testing")
  init_bgp(master, agent)

  # -----------------------------------
  id = 'default_properties_l2vpn'
  test_harness_bgp_nbr_af(tests, id, platform)

  tests[id][:ensure] = :absent
  test_harness_bgp_nbr_af(tests, id, platform)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 5. L2VPN  Non Default Property Testing")
  init_bgp(master, agent)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A1_l2vpn', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_M_l2vpn', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S1_l2vpn', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S2_l2vpn', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S3_l2vpn', platform)

  # Special Cases
  test_harness_bgp_nbr_af(tests, 'non_default_properties_ibgp_only_l2vpn', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_misc_maps_part_1_l2vpn', platform)
=======
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
    :non_def_S2,
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
  if platform[/n(5|6|7|9)k/]
    logger.info("\n#{'-' * 60}\nSection 3. L2VPN Property Testing")
    resource_absent_cleanup(agent, 'cisco_bgp', 'BGP CLEAN :: ')
    title = '2 default 1.1.1.1 l2vpn evpn'
    [
      :non_def_A1,
      :non_def_D2,
      :non_def_M,
      :non_def_S1,
      :non_def_S2,
      :non_def_S3,
      :non_def_misc_maps_1,
    ].each do |id|
      tests[id][:title_pattern] = title
      test_harness_run(tests, id)
    end
>>>>>>> develop

    id = :non_def_ibgp_only
    tests[id][:title_pattern].gsub!(/ipv4 unicast/, 'l2vpn evpn')
    test_harness_run(tests, id)
  end
  # -------------------------------------------------------------------
<<<<<<< HEAD
  logger.info("\n#{'-' * 60}\nSection 6. L2VPN Title Pattern Testing")
  init_bgp(master, agent)

  id = 'title_patterns'
  tests[id][:desc] = '6.1 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN}"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :neighbor => '1.1.1.1',
                     :afi => 'l2vpn', :safi => 'evpn' }
  test_harness_bgp_nbr_af(tests, id, platform)
  # -----------------------------------
  tests[id][:desc] = '6.2 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} default"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :neighbor => '2.2.2.2', :afi => 'l2vpn',
                     :safi => 'evpn' }
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '6.3 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} default 6.3.3.3"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :afi => 'l2vpn', :safi => 'evpn' }
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '6.4 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} default 4.4.4.4 l2vpn"
  tests[id][:manifest_props] = {}
  tests[id][:af] = { :safi => 'evpn' }
  test_harness_bgp_nbr_af(tests, id, platform)

  # -----------------------------------
  tests[id][:desc] = '6.5 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} default 5.5.5.5 l2vpn evpn"
  tests[id][:manifest_props] = {}
  tests[id].delete(:af)
  test_harness_bgp_nbr_af(tests, id, platform)
  cleanup_bgp(master, agent)
=======
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  test_harness_run(tests, :title_patterns_3)
  test_harness_run(tests, :title_patterns_4)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_bgp')
  skipped_tests_summary(tests)
>>>>>>> develop
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
