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
require File.expand_path('../../bgp/bgplib.rb', __FILE__)
require File.expand_path('../bgpaflib.rb', __FILE__)
# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bgp_af :: All default property values'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

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
# tests[id][:remote_as] - (Optional) allows explicit remote-as configuration
#   for some ebgp/ibgp-only testing

# default_properties
#

def remove_property(prop_symbol, test)
  test[:manifest_props].delete(prop_symbol)
  test[:resource_props].delete(prop_symbol.to_s)
end

def remove_unsupported_properties(test, platform, vrf)
  if platform == 'ios_xr' # remove properties not supported on XR
    remove_property(:next_hop_route_map, test)
    remove_property(:additional_paths_install, test)
    remove_property(:dampen_igp_metric, test)
    remove_property(:advertise_l2vpn_evpn, test)

    # TODO: marked in yaml as unsupported for XR (revisit)
    remove_property(:default_information_originate, test)

    # TODO: revisit when these props are handled in XR
    remove_property(:route_target_both_auto, test)
    remove_property(:route_target_both_auto_evpn, test)
    remove_property(:route_target_import, test)
    remove_property(:route_target_import_evpn, test)
    remove_property(:route_target_export, test)
    remove_property(:route_target_export_evpn, test)

    # properties that are not supported under a vrf
    if vrf != 'default'
      remove_property(:client_to_client, test)
      remove_property(:dampening_state, test)
      remove_property(:dampening_half_time, test)
      remove_property(:dampening_max_suppress_time, test)
      remove_property(:dampening_reuse_time, test)
      remove_property(:dampening_suppress_time, test)
    end
  end

  return unless vrf == 'default'

  # properties that are ONLY supported under a vrf
  remove_property(:advertise_l2vpn_evpn, test)
  remove_property(:route_target_both_auto, test)
  remove_property(:route_target_both_auto_evpn, test)
  remove_property(:route_target_import, test)
  remove_property(:route_target_import_evpn, test)
  remove_property(:route_target_export, test)
  remove_property(:route_target_export_evpn, test)
end

def test_default_properties(tests, platform, vrf, desc, present=true)
  id = 'default_properties'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :additional_paths_install      => 'default',
      :additional_paths_receive      => 'default',
      :additional_paths_selection    => 'default',
      :additional_paths_send         => 'default',
      :advertise_l2vpn_evpn          => 'default',
      :client_to_client              => 'default',
      :dampen_igp_metric             => 'default',
      :dampening_state               => 'default',
      :dampening_half_time           => 'default',
      :dampening_max_suppress_time   => 'default',
      :dampening_reuse_time          => 'default',
      :dampening_suppress_time       => 'default',
      :default_information_originate => 'default',
      :maximum_paths                 => 'default',
      :maximum_paths_ibgp            => 'default',
      :next_hop_route_map            => 'default',
      :networks                      => 'default',
      :redistribute                  => 'default',
      :route_target_both_auto        => 'default',
      :route_target_both_auto_evpn   => 'default',
      :route_target_import           => 'default',
      :route_target_import_evpn      => 'default',
      :route_target_export           => 'default',
      :route_target_export_evpn      => 'default',
    },

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
      'maximum_paths'                 => '1',
      'maximum_paths_ibgp'            => '1',
      'route_target_both_auto'        => 'false',
      'route_target_both_auto_evpn'   => 'false',
    },
  }
  tests[id][:ensure] = :absent unless present
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_default_dampening_routemap(tests, platform, vrf, desc)
  id = 'default_properties'

  # Special case: When dampening_routemap is set to default
  # it means that dampening is enabled without routemap.
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :dampening_routemap => 'default'
    },

    :resource_props => {
      'dampening_state'             => 'true',
      'dampening_half_time'         => '15',
      'dampening_max_suppress_time' => '45',
      'dampening_reuse_time'        => '750',
      'dampening_suppress_time'     => '2000',
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

#
# non_default_properties
#
def test_non_default_a(tests, platform, vrf, desc)
  id = 'non_default_properties_A'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :additional_paths_install   => true,
      :additional_paths_receive   => true,
      :additional_paths_selection => 'RouteMap',
      :additional_paths_send      => true,
      :advertise_l2vpn_evpn       => true,
    },

    :resource_props => {
      'additional_paths_install'   => 'true',
      'additional_paths_receive'   => 'true',
      'additional_paths_selection' => 'RouteMap',
      'additional_paths_send'      => 'true',
      'advertise_l2vpn_evpn'       => 'true',
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_non_default_c(tests, platform, vrf, desc)
  id = 'non_default_properties_C'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :client_to_client => false
    },

    :resource_props => {
      'client_to_client' => 'false'
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_non_default_d(tests, platform, vrf, desc)
  id = 'non_default_properties_D'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :dampen_igp_metric             => 200,
      :dampening_half_time           => 1,
      :dampening_max_suppress_time   => 4,
      :dampening_reuse_time          => 2,
      :dampening_suppress_time       => 3,
      :default_information_originate => true,
    },

    :resource_props => {
      'dampen_igp_metric'             => '200',
      'dampening_half_time'           => '1',
      'dampening_max_suppress_time'   => '4',
      'dampening_reuse_time'          => '2',
      'dampening_suppress_time'       => '3',
      'default_information_originate' => 'true',
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

# Special case: Just dampening_state, no properties.
def test_non_default_dampening_true(tests, platform, vrf, desc)
  id = 'non_default_properties_Dampening_true'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :dampening_state => 'true'
    },

    :resource_props => {
      'dampening_state'             => 'true',
      'dampening_half_time'         => '15',
      'dampening_max_suppress_time' => '45',
      'dampening_reuse_time'        => '750',
      'dampening_suppress_time'     => '2000',
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_non_default_dampening_false(tests, platform, vrf, desc)
  id = 'non_default_properties_Dampening_false'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :dampening_state => 'false'
    },

    :resource_props => {
      'dampening_state' => 'false'
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

# Special case: When dampening_routemap is mutually exclusive
# with other dampening properties.
def test_non_default_dampening_routemap(tests, platform, vrf, desc)
  id = 'non_default_properties_Dampening_routemap'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :dampening_routemap => 'RouteMap'
    },

    :resource_props => {
      'dampening_routemap' => 'RouteMap'
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_non_default_m(tests, platform, vrf, desc)
  id = 'non_default_properties_M'
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :maximum_paths      => 9,
      :maximum_paths_ibgp => 9,
    },

    :resource_props => {
      'ensure'             => 'present',
      'maximum_paths'      => '9',
      'maximum_paths_ibgp' => '9',
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_non_default_n(tests, platform, vrf, desc)
  id = 'non_default_properties_N'
  networks = [['192.168.5.0/24', 'RouteMap'], ['192.168.6.0/32']]
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :networks           => networks,
      :next_hop_route_map => 'RouteMap',
    },

    :resource_props => {
      'networks'           => "#{networks}",
      'next_hop_route_map' => 'RouteMap',
    },
  }
  test_harness_bgp_af(tests, id, platform, vrf)
