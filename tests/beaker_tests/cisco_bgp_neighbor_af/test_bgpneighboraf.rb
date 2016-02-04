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
# TestCase Name:
# -------------
# test-bgpneighboraf.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP Neighbor AF resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This BGP Neighbor AF resource test verifies default values for all properties.
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
# rubocop:disable Style/HashSyntax
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../../cisco_bgp/bgplib.rb', __FILE__)

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
  remove_property(test, :disable_peer_as_check)
  remove_property(test, :filter_list_in)
  remove_property(test, :filter_list_out)
  remove_property(test, :next_hop_third_party)
  remove_property(test, :prefix_list_in)
  remove_property(test, :prefix_list_out)
  remove_property(test, :suppress_inactive)
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
}

tests['title_patterns'] = {
  :manifest_props => '',
  :resource_props => { 'ensure' => 'present' },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource with neighbor AF
def puppet_resource_cmd(af)
  cmd = PUPPET_BINPATH + \
        "resource cisco_bgp_neighbor_af '#{af.values.join(' ')}'"
  get_namespace_cmd(agent, cmd, options)
end

def get_dependency_manifest(platform, af, remote)
  extra_config = ''
  if platform == 'ios_xr'
    # XR requires the following before a vrf AF can be configured:
    #   1. a global router_id
    #   2. a global address family
    #   3. route_distinguisher configured on the vrf
    #   4. remote-as is required for neightbor
    remote = 2 if remote.nil?
    if af[:vrf] == 'default'
      extra_config = "
      cisco_bgp { '#{af[:asn]} #{af[:vrf]}':
        ensure                                 => present,
      }

      cisco_bgp_af { '#{af[:asn]} #{af[:vrf]} #{af[:afi]} #{af[:safi]}':
        ensure                                 => present,
      }

      cisco_bgp_neighbor { '#{af[:asn]} #{af[:vrf]} #{af[:neighbor]}':
        ensure                                 => present,
        remote_as                              => #{remote},
      }"
    else
      extra_config = "
      cisco_bgp { '#{af[:asn]}':
        ensure                                 => present,
        router_id                              => '1.2.3.4',
      }
      cisco_bgp_af { '#{af[:asn]} #{af[:vrf]} #{af[:afi]} #{af[:safi]}':
        ensure                                 => present,
      }
      cisco_bgp { '#{af[:asn]} #{af[:vrf]}':
        ensure                                 => present,
        route_distinguisher                    => auto,
      }"
    end
    extra_config += "
      cisco_command_config { 'policy_config':
        command => '
          route-policy rm_in
            end-policy
          route-policy rm_out
            end-policy'
      }"
  else
    if remote
      extra_config = "
      cisco_bgp { '#{af[:asn]} #{af[:vrf]}':
        ensure                                 => present,
      }
      cisco_bgp_neighbor { '#{af[:asn]} #{af[:vrf]} #{af[:neighbor]}':
        ensure                                 => present,
        remote_as                              => #{remote},
      }"
    end
  end
  extra_config
end

# Create actual manifest for a given test scenario.
def build_manifest_bgp_nbr_af(tests, id, af, platform)
  remove_unsupported_properties(tests[id], platform)
  manifest_props = tests[id][:manifest_props]
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

    cisco_bgp_neighbor_af { '#{af[:asn]} #{af[:vrf]} #{af[:neighbor]} #{af[:afi]} #{af[:safi]}':
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

  if platform == 'ios_xr' && af[:vrf] != 'default'
    logger.info("\n--------\nSkip Case Address-Family ID: #{af} for ios_xr")
  else
    # Build the manifest for this test
    build_manifest_bgp_nbr_af(tests, id, af, platform)

    test_harness_common(tests, id)
    tests[id][:ensure] = nil
  end
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
  cleanup_bgp(master, agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  init_bgp(master, agent)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A1', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A2', platform)
  test_harness_bgp_nbr_af(tests, 'non_default_properties_A3', platform)
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
  cleanup_bgp(master, agent)

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
  cleanup_bgp(master, agent)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. L2VPN Default Property Testing")
  init_bgp(master, agent)

  # -----------------------------------
  id = 'default_properties_l2vpn'
  test_harness_bgp_nbr_af(tests, id, platform)

  tests[id][:ensure] = :absent
  test_harness_bgp_nbr_af(tests, id, platform)
  cleanup_bgp(master, agent)

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
  cleanup_bgp(master, agent)

  # -------------------------------------------------------------------
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
end

logger.info("TestCase :: #{testheader} :: End")
