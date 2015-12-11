# Manifest to demo cisco_vxlan_global provider
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

class ciscopuppet::demo_vxlan_global {
  cisco_vxlan_global { 'default':
    ensure                                => present,
    dup_host_ip_addr_detection_host_moves => 7,
    dup_host_ip_addr_detection_timeout    => 170,
    anycast_gateway_mac                   => '1234.3456.5678',
    dup_host_mac_detection_host_moves     => 7,
    dup_host_mac_detection_timeout        => 170,
  }
}

