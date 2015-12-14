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
# Snmp User Utility Library:
# ---------------------
# snmp_userlib.rb
#
# This is the utility library for the Snmp User provider Beaker test cases
# that contains the common methods used across the Snmp User testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Snmp User test case that runs an instance of Beaker::TestCase
# requires RadiusSettingLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for snmp_user Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing snmp_user resource
module SnmpUserLib
  # Group of Constants used in negative tests for snmp_user provider.
  ENSURE_NEGATIVE = 'unknown'

  # A. Methods to create manifests for snmp_user Puppet provider test cases.

  # Method to create a manifest for snmp_user resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_user_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_user { 'test_snmp_user':
    ensure          => present,
    roles           => ['network-operator'],
    auth            => 'md5',
    password        => '0x7e5030ffd26d7e1b366a9041e9c63c94',
    privacy         => 'aes128',
    private_key     => '0xcc012f26b3384d4b3da979bff48b4ffe',
    localized_key   => true,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_user resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_user_manifest_present_change
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_user { 'test_snmp_user':
    ensure          => present,
    auth            => 'sha',
    password        => '0x7e5030ffd26d7e1b366a9041e9c63c94',
    privacy         => 'des',
    private_key     => '0xcc012f26b3384d4b3da979bff48b4ffe',
    localized_key   => true,
    engine_id       => '128:0:0:9:3:8:0:39:34:152:217',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_user resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_user_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    snmp_user { 'test_snmp_user':
     ensure          => absent,
  }
}
EOF"
    manifest_str
  end
end
