# Manifest to demo cisco_interface provider
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

class ciscopuppet::demo_stp {

  $bd_designated_priority = platform_get() ? {
    'n7k' => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    default => undef
  }

  $bd_forward_time = platform_get() ? {
    'n7k' => [['2-42', '26'], ['83-92,1000-2300', '20']],
    default => undef
  }

  $bd_hello_time = platform_get() ? {
    'n7k' => [['2-42', '6'], ['83-92,1000-2300', '9']],
    default => undef
  }

  $bd_max_age = platform_get() ? {
    'n7k' => [['2-42', '26'], ['83-92,1000-2300', '20']],
    default => undef
  }

  $bd_priority = platform_get() ? {
    'n7k' => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    default => undef
  }

  $bd_root_priority = platform_get() ? {
    'n7k' => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    default => undef
  }

  $domain = platform_get() ? {
    /(n5k|n6k|n7k)/ => 100,
    default => undef
  }

  $fcoe = platform_get() ? {
    /(n3k|n9k)/ => false,
    default => undef
  }

  cisco_stp_global { 'default':
    bd_designated_priority   => $bd_designated_priority,
    bd_forward_time          => $bd_forward_time,
    bd_hello_time            => $bd_hello_time,
    bd_max_age               => $bd_max_age,
    bd_priority              => $bd_priority,
    bd_root_priority         => $bd_root_priority,
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
}
