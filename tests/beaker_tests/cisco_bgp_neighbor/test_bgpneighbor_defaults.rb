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
# BgpNeighbor-Provider-Defaults.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP Neighbor resource testcase for Puppet Agent on Nexus
# devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a BGP Neighbor resource test that tests for attribute default values
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
# rubocop:disable Style/HashSyntax,Style/ExtraSpacing,Metrics/MethodLength

# Require UtilityLib.rb and BgpNeighborLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../bgpneighborlib.rb', __FILE__)

UtilityLib.set_manifest_path(master, self)
result = 'PASS'
testheader = 'BGP Neighbor Resource :: Attribute Defaults'
id = 'test_green'
tests = {
  :master => master,
  :agent  => agent,
}

def create_bgp_neighbor_defaults(tests, id, title, string=false)
  asn = title[:asn]
  vrf = title[:vrf]
  neighbor = title[:neighbor]
  val = string ? 'default' : :default

  tests[id][:manifest_props] = {
    :ensure             => :present,
    :asn                => asn,
    :vrf                => vrf,
    :neighbor           => neighbor,
    :ebgp_multihop      => val,
    :local_as           => val,
    :low_memory_exempt  => val,
    :remote_as          => val,
    :suppress_4_byte_as => val,
    :timers_keepalive   => val,
    :timers_holdtime    => val,
  }

  tests[id][:resource] = {
    'ensure'                 => 'present',
    'ebgp_multihop'          => 'false',
    'local_as'               => '0',
    'low_memory_exempt'      => 'false',
    'maximum_peers'          => '0',
    'remote_as'              => '0',
    'suppress_4_byte_as'     => 'false',
    'timers_keepalive'       => '60',
    'timers_holdtime'        => '180',
    'transport_passive_only' => 'false',
  }

  if neighbor.split('/')[1].nil?
    # transport_passive_only attribute is only available in neighbor ip address
    # format, maximum_peers option is only available in neighbor ip/prefix
    # format.
    tests[id][:manifest_props][:transport_passive_only] = val
    tests[id][:manifest_props][:maximum_peers] = nil
  else
    tests[id][:manifest_props][:transport_passive_only] = nil
    tests[id][:manifest_props][:maximum_peers] = val
  end

  create_bgpneighbor_manifest(tests, id)
  resource_cmd_str =
    UtilityLib::PUPPET_BINPATH +
    "resource cisco_bgp_neighbor '#{asn} #{vrf} #{neighbor}'"
  tests[id][:resource_cmd] =
    get_namespace_cmd(agent, resource_cmd_str, options)
end

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for provider test'
  node_feature_cleanup(agent, 'bgp', stepinfo)
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  tests[id] = {}
  ['1.1.1.1', '2.2.2.0/24'].each do |neighbor|
    title = { :asn => 42, :vrf => 'red', :neighbor => neighbor }

    tests[id][:desc] =
      "1.1 Apply default manifest with 'default' as a string in attributes"
    create_bgp_neighbor_defaults(tests, id, title, true)
    test_manifest(tests, id)

    tests[id][:desc] =
      '1.2 Check cisco_bgp_neighbor resource present on agent'
    test_resource(tests, id)

    tests[id][:desc] =
      "1.3 Apply default manifest with 'default' as a symbol in attributes"
    create_bgp_neighbor_defaults(tests, id, title, false)
    # In this case, nothing changed, we would expect the puppet run return 0,
    # It also verified idempotent of the provider.
    tests[id][:code] = [0]
    test_manifest(tests, id)

    tests[id][:desc] = '1.4 Test resource absent manifest'
    tests[id][:manifest_props] = {
      :ensure   => :absent,
      :asn      => title[:asn],
      :vrf      => title[:vrf],
      :neighbor => title[:neighbor],
    }
    tests[id][:code] = nil
    tests[id][:resource] = { 'ensure' => 'absent' }
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)

    tests[id][:desc]  = '1.5 Verify resource absent on agent'
    test_resource(tests, id)
  end
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
