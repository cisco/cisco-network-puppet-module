# Manifest to demo cisco_interface provider
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

class ciscopuppet::cisco::demo_stp_vlan {

  $domain = platform_get() ? {
    /(n5k|n6k|n7k)/ => 100,
    default => undef
  }

  $fcoe = platform_get() ? {
    'n9k' => false,
    default => undef
  }

  $sys_bd_all_cmd = platform_get() ? {
    'n7k'  => 'system bridge-domain all',
    default => undef
  }

  $sys_bd_none_cmd = platform_get() ? {
    'n7k'  => 'system bridge-domain none',
    default => undef
  }

  cisco_command_config { 'system-bd-all':
    command => $sys_bd_all_cmd,
  }

  cisco_command_config { 'system-bd-none':
    command => $sys_bd_none_cmd,
  }

  cisco_stp_global { 'default':
    bpdufilter               => true,
    bpduguard                => true,
    bridge_assurance         => false,
    domain                   => $domain,
    fcoe                     => $fcoe,
    loopguard                => true,
    mode                     => 'mst',
    mst_designated_priority  => [['2-42', '40960'], ['83-92,100-230', '53248']],
    mst_forward_time         => 25,
    mst_hello_time           => 5,
    mst_inst_vlan_map        => [['2', '6-47'], ['92', '120-400']],
    mst_max_age              => 35,
    mst_max_hops             => 200,
    mst_name                 => 'nexus',
    mst_priority             => [['2-42', '40960'], ['83-92,100-230', '53248']],
    mst_revision             => 34,
    mst_root_priority        => [['2-42', '40960'], ['83-92,100-230', '53248']],
    pathcost                 => 'long',
    vlan_designated_priority => [['1-42', '40960'], ['83-92,100-230', '53248']],
    vlan_forward_time        => [['1-42', '19'], ['83-92,100-230', '13']],
    vlan_hello_time          => [['1-42', '10'], ['83-92,100-230', '6']],
    vlan_max_age             => [['1-42', '21'], ['83-92,100-230', '13']],
    vlan_priority            => [['1-42', '40960'], ['83-92,100-230', '53248']],
    vlan_root_priority       => [['1-42', '40960'], ['83-92,100-230', '53248']],
  }

  cisco_interface { 'Ethernet1/4':
    switchport_mode        => trunk,
    stp_bpdufilter         => 'enable',
    stp_bpduguard          => 'enable',
    stp_cost               => 2000,
    stp_guard              => 'loop',
    stp_link_type          => 'shared',
    stp_port_priority      => 64,
    stp_port_type          => 'network',
    stp_mst_cost           => [['0,2-4,6,8-12', '1000'], ['1000', '2568']],
    stp_mst_port_priority  => [['0,2-11,20-33', '64'], ['1111', '160']],
    stp_vlan_cost          => [['1-4,6,8-12', '1000'], ['1000', '2568']],
    stp_vlan_port_priority => [['1-11,20-33', '64'], ['1111', '160']],
  }
}
