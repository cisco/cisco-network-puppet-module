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
# Syslog Setting Utility Library:
# ---------------------
# syslog_settinglib.rb
#
# This is the utility library for the Syslog Setting provider Beaker test cases
# that contains the common methods used across the Syslog Setting testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Syslog Setting test case that runs an instance of Beaker::TestCase
# requires SyslogSettingLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for syslog_setting Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing syslog_setting resource
module SyslogSettingLib
  # Group of Constants used in negative tests for syslog_setting provider.
  ENSURE_NEGATIVE = 'unknown'

  # A. Methods to create manifests for syslog_setting Puppet provider test cases.

  # Method to create a manifest for syslog_setting with default attributes
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_syslog_settings_manifest_default
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    syslog_settings {'default':
      console          => '2',
      monitor          => '5',
      source_interface => 'unset',
      time_stamp_units => 'seconds',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for syslog_setting with non-default attributes
  # @param intf [String] source_interface
  # @result none [None] Returns no object.
  def self.create_syslog_settings_manifest_nondefault(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    syslog_settings {'default':
      console          => '1',
      monitor          => '1',
      source_interface => '#{intf}',
      time_stamp_units => 'milliseconds',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for syslog_setting with unset attributes
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_syslog_settings_manifest_unset
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    syslog_settings {'default':
      console          => 'unset',
      monitor          => 'unset',
      source_interface => 'unset',
      time_stamp_units => 'seconds',
    }
}
EOF"
    manifest_str
  end
end
