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

# ACCESSVLAN Utility Library:
# ---------------------------
# accessvlanlib.rb
#
# This is the utility library for the ACCESSVLAN provider Beaker test cases that
# contains the common methods used across the ACCESSVLAN testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker ACCESSVLAN test case that runs an instance of Beaker::TestCase
# requires AccessVlanLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_interface Puppet provider test cases.
module AccessVlanLib
  # Group of Constants used in negative tests for ACCESSVLAN provider.
  DESCRIPTION_NEGATIVE         = ''
  IPV4PROXYARP_NEGATIVE        = 'invalid'
  IPV4REDIRECTS_NEGATIVE       = 'invalid'
  NEGOTIATEAUTO_NEGATIVE       = 'invalid'
  SHUTDOWN_NEGATIVE            = 'invalid'
  AUTOSTATE_NEGATIVE           = 'invalid'
  SWITCHPORTVTP_NEGATIVE       = 'invalid'

  # A. Methods to create manifests for cisco_interface Puppet provider test cases.

  # Method to create a manifest for AccessVLAN resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_present(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      shutdown                     => 'default',
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      description                  => 'default',
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      #negotiate_auto               => 'default', # TBD: Needs plat awareness
      shutdown                     => 'default',
      switchport_autostate_exclude => 'default',
      switchport_mode              => 'access',
      switchport_vtp               => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_absent(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => absent,
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '1',
      description                  => 'default',
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      #negotiate_auto               => 'default', # TBD: Needs plat awareness
      shutdown                     => 'default',
      switchport_autostate_exclude => 'default',
      switchport_mode              => 'access',
      switchport_vtp               => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attributes:
  # access_vlan, description, ipv4_proxy_arp, ipv4_redirects,
  # negotiate_auto, shutdown, switchport_autostate_exclude, switchport_mode
  # and switchport_vtp.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_nondefaults(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      shutdown                     => 'default',
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      description                  => 'Configured with puppet',
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      #negotiate_auto               => 'default', # TBD: Needs plat awareness
      shutdown                     => 'true',
      switchport_autostate_exclude => 'default',
      switchport_mode              => 'access',
      switchport_vtp               => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'ipv4_proxy_arp'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_ipv4proxyarp_negative(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      ipv4_proxy_arp               => #{AccessVlanLib::IPV4PROXYARP_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'ipv4_redirects'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_ipv4redir_negative(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      ipv4_redirects               => #{AccessVlanLib::IPV4REDIRECTS_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'negotiate_auto'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_negoauto_negative(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      #negotiate_auto               => #{AccessVlanLib::NEGOTIATEAUTO_NEGATIVE}, # TBD: Needs plat awareness
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'shutdown'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_shutdown_negative(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      shutdown                     => #{AccessVlanLib::SHUTDOWN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'autostate'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_autostate_negative(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      switchport_autostate_exclude => #{AccessVlanLib::AUTOSTATE_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for AccessVLAN resource attribute 'switchport_vtp'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_accessvlan_manifest_vtp_negative(intf)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan { '128':
      ensure                       => present,
      state                        => 'default',
    }
    cisco_interface { '#{intf}':
      ensure                       => present,
      access_vlan                  => '128',
      switchport_vtp               => #{AccessVlanLib::SWITCHPORTVTP_NEGATIVE},
    }
}
EOF"
    manifest_str
  end
end
