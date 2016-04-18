# Manifest to demo cisco_interface_service_vni provider
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

class ciscopuppet::cisco::demo_interface_service_vni {

  if platform_get() =~ /n7k/ {
    $slot = find_linecard('N7K-F3')
    if $slot == '' {
      notify{'## SKIP: This provider demo requires an N7K-F3 linecard': }

    } else {
      $intf = "ethernet$slot/2"

      cisco_encapsulation {"vni_500_5000" :
        ensure          => present,
        dot1q_map       => ['500', '5000'],
      }
      cisco_interface_service_vni { "$intf 344" :
        encapsulation_profile_vni   => 'vni_500_5000',
        shutdown                    => true,
      }

      cisco_encapsulation {"vni_600_6000" :
        ensure          => present,
        dot1q_map       => ['600', '6000'],
      }
      cisco_interface_service_vni { "$intf 491" :
        encapsulation_profile_vni   => 'vni_600_6000',
        shutdown                    => 'default',
      }
    }
  } else {
     notify{'## SKIP: This platform does not support cisco_interface_service_vni': }
  }
}
