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

class ciscopuppet::netdev::demo_radius {

  $accounting_only = $operatingsystem ? {
    'nexus' => true,
    default => undef
  }

  $authentication_only = $operatingsystem ? {
    'nexus' => true,
    default => undef
  }

  radius { 'default':
    enable => true,
  }

  radius_global { 'default':
    key              => '44444444',
    key_format       => '7',
    retransmit_count => '3',
    timeout          => '1',
  }

  radius_server { '8.8.8.8':
    ensure              => 'present',
    accounting_only     => $accounting_only,
    acct_port           => '66',
    auth_port           => '77',
    authentication_only => $authentication_only,
    key                 => '44444444',
    key_format          => '7',
    retransmit_count    => '4',
    timeout             => '2',
  }

}
