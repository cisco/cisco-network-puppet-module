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
# Network TRUNK Utility Library:
# ---------------------
# network_trunklib.rb
#
# This is the utility library for the network_trunk provider Beaker test cases
# that contains the common methods used across the network_trunk testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker network vlan test case that runs an instance of Beaker::TestCase
# requires NetworkTrunkLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for network_trunk Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing network_trunk resource
module NetworkTrunkLib
  # A. Methods to create manifests for network_trunk Puppet provider test cases.

  def self.create_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { '128':
    ensure        => 'absent',
  }
  network_trunk { 'ethernet1/4':
    ensure        => 'present',
    mode          => 'trunk',
    untagged_vlan => 1,
  }
}
EOF"
    manifest_str
  end

  def self.create_defaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { '128':
    ensure        => 'present',
  }
  network_trunk { 'ethernet1/4':
    ensure        => 'present',
    mode          => 'trunk',
    tagged_vlans  => [2],
    untagged_vlan => 128,
  }
}
EOF"
    manifest_str
  end

  def self.create_non_defaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { '128':
    ensure        => 'absent',
  }
  network_trunk { 'ethernet1/4':
    ensure        => 'present',
    mode          => 'trunk',
    tagged_vlans  => [2,3,4,6,7,8],
    untagged_vlan => 1,
  }
}
EOF"
    manifest_str
  end
end
