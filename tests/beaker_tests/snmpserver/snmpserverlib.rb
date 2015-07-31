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
# SNMPSERVER Utility Library: 
# ---------------------------
# snmpserverlib.rb
#  
# This is the utility library for the SNMPSERVER provider Beaker test cases that 
# contains the common methods used across the SNMPSERVER testsuite's cases. The  
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module 
# methods.
#
# Every Beaker SNMPSERVER test case that runs an instance of Beaker::TestCase 
# requires SnmpServerLib module.
# 
# The module has a single set of methods:
# A. Methods to create manifests for cisco_snmp_server Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)

module SnmpServerLib

  # Group of Constants used in negative tests for SNMPSERVER provider.
  PACKETSIZE_NEGATIVE   = '-1'
  AAATIMEOUT_NEGATIVE   = '-1'
  TCPAUTH_NEGATIVE      = 'unknown'
  PROTOCOL_NEGATIVE     = 'unknown'
  GLOBALPRIV_NEGATIVE   = 'unknown'

  # A. Methods to create manifests for cisco_snmp_server Puppet provider test cases.

  # Method to create a manifest for SNMPSERVER resource attributes:
  # aaa_user_cache_timeout, global_enforce_priv, packet_size,
  # protocol, tcp_session_auth, contact and location.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_defaults()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'default':
      packet_size            => 'default',
      aaa_user_cache_timeout => 'default',
      tcp_session_auth       => 'default',
      protocol               => 'default',
      global_enforce_priv    => 'default',
      contact                => 'default',
      location               => 'default',
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for SNMPSERVER resource attributes:
  # aaa_user_cache_timeout, global_enforce_priv, packet_size,
  # protocol, tcp_session_auth, contact and location.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_nondefaults()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'default':
      packet_size            => 2500,
      aaa_user_cache_timeout => 1000,
      tcp_session_auth       => false,
      protocol               => false,
      global_enforce_priv    => false,
      contact                => 'user1',
      location               => 'rtp',
    }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for SNMPSERVER resource attribute 'packet_size'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_packetsize_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'test':
      packet_size            => #{SnmpServerLib::PACKETSIZE_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for SNMPSERVER resource attribute 'aaa_cache_timeout'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_aaatimeout_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'test':
      aaa_user_cache_timeout => #{SnmpServerLib::AAATIMEOUT_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for SNMPSERVER resource attribute 'tcp_session_auth'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_tcpauth_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'test':
      tcp_session_auth       => #{SnmpServerLib::TCPAUTH_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for SNMPSERVER resource attribute 'protocol'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_protocol_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'test':
      protocol               => #{SnmpServerLib::PROTOCOL_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

  # Method to create a manifest for SNMPSERVER resource attribute 'global_priv'.
  # @param none [None] No input parameters exist. 
  # @result none [None] Returns no object.
  def SnmpServerLib.create_snmpserver_manifest_globalpriv_negative()
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_snmp_server { 'test':
      global_enforce_priv    => #{SnmpServerLib::GLOBALPRIV_NEGATIVE},
  }
}
EOF"
    return manifest_str
  end

end

