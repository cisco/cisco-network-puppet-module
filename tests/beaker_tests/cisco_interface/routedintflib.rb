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

# ROUTEDINTF Utility Library:
# ---------------------------
# routedintflib.rb
#
# This is the utility library for the ROUTEDINTF provider Beaker test cases that
# contains the common methods used across the ROUTEDINTF testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
# Every Beaker ROUTEDINTF test case that runs an instance of Beaker::TestCase
# requires RoutedIntfLib module.
# The module has a single set of methods:
# A. Methods to create manifests for cisco_interface Puppet provider test cases.
module RoutedIntfLib
  # Group of Constants used in negative tests for ROUTEDINTF provider.
  ENCAP_DOT1Q_NEGATIVE         = 'invalid'
  IPV4ADDRESS_NEGATIVE         = '-1.-1.-1.-1'
  IPV4MASKLEN_NEGATIVE         = '-1'
  IPV4PIMSPARSEMODE            = 'invalid'
  IPV4PROXYARP_NEGATIVE        = 'invalid'
  IPV4REDIR_NEGATIVE           = 'invalid'
  MTU_NEGATIVE                 = '1999'
  SHUTDOWN_NEGATIVE            = 'invalid'
  TRUNK_ALLOWED_NEGATIVE       = 'invalid'
  TRUNK_NATIVE_NEGATIVE        = 'invalid'
  VRF_NEGATIVE                 = '~'
  CHANNEL_GROUP_NEGATIVE       = '-1'
  IPV4_ACL_IN_NEGATIVE         = '~'
  IPV4_ACL_OUT_NEGATIVE        = '~'
  IPV6_ACL_IN_NEGATIVE         = '~'
  IPV6_ACL_OUT_NEGATIVE        = '~'

  # A. Methods to create manifests for cisco_interface Puppet provider test cases.
  # Method to create a manifest for RoutedINTF resource attribute 'ensure' where
  # 'ensure' is set to present and 'switchport_mode' is set to disabled.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_switchport_disabled
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {

    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      description                  => 'default',
      shutdown                     => false,
      switchport_mode              => disabled,
      ipv4_address                 => '192.168.1.1',
      ipv4_netmask_length          => 16,
      ipv4_proxy_arp               => 'default',
      ipv4_redirects               => 'default',
      mtu                          => 'default',
      speed                        => 'auto',
      duplex                       => 'auto',
      switchport_autostate_exclude => 'default',
      switchport_vtp               => 'default',
      vrf                          => 'default',
      ipv4_acl_in                  => 'default',
      ipv4_acl_out                 => 'default',
      ipv6_acl_in                  => 'default',
      ipv6_acl_out                 => 'default',
  }}
EOF"
    manifest_str
  end

  def self.create_routedintf_manifest_channel_group
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      switchport_mode              => disabled,
      channel_group                => 200,
  }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ensure' where
  # 'ensure' is set to present and 'switchport_mode' is set to access.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_switchport_access
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      description                  => 'default',
      shutdown                     => false,
      switchport_mode              => access,
    }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ensure' where
  # 'ensure' is set to present and 'switchport_mode' is set to trunk.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_switchport_trunk_defaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                        => present,
      description                   => 'default',
      shutdown                      => false,
      switchport_mode               => trunk,
      switchport_trunk_allowed_vlan => 'default',
      switchport_trunk_native_vlan  => 'default',
    }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ensure' where
  # 'ensure' is set to present and 'switchport_mode' is set to trunk.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_switchport_trunk_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                        => present,
      description                   => 'default',
      shutdown                      => false,
      switchport_mode               => trunk,
      switchport_trunk_allowed_vlan => '30, 40',
      switchport_trunk_native_vlan  => 20,
    }}
