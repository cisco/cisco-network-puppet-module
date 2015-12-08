# Manifest to demo cisco_bgp provider
#
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

class ciscopuppet::demo_bgp {

  # --------------------------------------------------------------------------#
  # Configure Global BGP                                                      #
  # --------------------------------------------------------------------------#
  cisco_bgp { '55.77 blue':
    ensure                                 => present,

    router_id                              => '192.168.0.66',
    cluster_id                             => '55',
    confederation_id                       => '33',
    confederation_peers                    => '99 88 200.1',
    enforce_first_as                       => false,
    maxas_limit                            => '50',
    suppress_fib_pending                   => false,
    log_neighbor_changes                   => false,

    # Best Path Properties
    bestpath_always_compare_med            => true,
    bestpath_aspath_multipath_relax        => true,
    bestpath_compare_routerid              => true,
    bestpath_cost_community_ignore         => true,
    bestpath_med_confed                    => true,
    bestpath_med_missing_as_worst          => true,
    bestpath_med_non_deterministic         => true,
    timer_bestpath_limit                   => '255',
    timer_bestpath_limit_always            => true,

    # Graceful Restart Properties
    graceful_restart                       => false,
    graceful_restart_timers_restart        => '131',
    graceful_restart_timers_stalepath_time => '311',
    graceful_restart_helper                => true,

    # Timer Properties
    timer_bgp_keepalive                    => '46',
    timer_bgp_holdtime                     => '111',
  }

  # --------------------------------------------------------------------------#
  # Configure Address Family IPv4 Unicast                                     #
  # --------------------------------------------------------------------------#
  $ipv4_networks = [['192.168.5.0/24', 'nrtemap1'], ['192.168.6.0/32']]
  $ipv4_redistribute = [['eigrp 1', 'e_rtmap_29'], ['ospf 3',  'o_rtmap']]

  cisco_bgp_af { '55.77 blue ipv4 unicast':
    ensure                        => present,
    #asn                           => 55.77,
    #vrf                           => 'blue',
    #afi                           => 'ipv4',
    #safi                          => 'unicast',
    # Properties
    client_to_client              => false,
    default_information_originate => true,
    maximum_paths                 => '8',
    maximum_paths_ibgp            => '7',
    next_hop_route_map            => 'RouteMap',
    additional_paths_install      => true,
    additional_paths_receive      => true,
    additional_paths_selection    => 'RouteMap',
    additional_paths_send         => true,
    dampen_igp_metric             => 55,

    # dampening_routemap is mutually exclusive with
    # dampening_half_time, reuse_time, suppress_time
    # and max_suppress_time.
    #
    dampening_state               => true,
    dampening_half_time           => 1,
    dampening_reuse_time          => 2,
    dampening_suppress_time       => 3,
    dampening_max_suppress_time   => 4,
    #dampening_routemap            => default,

    networks                      => $ipv4_networks,
    redistribute                  => $ipv4_redistribute,
  }

  # --------------------------------------------------------------------------#
  # Configure Address Family IPv6 Unicast                                     #
  # --------------------------------------------------------------------------#

  $ipv6_networks = [['192:168::5:0/112', 'nrtemap1'], ['192:168::6:0/112']]
  $ipv6_redistribute = [['eigrp 1', 'e_v6'], ['ospfv3 3',  'o_v6']]
  cisco_bgp_af { '55.77 blue ipv6 unicast':
    ensure                        => present,

    # Properties
    client_to_client              => false,
    default_information_originate => true,
    maximum_paths                 => '7',
    maximum_paths_ibgp            => '7',
    next_hop_route_map            => 'RouteMap',
    additional_paths_receive      => true,
    additional_paths_selection    => 'RouteMap',
    additional_paths_send         => true,
    dampen_igp_metric             => 55,

    # dampening_routemap is mutually exclusive with
    # dampening_half_time, reuse_time, suppress_time
    # and max_suppress_time.
    #
    dampening_state               => true,
    #dampening_half_time           => 1,
    #dampening_reuse_time          => 2,
    #dampening_suppress_time       => 3,
    #dampening_max_suppress_time   => 4,
    dampening_routemap            => 'RouteMap',

    networks                      => $ipv6_networks,
    redistribute                  => $ipv6_redistribute,
  }

  #---------------------------------------------------------------------------#
  # Configure BGP IPv4 Neighbors
  #---------------------------------------------------------------------------#

  $capability_negotiation = $operatingsystem ? {
    'nexus' => true,
    default => undef
  }
  $dynamic_capability = $operatingsystem ? {
    'nexus' => true,
    default => undef
  }
  $log_neighbor_changes = $operatingsystem ? {
    'nexus' => disable,
    default => undef
  }
  $low_memory_exempt = $operatingsystem ? {
    'nexus' => false,
    default => undef
  }
  $remove_private_as = $operatingsystem ? {
    'nexus' => 'all',
    default => undef
  }
  $update_source = $operatingsystem ? {
    'nexus' => 'ethernet1/1',
    default => 'fastethernet1/1/1/1'
  }

