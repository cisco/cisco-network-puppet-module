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
# Network VLAN Utility Library:
# ---------------------
# network_vlanlib.rb
#
# This is the utility library for the network_vlan provider Beaker test cases
# that contains the common methods used across the network_vlan testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker network vlan test case that runs an instance of Beaker::TestCase
# requires NetworkVlanLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for network_vlan Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing network_vlan resource
module NetworkVlanLib
  # A. Methods to create manifests for network_vlan Puppet provider test cases.

  # Method to create a manifest for network_vlan resource properties
  # @param name [String] The value to pass as the resource title
  # @param ens [String] The value to pass to the ensure property
  # @param vname [String] The value to pass to the vlan_name property
  # @param shut [Boolean] The value to pass to the shutdown property
  # @result none [None] Returns no object.
  def self.create_network_vlan_manifest(name, ens, vname, shut)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { #{name.inspect}:
    ensure    => #{ens.inspect},
    vlan_name => #{vname.inspect},
    shutdown  => #{shut.inspect},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for network_vlan resource with only ensure
  # @param name [String] The value to pass as the resource title
  # @param ensure [String] The value to pass to the ensure property
  # @result none [None] Returns no object.
  def self.create_network_vlan_manifest_ensure(name, ens)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { #{name}:
    ensure    => #{ens.inspect},
  }
}
EOF"
    manifest_str
  end
end
