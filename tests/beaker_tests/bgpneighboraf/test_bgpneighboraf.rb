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

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bgp_neighbor_af'

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
  :master => master,
  :agent => agent,
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
#
tests['default_properties'] = {
  :desc => '1.1 Default Properties',
  :title_pattern => '2 default 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    allowas_in                     => 'default',
    allowas_in_max                 => 'default',
    cap_add_paths_receive          => 'default',
    cap_add_paths_receive_disable  => 'default',
    cap_add_paths_send             => 'default',
    cap_add_paths_send_disable     => 'default',
    default_originate              => 'default',
    default_originate_route_map    => 'default',
    disable_peer_as_check          => 'default',
    max_prefix_limit               => 'default',
    max_prefix_threshold           => 'default',
    max_prefix_interval            => 'default',
    next_hop_self                  => 'default',
    next_hop_third_party           => 'default',
    route_reflector_client         => 'default',
    send_community                 => 'default',
    soft_reconfiguration_in        => 'default',
    soft_reconfiguration_in_always => 'default',
    suppress_inactive              => 'default',
    unsuppress_map                 => 'default',
    weight                         => 'default',
    ",

  # default_properties
  :resource_props => {
    'ensure'                         => 'present',
    'allowas_in'                     => 'false',
    'allowas_in_max'                 => '3',
    'as_override'                    => 'false',
    'cap_add_paths_receive'          => 'false',
    'cap_add_paths_receive_disable'  => 'false',
    'cap_add_paths_send'             => 'false',
    'cap_add_paths_send_disable'     => 'false',
    'default_originate'              => 'false',
    'disable_peer_as_check'          => 'false',
    'next_hop_self'                  => 'false',
    'next_hop_third_party'           => 'true',
    'route_reflector_client'         => 'false',
    'send_community'                 => 'none',
    'soft_reconfiguration_in'        => 'false',
    'soft_reconfiguration_in_always' => 'false',
    'suppress_inactive'              => 'false',
  },
}

tests['non_default_properties_A'] = {
  :desc => "2.1 Non Default Properties: 'A' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    allowas_in                       => true,
    allowas_in_max                   => 5,
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'allowas_in'                     => 'true',
    'allowas_in_max'                 => '5',
  }
}

tests['non_default_properties_C'] = {
  :desc => "2.2 Non Default Properties: 'C' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    cap_add_paths_receive            => true,
    cap_add_paths_receive_disable    => false,
    cap_add_paths_send               => true,
    cap_add_paths_send_disable       => true,
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'cap_add_paths_receive'          => 'true',
    'cap_add_paths_receive_disable'  => 'false',
    'cap_add_paths_send'             => 'true',
    'cap_add_paths_send_disable'     => 'true',
  }
}

tests['non_default_properties_D'] = {
  :desc => "2.3 Non Default Properties: 'D' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    default_originate                => true,
    default_originate_route_map      => 'my_def_map',
    disable_peer_as_check            => true,
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'default_originate'              => 'true',
    'default_originate_route_map'    => 'my_def_map',
    'disable_peer_as_check'          => 'true',
  }
}

tests['non_default_properties_M'] = {
  :desc => "2.4 Non Default Properties: 'M' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    max_prefix_limit                 => 100,
    max_prefix_threshold             => 50,
    max_prefix_interval              => 30,
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'max_prefix_interval'            => '30',
    'max_prefix_limit'               => '100',
    'max_prefix_threshold'           => '50',
  }
}

tests['non_default_properties_N'] = {
  :desc => "2.5 Non Default Properties: 'N' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    next_hop_self                    => true,
    next_hop_third_party             => false,
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'next_hop_self'                  => 'true',
    'next_hop_third_party'           => 'false',
  }
}

tests['non_default_properties_S'] = {
  :desc => "2.6 Non Default Properties: 'S' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    send_community                   => 'extended',
    soft_reconfiguration_in          => true,
    soft_reconfiguration_in_always   => true,
    suppress_inactive                => true,
    unsuppress_map                   => 'unsup_map',
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'send_community'                 => 'extended',
    'soft_reconfiguration_in'        => 'true',
    'soft_reconfiguration_in_always' => 'true',
    'suppress_inactive'              => 'true',
    'unsuppress_map'                 => 'unsup_map',
  }
}

tests['non_default_properties_W'] = {
  :desc => "2.7 Non Default Properties: 'W' commands",
  :title_pattern => '2 blue 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    weight                           => 30,
  ",
  :resource_props => {
    'ensure'                         => 'present',
    'weight'                         => '30',
  }
}

tests['non_default_properties_ebgp_only'] = {
  :desc => "2.9 Non Default Properties: 'ebgp' commands",
  :title_pattern => '2 yellow 3.3.3.3 ipv4 unicast',
  :remote_as => '2 yellow  3.3.3.3 3',
  :manifest_props => "
    as_override                      => true,
  ",
  :resource_props => {
    'as_override'                    => 'true',
  }
}

tests['non_default_properties_ibgp_only'] = {
  :desc => "2.10 Non Default Properties: 'ibgp' commands",
  :title_pattern => '2 green 2.2.2.2 ipv4 unicast',
  :remote_as => '2 green  2.2.2.2 2',
  :manifest_props => "
    route_reflector_client           => true,
  ",
  :resource_props => {
    'route_reflector_client'         => 'true',
  }
}

