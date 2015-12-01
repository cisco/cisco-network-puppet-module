# Manifest to demo cisco_aaa* providers
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

class ciscopuppet::demo_aaa {
    cisco_tacacs_server_host { 'testhost':
      ensure                 => present,
  }
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      deadtime               => '30',
      server_hosts           => ['testhost'],
      source_interface       => 'Ethernet1/1',
      vrf_name               => 'blue',
      require                => Cisco_tacacs_server_host['testhost']
  }
    cisco_aaa_authentication_login { 'default':
      ascii_authentication => 'true',
      chap                 => 'false',
      error_display        => 'true',
      mschap               => 'false',
      mschapv2             => 'false',
  }
}
