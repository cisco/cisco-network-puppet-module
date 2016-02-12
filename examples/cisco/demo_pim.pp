# Manifest to demo radius providers
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

class ciscopuppet::cisco::demo_pim {

    cisco_pim { 'ipv4' :
      ensure         => present,
      vrf            => 'default',
      ssm_range      => '224.0.0.0/8 225.0.0.0/8'
    }

    cisco_pim_rp_address { 'ipv4' :
      ensure          => present,
      vrf             => 'default',
      rp_addr         => '1.1.1.1'
    }

    cisco_pim_grouplist { 'ipv4' :
      ensure          => present,
      vrf             => 'default',
      rp_addr         => '11.11.11.11',
      group           => '224.0.0.0/8',
    }

}
