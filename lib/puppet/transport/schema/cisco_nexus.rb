require 'puppet/resource_api'
# Copyright (c) 2013-2019 Cisco and/or its affiliates.
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
Puppet::ResourceApi.register_transport(
  name:            'cisco_nexus',
  desc:            'This transport connects to a Cisco Nexus Switch.',
  connection_info: {
    host:        {
      type: 'Optional[String]',
      desc: 'The FQDN or IP address of the device to connect to.',
    },
    port:        {
      type: 'Optional[Integer]',
      desc: 'The port of the device to connect to.',
    },
    transport:   {
      type: 'Optional[Enum["http", "https"]]',
      desc: 'The type of transport protocol to use when connecting to the device. If not specified this will default to "http"',
    },
    verify_mode: {
      type: 'Optional[Enum["peer", "client-once", "fail-no-peer", "none"]]',
      desc: 'The type of OpenSSL client verification mode to use. Only applies if `transport` is `https`',
    },
    user:        {
      type: 'String',
      desc: 'The username to use for authenticating all connections to the device.',
    },
    password:    {
      type:      'String',
      desc:      'The password to use for authenticating all connections to the device.',
      sensitive: true,
    },
  },
)
