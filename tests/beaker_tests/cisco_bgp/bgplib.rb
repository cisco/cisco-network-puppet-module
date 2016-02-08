#
# BgpLib Module Library:
# ----------------------
# bgplib.rb
#
# Utility module library for cisco_bgp puppet provider beaker test cases.
# All cisco_bgp provider test cases require the BgpLib module.
#
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# BgpLib beaker test module for class cisco_bgp
module BgpLib
  ASN         = '1638402'
  ASN_ASDOT   = '55.77'
  ASN_ASPLAIN = '3604557'
  VRF1        = 'blue'
  VRF2        = 'red'

  # Create manifest ensure => present + 'default' property values
  def self.create_bgp_manifest_present(platform, vrf='default')
    conditional_props = ''
    if platform != 'ios_xr'
      conditional_props <<
        "bestpath_med_non_deterministic => 'default',
         disable_policy_batching        => 'default',
         disable_policy_batching_ipv4   => 'default',
         disable_policy_batching_ipv6   => 'default',
         event_history_cli              => 'default',
         event_history_detail           => 'default',
         event_history_events           => 'default',
         event_history_periodic         => 'default',
         flush_routes                   => 'default',
         graceful_restart_helper        => 'default',
         isolate                        => 'default',
         maxas_limit                    => 'default',
         neighbor_down_fib_accelerate   => 'default',
         shutdown                       => 'default',
         suppress_fib_pending           => 'default',
         timer_bestpath_limit           => 'default',
         timer_bestpath_limit_always    => 'default',
         "
    else
      conditional_props <<
        "# Nonstop Routing (NSR)
        nsr                             => 'default',"
    end

    if vrf != 'default'
      conditional_props <<
        "route_distinguisher            => 'default',"
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => '#{vrf}',
        router_id                              => 'default',
        cluster_id                             => 'default',
        confederation_id                       => 'default',
        confederation_peers                    => 'default',
        enforce_first_as                       => 'default',
        fast_external_fallover                 => 'default',
        log_neighbor_changes                   => 'default',

        # Best Path Properties
        bestpath_always_compare_med            => 'default',
        bestpath_aspath_multipath_relax        => 'default',
        bestpath_compare_routerid              => 'default',
        bestpath_cost_community_ignore         => 'default',
        bestpath_med_confed                    => 'default',
        bestpath_med_missing_as_worst          => 'default',


        # Graceful Restart Properties
        graceful_restart                       => 'default',
        graceful_restart_timers_restart        => 'default',
        graceful_restart_timers_stalepath_time => 'default',

        # Timer Properties
        timer_bgp_keepalive                    => 'default',
        timer_bgp_holdtime                     => 'default',

        #{conditional_props}
      }
    }\nEOF"
    manifest_str
  end

  # Create manifest ensure => present + 'default' property values
  # for vrf1
  def self.create_bgp_manifest_present_vrf1(platform)
    create_bgp_manifest_present(platform, BgpLib::VRF1)
  end

  # Create manifest ensure => present + 'default' property values
  # for vrf2
  def self.create_bgp_manifest_present_vrf2(platform)
    create_bgp_manifest_present(platform, BgpLib::VRF2)
  end

  # Create manifest ensure => present + 'non-default' property values
  def self.create_bgp_manifest_present_non_default(platform)
    conditional_props = ''
    if platform != 'ios_xr'
      conditional_props =
       "bestpath_med_non_deterministic => 'true',
        disable_policy_batching        => 'true',
        disable_policy_batching_ipv4   => 'xx',
        disable_policy_batching_ipv6   => 'yy',
        event_history_cli              => 'size_medium',
        event_history_detail           => 'size_large',
        event_history_events           => 'size_disable',
        event_history_periodic         => 'false',
        flush_routes                   => 'true',
        graceful_restart_helper        => 'true',
        isolate                        => 'true',
        maxas_limit                    => '50',
        neighbor_down_fib_accelerate   => 'true',
        shutdown                       => 'true',
        suppress_fib_pending           => 'true',
        timer_bestpath_limit           => '255',
        timer_bestpath_limit_always    => 'true',
        "
    else
      conditional_props <<
        "# Nonstop Routing (NSR)
        nsr                            => 'true',"
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
        router_id                              => '192.168.0.55',
        cluster_id                             => '10.0.0.1',
        confederation_id                       => '99',
        confederation_peers                    => '55 23.4 88 200.1',
        enforce_first_as                       => 'true',
        fast_external_fallover                 => 'false',
        log_neighbor_changes                   => 'true',

        # Best Path Properties
        bestpath_always_compare_med            => 'true',
        bestpath_aspath_multipath_relax        => 'true',
        bestpath_compare_routerid              => 'true',
        bestpath_cost_community_ignore         => 'true',
        bestpath_med_confed                    => 'true',
        bestpath_med_missing_as_worst          => 'true',

        # Timer Properties
        timer_bgp_keepalive                    => '45',
        timer_bgp_holdtime                     => '110',

        # Graceful Restart Properties
        graceful_restart                       => 'true',
        graceful_restart_timers_restart        => '130',
        graceful_restart_timers_stalepath_time => '310',

        #{conditional_props}
      }
    }\nEOF"
    manifest_str
  end
  # rubocop:enable Metrics/MethodLength

  # Create manifest ensure => present + 'non-default' property values
  # for vrf1
  def self.create_bgp_manifest_present_non_default_vrf1(platform)
    conditional_props = ''
    if platform != 'ios_xr'
      conditional_props =
       "bestpath_med_confed                    => 'true',
        bestpath_med_non_deterministic         => 'true',
        cluster_id                             => '55',
        confederation_id                       => '33',
        confederation_peers                    => '99 88 200.1',
        graceful_restart                       => 'false',
        graceful_restart_helper                => 'true',
        graceful_restart_timers_restart        => '131',
        graceful_restart_timers_stalepath_time => '311',
        maxas_limit                            => '55',
        neighbor_down_fib_accelerate           => 'true',
        suppress_fib_pending                   => 'false',
        timer_bestpath_limit                   => '255',
        timer_bestpath_limit_always            => 'true',
        "
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
        route_distinguisher                    => 'auto',
        router_id                              => '192.168.0.66',
        log_neighbor_changes                   => 'false',
        # Best Path Properties
        bestpath_always_compare_med            => 'true',
        bestpath_aspath_multipath_relax        => 'true',
        bestpath_compare_routerid              => 'true',
        bestpath_cost_community_ignore         => 'true',
        bestpath_med_missing_as_worst          => 'true',
        # Timer Properties
        timer_bgp_keepalive                    => '46',
        timer_bgp_holdtime                     => '111',

        #{conditional_props}
      }
    }\nEOF"
    manifest_str
  end

  # Create manifest ensure => present + 'non-default' property values
  # for vrf2
  def self.create_bgp_manifest_present_non_default_vrf2(platform)
    conditional_props = ''
    if platform != 'ios_xr'
      conditional_props =
       "bestpath_med_confed                    => 'false',
        bestpath_med_non_deterministic         => 'false',
        cluster_id                             => '10.0.0.2',
        confederation_id                       => '32.88',
        confederation_peers                    => '55 23.4 88 200.1',
        graceful_restart                       => 'false',
        graceful_restart_helper                => 'false',
        graceful_restart_timers_restart        => '132',
        graceful_restart_timers_stalepath_time => '312',
        maxas_limit                            => '60',
        neighbor_down_fib_accelerate           => 'true',
        suppress_fib_pending                   => 'false',
        timer_bestpath_limit                   => '115',
        timer_bestpath_limit_always            => 'false',
        "
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF2},
        route_distinguisher                    => '1.1.1.1:1',
        router_id                              => '192.168.0.77',
        log_neighbor_changes                   => 'false',
        # Best Path Properties
        bestpath_always_compare_med            => 'false',
        bestpath_aspath_multipath_relax        => 'false',
        bestpath_compare_routerid              => 'false',
        bestpath_cost_community_ignore         => 'false',
        bestpath_med_missing_as_worst          => 'false',
        # Timer Properties
        timer_bgp_keepalive                    => '48',
        timer_bgp_holdtime                     => '114',

        #{conditional_props}
      }
    }\nEOF"
    manifest_str
  end

  # Create manifest ensure => absent
  def self.create_bgp_manifest_absent(vrf='default', asn=BgpLib::ASN)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => absent,
        asn                                    => #{asn},
        vrf                                    => '#{vrf}',
      }
    }\nEOF"
    manifest_str
  end

  # Create manifest ensure => absent for vrf1
  def self.create_bgp_manifest_absent_vrf1
    create_bgp_manifest_absent(BgpLib::VRF1)
  end

  # Create manifest ensure => absent for vrf2
  def self.create_bgp_manifest_absent_vrf2
    create_bgp_manifest_absent(BgpLib::VRF2)
  end

  # The following manifests are used to validate title patterns that
  # create a cisco_bgp resource with the following attributes.
  #
  # asn => #{BgpLib::ASN}
  # vrf => 'default
  # (all_other_attributes => default values)
  def self.create_bgp_manifest_title_pattern1
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern2
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern3
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN}':
        ensure                                 => present,
        vrf                                    => 'default',
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern4
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN} default':
        ensure                                 => present,
      }
    }\nEOF"
    manifest_str
  end

  # asn and vrf properties take precedence over '55 blue'
  def self.create_bgp_manifest_title_pattern5
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '55 blue':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
      }
    }\nEOF"
    manifest_str
  end

  # The following manifests are used to validate title patterns that
  # create a cisco_bgp resource with the following attributes.
  #
  # asn => #{BgpLib::ASN}
  # vrf => #{BgpLib::VRF1}
  # (all_other_attributes => default values)

  def self.create_bgp_manifest_title_pattern6
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern6_remove
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern7
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN} #{BgpLib::VRF1}':
        ensure                                 => present,
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern7_remove
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN} #{BgpLib::VRF1}':
        ensure                                 => absent,
      }
    }\nEOF"
    manifest_str
  end

  # asn and vrf properties take precedence over '876 red'
  def self.create_bgp_manifest_title_pattern8
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876 red':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern8_remove
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876 red':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  # The following manifests are used to validate title patterns that
  # create a cisco_bgp resource with the following attributes.
  #
  # asn => #{BgpLib::ASN_ASDOT}
  # vrf => #{BgpLib::VRF1}
  # (all_other_attributes => default values)

  def self.create_bgp_manifest_title_pattern9
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern9_remove
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern10
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN_ASDOT} #{BgpLib::VRF1}':
        ensure                                 => present,
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern10_remove
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN_ASDOT} #{BgpLib::VRF1}':
        ensure                                 => absent,
      }
    }\nEOF"
    manifest_str
  end

  # asn and vrf properties take precedence over '876.99 red'
  def self.create_bgp_manifest_title_pattern11
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876.99 red':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_bgp_manifest_title_pattern11_remove
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876.500 red':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }\nEOF"
    manifest_str
  end

  def self.create_cleanup_bgp
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
      node 'default' {
        resources { cisco_bgp: purge => true }
      }\nEOF"
    manifest_str
  end
end

# Initialize BGP (clean up + enable BGP)
def init_bgp(master, agent)
  tests = { master: master, agent: agent }
  name = 'init'
  tests[name] = {}
  tests[name][:desc] = 'Initialize BGP'
  tests[name][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      resources { cisco_bgp: purge => true }
      cisco_bgp { 'default':
        ensure => present,
        asn    => #{BgpLib::ASN},
      }
    }\nEOF"
  tests[name][:code] = [0, 2, 6]
  test_manifest(tests, name)
end

# Clean up BGP
def cleanup_bgp(master, agent)
  tests = { master: master, agent: agent }
  name = 'cleanup'
  tests[name] = {}
  tests[name][:desc] = 'Clean up BGP'
  tests[name][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      resources { cisco_bgp: purge => true }
    }\nEOF"
  tests[name][:code] = [0, 2, 6]
  test_manifest(tests, name)
end
