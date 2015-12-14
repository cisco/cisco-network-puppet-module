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

# OSPFVRF Utility Library:
# ------------------------
# ospfvrflib.rb
#
# This is the utility library for the OSPFVRF provider Beaker test cases that
# contains the common methods used across the OSPFVRF testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker OSPFVRF test case that runs an instance of Beaker::TestCase
# requires OspfVrfLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_ospf_vrf Puppet provider test cases.
module OspfVrfLib
  # Group of Constants used in negative tests for OSPFVRF provider.
  AUTOCOST_NEGATIVE          = '100000000'
  DEFAULTMETRIC_NEGATIVE     = '-1'
  LSAHOLD_NEGATIVE           = '-1'
  LSAMAX_NEGATIVE            = '-1'
  LSASTART_NEGATIVE          = '-1'
  SPFHOLD_NEGATIVE           = '-1'
  SPFMAX_NEGATIVE            = '-1'
  SPFSTART_NEGATIVE          = '-1'

  # A. Methods to create manifests for cisco_ospf_vrf Puppet provider test cases.

  # Method to create a manifest for OSPFVRF resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    auto_cost                => 'default',
    default_metric           => 'default',
    log_adjacency            => 'default',
    timer_throttle_lsa_hold  => 'default',
    timer_throttle_lsa_max   => 'default',
    timer_throttle_lsa_start => 'default',
    timer_throttle_spf_hold  => 'default',
    timer_throttle_spf_max   => 'default',
    timer_throttle_spf_start => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => absent,
  }
  cisco_ospf { 'test':
    ensure                   => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attributes:
  # ensure, auto_cost, default_metric, log_adjacency, timer_throttle_lsa_hold,
  # timer_throttle_lsa_max, timer_throttle_lsa_start, timer_throttle_spf_hold,
  # timer_throttle_spf_max and timer_throttle_spf_start.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    auto_cost                => '80000',
    default_metric           => '1',
    log_adjacency            => 'log',
    timer_throttle_lsa_hold  => '2000',
    timer_throttle_lsa_max   => '10000',
    timer_throttle_lsa_start => '1',
    timer_throttle_spf_hold  => '2000',
    timer_throttle_spf_max   => '10000',
    timer_throttle_spf_start => '400',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'autocost'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_autocost_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    auto_cost                => #{OspfVrfLib::AUTOCOST_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'default_metric'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_defaultmetric_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    default_metric           => #{OspfVrfLib::DEFAULTMETRIC_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'lsahold'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_lsahold_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    timer_throttle_lsa_hold  => #{OspfVrfLib::LSAHOLD_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'lsamax'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_lsamax_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    timer_throttle_lsa_max   => #{OspfVrfLib::LSAMAX_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'lsastart'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_lsastart_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    timer_throttle_lsa_start => #{OspfVrfLib::LSASTART_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'spfhold'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_spfhold_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    timer_throttle_spf_hold  => #{OspfVrfLib::SPFHOLD_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'spfmax'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_spfmax_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    timer_throttle_spf_max   => #{OspfVrfLib::SPFMAX_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for OSPFVRF resource attribute 'spfstart'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_ospfvrf_manifest_spfstart_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_ospf_vrf { 'test green':
    ensure                   => present,
    timer_throttle_spf_start => #{OspfVrfLib::SPFSTART_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
