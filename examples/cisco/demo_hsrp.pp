# Manifest to demo cisco_hsrp_global provider
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

class ciscopuppet::cisco::demo_hsrp {

  $bfd_all_intf = platform_get() ? {
    /(n5k|n6k|n7k|n9k)/ => true,
    default => undef
  }

  cisco_hsrp_global { 'default':
    bfd_all_intf  => $bfd_all_intf,
    extended_hold => 200,
  }

  $n7k_ath = platform_get() ? {
    'n7k' => $facts['cisco']['images']['system_image'] ? {
      /(8.0)/ => true,
      default => false
    },
    /(n3k|n9k)/ => true,
    default => false
  }

  if $n7k_ath {
    cisco_interface { 'port-channel100':
      ensure             => 'present',
      switchport_mode    => 'disabled',
      hsrp_bfd           => true,
      hsrp_delay_minimum => 200,
      hsrp_delay_reload  => 300,
      hsrp_mac_refresh   => 400,
      hsrp_use_bia       => 'use_bia_intf',
      hsrp_version       => 2,
    }

    cisco_interface { 'port-channel200':
      ensure             => 'present',
      switchport_mode    => 'disabled',
      hsrp_delay_minimum => 50,
      hsrp_delay_reload  => 100,
      hsrp_mac_refresh   => 300,
      hsrp_version       => 2,
    }

    cisco_command_config { 'ipv6-addr':
      command => "
        interface Po100
          ipv6 address 2000::01/64
      "
    }
    cisco_interface_hsrp_group { 'port-channel100 2 ipv6':
      ensure                        => 'present',
      authentication_auth_type      => 'md5',
      authentication_string         => '12345678901234567890',
      authentication_key_type       => 'key-string',
      authentication_enc_type       => 'encrypted',
      authentication_compatibility  => true,
      authentication_timeout        => 200,
      ipv6_vip                      => ['2000::11', '2000::22'],
      ipv6_autoconfig               => true,
      group_name                    => 'MyHsrp',
      preempt                       => true,
      preempt_delay_minimum         => '100',
      preempt_delay_reload          => '100',
      preempt_delay_sync            => '100',
      priority                      => '45',
      priority_forward_thresh_lower => '10',
      priority_forward_thresh_upper => '40',
      timers_hello_msec             => true,
      timers_hold_msec              => true,
      timers_hello                  => 300,
      timers_hold                   => 1000,
    }

    cisco_interface_hsrp_group { 'port-channel100 2 ipv4':
      ensure                   => 'present',
      authentication_auth_type => 'cleartext',
      authentication_string    => 'MyPass',
      ipv4_enable              => true,
      ipv4_vip                 => '2.2.2.2',
    }

    cisco_interface_hsrp_group { 'port-channel200 50 ipv4':
      ensure      => 'present',
      ipv4_enable => true,
      mac_addr    => '00:00:11:11:22:22',
    }
  } else {
    warning('This platform does not support interface hsrp properties')
  }
}

