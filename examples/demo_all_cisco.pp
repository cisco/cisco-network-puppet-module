# Manifest to demo all cisco providers
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

class ciscopuppet::demo_all_cisco {

  include ciscopuppet::install

  # If a custom gem repo and/or proxy is needed, the installer
  # can be configured as follows:
  #
  # class {'ciscopuppet::install':
  #   repo  => 'http://gemserver.domain.com:8808',
  #   proxy => 'http://proxy.domain.com:8080',
  # }

  include ciscopuppet::cisco::demo_aaa
  include ciscopuppet::cisco::demo_acl
  include ciscopuppet::cisco::demo_bgp
  include ciscopuppet::cisco::demo_command_config
  include ciscopuppet::cisco::demo_evpn
  include ciscopuppet::cisco::demo_fabricpath
  include ciscopuppet::cisco::demo_interface
  #include ciscopuppet::cisco::demo_interface_service_vni
  include ciscopuppet::cisco::demo_itd
  include ciscopuppet::cisco::demo_ospf
  include ciscopuppet::cisco::demo_patching
  include ciscopuppet::cisco::demo_pim
  include ciscopuppet::cisco::demo_portchannel
  include ciscopuppet::cisco::demo_snmp
  #stp_bd and stp_vlan are exclusive, so comment one of them
  #include ciscopuppet::cisco::demo_stp_bd
  include ciscopuppet::cisco::demo_stp_vlan
  include ciscopuppet::cisco::demo_tacacs_server
  include ciscopuppet::cisco::demo_tacacs_server_host
  include ciscopuppet::cisco::demo_vlan
  include ciscopuppet::cisco::demo_vpc_domain
  include ciscopuppet::cisco::demo_vrf
  include ciscopuppet::cisco::demo_vtp
  include ciscopuppet::cisco::demo_bridge_domain
  include ciscopuppet::cisco::demo_encapsulation
  include ciscopuppet::cisco::demo_vxlan
}
