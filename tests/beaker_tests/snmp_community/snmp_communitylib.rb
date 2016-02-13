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
# Snmp Community Utility Library:
# ---------------------
# snmp_communitylib.rb
#
# This is the utility library for the Snmp Community provider Beaker test cases
# that contains the common methods used across the Snmp Community testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Snmp Community test case that runs an instance of Beaker::TestCase
# requires SnmpCommunityLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for snmp_community Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing snmp_community resource
module SnmpCommunityLib
  # A. Methods to create manifests for snmp_community Puppet provider test cases.

  # Method to create a manifest for snmp_community resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_community_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_community { 'red':
    ensure              => 'present',
    group               => 'network-admin',
    acl                 => 'my_acl'
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_community resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_community_manifest_present_change
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_community { 'red':
    ensure              => 'present',
    group               => 'network-admin',
    acl                 => 'my_acl2'
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_community resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_community_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    snmp_community {'red':
      ensure => absent,
    }
}
EOF"
    manifest_str
  end
end
