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
# LOOPBACKINTF Utility Library: 
# -----------------------------
# loopbackintflib.rb
#  
# This is the utility library for the LOOPBACKINTF provider Beaker test cases that
# contains the common methods used across the LOOPBACKINTF testsuite's cases. The 
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module 
# methods.
#
# Every Beaker LOOPBACKINTF test case that runs an instance of Beaker::TestCase 
# requires LoopbackIntfLib module.
# 
# The module has a single set of methods:
# A. Methods to create manifests for cisco_interface Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)

module LoopbackIntfLib

  # Group of Constants used in negative tests for LOOPBACKINTF provider.
  IPV4ADDRESS_NEGATIVE         = '-1.-1.-1.-1'
  IPV4MASKLEN_NEGATIVE         = '-1'
  SHUTDOWN_NEGATIVE            = 'invalid'
  IPV4PROXYARP_NEGATIVE        = 'invalid'
  IPV4REDIR_NEGATIVE           = 'invalid'
  VRF_NEGATIVE                 = '~'

  # A. Methods to create manifests for cisco_interface Puppet provider test cases.

  # Method to create a manifest for LoopbackINTF resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_present()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      description                  => 'Configured with Puppet',
      shutdown                     => false,
      ipv4_address                 => '192.168.1.1',
      ipv4_netmask_length          => 16,
      vrf                          => 'default',
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_absent()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => absent,
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attributes:
  # description, shutdown, ipv4_address and 
  # and ipv4_netmask_length.  
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_nondefaults()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      description                  => 'Configured with Puppet',
      shutdown                     => true,
      ipv4_address                 => '192.168.1.1',
      ipv4_netmask_length          => 16,
      vrf                          => 'test1',
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'ipv4_address'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_ipv4addr_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      shutdown                     => false,
      ipv4_address                 => #{LoopbackIntfLib::IPV4ADDRESS_NEGATIVE},
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'ipv4_netmask_length'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_ipv4masklen_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      shutdown                     => false,
      ipv4_address                 => '192.168.1.1',
      ipv4_netmask_length          => #{LoopbackIntfLib::IPV4MASKLEN_NEGATIVE},
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'shutdown'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_shutdown_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      shutdown                     => false,
      shutdown                     => #{LoopbackIntfLib::SHUTDOWN_NEGATIVE},
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'ipv4_proxy_arp'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_ipv4proxyarp_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      shutdown                     => false,
      ipv4_proxy_arp               => #{LoopbackIntfLib::IPV4PROXYARP_NEGATIVE},
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'ipv4_redirects'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_ipv4redir_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      shutdown                     => false,
      ipv4_redirects               => #{LoopbackIntfLib::IPV4REDIR_NEGATIVE},
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for LoopbackINTF resource attribute 'vrf'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def LoopbackIntfLib.create_loopbackintf_manifest_vrf_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'loopback1':
      ensure                       => present,
      shutdown                     => false,
      vrf                          => #{LoopbackIntfLib::VRF_NEGATIVE},
    }
}
EOF"
    return manifest_str
  end
end
