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
}
