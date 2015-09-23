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
# CISCOCOMMAND Utility Library:
# -----------------------------
# ciscocommandlib.rb
#
# This is the utility library for the CISCOCMD provider Beaker test cases that
# contains the common methods used across the CISCOCMD testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker CISCOCMD test case that runs an instance of Beaker::TestCase
# requires CiscoCommandLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_command_config Puppet test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

module CiscoCommandLib
  # A. Methods to create manifests for cisco_command_config Puppet test cases.

  # Method to create a manifest for CISCOCOMMAND resource attribute:
  # command.
  # 'command' is set to the NXOS command list to be applied to switch config.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_cisco_command_nondefaults
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_command_config { 'interface_config':
    command => '
      vlan 100
        state suspend
        exit
      interface Ethernet1/2
        description This is the new interface config.
        switchport
        switchport mode access
        switchport access vlan 100
        no shutdown
        exit',
  }
}
EOF"
    manifest_str
  end
end
