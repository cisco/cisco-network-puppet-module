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
    bfd                            => true,
    cost                           => '200',
    hello_interval                 => 'default',
    dead_interval                  => '200',
    message_digest                 => true,
    message_digest_key_id          => 30,
    message_digest_algorithm_type  => md5,
    message_digest_encryption_type => cisco_type_7,
    message_digest_password        => $md_password,
    mtu_ignore                     => true,
    network_type                   => 'p2p',
    passive_interface              => true,
    priority                       => 100,
    shutdown                       => true,
    transmit_delay                 => 300,
  }

  cisco_ospf_vrf { 'dark_blue default':
    ensure                   => 'present',
    auto_cost                => '45000',
    bfd                      => true,
    default_metric           => '5',
    log_adjacency            => 'detail',
    redistribute             => [['eigrp 1', 'rtmap_eigrp_1'], ['direct',  'rtmap_direct']],
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
    bfd                      => true,
    default_metric           => '10',
    log_adjacency            => 'log',
    redistribute             => [['direct',  'rtmap_direct_2']],
    timer_throttle_lsa_hold  => '5600',
    timer_throttle_lsa_max   => '5800',
    timer_throttle_lsa_start => '8',
    timer_throttle_spf_hold  => '1700',
    timer_throttle_spf_max   => '5700',
    timer_throttle_spf_start => '277',
  }

  cisco_ospf_area { 'dark_blue default 1.1.1.1':
    ensure          => 'present',
    authentication  => 'md5',
    default_cost    => 1000,
    filter_list_in  => 'fin',
    filter_list_out => 'fout',
    range           => [['10.3.0.0/16', 'not_advertise', '23'], ['10.3.3.0/24', '450']],
    stub            => true,
    stub_no_summary => true,
  }

  cisco_ospf_area { 'dark_blue vrf1 1450':
    ensure          => 'present',
    authentication  => 'cleartext',
    default_cost    => 5555,
    filter_list_in  => 'fin',
    filter_list_out => 'fout',
    range           => [['10.3.0.0/16', '4989'], ['10.3.1.1/32']],
    stub            => true,
    stub_no_summary => false,
  }

  cisco_ospf_area { 'dark_blue vrf2 5000':
    ensure                 => 'present',
    nssa                   => true,
    nssa_default_originate => true,
    nssa_no_redistribution => true,
    nssa_no_summary        => true,
    nssa_route_map         => 'aaa',
    nssa_translate_type7   => 'supress_fa',
  }

  $auth_password = '3109a60f51374a0d'
  cisco_ospf_area_vlink { 'dark_blue vrf2 12345 1.1.1.1':
    ensure                             => 'present',
    auth_key_chain                     => 'myKeyChain',
    authentication                     => md5,
    authentication_key_encryption_type => '3des',
    authentication_key_password        => $auth_password,
    dead_interval                      => 500,
    hello_interval                     => 2000,
    message_digest_algorithm_type      => md5,
    message_digest_encryption_type     => cisco_type_7,
    message_digest_key_id              => 39,
    message_digest_password            => $md_password,
    retransmit_interval                => 10000,
    transmit_delay                     => 400,
  }
}
