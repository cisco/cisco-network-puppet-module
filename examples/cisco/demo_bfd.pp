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
    /(n3k|n7k|n8k|n9k)/ => 300,
    default => undef
  }

  $fabricpath_interval = platform_get() ? {
    /(n5k|n6k|n7k)/ => 750,
    default => undef
  }

  $fabricpath_min_rx = platform_get() ? {
    /(n5k|n6k|n7k)/ => 350,
    default => undef
  }

  $fabricpath_multiplier = platform_get() ? {
    /(n5k|n6k|n7k)/ => 45,
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

  # To be removed later
  $interval = platform_get() ? {
    /(n3k|n5k|n6k|n7k)/ => 100,
    default => undef
  }

  $ipv4_echo_rx_interval = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 100,
    default => undef
  }

  $ipv4_interval = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 200,
    default => undef
  }

  $ipv4_min_rx = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 200,
    default => undef
  }

  $ipv4_multiplier = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 50,
    default => undef
  }

  $ipv4_slow_timer = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 10000,
    default => undef
  }

  $ipv6_echo_rx_interval = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 200,
    default => undef
  }

  $ipv6_interval = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 500,
    default => undef
  }

  $ipv6_min_rx = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 500,
    default => undef
  }

  $ipv6_multiplier = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 30,
    default => undef
  }

  $ipv6_slow_timer = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/ => 25000,
    default => undef
  }

  # To be removed later
  $min_rx = platform_get() ? {
    /(n3k|n5k|n6k|n7k)/ => 100,
    default => undef
  }

  # To be removed later
  $multiplier = platform_get() ? {
    /(n3k|n5k|n6k|n7k)/ => 25,
    default => undef
  }

  $startup_timer = platform_get() ? {
    /(n3k|n8k|n9k)/ => 25,
    default => undef
  }

  cisco_bfd_global { 'default':
    echo_interface        => 10,
    echo_rx_interval      => $echo_rx_interval,
    fabricpath_interval   => $fabricpath_interval,
    fabricpath_min_rx     => $fabricpath_min_rx,
    fabricpath_multiplier => $fabricpath_multiplier,
    fabricpath_slow_timer => $fabricpath_slow_timer,
    fabricpath_vlan       => $fabricpath_vlan,
    interval              => $interval,
    ipv4_echo_rx_interval => $ipv4_echo_rx_interval,
    ipv4_interval         => $ipv4_interval,
    ipv4_min_rx           => $ipv4_min_rx,
    ipv4_multiplier       => $ipv4_multiplier,
    ipv4_slow_timer       => $ipv4_slow_timer,
    ipv6_echo_rx_interval => $ipv6_echo_rx_interval,
    ipv6_interval         => $ipv6_interval,
    ipv6_min_rx           => $ipv6_min_rx,
    ipv6_multiplier       => $ipv6_multiplier,
    ipv6_slow_timer       => $ipv6_slow_timer,
    min_rx                => $min_rx,
    multiplier            => $multiplier,
    slow_timer            => 5000,
    startup_timer         => $startup_timer,
  }
}
