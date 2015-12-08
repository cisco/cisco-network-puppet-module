################################################################################
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
################################################################################
#
# TestCase Name:
# -------------
# BgpNeighbor-Provider-Titlepattern.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP Neighbor resource testcase to test neighbor title
# pattern.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a BGP Neighbor resource test that tests for various title patterns
# when created with 'ensure' => 'present'.
#
# The testcode checks for exit_codes from Puppet Agent, Vegas shell and
# Bash shell command executions. For Vegas shell and Bash shell command
# string executions, this is the exit_code convention:
# 0 - successful command execution, > 0 - failed command execution.
# For Puppet Agent command string executions, this is the exit_code convention:
# 0 - no changes have occurred, 1 - errors have occurred,
# 2 - changes have occurred, 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# Note: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The testcode also uses RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################
# rubocop:disable Style/HashSyntax

# Require UtilityLib.rb and BgpNeighborLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../bgpneighborlib.rb', __FILE__)

result = 'PASS'
testheader = 'BGP Neighbor Resource :: Title Pattern Test'
id = 'test_green'
UtilityLib.set_manifest_path(master, self)
tests = {
  :master => master,
  :agent  => agent,
}

test_name "TestCase :: #{testheader}" do
  tests[id] = {}
  init_bgp(tests, id) # clean slate
  stepinfo = 'Setup switch for provider test'
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  asn_title = BgpLib::ASN.to_s
  neighbor = '1.1.1.1'
  ['default', :default, 'red'].each do |vrf|
    tests[id] = {
      :desc           => '1.1 Apply title pattern of resource name and test harness',
      :manifest_props => {
        :ensure   => :present,
        :asn      => BgpLib::ASN,
        :vrf      => vrf,
        :neighbor => neighbor,
      },
      :resource       => {
        'ensure' => 'present'
      },
    }
    resource_cmd_str =
      UtilityLib::PUPPET_BINPATH +
      "resource cisco_bgp_neighbor '#{asn_title} #{vrf} #{neighbor}'"
    tests[id][:resource_cmd] =
      UtilityLib.get_namespace_cmd(agent, resource_cmd_str, options)
    create_bgpneighbor_manifest(tests, id)
    # when the bgp neighbor is first created, we test its harness first
    if vrf == 'default' || vrf == 'red'
      test_harness_common(tests, id)
    else
      # In this case, nothing changed, we would expect the puppet run return 0.
      tests[id][:code] = [0]
      test_manifest(tests, id)
    end

    id = "#{BgpLib::ASN}"
    tests[id] = {
      :desc           => '1.2 Apply title pattern of asn',
      :code           => [0],
      :manifest_props => {
        :ensure   => :present,
        :vrf      => vrf,
        :neighbor => neighbor,
      },
    }
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)

    if vrf == 'default'
      # Test if :vrf can default to 'default'
      tests[id] = {
        :desc           => '1.3 Test default vrf in manifest',
        :code           => [0],
        :manifest_props => {
          :ensure   => :present,
          :neighbor => neighbor,
        },
      }
      create_bgpneighbor_manifest(tests, id)
      test_manifest(tests, id)
    end

    id = "#{BgpLib::ASN} #{vrf}"
    tests[id] = {
      :desc           => "1.4 Apply title pattern of 'asn vrf'",
      :code           => [0],
      :manifest_props => {
        :ensure   => :present,
        :neighbor => neighbor,
      },
    }
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)

    id = "#{BgpLib::ASN} #{vrf} #{neighbor}"
    tests[id] = {
      :desc           => "1.5 Apply title pattern of 'asn vrf neighbor'",
      :code           => [0],
      :manifest_props => {
        :ensure => :present
      },
    }
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)

    id = "#{BgpLib::ASN} #{vrf} 1.1.1.1"
    tests[id] = {
      :desc           => '1.6 Test neighbor munge function',
      :code           => [0],
      :manifest_props => {
        :ensure => :present
      },
    }
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)
  end

  cleanup_bgp(tests, id)

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