end

def test_non_default_r(tests, platform, vrf, desc)
  id = 'non_default_properties_R'
  redistribute = [['static', 'RouteMap'], ['eigrp 1', 'RouteMap']] # rubocop:disable Style/WordArray
  routetargetimport = ['1.2.3.4:55', '102:33']
  routetargetimportevpn = ['1.2.3.4:55', '102:33']
  routetargetexport = ['1.2.3.4:55', '102:33']
  routetargetexportevpn = ['1.2.3.4:55', '102:33']
  tests[id] = {
    :desc           => "#{desc} (vrf '#{vrf}')",
    :title_pattern  => "#{BgpLib::ASN} #{vrf} ipv4 unicast",
    :manifest_props => {
      :redistribute                => redistribute,
      :route_target_both_auto      => true,
      :route_target_both_auto_evpn => true,
      :route_target_import         => routetargetimport,
      :route_target_import_evpn    => routetargetimportevpn,
      :route_target_export         => routetargetexport,
      :route_target_export_evpn    => routetargetexportevpn,
    },

    :resource_props => {
      'redistribute'                => "#{redistribute}",
      'route_target_both_auto'      => 'true',
      'route_target_both_auto_evpn' => 'true',
      'route_target_import'         => "#{routetargetimport}",
      'route_target_import_evpn'    => "#{routetargetimportevpn}",
      'route_target_export'         => "#{routetargetexport}",
      'route_target_export_evpn'    => "#{routetargetexportevpn}",
    },
  }

  test_harness_bgp_af(tests, id, platform, vrf)
end

# test vpnv4/vpnv6 afis on XR
def test_vpn_afis(tests, platform, desc)
  init_bgp(master, agent) # clean slate

  id = 'afi_safi'

  # list of [global af, vrf af] pairs to test
  afis = %w(vpnv4 vpnv6)
  safis = %w(unicast multicast)

  afis.each do |afi|
    # create a global AF and a vrf AF
    safis.each do |safi|
      tests[id] = {
        :desc           => "#{desc}: (#{afi} #{safi})",
        :title_pattern  => "#{BgpLib::ASN} default #{afi} #{safi}",
        :ensure         => :present,
        :manifest_props => {},
        :resource_props => { 'ensure' => 'present' },
      }
      tests[id][:resource_cmd] = puppet_resource_cmd(
        bgp_title_pattern_munge(tests, id, 'bgp_af'))
      build_manifest_bgp_af(tests, id, platform, 'default')

      test_manifest(tests, id)
      test_resource(tests, id)
    end
  end
