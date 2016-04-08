# Manifest to demo cisco_acl providers
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

class ciscopuppet::cisco::demo_acl {

  $fragments = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/  => 'permit',
    default              => undef
  }

  cisco_acl { 'ipv4 my_ipv4_acl':
    ensure                 => 'present',
    stats_per_entry        => false,
    fragments              => $fragments
  }

  cisco_ace { 'ipv4 my_ipv4_acl 10':
    ensure                 => 'present',
    action                 => 'permit',
    proto                  => 'tcp',
    src_addr               => '1.2.3.4 2.3.4.5',
    src_port               => 'eq 40',
    dst_addr               => '8.9.0.4/32',
    dst_port               => 'range 32 56',
  }

  $http_method = platform_get() ? {
    /(n3k|n8k|n9k)/  => 'post',
    default          => undef
  }

  $packet_length = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/  => 'range 80 1000',
    default              => undef
  }

  $redirect = platform_get() ? {
    /(n3k|n8k|n9k)/  => 'Ethernet1/1,Ethernet1/2,port-channel1',
    default          => undef
  }

  $tcp_option_length = platform_get() ? {
    /(n3k|n8k|n9k)/  => '20',
    default          => undef
  }

  $time_range = platform_get() ? {
    /(n3k|n7k|n8k|n9k)/  => 'my_range',
    default              => undef
  }

  $ttl = platform_get() ? {
    /(n3k|n8k|n9k)/  => '153', 
    default          => undef
  }

  cisco_ace { 'ipv4 my_ipv4_acl 20':
    action                 => 'permit',
    proto                  => 'tcp',
    src_addr               => '1.2.3.4 2.3.4.5',
    src_port               => 'eq 40',
    dst_addr               => '8.9.0.4/32',
    dst_port               => 'range 32 56',
    tcp_flags              => 'ack syn fin',
    dscp                   => 'af11',
    established            => false,
    http_method            => $http_method,
    packet_length          => $packet_length,
    tcp_option_length      => $tcp_option_length,
    time_range             => $time_range,
    redirect               => $redirect,
    log                    => false,
    # TBD: ttl is currently broken on NX platforms
    #ttl                    => $ttl,
  }

  cisco_acl { 'ipv6 my_ipv6_acl':
    ensure                 => 'present'
  }

  cisco_ace { 'ipv6 my_ipv6_acl 85':
    ensure                 => 'present',
    action                 => 'permit',
    proto                  => 'tcp',
    src_addr               => 'any',
    dst_addr               => 'any',
  }

  cisco_ace { 'ipv6 my_ipv6_acl 89':
    remark                 => 'my ace remark',
  }
}
