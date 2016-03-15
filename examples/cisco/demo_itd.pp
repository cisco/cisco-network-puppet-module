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
}
