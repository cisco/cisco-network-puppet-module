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
# Radius Server Utility Library:
# ---------------------
# radius_serverlib.rb
#
# This is the utility library for the Radius Server provider Beaker test cases
# that contains the common methods used across the Radius Server testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Radius Server test case that runs an instance of Beaker::TestCase
# requires RadiusSettingLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for radius_server Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing radius_server resource
module RadiusServerLib
  # Group of Constants used in negative tests for radius_server provider.
  ENSURE_NEGATIVE = 'unknown'

  # A. Methods to create manifests for radius_server Puppet provider test cases.

  # Method to create a manifest for radius_server resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_radius_server_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  radius_server { '8.8.8.8':
    ensure              => 'present',
    accounting_only     => 'true',
    acct_port           => '66',
    auth_port           => '77',
    authentication_only => 'true',
    key                 => '44444444',
    key_format          => '7',
    retransmit_count    => '4',
    timeout             => '2',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for radius_server resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_radius_server_manifest_present_change
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  radius_server { '8.8.8.8':
    ensure              => 'present',
    accounting_only     => 'false',
    acct_port           => '44',
    auth_port           => '55',
    authentication_only => 'true',
    key                 => 'unset',
    retransmit_count    => '-1',
    timeout             => '-1',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for radius_server resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_radius_server_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    radius_server {'8.8.8.8':
      ensure => absent,
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for radius_server resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_radius_server_manifest_present_ipv6
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  radius_server { '2003::7':
    ensure              => 'present',
    accounting_only     => 'true',
    acct_port           => '66',
    auth_port           => '77',
    authentication_only => 'true',
    key                 => '44444444',
    key_format          => '7',
    retransmit_count    => '4',
    timeout             => '2',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for radius_server resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_radius_server_manifest_absent_ipv6
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    radius_server {'2003::7':
      ensure => absent,
    }
}
EOF"
    manifest_str
  end
end
