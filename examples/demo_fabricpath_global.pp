# Manifest to demo cisco_fabricpath_global provider
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

class ciscopuppet::demo_fabricpath_global {
  cisco_fabricpath_global { 'default':
    ensure                         => present,
    allocate_delay                 => '30',
    graceful_merge                 => 'enable',
    linkup_delay                   => '20',
    loadbalance_unicast_layer      => 'layer4',
    loadbalance_unicast_has_vlan   => 'true',
    mode                           => 'transit',
    switch_id                      => '100',
    transition_delay               => '25',
  }
}
