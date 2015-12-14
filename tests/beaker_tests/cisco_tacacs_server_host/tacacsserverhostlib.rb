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

# TACACSERVERHOST Utility Library:
# --------------------------------
# tacacsserverhostlib.rb
#
# This is the utility library for the TACACSSERVERHOST Beaker test cases that
# contains the common methods used across the TACACSSERVERHOST testsuite. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker TACACSSERVERHOST test that runs an instance of Beaker::TestCase
# requires TacacsServerHostLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_tacacs_server_host Puppet tests.
module TacacsServerHostLib
  # Group of Constants used in negative tests for TACACSSERVERHOST provider.
  TIMEOUT_NEGATIVE       = '-1'
  PORT_NEGATIVE          = '-1'
  ENCRYPTYPE_NEGATIVE    = '-1'
  ENCRYPPASSWD_NEGATIVE  = ''

  # A. Methods to create manifests for cisco_tacacs_server_host Puppet tests.

  # Method to create a manifest for TACACSSERVERHOST attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => present,
    port                => 'default',
    timeout             => 'default',
    encryption_type     => 'default',
    encryption_password => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVERHOST attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVERHOST attributes:
  # ensure, timeout, deadtime, encryption_type, encryption_password,
  # directed_request and source_interface.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => present,
    port                => 90,
    timeout             => 39,
    encryption_type     => 'encrypted',
    encryption_password => 'test123',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVERHOST attribute 'timeout'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_timeout_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => present,
    timeout             => #{TacacsServerHostLib::TIMEOUT_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSSERVERHOST attribute 'port'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_port_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => present,
    port                => #{TacacsServerHostLib::PORT_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSHOST attribute 'encryption_type'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_type_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => present,
    encryption_type     => #{TacacsServerHostLib::ENCRYPTYPE_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for TACACSHOST attribute 'encryption_password'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_tacacsserverhost_passwd_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_tacacs_server_host { 'samplehost1':
    ensure              => present,
    encryption_type     => 'default',
    encryption_password => #{TacacsServerHostLib::ENCRYPPASSWD_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