tests['non_default_properties_vrf_only'] = {
  :desc => "2.11 Non Default Properties: 'vrf only' commands",
  :title_pattern => '2 purple 4.4.4.4 ipv4 unicast',
  :manifest_props => "
    soo                              => '3:3',
  ",
  :resource_props => {
    'soo'                            => '3:3',
  }
}

tests['non_default_misc_maps_part_1'] = {
  :desc => '2.12.1 Non Default Misc Map commands Part 1',
  :title_pattern => '2 default 1.1.1.1 ipv4 unicast',
  :manifest_props => "
    advertise_map_exist              => ['admap', 'exist_map'],
    filter_list_in                   => 'flin',
    filter_list_out                  => 'flout',
  ",
  :resource_props => {
    'advertise_map_exist'            => '..admap., .exist_map..',
    'filter_list_in'                 => 'flin',
    'filter_list_out'                => 'flout',
  }
}

tests['non_default_misc_maps_part_2'] = {
  :desc => '2.12.2 Non Default Misc Map commands Part 2',
  :title_pattern => '2 default 2.2.2.2 ipv4 unicast',
  :manifest_props => "
    advertise_map_non_exist          => ['admap', 'non_exist_map'],
  ",
  :resource_props => {
    'advertise_map_non_exist'        => '..admap., .non_exist_map..',
  }
}

tests['title_patterns'] = {
  :manifest_props => '',
  :resource_props => { 'ensure' => 'present', }
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource with neighbor AF
def puppet_resource_cmd(af)
  cmd = UtilityLib::PUPPET_BINPATH + \
        "resource cisco_bgp_neighbor_af '#{af.values.join(' ')}'"
  UtilityLib.get_namespace_cmd(agent, cmd, options)
end

# Search pattern for show run config testing
def af_pattern(tests, id, af)
  asn, vrf, nbr, afi, safi = af.values
  if tests[id][:ensure] == :present
    if vrf[/default/]
      [/router bgp #{asn}/, /neighbor #{nbr}/,
       /address-family #{afi} #{safi}/]
    else
      [/router bgp #{asn}/, /vrf #{vrf}/, /neighbor #{nbr}/,
       /address-family #{afi} #{safi}/]
    end
  else
    if vrf[/default/]
      [/router bgp #{asn}/, /neighbor #{nbr}/]
    else
      [/router bgp #{asn}/, /vrf #{vrf}/, /neighbor #{nbr}/]
    end
  end
end

# Create actual manifest for a given test scenario.
def build_manifest_bgp_nbr_af(tests, id)
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
  logger.debug("build_manifest_bgp_nbr_af :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_bgp_neighbor_af { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

# Wrapper for bgp_nbr_af specific settings prior to calling the
# common test_harness.
def test_harness_bgp_nbr_af(tests, id)
  af = bgp_title_pattern_munge(tests, id, 'bgp_neighbor_af')
  logger.info("\n--------\nTest Case Address-Family ID: #{af}")

  # Set up remote-as if necessary
  bgp_nbr_remote_as(agent, tests[id][:remote_as]) if tests[id][:remote_as]

  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:show_pattern] = af_pattern(tests, id, af)
  tests[id][:resource_cmd] = puppet_resource_cmd(af)

  # Build the manifest for this test
  build_manifest_bgp_nbr_af(tests, id)

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  node_feature_cleanup(agent, 'bgp')

  # -----------------------------------
  id = 'default_properties'
  test_harness_bgp_nbr_af(tests, id)

  tests[id][:ensure] = :absent
  test_harness_bgp_nbr_af(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  node_feature_cleanup(agent, 'bgp')

  test_harness_bgp_nbr_af(tests, 'non_default_properties_A')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_C')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_D')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_M')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_N')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_S')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_W')

  # Special Cases
  test_harness_bgp_nbr_af(tests, 'non_default_properties_ebgp_only')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_ibgp_only')
  test_harness_bgp_nbr_af(tests, 'non_default_properties_vrf_only')
  test_harness_bgp_nbr_af(tests, 'non_default_misc_maps_part_1')
  test_harness_bgp_nbr_af(tests, 'non_default_misc_maps_part_2')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  node_feature_cleanup(agent, 'bgp')

  id = 'title_patterns'
  tests[id][:desc] = '3.1 Title Patterns'
  tests[id][:title_pattern] = '2'
  tests[id][:af] = { :neighbor => '1.1.1.1',
                     :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.2 Title Patterns'
  tests[id][:title_pattern] = '2 blue'
  tests[id][:af] = { :neighbor => '2.2.2.2', :afi => 'ipv4',
                     :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.3 Title Patterns'
  tests[id][:title_pattern] = '2 green 3.3.3.3'
  tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.4 Title Patterns'
  tests[id][:title_pattern] = '2 red 4.4.4.4 ipv4'
  tests[id][:af] = { :safi => 'unicast' }
  test_harness_bgp_nbr_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.5 Title Patterns'
  tests[id][:title_pattern] = '2 yellow 5.5.5.5 ipv4 unicast'
  tests[id].delete(:af)
  test_harness_bgp_nbr_af(tests, id)
end

logger.info("TestCase :: #{testheader} :: End")
