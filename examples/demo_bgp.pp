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
  cisco_bgp { 'default':
    ensure                                 => present,
    asn                                    => 55.77,
    vrf                                    => 'blue',
    router_id                              => '192.168.0.66',
    cluster_id                             => '55',
    confederation_id                       => '33',
    confederation_peers                    => '99 88 200.1',
    suppress_fib_pending                   => false,
    log_neighbor_changes                   => false,

    # Best Path Properties
    bestpath_always_compare_med            => true,
    bestpath_aspath_multipath_relax        => true,
    bestpath_compare_routerid              => true,
    bestpath_cost_community_ignore         => true,
    bestpath_med_confed                    => true,
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
  cisco_bgp_af { 'default':
    ensure                                 => present,
    asn                                    => 55.77,
    vrf                                    => 'blue',
    afi                                    => 'ipv4',
    safi                                   => 'unicast',

    # Properties
    client_to_client                       => false,
    default_information_originate          => false,
    next_hop_route_map                     => 'RouteMap',
  }

  # --------------------------------------------------------------------------#
  # Configure Address Family IPv4 Multicast                                   #
  # --------------------------------------------------------------------------#
  cisco_bgp_af { 'default':
    ensure                                 => present,
    asn                                    => 55.77,
    vrf                                    => 'blue',
    afi                                    => 'ipv4',
    safi                                   => 'multicast',

    # Properties
    client_to_client                       => false,
    default_information_originate          => false,
    next_hop_route_map                     => 'RouteMap',
  }

  # --------------------------------------------------------------------------#
  # Configure Address Family IPv6 Unicast                                     #
  # --------------------------------------------------------------------------#
  cisco_bgp_af { 'default':
    ensure                                 => present,
    asn                                    => 55.77,
    vrf                                    => 'blue',
    afi                                    => 'ipv6',
    safi                                   => 'unicast',

    # Properties
    client_to_client                       => false,
    default_information_originate          => false,
    next_hop_route_map                     => 'RouteMap',
  }

  #---------------------------------------------------------------------------#
  # Configure A BGP Neighbor
  #---------------------------------------------------------------------------#
  cisco_bgp_neighbor {'default':
    ensure                                 => present,
    asn                                    => 55.77,
    vrf                                    => 'blue',
    neighbor                               => '1.1.1.1',

    #Properties
    description                            => 'my description',
    connected_check                        => true,
    capability_negotiation                 => true,
    dynamic_capability                     => true,
    ebgp_multihop                          => 2,
    local_as                               => 55.77,
    log_neighbor_changes                   => disable,
    low_memory_exempt                      => false,
    remote_as                              => 12,
    remove_private_as                      => 'all',
    shutdown                               => true,
    suppress_4_byte_as                     => true,
    timers_keepalive                       => 90,
    timers_holdtime                        => 270,
    update_source                          => 'ethernet1/1',
    transport_passive_only                 => false,
  }

  # --------------------------------------------------------------------------#
  # Configure Neighbor-level Address Family IPv4 Unicast
  # --------------------------------------------------------------------------#
  cisco_bgp_neighbor_af { '55.77 blue 1.1.1.1 ipv4 unicast':
    ensure                                 => present,

    # Properties
    additional_paths_receive               => 'enable',
    additional_paths_send                  => 'disable',
    allowas_in_max                         => 5,
    default_originate_route_map            => 'my_def_map',
    disable_peer_as_check                  => true,
    filter_list_in                         => 'flin',
    filter_list_out                        => 'flout',
    max_prefix_limit                       => 100,
    max_prefix_threshold                   => 50,
    max_prefix_interval                    => 30,
    next_hop_self                          => true,
    next_hop_third_party                   => false,
    prefix_list_in                         => 'pfx_in',
    prefix_list_out                        => 'pfx_out',
    route_map_in                           => 'rm_in',
    route_map_out                          => 'rm_out',
    send_community                         => 'extended',
    soft_reconfiguration_in                => 'always',
    soo                                    => '3:3',
    suppress_inactive                      => true,
    unsuppress_map                         => 'unsup_map',
    weight                                 => 30,
  }

  # --------------------------------------------------------------------------#
  # Configure A BGP Neighbor using title pattern
  # --------------------------------------------------------------------------#
  cisco_bgp_neighbor { '55.77 blue2 2.2.2.0/24':
    ensure                                 => present,

    #Properties
    description                            => 'my description',
    connected_check                        => true,
    capability_negotiation                 => true,
    dynamic_capability                     => true,
    ebgp_multihop                          => 2,
    local_as                               => 55.77,
    log_neighbor_changes                   => disable,
    low_memory_exempt                      => false,
    remote_as                              => 12,
    remove_private_as                      => 'all',
    shutdown                               => true,
    suppress_4_byte_as                     => true,
    timers_keepalive                       => 90,
    timers_holdtime                        => 270,
    update_source                          => 'ethernet1/1',
    maximum_peers                          => 2,
  }

  # TBD: The following manifests need cisco_bgp_neighbor to define remote-as ***
  #
  # --------------------------------------------------------------------------#
  # Configure Neighbor-level Address Family IPv4 Unicast (eBgp-only)
  # --------------------------------------------------------------------------#
  # cisco_bgp_neighbor_af { '55.77 blue2 2.2.2.0/24 ipv4 unicast':
  #   ensure                               => present,
  #   as_override                          => true,
  # }
  #
  # --------------------------------------------------------------------------#
  # Configure Neighbor-level Address Family IPv4 Unicast (iBgp-only)
  # --------------------------------------------------------------------------#
  # cisco_bgp_neighbor_af { '55.77 blue3 3.3.3.3 ipv4 unicast':
  #   ensure                               => present,
  #   route_reflector_client               => true,
  # }
}
