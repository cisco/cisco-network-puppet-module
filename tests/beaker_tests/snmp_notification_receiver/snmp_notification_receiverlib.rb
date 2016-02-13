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
# snmp_notification_receiverlib.rb
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
# A. Methods to create manifests for snmp_notification_receiver Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing snmp_notification_receiver resource
module SnmpNotificationReceiverLib
  # Group of Constants used in negative tests for snmp_notification_receiver provider.
  ENSURE_NEGATIVE = 'unknown'

  # A. Methods to create manifests for snmp_notification_receiver Puppet provider test cases.

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_v3
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/3',
    port             => '47',
    type             => 'traps',
    username         => 'jj',
    version          => 'v3',
    vrf              => 'red',
    security         => 'priv',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_change_v3
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/4',
    port             => '47',
    type             => 'traps',
    username         => 'ab',
    version          => 'v3',
    vrf              => 'red',
    security         => 'auth',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_change_v3_2
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/4',
    port             => '47',
    type             => 'traps',
    username         => 'ab',
    version          => 'v3',
    vrf              => 'red',
    security         => 'noauth',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_change_v3_3
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/4',
    port             => '47',
    type             => 'informs',
    username         => 'ab',
    version          => 'v3',
    vrf              => 'red',
    security         => 'noauth',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_v2
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/4',
    port             => '47',
    type             => 'traps',
    username         => 'ab',
    version          => 'v2',
    vrf              => 'red',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_change_v2
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/4',
    port             => '47',
    type             => 'informs',
    username         => 'ab',
    version          => 'v2',
    vrf              => 'red',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to present, and a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_present_v1
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  snmp_notification_receiver { '2.3.4.5':
    ensure           => 'present',
    source_interface => 'ethernet1/4',
    port             => '47',
    type             => 'traps',
    username         => 'ab',
    version          => 'v1',
    vrf              => 'red',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for snmp_notification_receiver resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_snmp_notification_receiver_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    snmp_notification_receiver { '2.3.4.5':
     ensure          => absent,
  }
}
EOF"
    manifest_str
  end
end
