###############################################################################
# Copyright (c) 2014-2017 Cisco and/or its affiliates.
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
# NTP Server Utility Library:
# ---------------------
# ntp_auth_keylib.rb
#
# This is the utility library for the ntp server provider Beaker test cases
# that contains the common methods used across the ntp server testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker ntp server test case that runs an instance of Beaker::TestCase
# requires NtpAuthKeyLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for ntp_auth_key Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing ntp_auth_key resource
module NtpAuthKeyLib
  # A. Methods to create manifests for ntp_auth_key Puppet provider test cases.

  # Method to create a manifest for ntp_auth_key resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ntp_auth_key_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  ntp_auth_key { '1':
    ensure    => 'present',
    password  => 'test',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ntp_auth_key resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ntp_auth_key_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    ntp_auth_key {'1':
      ensure => absent,
    }
}
EOF"
    manifest_str
  end
end
