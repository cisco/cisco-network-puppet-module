# Manifest to demo cisco_itd_device_group,
# cisco_itd_device_group_node and
# cisco_itd_service providers
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

class ciscopuppet::cisco::demo_itd {

  if platform_get() =~ /n(7|9)k/ {
    $nat_destination = platform_get() ? {
      'n7k'   => true,
      default => undef
    }

    $peer_local1 = platform_get() ? {
      'n9k'   => 'pser1',
      default => undef
    }

    $peer_local2 = platform_get() ? {
      'n9k'   => 'pser2',
      default => undef
    }

    $peer_vdc1 = platform_get() ? {
      'n7k'   => ['vdc1', 'pser1'],
      default => undef
    }

    $peer_vdc2 = platform_get() ? {
      'n7k'   => ['vdc2', 'pser2'],
      default => undef
    }

    cisco_itd_device_group {'icmpGroup':
      ensure           => 'present',
      probe_frequency  => 1800,
      probe_retry_down => 4,
      probe_retry_up   => 4,
      probe_timeout    => 1200,
      probe_type       => 'icmp',
    }

    cisco_itd_device_group {'dnsgroup':
      ensure           => 'present',
      probe_dns_host   => '8.8.8.8',
      probe_frequency  => 1800,
      probe_retry_down => 4,
      probe_retry_up   => 4,
      probe_timeout    => 1200,
      probe_type       => 'dns',
    }

    cisco_itd_device_group {'tcpGroup':
      ensure           => 'present',
      probe_control    => true,
      probe_frequency  => 1600,
      probe_port       => 6666,
      probe_retry_down => 4,
      probe_retry_up   => 4,
      probe_timeout    => 1200,
      probe_type       => 'tcp',
    }

    cisco_itd_device_group {'udpGroup':
      ensure           => 'present',
      probe_control    => true,
      probe_frequency  => 1600,
      probe_port       => 6666,
      probe_retry_down => 4,
      probe_retry_up   => 4,
      probe_timeout    => 1200,
      probe_type       => 'udp',
    }

    cisco_itd_device_group_node {'icmpGroup 2.2.2.2':
      ensure           => 'present',
      hot_standby      => false,
      node_type        => 'ip',
      probe_frequency  => 1600,
      probe_retry_down => 2,
      probe_retry_up   => 2,
      probe_timeout    => 1100,
      probe_type       => 'icmp',
      weight           => 20,
    }
    cisco_itd_device_group_node {'icmpGroup 1.1.1.1':
      ensure           => 'present',
      hot_standby      => false,
      probe_frequency  => 1800,
      probe_retry_down => 4,
      probe_retry_up   => 4,
      probe_timeout    => 1200,
      probe_type       => 'icmp',
      weight           => 200,
    }
    cisco_itd_device_group_node {'udpGroup 2.2.2.2':
      ensure           => 'present',
      hot_standby      => true,
      probe_control    => true,
      probe_frequency  => 1800,
      probe_port       => 6666,
      probe_retry_down => 4,
      probe_retry_up   => 4,
      probe_timeout    => 1200,
      probe_type       => 'udp',
      weight           => 1,
    }
    cisco_itd_device_group_node {'udpGroup 3.3.3.3':
      ensure           => 'present',
      hot_standby      => false,
      probe_control    => false,
      probe_frequency  => 10,
      probe_retry_down => 3,
      probe_retry_up   => 3,
      probe_timeout    => 5,
      probe_type       => default,
      weight           => 1,
    }

    cisco_acl { 'ipv4 ial':
      ensure => present
    }
  
    cisco_acl { 'ipv4 eal':
      ensure => present
    }

    cisco_interface { 'ethernet1/1':
      switchport_mode => 'disabled'
    }

    cisco_interface { 'ethernet1/2':
      switchport_mode => 'disabled'
    }

    cisco_vlan { '2':
      ensure => present
    }

    cisco_interface { 'vlan2':
      ensure => present,
    }

    cisco_interface { 'port-channel100':
      ensure          => present,
      switchport_mode => 'disabled'
    }

    $ingress_interface = [['vlan 2', '4.4.4.4'],
    ['ethernet 1/1', '6.6.6.6'], ['port-channel 100', '7.7.7.7']]
  
    $virtual_ip = ['ip 3.3.3.3 255.0.0.0 tcp 500 advertise enable']

    cisco_itd_service {'myservice1':
      ensure                        => 'present',
      device_group                  => 'udpGroup',
      exclude_access_list           => 'eal',
      fail_action                   => false,
      ingress_interface             => $ingress_interface,
      load_bal_enable               => true,
      load_bal_buckets              => 8,
      load_bal_mask_pos             => 4,
      load_bal_method_bundle_hash   => 'ip-l4port',
      load_bal_method_bundle_select => 'src',
      load_bal_method_end_port      => 202,
      load_bal_method_proto         => 'udp',
      load_bal_method_start_port    => 101,
      nat_destination               => $nat_destination,
      peer_vdc                      => $peer_vdc1,
      peer_local                    => $peer_local1,
      shutdown                      => true,
      virtual_ip                    => $virtual_ip,
    }

    cisco_itd_service {'myservice2':
      ensure                        => 'present',
      device_group                  => 'udpGroup',
      ingress_interface             => [['ethernet 1/2', '22.2.2.2']],
      load_bal_enable               => true,
      load_bal_buckets              => 16,
      load_bal_mask_pos             => 10,
      load_bal_method_bundle_hash   => 'ip',
      load_bal_method_bundle_select => 'dst',
      peer_vdc                      => $peer_vdc2,
      peer_local                    => $peer_local2,
      shutdown                      => false,
    }
  }
  else {
    notify{'SKIP: This platform does not support cisco_itd_service': }
  }
}
