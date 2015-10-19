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
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# TRUNKVLAN Utility Library:
# --------------------------
# trunkvlanlib.rb
#
# This is the utility library for the TRUNKVLAN provider Beaker test cases that
# contains the common methods used across the TRUNKVLAN testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker TRUNKVLAN test case that runs an instance of Beaker::TestCase
# requires TrunkVlanLib module.
#
# The module has two sets of methods:
# A. Methods to create manifests for cisco_interface Puppet provider test cases.
module TrunkVlanLib
  # Group of Constants used in negative tests for TRUNKVLAN provider.
  DESCRIPTION_NEGATIVE         = ''
  IPV4PROXYARP_NEGATIVE        = 'invalid'
  IPV4REDIRECTS_NEGATIVE       = 'invalid'
  NEGOTIATEAUTO_NEGATIVE       = 'invalid'
  SHUTDOWN_NEGATIVE            = 'invalid'
  AUTOSTATE_NEGATIVE           = 'invalid'
  SWITCHPORTVTP_NEGATIVE       = 'invalid'

  # A. Methods to create manifests for cisco_interface Puppet provider test cases.

  # Method to create a manifest for TrunkVLAN resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_present
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      shutdown                     => 'default',
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      description                  => 'default',
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      negotiate_auto               => 'default',
      shutdown                     => 'default',
      switchport_autostate_exclude => 'default',
      switchport_mode              => 'trunk',
      switchport_vtp               => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_absent
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => absent,
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '1',
      description                  => 'default',
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      negotiate_auto               => 'default',
      shutdown                     => 'default',
      switchport_autostate_exclude => 'default',
      switchport_mode              => 'trunk',
      switchport_vtp               => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attributes:
  # access_vlan, description, ipv4_proxy_arp, ipv4_redirects,
  # negotiate_auto, shutdown, switchport_autostate_exclude, switchport_mode
  # and swichport_vtp.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_nondefaults
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      shutdown                     => 'default',
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      description                  => 'Configured with puppet',
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      negotiate_auto               => 'default',
      shutdown                     => 'true',
      switchport_autostate_exclude => 'default',
      switchport_mode              => 'trunk',
      switchport_vtp               => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'ipv4_proxy_arp'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_ipv4proxyarp_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      ipv4_proxy_arp               => #{TrunkVlanLib::IPV4PROXYARP_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'ipv4_redirects'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_ipv4redir_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      ipv4_redirects               => #{TrunkVlanLib::IPV4REDIRECTS_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'negotiate_auto'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_negoauto_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      negotiate_auto               => #{TrunkVlanLib::NEGOTIATEAUTO_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'shutdown'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_shutdown_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      shutdown                     => #{TrunkVlanLib::SHUTDOWN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'autostate'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_autostate_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      switchport_autostate_exclude => #{TrunkVlanLib::AUTOSTATE_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TrunkVLAN resource attribute 'switchport_vtp'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_trunkvlan_manifest_vtp_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      access_vlan                  => '128',
      switchport_vtp               => #{TrunkVlanLib::SWITCHPORTVTP_NEGATIVE},
    }
}
EOF"
    manifest_str
  end
end
