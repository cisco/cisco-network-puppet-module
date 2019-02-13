# Manifest to demo TRM providers
#
# Copyright (c) 2018 Cisco and/or its affiliates.
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

class ciscopuppet::cisco::demo_trm {

  if platform_get() =~ /n9k(-ex)?$/ {

    if image_supports_trm() {

      $mvpn_support = prop_supported('route_target_import_mvpn')

      $rt_both_mvpn = $mvpn_support ? {
        true    => true,
        default => undef
      }

      $rt_import_mvpn = $mvpn_support ? {
        true    => ['12:13', '14:15'],
        default => undef
      }

      $rt_export_mvpn = $mvpn_support ? {
        true    => ['16:17', '18:19'],
        default => undef
      }

      cisco_evpn_multicast { 'default':
        ensure          => present,
      }

      cisco_vrf_af { 'red ipv4 unicast':
        ensure                      => present,
        route_policy_export         => 'abc',
        route_policy_import         => 'abc',
        route_target_import_mvpn    => $rt_import_mvpn,
        route_target_export_mvpn    => $rt_export_mvpn,
        route_target_both_auto_mvpn => $rt_both_mvpn,
      }

      cisco_ip_multicast { 'default':
        ensure                 =>                 present,
        overlay_distributed_dr => true,
        overlay_spt_only       =>       true,
      }
    } else {
      notify{'SKIP: This image does not support TRM': }
    }
  } else {
    notify{'SKIP: This platform does not support TRM': }
  }
}
