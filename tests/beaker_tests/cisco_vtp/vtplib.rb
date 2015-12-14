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

# VTP Utility Library:
# --------------------
# vtplib.rb
#
# This is the utility library for the VTP provider Beaker test cases that
# contains the common methods used across the VTP testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker VTP test case that runs an instance of Beaker::TestCase
# requires VtpLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for cisco_vtp Puppet provider test cases.
module VtpLib
  # Group of Constants used in negative tests for VTP provider.
  DOMAIN_NEGATIVE         = ''
  FILENAME_NEGATIVE       = ''
  PASSWORD_NEGATIVE       = ''
  VERSION_NEGATIVE        = '-1'

  # A. Methods to create manifests for cisco_vtp Puppet provider test cases.

  # Method to create a manifest for VTP resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => present,
    domain    => 'cisco1234',
    filename  => 'default',
    password  => 'default',
    version   => 'default',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for VTP resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => absent,
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for VTP resource attributes:
  # ensure, filename, password and version.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => present,
    domain    => 'cisco1234',
    filename  => 'vtp.dat',
    password  => 'cisco12345$%^&',
    version   => '2',
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for VTP resource attribute 'domain'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_domain_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => present,
    domain    => #{VtpLib::DOMAIN_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for VTP resource attribute 'filename'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_filename_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => present,
    domain    => 'cisco1234',
    filename  => #{VtpLib::FILENAME_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for VTP resource attribute 'password'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_password_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => present,
    domain    => 'cisco1234',
    password  => #{VtpLib::PASSWORD_NEGATIVE},
  }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for VTP resource attribute 'version'.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_vtp_manifest_version_negative
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  cisco_vtp { 'default':
    ensure    => present,
    domain    => 'cisco1234',
    version   => #{VtpLib::VERSION_NEGATIVE},
  }
}
EOF"
    manifest_str
  end
end
