# Manifest to demo cisco_aaa* providers
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

class ciscopuppet::cisco::demo_aaa {
  cisco_tacacs_server { 'default':
    ensure              => present,
    encryption_type     => clear,
    encryption_password => 'testing123',
    source_interface    => 'mgmt0',
  }
  cisco_tacacs_server_host { '1.1.1.1':
    ensure              => present,
    encryption_type     => 'encrypted',
    encryption_password => 'testing123',
    require             => Cisco_tacacs_server['default'],
  }
  cisco_aaa_group_tacacs { 'group1':
    ensure           => present,
    deadtime         => '30',
    server_hosts     => ['1.1.1.1'],
    source_interface => 'mgmt0',
    vrf_name         => 'management',
    require          => Cisco_tacacs_server_host['1.1.1.1']
  }
  cisco_aaa_authentication_login { 'default':
    ascii_authentication => 'true',
    chap                 => 'false',
    error_display        => 'true',
    mschap               => 'false',
    mschapv2             => 'false',
  }
  cisco_aaa_authorization_login_cfg_svc { 'default':
    ensure => 'present',
    groups => ["group1"],
    method => 'local',
  }
  cisco_aaa_authorization_login_exec_svc { 'default':
    ensure => 'present',
    groups => ["group1"],
    method => 'local',
  }
}
