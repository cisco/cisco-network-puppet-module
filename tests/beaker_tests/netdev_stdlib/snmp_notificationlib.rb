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
# SNMP notification Utility Library:
# ---------------------
# snmp_notificationlib.rb
#
# This is the utility library for the snmp_notification provider Beaker test cases
# that contains the common methods used across the snmp_notification testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker network vlan test case that runs an instance of Beaker::TestCase
# requires SnmpNotificationLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for snmp_notification Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing snmp_notification resource
module SnmpNotificationLib
  # A. Methods to create manifests for snmp_notification Puppet provider test cases.

  def self.create_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification { 'aaa server-state-change':
    enable => false,
  }
}
EOF"
    manifest_str
  end

  def self.create_defaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification { 'aaa server-state-change':
    enable => false,
  }
}
EOF"
    manifest_str
  end

  def self.create_non_defaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification { 'aaa server-state-change':
    enable => true,
  }
}
EOF"
    manifest_str
  end
end
