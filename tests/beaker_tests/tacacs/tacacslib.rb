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
# Tacacs Utility Library:
# ---------------------
# tacacslib.rb
#
# This is the utility library for the Tacacs provider Beaker test cases
# that contains the common methods used across the Tacacs testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker Tacacs test case that runs an instance of Beaker::TestCase
# requires TacacsLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for tacacs Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing tacacs resource
module TacacsLib
  # A. Methods to create manifests for tacacs Puppet provider test cases.

  # Method to create a manifest for tacacs
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacs_manifest
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  tacacs { 'default':
    enable              => true,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for tacacs resource
  # with a few properties removed made from above.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacs_manifest_change_disabled
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  tacacs { 'default':
    enable  => false,
  }
}
EOF"
    manifest_str
  end
end
