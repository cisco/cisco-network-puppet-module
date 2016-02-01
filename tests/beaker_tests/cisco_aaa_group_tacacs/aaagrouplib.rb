###############################################################################
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# AAAGROUP Utility Library:
# -------------------------
# aaagrouplib.rb
#
# This is the utility library for the AAAGROUP provider Beaker test cases that
# contains the common methods used across the AAAGROUP testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker AAAGROUP test case that runs an instance of Beaker::TestCase
# requires AaaGroupLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_aaa_group Puppet provider test cases.
module AaaGroupLib
  # Group of Constants used in negative tests for AAAGROUP provider.
  DEADTIME_NEGATIVE         = ''
  VRF_NAME_NEGATIVE         = ''
  SOURCE_INTERFACE_NEGATIVE = ''
  SERVER_HOSTS_NEGATIVE     = ''

  # A. Methods to create manifests for cisco_aaa_group Puppet provider test cases.

  # Method to create a manifest for AAAGROUP resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      deadtime               => 'default',
      vrf_name               => 'default',
      source_interface       => 'default',
      server_hosts           => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AAAGROUP resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_aaa_group_tacacs { 'test':
      ensure                 => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AAAGROUP resource attributes:
  # deadtime, vrf_name, source_interface, and server_hosts.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_tacacs_server { 'default':
      ensure                 => present,
  }
    cisco_tacacs_server_host { 'testhost':
      ensure                 => present,
  }
    cisco_tacacs_server_host { '1.1.1.1':
      ensure                 => present,
  }
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      deadtime               => '30',
      vrf_name               => 'blue',
      source_interface       => 'Ethernet1/1',
      server_hosts           => ['testhost', '1.1.1.1'],
      require                => Cisco_tacacs_server_host['testhost', '1.1.1.1'],
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AAAGROUP resource attribute 'deadtime'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_deadtime_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      deadtime               => #{AaaGroupLib::DEADTIME_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AAAGROUP resource attribute 'vrf_name'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_vrf_name_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      vrf_name               => #{AaaGroupLib::VRF_NAME_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AAAGROUP attribute 'source_interface'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_source_interface_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      source_interface       => #{AaaGroupLib::SOURCE_INTERFACE_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AAAGROUP attribute 'server_hosts'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_aaagroup_manifest_server_hosts_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_aaa_group_tacacs { 'test':
      ensure                 => present,
      server_hosts           => #{AaaGroupLib::SERVER_HOSTS_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
