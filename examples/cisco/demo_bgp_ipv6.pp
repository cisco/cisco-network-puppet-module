# Manifest that uses the cisco_command_config provider to configure BGP
# and enable IPv6 address-families.
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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
#

class ciscopuppet::cisco::demo_bgp_ipv6 {

  # --------------------------------------------------------------------------#
  # Configure Global BGP                                                      #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp':
  command => "
    router bgp 55
      shutdown
      router-id 192.55.55.55
      cluster-id 172.5.5.5
      timers bgp 33 190
      timers bestpath-limit 44 always
      graceful-restart-helper
      graceful-restart restart-time 55
      graceful-restart stalepath-time 55
      confederation identifier 50
      confederation peers 327686 327685 200608 5000 6000 32 43
      bestpath as-path multipath-relax
      bestpath cost-community ignore
      bestpath compare-routerid
      bestpath med confed
      bestpath med non-deterministic
      bestpath always-compare-med
      reconnect-interval 22
      suppress-fib-pending
      neighbor-down fib-accelerate
      log-neighbor-changes",
  }

  # --------------------------------------------------------------------------#
  # Configure Address Family IPv6 Unicast                                     #
  #  Requires: cisco_bgp (Global BGP)                                         #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_af':
  command   => "
    router bgp 55
      address-family ipv6 unicast
        timers bestpath-defer 302 maximum 3001
        dampening 30 4 30 200
        network 192::50/124 route-map twomap
        redistribute ospfv3 30 route-map ospf_map
        redistribute isis 3 route-map isis_map
        redistribute eigrp 1 route-map eigrp_map
        aggregate-address 25::20/124
        maximum-paths 8
        maximum-paths ibgp 6
        nexthop route-map nhrp_map
        no client-to-client reflection
        default-information originate
        dampen-igp-metric 60
        additional-paths send
        additional-paths receive
        additional-paths selection route-map foo_bar",
    require => Cisco_command_config['cisco_bgp'],
  }

  # --------------------------------------------------------------------------#
  # Configure Non-Default VRF Address Family IPv6 Unicast                     #
  #  Requires: cisco_bgp (Global BGP)                                         #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_af_ipv6vrf':
  command   => "
    router bgp 55
      vrf ipv6vrf
        address-family ipv6 unicast
          timers bestpath-defer 302 maximum 3001
          dampening 30 4 30 200
          network 192::50/124 route-map twomap
          redistribute ospfv3 30 route-map ospf_map
          redistribute isis 3 route-map isis_map
          redistribute eigrp 1 route-map eigrp_map
          aggregate-address 25::20/124
          maximum-paths 8
          maximum-paths ibgp 6
          nexthop route-map nhrp_map
          no client-to-client reflection
          default-information originate
          dampen-igp-metric 60
          additional-paths send
          additional-paths receive
          additional-paths selection route-map foo_bar",
    require => Cisco_command_config['cisco_bgp'],
  }

  # --------------------------------------------------------------------------#
  # Configure IPv6 Neighbor                                                   #
  #  Requires: cisco_bgp (Global BGP)                                         #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_neighbor':
  command   => "
    router bgp 55
      neighbor 2040::1
        bfd
        inherit peer peer_template_one
        remote-as 24
        description 'one dot one'
        password 0 bgppassword 
        update-source Ethernet1/1
        remove-private-as all",
    require => Cisco_command_config['cisco_bgp'],
  }

  # --------------------------------------------------------------------------#
  # Configure IPv6 Neighbor Address Family IPv4 Unicast                       #
  #  Requires: cisco_bgp_neighbor (IPv6 Neighbor)                             #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_v6_neighbor_afv4':
  command   => "
    router bgp 55
      neighbor 2040::1 
        address-family ipv4 unicast
          allowas-in
          no disable-peer-as-check
          no route-reflector-client
          weight 40
          maximum-prefix 3 90 restart 4",
    require => Cisco_command_config['cisco_bgp_neighbor'],
  }

  # --------------------------------------------------------------------------#
  # Configure Non-Default VRF IPv6 Neighbor Address Family IPv4 Unicast       #
  #  Requires: cisco_bgp_neighbor (IPv6 Neighbor)                             #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_v6_neighbor_afv4_nondefault':
  command   => "
    router bgp 55
      vrf nondefault
        neighbor 2040::1 
          address-family ipv4 unicast
            allowas-in
            no disable-peer-as-check
            no route-reflector-client
            weight 40
            maximum-prefix 3 90 restart 4",
    require => Cisco_command_config['cisco_bgp_neighbor'],
  }

  # --------------------------------------------------------------------------#
  # Configure IPv6 Neighbor Address Family IPv6 Unicast                       #
  #  Requires: cisco_bgp_neighbor (IPv6 Neighbor)                             #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_v6_neighbor_afv6':
  command   => "
    router bgp 55
      neighbor 2040::1 
        address-family ipv6 unicast
          allowas-in
          no disable-peer-as-check
          no route-reflector-client
          weight 40
          maximum-prefix 3 90 restart 4
          next-hop-self",
    require => Cisco_command_config['cisco_bgp_neighbor'],
  }

  # --------------------------------------------------------------------------#
  # Configure Non-Default VRF IPv6 Neighbor Address Family IPv6 Unicast       #
  #  Requires: cisco_bgp_neighbor (IPv6 Neighbor)                             #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'cisco_bgp_v6_neighbor_afv6_nondefault':
  command   => "
    router bgp 55
      vrf nondefault
        neighbor 2040::1 
          address-family ipv6 unicast
            allowas-in
            no disable-peer-as-check
            no route-reflector-client
            weight 40
            maximum-prefix 3 90 restart 4
            next-hop-self",
    require => Cisco_command_config['cisco_bgp_neighbor'],
  }

  # --------------------------------------------------------------------------#
  # Enable BGP Feature                                                        #
  #  Before: cisco_bgp (Global BGP)                                           #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'bgp_enable':
    command => "
      feature bgp",
    before  => Cisco_command_config['cisco_bgp'],
  }

  # --------------------------------------------------------------------------#
  # Enable BFD Feature                                                        #
  #  Before: cisco_bgp_neighbor (IPv6 Neighbor)                               #
  # --------------------------------------------------------------------------#
  cisco_command_config { 'bfd_enable':
    command => "
      feature bfd",
    before  => Cisco_command_config['cisco_bgp_neighbor'],
  }
}

