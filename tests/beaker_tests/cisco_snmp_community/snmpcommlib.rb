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

# SNMPCOMM Utility Library:
# -------------------------
# snmpcommlib.rb
#
# This is the utility library for the SNMPCOMM provider Beaker test cases that
# contains the common methods used across the SNMPCOMM testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker SNMPCOMM test case that runs an instance of Beaker::TestCase
# requires SnmpCommLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_snmp_comm Puppet provider test cases.
module SnmpCommLib
  # Group of Constants used in negative tests for SNMPCOMM provider.
  GROUP_NEGATIVE = ''
  ACL_NEGATIVE   = ''

  # A. Methods to create manifests for cisco_snmp_comm Puppet provider test cases.

  # Method to create a manifest for SNMPCOMM resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpcommunity_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_community { 'test':
      ensure                 => present,
      group                  => 'default',
      acl                    => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPCOMM resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpcommunity_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_community { 'test':
      ensure                 => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPCOMM resource attributes:
  # group and acl.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpcommunity_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_community { 'test':
      ensure                 => present,
      group                  => 'network-operator',
      acl                    => 'aclname',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPCOMM resource attribute 'group'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpcommunity_manifest_group_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_community { 'test':
      ensure                 => present,
      group                  => #{SnmpCommLib::GROUP_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPCOMM resource attribute 'acl'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpcommunity_manifest_acl_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_community { 'test':
      ensure                 => present,
      acl                    => #{SnmpCommLib::ACL_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
