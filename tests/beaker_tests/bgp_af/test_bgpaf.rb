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
###############################################################################
# TestCase Name:
# -------------
# test_bgpaf.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP AF resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This BGP AF resource test verifies default values for all properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../bgpaflib.rb', __FILE__)
# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bgp_af :: All default property values'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

# Create hash entries for each test case's manifest config data and
# puppet resource command expected results.
# :manifest is used to create the manifest that gets applied on the puppet master
# :resource is used to build the test data structure that gets compared to the
#  manifest application result
data_hash = {}

#
# Test_1_default_properties
#
# client_to_client (default is no client-to-client reflection)
# default_information_originate
data_hash['Test_1_default_properties'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => 'default',
    default_information_originate => 'default',
    ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'false',
    'default_information_originate' => 'false',
  }
}

#
# Test_2_non_default_properties
#
data_hash['Test_2_non_default_properties'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => false,
    default_information_originate => false,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'false',
    'default_information_originate' => 'false',
    'next_hop_route_map'            => 'RouteMap',
  }
}

#
# Test_3_non_default_properties
#
data_hash['Test_3_non_default_properties'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => true,
    default_information_originate => true,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'true',
    'default_information_originate' => 'true',
    'next_hop_route_map'            => 'RouteMap',
  }
}

#
# Test_4_title_pattern1
#
data_hash['1'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => false,
    default_information_originate => true,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'false',
    'default_information_originate' => 'true',
    'next_hop_route_map'            => 'RouteMap',
  }
}

#
# Test_4_title_pattern2
#
data_hash['1 red'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => true,
    default_information_originate => false,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'true',
    'default_information_originate' => 'false',
    'next_hop_route_map'            => 'RouteMap',
  }
}

#
# Test_4_title_pattern3
#
data_hash['1 red ipv4'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => true,
    default_information_originate => true,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'true',
    'default_information_originate' => 'true',
    'next_hop_route_map'            => 'RouteMap',
  }
}

#
# Test_4_title_pattern4
#
data_hash['1 red ipv4 unicast'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => false,
    default_information_originate => false,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'false',
    'default_information_originate' => 'false',
    'next_hop_route_map'            => 'RouteMap',
  }
}

#
# Test_4_title_pattern5
#
data_hash['1 red ipv4 multicast'] = {
  :manifest => "
    ensure                        => present,
    client_to_client              => false,
    default_information_originate => false,
    next_hop_route_map            => 'RouteMap',
  ",

  :resource => {
    'ensure'                        => 'present',
    'client_to_client'              => 'false',
    'default_information_originate' => 'false',
    'next_hop_route_map'            => 'RouteMap',
  }
}

# Create actual manifest for a given test scenario
def build_manifest(af, data_hash, test_name)
  "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
     node 'default' {
       cisco_bgp_af { '#{test_name}':
         #{BgpAFLib.manifest_id_props(af)}
         #{data_hash[test_name][:manifest]}
       }
     }
     EOF"
end

# Wrapper for processing the four tests for each test scenario
def harness(af, test_name, master, agent, data_hash, test_name_hash = '')
  logger.info("----\nAddress-Family ID: #{af} #{test_name}")

  node_cleanup_bgp(agent, 'Clean Test Node')

  test_manifest(master, agent,
                build_manifest(af, data_hash, test_name),
                test_name)

  unless test_name_hash.to_s.empty?
    # Merge title pattern hash and original af if using a title pattern
    af = af.merge(test_name_hash)
  end

  test_resource(agent, puppet_resource_cmd(af),
                data_hash[test_name][:resource], test_name)

  test_show_run(agent, 'show run bgp all', BgpAFLib.af_pattern(af), test_name)

  test_idempotence(agent, test_name)

  # Clean up old manifest, change ensure to absent
  # Create an absent data hash
  data_hash_absent = {}
  data_hash_absent["#{test_name}"] = {
    :manifest => "
      ensure => absent,
    ",

    :resource => {
      'ensure' => 'absent',
    }
  }

  test_absent(master, agent,
              build_manifest(af, data_hash_absent, test_name),
              test_name)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -----------------------------------
  # Test 1. Default properties
  # -----------------------------------
  test_name = 'Test_1_default_properties'
  af = { :asn => 2, :vrf => 'blue', :afi => 'ipv4', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash)

  # -----------------------------------
  # Test 2. Non-Default properties
  # -----------------------------------
  test_name = 'Test_2_non_default_properties'
  af = { :asn => 2, :vrf => 'blue', :afi => 'ipv4', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash)

  # -----------------------------------
  # Test 3. Non-Default properties (change afi and safi)
  # -----------------------------------
  test_name = 'Test_3_non_default_properties'
  af = { :asn => 2, :vrf => 'blue', :afi => 'ipv4', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash)

  # IPv6
  test_name = 'Test_3_non_default_properties'
  af = { :asn => 2, :vrf => 'green', :afi => 'ipv6', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash)

  # IPv4 Multicast
  test_name = 'Test_3_non_default_properties'
  af = { :asn => 55, :vrf => 'red', :afi => 'ipv4', :safi => 'multicast' }
  harness(af, test_name, master, agent, data_hash)

  # -----------------------------------
  # Test 4. Test Title Patterns
  # -----------------------------------
  # 'test_name' is also a title pattern
  # 'test_name_hash' is a copy of test_name in hash format. This is
  # necessary because in the case of title patterns we need to combine the title
  # pattern and the af to run the puppet resource command.

  # Title pattern includes asn
  test_name = '1'
  test_name_hash = { :asn => '1' }
  af = { :asn => nil, :vrf => 'red', :afi => 'ipv4', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash, test_name_hash)

  # Title pattern includes asn and vrf
  test_name = '1 red'
  test_name_hash = { :asn => '1', :vrf => 'red' }
  af = { :asn => nil, :vrf => '', :afi => 'ipv4', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash, test_name_hash)

  # Title pattern includes asn, vrf and afi
  test_name = '1 red ipv4'
  test_name_hash = { :asn => '1', :vrf => 'red', :afi => 'ipv4' }
  af = { :asn => nil, :vrf => '', :afi => '', :safi => 'unicast' }
  harness(af, test_name, master, agent, data_hash, test_name_hash)

  # Title pattern includes asn, vrf, afi and safi
  test_name = '1 red ipv4 unicast'
  test_name_hash = { :asn => '1', :vrf => 'red', :afi => 'ipv4', :safi => 'unicast' }
  af = { :asn => nil, :vrf => '', :afi => '', :safi => '' }
  harness(af, test_name, master, agent, data_hash, test_name_hash)

  # Title pattern includes asn, vrf, afi and safi (changed)
  test_name = '1 red ipv4 multicast'
  test_name_hash = { :asn => '1', :vrf => 'red', :afi => 'ipv4', :safi => 'multicast' }
  af = { :asn => nil, :vrf => '', :afi => '', :safi => '' }
  harness(af, test_name, master, agent, data_hash, test_name_hash)
end

logger.info("TestCase :: #{testheader} :: End")
