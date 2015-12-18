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

# FILESVCPKG Utility Library:
# ----------------------------
# filesvcpkglib.rb
#
# This is the utility library for the FILESVCPKG provider Beaker test cases that
# contains the common methods used across the FILESVCPKG testsuite's cases. The
# library is implemented as a module with related methods and constants defined
# inside it for use as a namespace. All of the methods are defined as module
# methods.
#
# Every Beaker FILESVCPKG test case that runs an instance of Beaker::TestCase
# requires FileSvcPkgLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for file, service and pkg Puppet test cases.
module FileSvcPkgLib
  # A. Methods to create manifests for file, service and pkg Puppet test cases.

  # Method to create a manifest for FILE resource attributes:
  # path, ensure, content, checksum, mode, owner and provider.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_file_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    file { 'testfile.txt':
        path            => '/tmp/testfile.txt',
        ensure          => present,
        content         => 'These are the contents of the file.',
        checksum        => 'sha256',
        mode            => 'ug+rw',
        owner           => 'root',
        provider        => 'posix',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for FILE resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_file_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    file { 'testfile.txt':
        path            => '/tmp/testfile.txt',
        ensure          => absent,
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SVC resource attributes:
  # name, ensure and enable.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_service_manifest_nondefaults
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    service { 'syslog':
        name            => 'syslog',
        ensure          => 'running',
        enable          => 'true',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for SVC resource attribute 'ensure' where
  # 'ensure' is set to stopped.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_service_manifest_stopped
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    service { 'syslog':
        name            => 'syslog',
        ensure          => 'stopped',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for PKG resource attribute 'ensure' where
  # 'ensure' is set to installed.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_package_curl_manifest_installed
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    package { 'curl':
        name            => 'curl',
        ensure          => installed,
        provider        => 'yum',
        allow_virtual   => 'false',
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for PKG resource attribute 'ensure' where
  # 'ensure' is set to latest.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_package_curl_manifest_latest
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    package { 'curl':
        name            => 'curl',
        ensure          => latest,
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for PKG resource attribute 'ensure' where
  # 'ensure' is set to present.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_package_sample_manifest_present
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    package { 'n9000_sample.x86_64':
        name            => 'n9000_sample-1.0.0-7.0.3.x86_64.rpm',
        ensure          => present,
        provider        => 'nxapi',
        source          => '/bootflash/n9000_sample-1.0.0-7.0.3.x86_64.rpm',
        package_settings => {'target' => 'host'},
    }
}
EOF"
    manifest_str
  end

  # Method to create a manifest for PKG resource attribute 'ensure' where
  # 'ensure' is set to absent.
  # @param none [None] No input parameters exist.
  # @result none [None] Returns no object.
  def self.create_package_sample_manifest_absent
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
    package { 'n9000_sample.x86_64':
        name            => 'n9000_sample-1.0.0-7.0.3.x86_64.rpm',
        ensure          => absent,
        provider        => 'nxapi',
        source          => '/bootflash/n9000_sample-1.0.0-7.0.3.x86_64.rpm',
        package_settings => {'target' => 'host'},
    }
}
EOF"
    manifest_str
  end
end
