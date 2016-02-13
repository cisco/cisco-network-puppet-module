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
# Network DNS Utility Library:
# ---------------------
# network_dnslib.rb
#
# This is the utility library for the network_dns provider Beaker test cases
# that contains the common methods used across the network_dns testsuite's
# cases. The library is implemented as a module with related methods and
# constants defined inside it for use as a namespace. All of the methods are
# defined as module methods.
#
# Every Beaker network dns test case that runs an instance of Beaker::TestCase
# requires NetworkDnsLib module.
#
# The module has a single set of methods:
# A. Methods to create manifests for network_dns Puppet provider test cases.
###############################################################################

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# A library to assist testing network_dns resource
module NetworkDnsLib
  # A. Methods to create manifests for network_dns Puppet provider test cases.

  # Method to create a manifest for network_dns resource properties
  # @param domain [String] The value to pass to the domain property
  # @param search [Array, String] The value to pass to the search property
  # @param servers [Array, String] The value to pass to the servers property
  # @result none [None] Returns no object.
  def self.create_network_dns_manifest(domain, search, servers)
    manifest_str = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {
  network_dns { 'settings':
    domain  => #{domain.inspect},
    search  => #{search.inspect},
    servers => #{servers.inspect},
  }
}
EOF"
    manifest_str
  end
end
