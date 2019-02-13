# Manifest to demo evpn_multisite providers
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

class ciscopuppet::cisco::demo_evpn_multisite {

  if platform_get() =~ /n9k-ex/ {

    cisco_evpn_multisite { '150':
      ensure        => present,
      delay_restore => 50,
    }

    cisco_evpn_stormcontrol { 'unicast':
      ensure => present,
      level  => 50,
    }

    cisco_interface_evpn_multisite { 'Ethernet1/1':
      ensure   => present,
      tracking => 'dci-tracking',
    }

  } else {
    notify{'SKIP: This platform does not support cisco_evpn_multisite': }
  }
}
