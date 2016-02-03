# Manifest to demo all netdev providers
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

class ciscopuppet::demo_all_netdev {

  include ciscopuppet::install

  # If a custom gem repo and/or proxy is needed, the installer
  # can be configured as follows:
  #
  # class {'ciscopuppet::install':
  #   repo  => 'http://gemserver.domain.com:8808',
  #   proxy => 'http://proxy.domain.com:8080',
  # }

  include ciscopuppet::netdev::demo_domain
  include ciscopuppet::netdev::demo_interface
  include ciscopuppet::netdev::demo_port_channel
  include ciscopuppet::netdev::demo_network_trunk
  include ciscopuppet::netdev::demo_ntp
  include ciscopuppet::netdev::demo_radius
  include ciscopuppet::netdev::demo_snmp
  include ciscopuppet::netdev::demo_syslog
  include ciscopuppet::netdev::demo_tacacs
}
