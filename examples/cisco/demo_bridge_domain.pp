# Manifest to demo cisco_bridge_domain provider
#
# Copyright (c) 2016 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class ciscopuppet::cisco::demo_bridge_domain {
  cisco_bridge_domain {"100" :
    ensure          => present,
    bd_name         => 'demo_test',
    shutdown        => true,
    fabric_control  => false
  }

  cisco_bridge_domain_vni {"100-104,200-210" :
    ensure      => present,
    member_vni  => '5100-5102,7103-7104,10000-10010'
  }
}
