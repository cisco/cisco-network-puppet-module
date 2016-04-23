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

class ciscopuppet::netdev::demo_interface {

  network_interface { 'ethernet1/9':
    description => 'default',
    # Removed because of too many differences between platforms and linecards
    # duplex      => 'auto',
    # speed       => '100m',
    # mtu         => '9000',
  }

}