EOF"
    manifest_str
  end

  def self.create_routedintf_acl_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_acl { 'ipv4 v4acl1':
      ensure                      => present,
      stats_per_entry             => false,
      fragments                   => 'default'
    }

   cisco_acl { 'ipv4 v4acl2':
      ensure                      => present,
      stats_per_entry             => false,
      fragments                   => 'default'
    }

   cisco_acl { 'ipv6 v6acl1':
      ensure                      => present,
      stats_per_entry             => false,
      fragments                   => 'default'
    }

  cisco_acl { 'ipv6 v6acl2':
      ensure                      => present,
      stats_per_entry             => false,
      fragments                   => 'default'
    }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attributes:
  # description, shutdown, switchport_mode, ipv4_address,
  # ipv4_netmask_length, ipv4_proxy_arp and ipv4_redirects.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {

    cisco_interface { 'ethernet1/4':
      ensure                         => present,
      description                    => 'Configured with Puppet',
      shutdown                       => true,
      switchport_mode                => disabled,
      ipv4_address                   => '192.168.1.1',
      ipv4_netmask_length            => 16,
      ipv4_address_secondary         => '10.0.55.55',
      ipv4_netmask_length_secondary  => 24,
      ipv4_pim_sparse_mode           => true,
      ipv4_proxy_arp                 => true,
      ipv4_redirects                 => false,
      mtu                            => 1556,
      speed                          => 100,
      duplex                         => full,
      switchport_autostate_exclude   => false,
      switchport_vtp                 => false,
      vrf                            => 'test1',
      ipv4_acl_in                  => 'v4acl1',
      ipv4_acl_out                 => 'v4acl2',
      ipv6_acl_in                  => 'v6acl1',
      ipv6_acl_out                 => 'v6acl2',
    }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF subinterface attributes.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_subinterface
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure => present,
      switchport_mode => disabled,
    }
    cisco_interface { 'ethernet1/4.1':
      ensure              => present,
      encapsulation_dot1q => 30,
    }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute:
  # 'encapsulation_dot1q'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_encap_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure => present,
      switchport_mode => disabled,
    }
    cisco_interface { 'ethernet1/4.1':
      ensure              => present,
      encapsulation_dot1q => #{RoutedIntfLib::ENCAP_DOT1Q_NEGATIVE},
    }}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_address'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4addr_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      ipv4_address                 => #{RoutedIntfLib::IPV4ADDRESS_NEGATIVE},
      ipv4_netmask_length          => 16,
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_netmask_length'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4masklen_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      ipv4_address                 => '192.168.1.1',
      ipv4_netmask_length          => #{RoutedIntfLib::IPV4MASKLEN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'mtu'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_mtu_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      mtu                          => #{RoutedIntfLib::MTU_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'shutdown'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_shutdown_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      shutdown                     => #{RoutedIntfLib::SHUTDOWN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attributes:
  # switchport_trunk_allowed_vlan.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_trunk_allowed_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                        => present,
      shutdown                      => false,
      switchport_mode               => trunk,
      switchport_trunk_allowed_vlan => #{RoutedIntfLib::TRUNK_ALLOWED_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attributes:
  # switchport_trunk_native_vlan.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_trunk_native_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => trunk,
      switchport_trunk_native_vlan => #{RoutedIntfLib::TRUNK_NATIVE_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_pim_sparse_mode'
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4pimsparsemode_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      ipv4_pim_sparse_mode         => #{RoutedIntfLib::IPV4PIMSPARSEMODE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_proxy_arp'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4proxyarp_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      ipv4_proxy_arp               => #{RoutedIntfLib::IPV4PROXYARP_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_redirects'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4redir_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      ipv4_redirects               => #{RoutedIntfLib::IPV4REDIR_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'vrf'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_vrf_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      shutdown                     => false,
      switchport_mode              => disabled,
      vrf                          => #{RoutedIntfLib::VRF_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'channel-group'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_channel_group_manifest_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      channel_group                => #{RoutedIntfLib::CHANNEL_GROUP_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_acl_in'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4_acl_in_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      ipv4_acl_in                  => #{RoutedIntfLib::IPV4_ACL_IN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv4_acl_out'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv4_acl_out_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      ipv4_acl_out                 => #{RoutedIntfLib::IPV4_ACL_OUT_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv6_acl_in'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv6_acl_in_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      ipv6_acl_in                  => #{RoutedIntfLib::IPV6_ACL_IN_NEGATIVE},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for RoutedINTF resource attribute 'ipv6_acl_out'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_routedintf_manifest_ipv6_acl_out_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    cisco_interface { 'ethernet1/4':
      ensure                       => present,
      ipv6_acl_out                 => #{RoutedIntfLib::IPV6_ACL_OUT_NEGATIVE},
    }
}
EOF"
    manifest_str
  end
end
