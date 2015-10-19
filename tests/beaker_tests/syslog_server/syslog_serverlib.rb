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
# Syslog Server Utility Library:
# ---------------------
# syslog_serverlib.rb
#
# This is the utility library for the Syslog Server provider Beaker test cases
# that contains the common methods used across the Syslog Server testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Syslog Server test case that runs an instance of Beaker::TestCase
# requires SyslogSettingLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for syslog_server Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing syslog_server resource
module SyslogServerLib
  # Group of Constants used in negative tests for syslog_server provider.
  ENSURE_NEGATIVE = 'unknown'

  # A. Methods to create manifests for syslog_server Puppet provider test cases.

  # Method to create a manifest for syslog_server resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_syslog_server_manifest_present
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  syslog_server {'1.2.3.4':
    ensure         => present,
    severity_level => 2,
    vrf            => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for syslog_server resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_syslog_server_manifest_absent
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    syslog_server {'1.2.3.4':
      ensure => absent,
    }
}
EOF"
    manifest_str
  end
end
