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

# SVIINTF Utility Library:
# -------------------------
# sviintflib.rb
#
# This is the utility library for the SVIINTF provider Beaker test cases that
# contains the common methods used across the SVIINTF testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker SVIINTF test case that runs an instance of Beaker::TestCase
# requires SviIntfLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_interface Puppet provider test cases.
module SviIntfLib
  # Group of Constants used in negative tests for SVIINTF provider.
  SVIMANAGEMENT_NEGATIVE       = 'invalid'
  SVIAUTOSTATE_NEGATIVE        = 'invalid'
  SHUTDOWN_NEGATIVE            = 'invalid'
  IPV4ADDRESS_NEGATIVE         = '-1.-1.-1.-1'
  IPV4MASKLEN_NEGATIVE         = '-1'

  # A. Methods to create manifests for cisco_interface Puppet provider test cases.

  # Method to create a manifest for SviINTF resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      svi_management         => 'default',
      svi_autostate          => 'default',
      shutdown               => false,
      ipv4_address           => '192.168.1.1',
      ipv4_netmask_length    => 16,
      ipv4_arp_timeout       => 'default',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => absent,
    }
    cisco_interface { 'VLAN80':
      ensure                 => absent,
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attributes:
  # svi_management, svi_autostate, shutdown,
  # ipv4_address and ipv4_netmask_length.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      svi_management         => true,
      svi_autostate          => false,
      shutdown               => true,
      ipv4_address           => '192.168.1.1',
      ipv4_netmask_length    => 16,
      ipv4_arp_timeout       => 300,
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attribute 'svi_management'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_svimanagement_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      svi_management         => #{SviIntfLib::SVIMANAGEMENT_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attribute 'svi_autostate'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_sviautostate_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      svi_autostate          => #{SviIntfLib::SVIAUTOSTATE_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attribute 'shutdown'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_shutdown_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      shutdown               => #{SviIntfLib::SHUTDOWN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attribute 'ipv4_address'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_ipv4addr_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      ipv4_address           => #{SviIntfLib::IPV4ADDRESS_NEGATIVE},
      ipv4_netmask_length    => '16',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SviINTF resource attribute 'ipv4_netmask_length'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_sviintf_manifest_ipv4masklen_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_vlan      { '80':
      ensure                 => present,
      state                  => active,
    }
    cisco_interface { 'VLAN80':
      ensure                 => present,
      ipv4_address           => '192.168.1.1',
      ipv4_netmask_length    => #{SviIntfLib::IPV4MASKLEN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end
end
