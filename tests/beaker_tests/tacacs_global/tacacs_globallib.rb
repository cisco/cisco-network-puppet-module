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
# Tacacs Global Utility Library:
# ---------------------
# tacacs_globallib.rb
#
# This is the utility library for the Tacacs Global provider Beaker test cases
# that contains the common methods used across the Radius Server testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Radius Server test case that runs an instance of Beaker::TestCase
# requires RadiusSettingLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for tacacs_global Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing tacacs_global resource
module TacacsGlobalLib
  # A. Methods to create manifests for tacacs_global Puppet provider test cases.

  # Method to create a manifest for tacacs_global
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacs_global_manifest
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  tacacs_global { 'default':
    enable              => true,
    key                 => '44444444',
    key_format          => '7',
    timeout             => '2',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for tacacs_global resource
  # with a few changes made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacs_global_manifest_change
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  tacacs_global { 'default':
    enable              => true,
    key                 => '44444444',
    key_format          => '7',
    timeout             => '3',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for tacacs_global resource
  # with a few properties removed made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacs_global_manifest_change_disabled
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  tacacs_global { 'default':
    enable  => false,
  }
}
EOF"
    manifest_str
  end
end
