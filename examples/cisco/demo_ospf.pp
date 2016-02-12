# Manifest to demo cisco_*ospf* providers
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

class ciscopuppet::cisco::demo_ospf {
  cisco_ospf { 'Sample':
    ensure => present,
  }

  # Pre-clean interface, set to L3
  cisco_interface { 'Ethernet1/4':
    switchport_mode                => 'disabled',
  }

  $md_password = '046E1803362E595C260E0B240619050A2D'
  cisco_interface_ospf { 'Ethernet1/4 Sample':
    ensure                         => present,
    area                           => 200,
    cost                           => '200',
    hello_interval                 => 'default',
    dead_interval                  => '200',
    message_digest                 => true,
    message_digest_key_id          => 30,
    message_digest_algorithm_type  => md5,
    message_digest_encryption_type => cisco_type_7,
    message_digest_password        => $md_password,
    passive_interface              => true,
  }

  cisco_ospf_vrf { 'dark_blue default':
    ensure                   => 'present',
    auto_cost                => '45000',
    default_metric           => '5',
    log_adjacency            => 'detail',
    timer_throttle_lsa_hold  => '5500',
    timer_throttle_lsa_max   => '5600',
    timer_throttle_lsa_start => '5',
    timer_throttle_spf_hold  => '1500',
    timer_throttle_spf_max   => '5500',
    timer_throttle_spf_start => '250',
  }

  cisco_ospf_vrf { 'dark_blue vrf1':
    ensure                   => 'present',
    auto_cost                => '46000',
    default_metric           => '10',
    log_adjacency            => 'log',
    timer_throttle_lsa_hold  => '5600',
    timer_throttle_lsa_max   => '5800',
    timer_throttle_lsa_start => '8',
    timer_throttle_spf_hold  => '1700',
    timer_throttle_spf_max   => '5700',
    timer_throttle_spf_start => '277',
  }
}