  cisco_bgp_neighbor {'55.77 blue 1.1.1.1':
    ensure                 => present,

    #Properties
    description            => 'my description',
    connected_check        => true,
    capability_negotiation => $capability_negotiation,
    dynamic_capability     => $dynamic_capability,
    ebgp_multihop          => 2,
    local_as               => 55.88,
    log_neighbor_changes   => $log_neighbor_changes,
    low_memory_exempt      => $low_memory_exempt,
    remote_as              => 12,
    remove_private_as      => $remove_private_as,
    shutdown               => true,
    suppress_4_byte_as     => true,
    timers_keepalive       => 90,
    timers_holdtime        => 270,
    update_source          => $update_source,
    transport_passive_only => false,
  }

  cisco_bgp_neighbor {'55.77 default 2.2.2.2':
    ensure                 => present,

    #Properties
    description            => 'my description',
    connected_check        => true,
    capability_negotiation => $capability_negotiation,
    dynamic_capability     => $dynamic_capability,
    ebgp_multihop          => 2,
    log_neighbor_changes   => $log_neighbor_changes,
    low_memory_exempt      => $low_memory_exempt,
    remote_as              => 12,
    remove_private_as      => $remove_private_as,
    shutdown               => true,
    suppress_4_byte_as     => true,
    timers_keepalive       => 90,
    timers_holdtime        => 270,
    update_source          => $update_source,
    transport_passive_only => false,
  }

  cisco_bgp_neighbor {'55.77 blue 3.3.3.3':
    ensure      => present,

    #Properties
    description => 'config_for_rr_client',
    remote_as   => 3604557,
    shutdown    => false,
  }

  #---------------------------------------------------------------------------#
  # Configure BGP IPv6 Neighbor
  #---------------------------------------------------------------------------#

  cisco_bgp_neighbor {'55.77 blue 1:1::1:1':
    ensure                 => present,

    #Properties
    description            => 'my description',
    connected_check        => true,
    capability_negotiation => $capability_negotiation,
    dynamic_capability     => $dynamic_capability,
    ebgp_multihop          => 2,
    local_as               => 55.88,
    log_neighbor_changes   => $log_neighbor_changes,
    low_memory_exempt      => $low_memory_exempt,
    remote_as              => 12,
    remove_private_as      => $remove_private_as,
    shutdown               => true,
    suppress_4_byte_as     => true,
    timers_keepalive       => 90,
    timers_holdtime        => 270,
    update_source          => $update_source,
    transport_passive_only => false,
  }

  # --------------------------------------------------------------------------#
  # Configure Neighbor-level Address Family IPv4 Unicast
  # --------------------------------------------------------------------------#
  cisco_bgp_neighbor_af { '55.77 blue 1.1.1.1 ipv4 unicast':
    ensure                      => present,

    # Properties
    additional_paths_receive    => 'enable',
    additional_paths_send       => 'disable',
    allowas_in_max              => 5,
    default_originate_route_map => 'my_def_map',
    disable_peer_as_check       => true,
    filter_list_in              => 'flin',
    filter_list_out             => 'flout',
    max_prefix_limit            => 100,
    max_prefix_threshold        => 50,
    max_prefix_interval         => 30,
    next_hop_self               => true,
    next_hop_third_party        => false,
    prefix_list_in              => 'pfx_in',
    prefix_list_out             => 'pfx_out',
    route_map_in                => 'rm_in',
    route_map_out               => 'rm_out',
    send_community              => 'extended',
    soft_reconfiguration_in     => 'always',
    soo                         => '3:3',
    suppress_inactive           => true,
    unsuppress_map              => 'unsup_map',
    weight                      => 30,
  }

  cisco_bgp_neighbor_af { '55.77 blue 2.2.2.2 ipv4 unicast':
    ensure                      => present,

    # Properties
    additional_paths_receive    => 'enable',
    additional_paths_send       => 'disable',
    allowas_in_max              => 5,
    as_override                 => true,
    default_originate_route_map => 'my_def_map',
    disable_peer_as_check       => true,
    filter_list_in              => 'flin',
    filter_list_out             => 'flout',
    max_prefix_limit            => 100,
    max_prefix_threshold        => 50,
    max_prefix_interval         => 30,
    next_hop_self               => true,
    next_hop_third_party        => false,
    prefix_list_in              => 'pfx_in',
    prefix_list_out             => 'pfx_out',
    route_map_in                => 'rm_in',
    route_map_out               => 'rm_out',
    send_community              => 'extended',
    soft_reconfiguration_in     => 'always',
    soo                         => '3:3',
    suppress_inactive           => true,
    unsuppress_map              => 'unsup_map',
    weight                      => 30,
  }

  cisco_bgp_neighbor_af { '55.77 blue 3.3.3.3 ipv4 unicast':
    ensure                      => present,
    # Properties
    additional_paths_receive    => 'enable',
    additional_paths_send       => 'disable',
    allowas_in_max              => 5,
    default_originate_route_map => 'my_def_map',
    filter_list_in              => 'flin',
    filter_list_out             => 'flout',
    max_prefix_limit            => 100,
    max_prefix_threshold        => 50,
    max_prefix_interval         => 30,
    next_hop_self               => true,
    next_hop_third_party        => false,
    prefix_list_in              => 'pfx_in',
    prefix_list_out             => 'pfx_out',
    route_map_in                => 'rm_in',
    route_map_out               => 'rm_out',
    route_reflector_client      => true,
    send_community              => 'extended',
    soft_reconfiguration_in     => 'always',
    soo                         => '3:3',
    suppress_inactive           => true,
    unsuppress_map              => 'unsup_map',
    weight                      => 30,
  }
}
