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
# test_bgpaf.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP AF resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This BGP AF resource test verifies default values for all properties.
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
require File.expand_path('../bgpaflib.rb', __FILE__)
# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bgp_af :: All default property values'

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
  :master   => master,
  :agent    => agent,
  :show_cmd => 'show run bgp all',
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
# tests[id][:remote_as] - (Optional) allows explicit remote-as configuration
#   for some ebgp/ibgp-only testing

# default_properties
#
tests['default_properties'] = {
  :desc           => '1.1 Default Properties',
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    additional_paths_install      => 'default',
    additional_paths_receive      => 'default',
    additional_paths_selection    => 'default',
    additional_paths_send         => 'default',
    advertise_l2vpn_evpn          => 'default',
    client_to_client              => 'default',
    dampen_igp_metric             => 'default',
    dampening_state               => 'default',
    dampening_half_time           => 'default',
    dampening_max_suppress_time   => 'default',
    dampening_reuse_time          => 'default',
    dampening_suppress_time       => 'default',
    default_information_originate => 'default',
    default_metric                => 'default',
    distance_ebgp                 => 'default',
    distance_ibgp                 => 'default',
    distance_local                => 'default',
    inject_map                    => 'default',
    maximum_paths                 => 'default',
    maximum_paths_ibgp            => 'default',
    next_hop_route_map            => 'default',
    networks                      => 'default',
    redistribute                  => 'default',
    suppress_inactive             => 'default',
    table_map                     => 'default',
    table_map_filter              => 'default',
    ",

  :resource_props => {
    'additional_paths_install'      => 'false',
    'additional_paths_receive'      => 'false',
    'additional_paths_send'         => 'false',
    'advertise_l2vpn_evpn'          => 'false',
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
tests['default_dampening_routemap'] = {
  :desc           => '1.2 Default dampening_routemap',
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    dampening_routemap            => 'default',
    ",

  :resource_props => {
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
tests['non_default_properties_A'] = {
  :desc           => "2.1 Non Default Properties: 'A' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    additional_paths_install        => true,
    additional_paths_receive        => true,
    additional_paths_selection      => 'RouteMap',
    additional_paths_send           => true,
    advertise_l2vpn_evpn            => true,
  ",

  :resource_props => {
    'additional_paths_install'   => 'true',
    'additional_paths_receive'   => 'true',
    'additional_paths_selection' => 'RouteMap',
    'additional_paths_send'      => 'true',
    'advertise_l2vpn_evpn'       => 'true',
  },
}

tests['non_default_properties_C'] = {
  :desc           => "2.2 Non Default Properties: 'C' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    client_to_client => false,
  ",

  :resource_props => {
    'client_to_client' => 'false'
  },
}

tests['non_default_properties_D'] = {
  :desc           => "2.3 Non Default Properties: 'D' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    dampen_igp_metric               => 200,
    dampening_half_time             => 1,
    dampening_max_suppress_time     => 4,
    dampening_reuse_time            => 2,
    dampening_suppress_time         => 3,
    default_information_originate   => true,
    default_metric                  => 50,
    distance_ebgp                   => 30,
    distance_ibgp                   => 60,
    distance_local                  => 90,
  ",

  :resource_props => {
    'dampen_igp_metric'             => '200',
    'dampening_half_time'           => '1',
    'dampening_max_suppress_time'   => '4',
    'dampening_reuse_time'          => '2',
    'dampening_suppress_time'       => '3',
    'default_information_originate' => 'true',
    'default_metric'                => '50',
    'distance_ebgp'                 => '30',
    'distance_ibgp'                 => '60',
    'distance_local'                => '90',
  },
}

# Special case: Just dampening_state, no properties.
tests['non_default_properties_Dampening_true'] = {
  :desc           => '2.3.1 Non-Default dampening true',
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    dampening_state               => 'true',
    ",

  :resource_props => {
    'dampening_state'             => 'true',
    'dampening_half_time'         => '15',
    'dampening_max_suppress_time' => '45',
    'dampening_reuse_time'        => '750',
    'dampening_suppress_time'     => '2000',
  },
}

tests['non_default_properties_Dampening_false'] = {
  :desc           => '2.3.2 Non-Default dampening false',
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    dampening_state               => 'false',
    ",

  :resource_props => {
    'dampening_state' => 'false'
  },
}

# Special case: When dampening_routemap is mutually exclusive
# with other dampening properties.
tests['non_default_properties_Dampening_routemap'] = {
  :desc           => '2.3.3 Non-Default dampening_routemap',
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    dampening_routemap => 'RouteMap',
    ",

  :resource_props => {
    'dampening_routemap' => 'RouteMap'
  },
}

injectmap = [['nyc', 'sfo'], ['sjc', 'sfo', 'copy-attributes']] # rubocop:disable Style/WordArray
tests['non_default_properties_I'] = {
  :desc           => "2.4 Non Default Properties: 'I' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    inject_map => #{injectmap},
  ",

  :resource_props => {
    'inject_map' => "#{injectmap}"
  },
}

tests['non_default_properties_M'] = {
  :desc           => "2.5 Non Default Properties: 'M' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    maximum_paths                   => 9,
    maximum_paths_ibgp              => 9,
  ",

  :resource_props => {
    'ensure'             => 'present',
    'maximum_paths'      => '9',
    'maximum_paths_ibgp' => '9',
  },
}

networks = [['192.168.5.0/24', 'nrtemap1'], ['192.168.6.0/32']]
tests['non_default_properties_N'] = {
  :desc           => "2.6 Non Default Properties: 'N' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    networks                        => #{networks},
    next_hop_route_map              => 'RouteMap',
  ",

  :resource_props => {
    'networks'           => "#{networks}",
    'next_hop_route_map' => 'RouteMap',
  },
}

redistribute = [['static', 's_rmap'], ['eigrp 1', 'e_rmap']] # rubocop:disable Style/WordArray
tests['non_default_properties_R'] = {
  :desc           => "2.7 Non Default Properties: 'R' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    redistribute                => #{redistribute},
  ",

  :resource_props => {
    'redistribute' => "#{redistribute}"
  },
}

tests['non_default_properties_S'] = {
  :desc           => "2.8 Non Default Properties: 'S' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    suppress_inactive    => true,
  ",

  :resource_props => {
    'suppress_inactive' => 'true'
  },
}

tests['non_default_properties_T'] = {
  :desc           => "2.9 Non Default Properties: 'T' commands",
  :title_pattern  => '2 blue ipv4 unicast',
  :manifest_props => "
    table_map        => 'sjc',
    table_map_filter => 'true',
  ",

  :resource_props => {
    'table_map'        => 'sjc',
    'table_map_filter' => 'true',
  },
}

tests['title_patterns'] = {
  :manifest_props => '',
  :resource_props => { 'ensure' => 'present' },
}

# Search pattern for show run config testing
def af_pattern(tests, id, af)
  asn, vrf, afi, safi = af.values
  if tests[id][:ensure] == :present
    if vrf[/default/]
      [/router bgp #{asn}/, /address-family #{afi} #{safi}/]
    else
      [/router bgp #{asn}/, /vrf #{vrf}/, /address-family #{afi} #{safi}/]
    end
  else
    if vrf[/default/]
      [/router bgp #{asn}/]
    else
      [/router bgp #{asn}/, /vrf #{vrf}/]
    end
  end
end

# Create actual manifest for a given test scenario.
def build_manifest_bgp_af(tests, id)
  manifest = prop_hash_to_manifest(tests[id][:af])
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
    manifest += tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_bgp_af :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_bgp_af { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

# Wrapper for bgp_af specific settings prior to calling the
# common test_harness.
def test_harness_bgp_af(tests, id)
  af = af_title_pattern_munge(tests, id, 'bgp_af')
  logger.info("\n--------\nTest Case Address-Family ID: #{af}")

  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:show_pattern] = af_pattern(tests, id, af)
  tests[id][:resource_cmd] = puppet_resource_cmd(af)

  # Build the manifest for this test
  build_manifest_bgp_af(tests, id)

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  node_feature_cleanup(agent, 'bgp')

  # -----------------------------------
  id = 'default_properties'
  test_harness_bgp_af(tests, id)

  tests[id][:desc] = '1.1 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_bgp_af(tests, id)

  test_harness_bgp_af(tests, 'default_dampening_routemap')
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  node_feature_cleanup(agent, 'bgp')

  test_harness_bgp_af(tests, 'non_default_properties_A')
  test_harness_bgp_af(tests, 'non_default_properties_C')
  test_harness_bgp_af(tests, 'non_default_properties_D')
  test_harness_bgp_af(tests, 'non_default_properties_Dampening_routemap')
  node_feature_cleanup(agent, 'bgp')
  test_harness_bgp_af(tests, 'non_default_properties_Dampening_true')
  test_harness_bgp_af(tests, 'non_default_properties_Dampening_false')
  test_harness_bgp_af(tests, 'non_default_properties_I')
  test_harness_bgp_af(tests, 'non_default_properties_M')
  test_harness_bgp_af(tests, 'non_default_properties_N')
  test_harness_bgp_af(tests, 'non_default_properties_R')
  test_harness_bgp_af(tests, 'non_default_properties_S')
  test_harness_bgp_af(tests, 'non_default_properties_T')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  node_feature_cleanup(agent, 'bgp')

  id = 'title_patterns'
  tests[id][:desc] = '3.1 Title Patterns'
  tests[id][:title_pattern] = '2'
  tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.2 Title Patterns'
  tests[id][:title_pattern] = '2 blue'
  tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.3 Title Patterns'
  tests[id][:title_pattern] = '2 red ipv4'
  tests[id][:af] = { :safi => 'unicast' }
  test_harness_bgp_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.4 Title Patterns'
  tests[id][:title_pattern] = '2 yellow ipv4 unicast'
  tests[id].delete(:af)
  test_harness_bgp_af(tests, id)
end

logger.info("TestCase :: #{testheader} :: End")
