# Manifest to demo vrf providers
#
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

class ciscopuppet::cisco::demo_vrf {

  # Check for platform/linecard support
  $rd_support = prop_supported('route_distinguisher')
  $rt_support = prop_supported('route_target_import')
  $evpn_support = prop_supported('route_target_import_evpn')

  $rd_auto = $rd_support ? {
    true    => 'auto',
    default => undef
  }

  $rd_1_1 = $rd_support ? {
    true    => '1:1',
    default => undef
  }

  $rt_import = $rt_support ? {
    true    => ['2:3', '4:5'],
    default => undef
  }

  $rt_export = $rt_support ? {
    true    => ['6:7', '8:9'],
    default => undef
  }

  $rt_both = $rt_support ? {
    true    => false,
    default => undef
  }

  $rt_import_evpn = $evpn_support ? {
    true    => ['12:13', '14:15'],
    default => undef
  }

  $rt_export_evpn = $evpn_support ? {
    true    => ['16:17', '18:19'],
    default => undef
  }

  $rt_both_evpn = $evpn_support ? {
    true    => true,
    default => undef
  }

  $vni = platform_get('vni') ? {
    /n9k/   => 4096,
    default => undef
  }

  cisco_vrf { 'test_vrf':
    ensure              => present,
    description         => 'test vrf for puppet',
    route_distinguisher => $rd_auto,
    shutdown            => false,
    vni                 => $vni,
  }

  cisco_vrf { 'red':
    ensure              => present,
    route_distinguisher => $rd_1_1,
  }

  cisco_vrf_af { 'red ipv4 unicast':
    ensure                        => present,
    route_target_import           => $rt_import,
    route_target_export           => $rt_export,
    route_target_both_auto        => $rt_both,
    route_target_import_evpn      => $rt_import_evpn,
    route_target_export_evpn      => $rt_export_evpn,
    route_target_both_auto_evpn   => $rt_both_evpn,
  }
}
