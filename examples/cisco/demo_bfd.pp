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

class ciscopuppet::cisco::demo_bfd {

  $echo_rx_interval = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => 300,
    default => undef
  }

  $fabricpath_interval = platform_get() ? {
    /(n5k|n6k|n7k)/ => ['750', '350', '35'],
    default => undef
  }

  $fabricpath_slow_timer = platform_get() ? {
    /(n5k|n6k|n7k)/ => 15000,
    default => undef
  }

  $fabricpath_vlan = platform_get() ? {
    /(n5k|n6k|n7k)/ => 100,
    default => undef
  }

  # TBD: this is due to a bug on n9k-f and n9k
  $interval = platform_get() ? {
    /(n3k|n5k|n6k|n7k)/ => ['100', '100', '25'],
    default => undef
  }

  $ipv4_echo_rx_interval = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => 100,
    default => undef
  }

  $ipv4_interval = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => ['200', '200', '50'],
    default => undef
  }

  $ipv4_slow_timer = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => 10000,
    default => undef
  }

  $ipv6_echo_rx_interval = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => 200,
    default => undef
  }

  $ipv6_interval = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => ['500', '500', '30'],
    default => undef
  }

  $ipv6_slow_timer = platform_get() ? {
    /(n3k|n7k|n3k-f|n9k-f|n9k)/ => 25000,
    default => undef
  }

  $startup_timer = platform_get() ? {
    /(n3k|n3k-f|n9k-f|n9k)/ => 25,
    default => undef
  }

  cisco_command_config { 'loopback':
    command => 'interface loopback10',
  }

  cisco_bfd_global { 'default':
    ensure                => 'present',
    echo_interface        => 'loopback10',
    echo_rx_interval      => $echo_rx_interval,
    fabricpath_interval   => $fabricpath_interval,
    fabricpath_slow_timer => $fabricpath_slow_timer,
    fabricpath_vlan       => $fabricpath_vlan,
    interval              => $interval,
    ipv4_echo_rx_interval => $ipv4_echo_rx_interval,
    ipv4_interval         => $ipv4_interval,
    ipv4_slow_timer       => $ipv4_slow_timer,
    ipv6_echo_rx_interval => $ipv6_echo_rx_interval,
    ipv6_interval         => $ipv6_interval,
    ipv6_slow_timer       => $ipv6_slow_timer,
    slow_timer            => 5000,
    startup_timer         => $startup_timer,
  }
}
