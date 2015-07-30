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

# Require UtilityLib.rb path.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)

module BgpLib

  ASN         = '1638402'
  ASN_ASDOT   = '55.77'
  ASN_ASPLAIN = '3604557'
  VRF1        = 'blue'
  VRF2        = 'red'

  # Create manifest ensure => present + 'default' property values
  def BgpLib.create_bgp_manifest_present()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
        router_id                              => 'default',
        cluster_id                             => 'default',
        confederation_id                       => 'default',
        confederation_peers                    => 'default',
        shutdown                               => 'default',

        suppress_fib_pending                   => 'default',
        log_neighbor_changes                   => 'default',

        # Best Path Properties
        bestpath_always_compare_med            => 'default',
        bestpath_aspath_multipath_relax        => 'default',
        bestpath_compare_routerid              => 'default',
        bestpath_cost_community_ignore         => 'default',
        bestpath_med_confed                    => 'default',
        bestpath_med_non_deterministic         => 'default',
        timer_bestpath_limit                   => 'default',
        timer_bestpath_limit_always            => 'default',

        # Graceful Restart Properties
        graceful_restart                       => 'default',
        graceful_restart_timers_restart        => 'default',
        graceful_restart_timers_stalepath_time => 'default',
        graceful_restart_helper                => 'default',

        # Timer Properties
        timer_bgp_keepalive                    => 'default',
        timer_bgp_holdtime                     => 'default',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => present + 'default' property values
  # for vrf1
  def BgpLib.create_bgp_manifest_present_vrf1()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
        router_id                              => 'default',
        cluster_id                             => 'default',
        confederation_id                       => 'default',
        confederation_peers                    => 'default',
        shutdown                               => 'default',

        suppress_fib_pending                   => 'default',
        log_neighbor_changes                   => 'default',

        # Best Path Properties
        bestpath_always_compare_med            => 'default',
        bestpath_aspath_multipath_relax        => 'default',
        bestpath_compare_routerid              => 'default',
        bestpath_cost_community_ignore         => 'default',
        bestpath_med_confed                    => 'default',
        bestpath_med_non_deterministic         => 'default',
        timer_bestpath_limit                   => 'default',
        timer_bestpath_limit_always            => 'default',

        # Graceful Restart Properties
        graceful_restart                       => 'default',
        graceful_restart_timers_restart        => 'default',
        graceful_restart_timers_stalepath_time => 'default',
        graceful_restart_helper                => 'default',

        # Timer Properties
        timer_bgp_keepalive                    => 'default',
        timer_bgp_holdtime                     => 'default',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => present + 'default' property values
  # for vrf2
  def BgpLib.create_bgp_manifest_present_vrf2()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF2},
        router_id                              => 'default',
        cluster_id                             => 'default',
        confederation_id                       => 'default',
        confederation_peers                    => 'default',
        shutdown                               => 'default',

        suppress_fib_pending                   => 'default',
        log_neighbor_changes                   => 'default',

        # Best Path Properties
        bestpath_always_compare_med            => 'default',
        bestpath_aspath_multipath_relax        => 'default',
        bestpath_compare_routerid              => 'default',
        bestpath_cost_community_ignore         => 'default',
        bestpath_med_confed                    => 'default',
        bestpath_med_non_deterministic         => 'default',
        timer_bestpath_limit                   => 'default',
        timer_bestpath_limit_always            => 'default',

        # Graceful Restart Properties
        graceful_restart                       => 'default',
        graceful_restart_timers_restart        => 'default',
        graceful_restart_timers_stalepath_time => 'default',
        graceful_restart_helper                => 'default',

        # Timer Properties
        timer_bgp_keepalive                    => 'default',
        timer_bgp_holdtime                     => 'default',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => present + 'non-default' property values
  def BgpLib.create_bgp_manifest_present_non_default()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
        router_id                              => '192.168.0.55',
        cluster_id                             => '10.0.0.1',
        confederation_id                       => '99',
        confederation_peers                    => '55 23.4 88 200.1',
        shutdown                               => 'true',

        suppress_fib_pending                   => 'true',
        log_neighbor_changes                   => 'true',

        # Best Path Properties
        bestpath_always_compare_med            => 'true',
        bestpath_aspath_multipath_relax        => 'true',
        bestpath_compare_routerid              => 'true',
        bestpath_cost_community_ignore         => 'true',
        bestpath_med_confed                    => 'true',
        bestpath_med_non_deterministic         => 'true',
        timer_bestpath_limit                   => '255',
        timer_bestpath_limit_always            => 'true',

        # Graceful Restart Properties
        graceful_restart                       => 'true',
        graceful_restart_timers_restart        => '130',
        graceful_restart_timers_stalepath_time => '310',
        graceful_restart_helper                => 'true',

        # Timer Properties
        timer_bgp_keepalive                    => '45',
        timer_bgp_holdtime                     => '110',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => present + 'non-default' property values
  # for vrf1
  def BgpLib.create_bgp_manifest_present_non_default_vrf1()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
        router_id                              => '192.168.0.66',
        cluster_id                             => '55',
        confederation_id                       => '33',
        confederation_peers                    => '99 88 200.1',

        suppress_fib_pending                   => 'false',
        log_neighbor_changes                   => 'false',

        # Best Path Properties
        bestpath_always_compare_med            => 'true',
        bestpath_aspath_multipath_relax        => 'true',
        bestpath_compare_routerid              => 'true',
        bestpath_cost_community_ignore         => 'true',
        bestpath_med_confed                    => 'true',
        bestpath_med_non_deterministic         => 'true',
        timer_bestpath_limit                   => '255',
        timer_bestpath_limit_always            => 'true',

        # Graceful Restart Properties
        graceful_restart                       => 'false',
        graceful_restart_timers_restart        => '131',
        graceful_restart_timers_stalepath_time => '311',
        graceful_restart_helper                => 'true',

        # Timer Properties
        timer_bgp_keepalive                    => '46',
        timer_bgp_holdtime                     => '111',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => present + 'non-default' property values
  # for vrf2
  def BgpLib.create_bgp_manifest_present_non_default_vrf2()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF2},
        router_id                              => '192.168.0.77',
        cluster_id                             => '10.0.0.2',
        confederation_id                       => '32.88',
        confederation_peers                    => '55 23.4 88 200.1',

        suppress_fib_pending                   => 'false',
        log_neighbor_changes                   => 'false',

        # Best Path Properties
        bestpath_always_compare_med            => 'false',
        bestpath_aspath_multipath_relax        => 'false',
        bestpath_compare_routerid              => 'false',
        bestpath_cost_community_ignore         => 'false',
        bestpath_med_confed                    => 'false',
        bestpath_med_non_deterministic         => 'false',
        timer_bestpath_limit                   => '115',
        timer_bestpath_limit_always            => 'false',

        # Graceful Restart Properties
        graceful_restart                       => 'false',
        graceful_restart_timers_restart        => '132',
        graceful_restart_timers_stalepath_time => '312',
        graceful_restart_helper                => 'false',

        # Timer Properties
        timer_bgp_keepalive                    => '48',
        timer_bgp_holdtime                     => '114',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => absent
  def BgpLib.create_bgp_manifest_absent()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => absent for vrf1
  def BgpLib.create_bgp_manifest_absent_vrf1()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  # Create manifest ensure => absent for vrf2
  def BgpLib.create_bgp_manifest_absent_vrf2()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'default':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF2},
      }
    }
    EOF"
    return manifest_str
  end

  # The following manifests are used to validate title patterns that
  # create a cisco_bgp resource with the following attributes.
  #
  # asn => #{BgpLib::ASN}
  # vrf => 'default
  # (all_other_attributes => default values)
  def BgpLib.create_bgp_manifest_title_pattern1()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern2()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern3()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN}':
        ensure                                 => present,
        vrf                                    => 'default',
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern4()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN} default':
        ensure                                 => present,
      }
    }
    EOF"
    return manifest_str
  end

  # asn and vrf properties take precedence over '55 blue'
  def BgpLib.create_bgp_manifest_title_pattern5()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '55 blue':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => 'default',
      }
    }
    EOF"
    return manifest_str
  end


  # The following manifests are used to validate title patterns that
  # create a cisco_bgp resource with the following attributes.
  #
  # asn => #{BgpLib::ASN}
  # vrf => #{BgpLib::VRF1}
  # (all_other_attributes => default values)

  def BgpLib.create_bgp_manifest_title_pattern6()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern6_remove()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern7()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN} #{BgpLib::VRF1}':
        ensure                                 => present,
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern7_remove()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN} #{BgpLib::VRF1}':
        ensure                                 => absent,
      }
    }
    EOF"
    return manifest_str
  end

  # asn and vrf properties take precedence over '876 red'
  def BgpLib.create_bgp_manifest_title_pattern8()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876 red':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern8_remove()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876 red':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  # The following manifests are used to validate title patterns that
  # create a cisco_bgp resource with the following attributes.
  #
  # asn => #{BgpLib::ASN_ASDOT}
  # vrf => #{BgpLib::VRF1}
  # (all_other_attributes => default values)

  def BgpLib.create_bgp_manifest_title_pattern9()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern9_remove()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { 'raleigh':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern10()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN_ASDOT} #{BgpLib::VRF1}':
        ensure                                 => present,
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern10_remove()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '#{BgpLib::ASN_ASDOT} #{BgpLib::VRF1}':
        ensure                                 => absent,
      }
    }
    EOF"
    return manifest_str
  end

  # asn and vrf properties take precedence over '876.99 red'
  def BgpLib.create_bgp_manifest_title_pattern11()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876.99 red':
        ensure                                 => present,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

  def BgpLib.create_bgp_manifest_title_pattern11_remove()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      cisco_bgp { '876.500 red':
        ensure                                 => absent,
        asn                                    => #{BgpLib::ASN_ASDOT},
        vrf                                    => #{BgpLib::VRF1},
      }
    }
    EOF"
    return manifest_str
  end

end
