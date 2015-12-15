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

# TACACSERVER Utility Library:
# ----------------------------
# tacacsserverlib.rb
#
# This is the utility library for the TACACSSERVER Beaker test cases that
# contains the common methods used across the TACACSSERVER testsuite cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker TACACSSERVER test case that runs an instance of Beaker::TestCase
# requires TacacsServerLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_tacacs_server Puppet provider tests.
module TacacsServerLib
  # Group of Constants used in negative tests for TACACSSERVER provider.
  TIMEOUT_NEGATIVE       = '-1'
  DEADTIME_NEGATIVE      = '-1'
  ENCRYPTYPE_NEGATIVE    = '-1'
  ENCRYPPASSWD_NEGATIVE  = ''
  SOURCEINTF_NEGATIVE    = 'unknown'

  # A. Methods to create manifests for cisco_tacacs_server Puppet provider tests.

  # Method to create a manifest for TACACSSERVER attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'default':
    ensure              => present,
    timeout             => 'default',
    deadtime            => 'default',
    encryption_type     => 'default',
    encryption_password => 'default',
    directed_request    => 'false',
    source_interface    => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'default':
    ensure              => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attributes:
  # ensure, timeout, deadtime, encryption_type, encryption_password,
  # directed_request and source_interface.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'test':
    ensure              => present,
    timeout             => 50,
    deadtime            => 'default',
    encryption_type     => 'encrypted',
    encryption_password => 'WXYZ12',
    directed_request    => 'false',
    source_interface    => 'Ethernet1/4',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attribute 'timeout'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_timeout_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'test':
    ensure              => present,
    timeout             => #{TacacsServerLib::TIMEOUT_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attribute 'deadtime'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_deadtime_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'test':
    ensure              => present,
    deadtime            => #{TacacsServerLib::DEADTIME_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attribute 'encryption_type'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_type_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'test':
    ensure              => present,
    encryption_type     => #{TacacsServerLib::ENCRYPTYPE_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attribute 'encryption_password'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_passwd_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'test':
    ensure              => present,
    encryption_type     => 'default',
    encryption_password => #{TacacsServerLib::ENCRYPPASSWD_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVER attribute 'source_interface'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserver_sourceintf_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server { 'test':
    ensure              => present,
    source_interface    => #{TacacsServerLib::SOURCEINTF_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
