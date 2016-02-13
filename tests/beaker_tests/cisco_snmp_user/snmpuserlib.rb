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

# SNMPUSER Utility Library:
# -------------------------
# snmpuserlib.rb
#
# This is the utility library for the SNMPUSER provider Beaker test cases that
# contains the common methods used across the SNMPUSER testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker SNMPUSER test case that runs an instance of Beaker::TestCase
# requires SnmpUserLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_snmp_user Puppet provider test cases.
module SnmpUserLib
  # Group of Constants used in negative tests for SNMPUSER provider.
  AUTHPROT_NEGATIVE       = 'unknown'
  PRIVPROT_NEGATIVE       = 'unknown'

  # A. Methods to create manifests for cisco_snmp_user Puppet provider test cases.

  # Method to create a manifest for SNMPUSER resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpuser_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_user { 'snmpuser1':
      ensure                 => present,
      groups                 => ['network-operator'],
      auth_protocol          => 'md5',
      auth_password          => 'XXWWPass0wrf',
      priv_protocol          => 'aes128',
      priv_password          => 'WWXXPaas0wrf',
      localized_key          => false,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPUSER resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpuser_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_snmp_user { 'snmpuser1':
      ensure                 => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPUSER resource attributes:
  # ensure, groups, auth_protocol, auth_password, priv_protocol,
  # priv_password and localized_key.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpuser_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_user { 'snmpuser1':
      ensure                 => present,
      groups                 => ['network-operator'],
      auth_protocol          => 'sha',
      auth_password          => 'XXWWPass0wrf',
      priv_protocol          => 'des',
      priv_password          => 'WWXXPaas0wrf',
      localized_key          => false,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPUSER resource attribute 'auth_protocol'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpuser_manifest_authprotocol_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_user { 'snmpuser1':
      ensure                 => present,
      auth_protocol          => #{SnmpUserLib::AUTHPROT_NEGATIVE},
      auth_password          => 'XXWWPass0wrf',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SNMPUSER resource attribute 'priv_protocol'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmpuser_manifest_privprotocol_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_user { 'snmpuser1':
      ensure                 => present,
      priv_protocol          => #{SnmpUserLib::PRIVPROT_NEGATIVE},
      priv_password          => 'WWXXPaas0wrf',
  }
}
EOF"
    manifest_str
  end
end