end

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
def build_manifest_bgp_af(tests, id, platform, vrf='default')
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
    extra_config = get_dependency_manifest(platform, vrf, tests[id][:title_pattern])
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_bgp_af :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {

    #{extra_config}

    cisco_bgp_af { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

# get extra manifest content to handle dependencies
def get_dependency_manifest(platform, vrf, title_pattern)
  extra_config = ''
  if platform == 'ios_xr'
    # XR requires the following before a vrf AF can be configured:
    #   1. a global router_id
    #   2. a global address family
    #   3. route_distinguisher configured on the vrf
    extra_config = "
      cisco_bgp { '#{BgpLib::ASN} default':
        ensure                                 => present,
        router_id                              => '1.2.3.4',
      }"

    parent_title = "#{BgpLib::ASN} default vpnv4 unicast"
    if parent_title != title_pattern
      extra_config += "
        cisco_bgp_af { '#{parent_title}':
          ensure                                 => present,
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
      cisco_bgp { '#{BgpLib::ASN} #{vrf}':
        ensure                                 => present,
        route_distinguisher                    => auto,
      }"
    end
  end
  extra_config
end

# Wrapper for bgp_af specific settings prior to calling the
# common test_harness.
def test_harness_bgp_af(tests, id, platform, vrf)
  af = bgp_title_pattern_munge(tests, id, 'bgp_af')
  logger.info("\n--------\nTest Case Address-Family ID: #{af}")

  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd(af)

  props_empty = tests[id][:manifest_props].empty?

  remove_unsupported_properties(tests[id], platform, vrf)

  if !props_empty && tests[id][:manifest_props].empty?
    logger.info("Skipping '#{tests[id][:desc]}' - no supported properties remain")
  else
    # Build the manifest for this test
    build_manifest_bgp_af(tests, id, platform, vrf)

    test_harness_common(tests, id)
  end

  tests[id][:ensure] = nil
end

# TODO: Move to/update utilitylib.rb when test_bgpneighboraf is finished.
def bgp_title_pattern_munge(tests, id, provider=nil)
  title = tests[id][:title_pattern]
  af = {}
  props = tests[id][:manifest_props]
  [:asn, :vrf, :neighbor, :afi, :safi].each do |key|
    af[key] = props[key] if props.key?(key)
  end

  if title.nil?
    puts 'no title'
    return af
  end

  t = {}

  case provider
  when 'bgp_af'
    t[:asn], t[:vrf], t[:afi], t[:safi] = title.split
  when 'bgp_neighbor_af'
    t[:asn], t[:vrf], t[:neighbor], t[:afi], t[:safi] = title.split
  end
  t.merge!(af)
  t[:vrf] = 'default' if t[:vrf].nil?
  t
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  platform = fact_on(agent, 'os.name')

  %w(default blue).each do |vrf|
    logger.info("\n#{'-' * 60}\nSection 1. "\
                "Default Property Testing (vrf '#{vrf}')")

    init_bgp(master, agent) # clean slate

    # -----------------------------------
    test_default_properties(tests, platform, vrf, '1.1 Ensure present')

    test_default_properties(tests, platform, vrf, '1.2 Ensure absent', false)

    if platform != 'ios_xr'
      test_default_dampening_routemap(
        tests, platform, vrf, '1.3 Test dampening')
    end

    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 2. "\
                "Non Default Property Testing (vrf '#{vrf}')")

    init_bgp(master, agent) # clean slate

    test_non_default_a(
      tests, platform, vrf, "2.1 Non Default Properties: 'A' commands")

    test_non_default_c(
      tests, platform, vrf, "2.2 Non Default Properties: 'C' commands")

    test_non_default_d(
      tests, platform, vrf, "2.3 Non Default Properties: 'D' commands")

    # not supported on XR under a vrf
    if platform != 'ios_xr' || vrf == 'default'
      test_non_default_dampening_routemap(
        tests, platform, vrf, '2.3.1 Non-Default dampening true')
    end

    init_bgp(master, agent) # clean slate

    test_non_default_dampening_true(
      tests, platform, vrf, '2.3.2 Non-Default dampening true')

    test_non_default_dampening_false(
      tests, platform, vrf, '2.3.3 Non-Default dampening false')

    test_non_default_m(
      tests, platform, vrf, "2.4 Non Default Properties: 'M' commands")

    test_non_default_n(
      tests, platform, vrf, "2.5 Non Default Properties: 'N' commands")

    test_non_default_r(
      tests, platform, vrf, "2.6 Non Default Properties: 'R' commands")
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  init_bgp(master, agent) # clean slate

  id = 'title_patterns'
  tests[id][:desc] = '3.1 Title Patterns'
  tests[id][:title_pattern] = BgpLib::ASN
  tests[id][:manifest_props] = { :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_af(tests, id, platform, 'default')

  # -----------------------------------
  tests[id][:desc] = '3.2 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} blue"
  tests[id][:manifest_props] = { :afi => 'ipv4', :safi => 'unicast' }
  test_harness_bgp_af(tests, id, platform, 'blue')

  # -----------------------------------
  tests[id][:desc] = '3.3 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} red ipv4"
  tests[id][:manifest_props] = { :safi => 'unicast' }
  test_harness_bgp_af(tests, id, platform, 'red')

  # -----------------------------------
  tests[id][:desc] = '3.4 Title Patterns'
  tests[id][:title_pattern] = "#{BgpLib::ASN} yellow ipv4 unicast"
  tests[id][:manifest_props] = {}
  test_harness_bgp_af(tests, id, platform, 'yellow')

  test_vpn_afis(tests, platform, '3.5 VPN AFIs') if platform == 'ios_xr'

  cleanup_bgp(master, agent)
end

logger.info("TestCase :: #{testheader} :: End")
