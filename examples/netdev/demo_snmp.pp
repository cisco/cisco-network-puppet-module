# Manifest to demo the netdev snmp* providers
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

class ciscopuppet::netdev::demo_snmp {

  # netdev network_snmp
  network_snmp {'default':
    enable   => true,
    location => 'UK',
    contact  => 'SysAdmin',
  }

  snmp_community { 'setcom':
    ensure => present,
    group  => 'network-admin',
    acl    => 'testcomacl',
  }

  snmp_user { 'test_snmp_user':
    ensure          => present,
    roles           => ['network-operator'],
    auth            => 'md5',
    password        => '0x7e5030ffd26d7e1b366a9041e9c63c94',
    privacy         => 'aes128',
    private_key     => '0xcc012f26b3384d4b3da979bff48b4ffe',
    localized_key   => true,
  }

  snmp_notification { 'vtp vlandelete':
    enable => 'true',
  }

  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/3',
    port             => '47',
    type             => 'traps',
    username         => 'jj',
    version          => 'v3',
    security         => 'priv',
  }
}
