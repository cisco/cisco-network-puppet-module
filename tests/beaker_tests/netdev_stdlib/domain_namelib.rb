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
# Domain Name Utility Library:
# ---------------------
# domain_namelib.rb
#
# This is the utility library for the domain name provider Beaker test cases
# that contains the common methods used across the domain_name testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker domain name test case that runs an instance of Beaker::TestCase
# requires DomainNameLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for domain_name Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing domain_name resource
module DomainNameLib
  # Group of Constants used in negative tests for domain_name provider.
  ENSURE_NEGATIVE = 'unknown'
  NAME_VALID      = 'test.xyz'
  NAME_INVALID    = 'a.b.c'

  # A. Methods to create manifests for domain_name Puppet provider test cases.

  # Method to create a manifest for domain_name resource attribute 'ensure'
  # where 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_domain_name_manifest_present
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  domain_name {'#{DomainNameLib::NAME_VALID}':
    ensure => present,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for domain_name resource attribute 'ensure'
  # where 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_domain_name_manifest_absent
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  domain_name {'#{DomainNameLib::NAME_VALID}':
    ensure => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for domain_name resource attribute 'ensure'
  # where 'ensure' is set to unknown.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_domain_name_manifest_negative
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  domain_name {'#{DomainNameLib::NAME_VALID}':
    ensure => #{DomainNameLib::ENSURE_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for domain_name resource attribute 'name'
  # where 'name' is set to invalid parameter.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_domain_name_manifest_name_invalid
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
node default {
  domain_name {'#{DomainNameLib::NAME_INVALID}':
    ensure => present,
  }
}
EOF"
    manifest_str
  end
end
