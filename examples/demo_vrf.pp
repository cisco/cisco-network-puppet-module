# Manifest to demo cisco_vrf provider
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

class ciscopuppet::demo_vrf {
  cisco_vrf { 'test_vrf':
    ensure              => present,
    description         => 'test vrf for puppet',
    # route_distinguisher is not supported on all platforms
    # route_distinguisher => 'auto',
    shutdown            => false,
    vrf                 => 4096,
  }

  cisco_vrf { 'red':
    ensure              => present,
    # route_distinguisher is not supported on all platforms
    # route_distinguisher => '1:1',
  }
  cisco_vrf_af { 'red ipv4 unicast':
    ensure                        => present,
    # route_target properties are not supported on all platforms
    # route_target_import           => ['55:33', '102:33'],
    # route_target_import_evpn      => ['55:33', '102:33'],
    # route_target_export           => ['1.2.3.4:55', '102:33'],
    # route_target_export_evpn      => ['1.2.3.4:55', '102:33'],
    # route_target_both_auto        => false,
    # route_target_both_auto_evpn   => true,
  }
}
