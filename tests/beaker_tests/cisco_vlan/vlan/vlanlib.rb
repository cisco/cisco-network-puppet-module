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

# Require UtilityLib.rb path.
require File.expand_path('../../../lib/utilitylib.rb', __FILE__)

# VLAN Utility Library:
# ---------------------
# vlanlib.rb
#
# This is the utility library for the VLAN provider Beaker test cases that
# contains the common methods used across the VLAN testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker VLAN test case that runs an instance of Beaker::TestCase
# requires VlanLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_vlan Puppet provider test cases.
module VlanLib
  # Group of Constants used in negative tests for VLAN provider.
  VLANNAME_NEGATIVE   = ''
  STATE_NEGATIVE      = 'invalid'
  SHUTDOWN_NEGATIVE   = 'invalid'

  # A. Methods to create manifests for cisco_vlan Puppet provider test cases.

  # Method to create a manifest for StandardVLAN resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_stdvlan_manifest_present(test_properties)
    if test_properties[:mapped_vni]
      manifest = "
        cisco_vlan { '128':
          ensure         => present,
          state          => 'default',
          mapped_vni     => 'default',
          shutdown       => 'default',
        }"
    else
      if test_properties[:fabric_control]
        manifest = "
          cisco_vlan { '128':
            ensure         => present,
            state          => 'default',
            shutdown       => 'default',
            fabric_control => 'default',
          }"
      else
        manifest = "
          cisco_vlan { '128':
            ensure         => present,
            state          => 'default',
            shutdown       => 'default',
          }"
      end
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  #{manifest}
}
EOF"
    manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_stdvlan_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attributes:
  # vlan_name, state and shutdown.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_stdvlan_manifest_nondefaults(test_properties)
    if test_properties[:mapped_vni]
      manifest = "
        cisco_vlan { '128':
          ensure         => present,
          vlan_name      => 'DESCR-VLAN0128',
          state          => 'suspend',
          mapped_vni     => '128000',
          shutdown       => 'true',
         }"
    else
      if test_properties[:fabric_control]
        manifest = "
          cisco_vlan { '128':
            ensure         => present,
            vlan_name      => 'DESCR-VLAN0128',
            state          => 'suspend',
            shutdown       => 'true',
            fabric_control => 'true',
          }"
      else
        manifest = "
          cisco_vlan { '128':
            ensure         => present,
            vlan_name      => 'DESCR-VLAN0128',
            state          => 'suspend',
            shutdown       => 'true',
          }"
      end
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  #{manifest}
}
EOF"
    manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'vlan_name'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_stdvlan_manifest_vlanname_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    vlan_name      => #{VlanLib::VLANNAME_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'state'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_stdvlan_manifest_state_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    state          => #{VlanLib::STATE_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'shutdown'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_stdvlan_manifest_shutdown_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    shutdown       => #{VlanLib::SHUTDOWN_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_extvlan_manifest_present(test_mapped_vni)
    if test_mapped_vni
      manifest = "
        cisco_vlan { '2400':
          ensure         => present,
          state          => 'default',
          mapped_vni     => 'default',
          shutdown       => 'default',
        }"
    else
      manifest = "
        cisco_vlan { '2400':
          ensure         => present,
          state          => 'default',
          shutdown       => 'default',
        }"
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  #{manifest}
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_extvlan_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attributes:
  # vlan_name and state.
  # Extended VLANs cannot be shutdown.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_extvlan_manifest_nondefaults(test_mapped_vni)
    if test_mapped_vni
      manifest = "
        cisco_vlan { '2400':
          ensure         => present,
          mapped_vni     => '24000',
          vlan_name      => 'DESCR-VLAN2400',
         }"
    else
      manifest = "
        cisco_vlan { '2400':
          ensure         => present,
          vlan_name      => 'DESCR-VLAN2400',
        }"
    end

    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  #{manifest}
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'vlan_name'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_extvlan_manifest_vlanname_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    vlan_name      => #{VlanLib::VLANNAME_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'state'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_extvlan_manifest_state_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    state          => #{VlanLib::STATE_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'shutdown'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_extvlan_manifest_shutdown_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    shutdown       => #{VlanLib::SHUTDOWN_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
