# Manifest to demo cisco_hsrp_global provider
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

class ciscopuppet::cisco::demo_hsrp {

  $bfd_all_intf = platform_get() ? {
    /(n5k|n6k|n7k|n8k|n9k)/ => true,
    default => undef
  }

  cisco_hsrp_global { 'default':
    bfd_all_intf  => $bfd_all_intf,
    extended_hold => 200,
  }

  if platform_get() =~ /n(3|9)k/ {
    cisco_interface { 'port-channel100':
      ensure             => 'present',
      hsrp_bfd           => true,
      hsrp_delay_minimum => 200,
      hsrp_delay_reload  => 300,
      hsrp_mac_refresh   => 400,
      hsrp_use_bia       => 'use_bia_intf',
      hsrp_version       => 2,
    }
  } else {
    warning('This platform does not support interface hsrp properties')
  }
}

