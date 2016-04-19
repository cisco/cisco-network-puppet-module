# Manifest to demo evpn providers
#
# Copyright (c) 2016 Cisco and/or its affiliates.
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

class ciscopuppet::cisco::demo_evpn {

  if platform_get() =~ /n(5|6|7|8|9)k/ {

    cisco_evpn_vni { '4096':
      ensure                        => present,
      route_distinguisher           => '1:1',
      route_target_import           => ['10.0.0.1:1', '10:1'],
      route_target_export           => ['10.0.0.2:2', '10:2'],
      route_target_both             => ['10.0.0.3:3', '10:3']
    }

  } else {
    notify{'SKIP: This platform does not support cisco_evpn_vni': }
  }
}
