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

class ciscopuppet::cisco::demo_itd {

  $non_icmp_type = platform_get() ? {
    'n7k'  => 'present',
    default => 'absent'
  }

  $probe_control = platform_get() ? {
    'n7k'  => true,
    default => undef
  }

  $probe_dns_host = platform_get() ? {
    'n7k'  => '8.8.8.8',
    default => undef
  }

  $probe_port = platform_get() ? {
    'n7k'  => 6666,
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
    ensure           => $non_icmp_type,
    probe_dns_host   => $probe_dns_host,
    probe_frequency  => 1800,
    probe_retry_down => 4,
    probe_retry_up   => 4,
    probe_timeout    => 1200,
    probe_type       => 'dns',
  }

  cisco_itd_device_group {'tcpGroup':
    ensure           => $non_icmp_type,
    probe_control    => $probe_control,
    probe_frequency  => 1600,
    probe_port       => $probe_port,
    probe_retry_down => 4,
    probe_retry_up   => 4,
    probe_timeout    => 1200,
    probe_type       => 'tcp',
  }

  cisco_itd_device_group {'udpGroup':
    ensure           => $non_icmp_type,
    probe_control    => $probe_control,
    probe_frequency  => 1600,
    probe_port       => $probe_port,
    probe_retry_down => 4,
    probe_retry_up   => 4,
    probe_timeout    => 1200,
    probe_type       => 'udp',
  }

  cisco_itd_device_group_node {'icmpGroup 1.1.1.1':
    ensure           => 'present',
    hot_standby      => false,
    node_type        => 'ip',
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
    node_type        => 'ip',
    probe_control    => $probe_control,
    probe_frequency  => 1800,
    probe_port       => $probe_port,
    probe_retry_down => 4,
    probe_retry_up   => 4,
    probe_timeout    => 1200,
    probe_type       => 'udp',
    weight           => 1,
  }
}
