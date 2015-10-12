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
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)

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
  def VlanLib.create_stdvlan_manifest_present()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    state          => 'default',
    shutdown       => 'default',
  }
}
EOF"
    return manifest_str
  end

  # This is identical in purpose to create_stdvlan_manifest_present(), but it applies to the netdev_stdlib type
  def VlanLib.create_networkvlan_manifest_present()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { '128':
    ensure         => present,
    shutdown       => 'false',
  }
}
EOF"
  end

  # Method to create a manifest for StandardVLAN resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_stdvlan_manifest_absent
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => absent,
  }
}
EOF"
  end

  # This is identical in purpose to create_stdvlan_manifest_absent(), but it applies to the netdev_stdlib type
  def VlanLib.create_networkvlan_manifest_absent
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  network_vlan { '128':
    ensure         => absent,
  }
}
EOF"
  end

  # Method to create a manifest for StandardVLAN resource attributes:
  # vlan_name, state and shutdown. 
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_stdvlan_manifest_nondefaults()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    vlan_name      => 'DESCR-VLAN0128',
    state          => 'suspend',
    shutdown       => 'true',
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'vlan_name'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_stdvlan_manifest_vlanname_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    vlan_name      => #{VlanLib::VLANNAME_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'state'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_stdvlan_manifest_state_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    state          => #{VlanLib::STATE_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for StandardVLAN resource attribute 'shutdown'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_stdvlan_manifest_shutdown_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '128':
    ensure         => present,
    shutdown       => #{VlanLib::SHUTDOWN_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_extvlan_manifest_present()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    state          => 'default',
    shutdown       => 'default',
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_extvlan_manifest_absent()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => absent,
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attributes:
  # vlan_name and state.
  # Extended VLANs cannot be shutdown.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_extvlan_manifest_nondefaults()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    vlan_name      => 'DESCR-VLAN2400',
    state          => 'suspend',
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'vlan_name'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_extvlan_manifest_vlanname_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    vlan_name      => #{VlanLib::VLANNAME_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'state'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_extvlan_manifest_state_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    state          => #{VlanLib::STATE_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for ExtendedVLAN resource attribute 'shutdown'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def VlanLib.create_extvlan_manifest_shutdown_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vlan { '2400':
    ensure         => present,
    shutdown       => #{VlanLib::SHUTDOWN_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end
end
