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
# NTP Config Utility Library:
# ---------------------
# ntp_configlib.rb
#
# This is the utility library for the NTP Config provider Beaker test cases
# that contains the common methods used across the NTP Config testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker NTP Config test case that runs an instance of Beaker::TestCase
# requires NtpConfigLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for ntp_config Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing ntp_config resource
module NtpConfigLib
  # Group of Constants used in negative tests for ntp_config provider.
  ENSURE_NEGATIVE = 'unknown'

  # A. Methods to create manifests for ntp_config Puppet provider test cases.

  # Method to create a manifest for ntp_config resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ntp_config_manifest_set(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  ntp_config {'default':
    source_interface => '#{intf}',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ntp_config resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ntp_config_manifest_unset
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    ntp_config {'default':
      source_interface => 'unset',
    }
}
EOF"
    manifest_str
  end
end
