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

# SNMPGROUP Utility Library:
# ---------------------------
# snmpgrouplib.rb
#
# This is the utility library for the SNMPGROUP provider Beaker test cases that
# contains the common methods used across the SNMPGROUP testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker SNMPGROUP test case that runs an instance of Beaker::TestCase
# requires SnmpGroupLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_snmp_group Puppet provider tests.
module SnmpGroupLib
  # Create a manifest describing SNMP group default state.
  def self.create_snmpgroup_manifest_defaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_group { 'network-admin':
    ensure => 'present',
  }

  cisco_snmp_group { 'foobar':
    ensure => 'absent',
  }
}
EOF"
    manifest_str
  end

  # Negative test #1 - try to create a group that does not exist.
  def self.create_snmpgroup_manifest_negative_1
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_group { 'go-jackets':
    ensure => 'present',
  }
}
EOF"
    manifest_str
  end

  # Negative test #2 - try to delete a group that exists.
  def self.create_snmpgroup_manifest_negative_2
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_group { 'network-operator':
    ensure => 'absent',
  }
}
EOF"
    manifest_str
  end
end
