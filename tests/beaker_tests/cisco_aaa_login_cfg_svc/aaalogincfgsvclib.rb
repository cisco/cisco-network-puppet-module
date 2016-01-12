###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Method to create a manifest for aaalogincfgsvc with attributes:
# @param name [String] Name of the bgp neighbor.
# @param tests [Hash] a hash that contains the supported attributes
# @result none [None] Returns no object.
def create_aaalogincfgsvc_manifest_simple(tests, name)
  # config service needs proper supporting configuration, else the
  # configuration CLI will be locked
  tests[name][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node default {
    cisco_aaa_authorization_login_cfg_svc { '#{name}':
#{prop_hash_to_manifest(tests[name][:manifest_props])}
    }
    cisco_tacacs_server { 'default':
      ensure => present,
    }
  }
EOF"
end

# Method to create a manifest for aaalogincfgsvc with attributes AND
# all supporting configuration to allow group configuration
# @param name [String] Name of the bgp neighbor.
# @param tests [Hash] a hash that contains the supported attributes
# @result none [None] Returns no object.
def create_aaalogincfgsvc_manifest_full(tests, name)
  # config service needs proper supporting configuration, else the
  # configuration CLI will be locked
  tests[name][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node default {
    cisco_aaa_authorization_login_cfg_svc { '#{name}':
#{prop_hash_to_manifest(tests[name][:manifest_props])}
    }
    cisco_tacacs_server { 'default':
      ensure => present,
      encryption_type     => clear,
      encryption_password => 'testing123',
      source_interface    => 'mgmt0',
    }
    cisco_tacacs_server_host { '1.1.1.1':
      encryption_type     => 'encrypted',
      encryption_password => 'testing123',
      require             => Cisco_tacacs_server['default'],
    }
    cisco_aaa_authentication_login { 'default':
      ascii_authentication => true,
    }
    cisco_aaa_group_tacacs { 'group1':
      ensure           => present,
      vrf_name         => 'management',
      source_interface => 'mgmt0',
      server_hosts     => ['1.1.1.1'],
      require          => Cisco_tacacs_server_host['1.1.1.1'],
    }
  }
EOF"
end
