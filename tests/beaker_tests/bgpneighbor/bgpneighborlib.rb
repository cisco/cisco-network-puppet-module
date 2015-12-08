###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../../bgp/bgplib.rb', __FILE__)

# Method to create a manifest for bgp neighbor with attributes:
# @param name [String] Name of the bgp neighbor.
# @param tests [Hash] a hash that contains the supported attributes
# @result none [None] Returns no object.
def create_bgpneighbor_manifest(tests, name)
  tests[name][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node default {
    cisco_bgp_neighbor { '#{name}':
#{prop_hash_to_manifest(tests[name][:manifest_props])}
    }
  }\nEOF"
end

# Initialize BGP (clean up + enable BGP)
def init_bgp(tests, name)
  tests[name][:desc] = 'Initialize BGP'
  tests[name][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      resources { cisco_bgp: purge => true }
      cisco_bgp { 'default':
        ensure => present,
        asn    => #{BgpLib::ASN},
      }
    }\nEOF"
  tests[name][:code] = [0, 2, 6]
  test_manifest(tests, name)
end

# Clean up BGP
def cleanup_bgp(tests, name)
  tests[name][:desc] = 'Clean up BGP'
  tests[name][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node 'default' {
      resources { cisco_bgp: purge => true }
    }\nEOF"
  tests[name][:code] = [0, 2, 6]
  test_manifest(tests, name)
end
