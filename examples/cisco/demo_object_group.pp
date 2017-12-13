# Manifest to demo cisco_acl providers
#
# Copyright (c) 2017 Cisco and/or its affiliates.
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

class ciscopuppet::cisco::demo_object_group {

  cisco_object_group { 'ipv4 address my_addr1':
    ensure                 => 'present',
  }

  cisco_object_group_entry { 'ipv4 address my_addr1 10':
    ensure  => 'present',
    address => '1.2.3.4 2.3.4.5',
  }

  cisco_object_group_entry { 'ipv4 address my_addr1 20':
    ensure  => 'present',
    address => '3.3.3.3/24',
  }

  cisco_object_group_entry { 'ipv4 address my_addr1 30':
    ensure  => 'present',
    address => 'host 4.4.4.4',
  }

  cisco_object_group { 'ipv6 address my_addr2':
    ensure                 => 'present'
  }

  cisco_object_group_entry { 'ipv6 address my_addr2 20':
    ensure  => 'present',
    address => '2000::1/64',
  }

  cisco_object_group_entry { 'ipv6 address my_addr2 30':
    ensure  => 'present',
    address => 'host 2001::10',
  }

  cisco_object_group { 'ipv4 port my_port':
    ensure                 => 'present'
  }

  cisco_object_group_entry { 'ipv4 port my_port 20':
    ensure => 'present',
    port   => 'range 100 200',
  }

  cisco_object_group_entry { 'ipv4 port my_port 30':
    ensure => 'present',
    port   => 'neq 154',
  }
}
