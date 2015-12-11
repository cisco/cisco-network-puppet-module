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
# BgpNeighbor-Provider-Nondefaults.rb
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
# This is a BGP Neighbor resource test that tests for non-default values of all
# attributes except password and type when created with 'ensure' => 'present'.
# Password and type attributes will be tested in another test case as they
# don't support idempotent.
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
testheader = 'BGP Neighbor Resource :: Attribute Non-defaults'
UtilityLib.set_manifest_path(master, self)
id = 'test_green'
tests = {
  :master => master,
  :agent  => agent,
}

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for provider test'
  node_feature_cleanup(agent, 'bgp', stepinfo)
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  asn = 42
  vrf = 'red'
  tests[id] = {}
  ['1.1.1.1', '2.2.2.0/24'].each do |neighbor|
    tests[id] = {
      :manifest_props => {
        :ensure                 => :present,
        :asn                    => asn,
        :vrf                    => vrf,
        :neighbor               => neighbor,
        :description            => 'tested by beaker',
        :connected_check        => :true,
        :capability_negotiation => :true,
        :dynamic_capability     => :true,
        :ebgp_multihop          => 2,
        :local_as               => 42,
        :log_neighbor_changes   => :enable,
        :low_memory_exempt      => :true,
        :remote_as              => 12.1,
        :remove_private_as      => :all,
        :shutdown               => :true,
        :suppress_4_byte_as     => :true,
        :timers_keepalive       => 90,
        :timers_holdtime        => 270,
        :update_source          => 'Ethernet1/1',
      },
      :resource       => {
        'ensure'                 => 'present',
        'description'            => 'tested by beaker',
        'connected_check'        => 'true',
        'capability_negotiation' => 'true',
        'dynamic_capability'     => 'true',
        'ebgp_multihop'          => '2',
        'local_as'               => '42',
        'log_neighbor_changes'   => 'enable',
        'low_memory_exempt'      => 'true',
        'remote_as'              => '12.1',
        'remove_private_as'      => 'all',
        'shutdown'               => 'true',
        'suppress_4_byte_as'     => 'true',
        'timers_keepalive'       => '90',
        'timers_holdtime'        => '270',
        'update_source'          => 'ethernet1/1',
      },
    }
    resource_cmd_str =
      UtilityLib::PUPPET_BINPATH +
      "resource cisco_bgp_neighbor '#{asn} #{vrf} #{neighbor}'"
    tests[id][:resource_cmd] =
      get_namespace_cmd(agent, resource_cmd_str, options)
    # transport_passive_only attribute is only available in neighbor ip address
    # format, maximum_peers option is only available in neighbor ip/prefix
    # format.
    if neighbor == '1.1.1.1'
      tests[id][:manifest_props][:transport_passive_only] = :true
      tests[id][:resource]['transport_passive_only'] = 'true'
      tests[id][:manifest_props][:maximum_peers] = nil
      tests[id][:resource]['maximum_peers'] = '0'
    else
      tests[id][:manifest_props][:transport_passive_only] = nil
      tests[id][:resource]['transport_passive_only'] =
        'false'
      tests[id][:manifest_props][:maximum_peers] = 2
      tests[id][:resource]['maximum_peers'] = '2'
    end

    tests[id][:desc] =
      '1.1 Apply manifest with non-default attributes, and test harness'
    create_bgpneighbor_manifest(tests, id)
    test_harness_common(tests, id)

    tests[id][:desc] =
      '1.2 Apply manifest with string format non-default attributes'
    tests[id][:manifest_props] = {
      :ensure                 => :present,
      :asn                    => asn,
      :vrf                    => vrf,
      :neighbor               => neighbor,
      :description            => 'tested by beaker',
      :connected_check        => 'true',
      :capability_negotiation => 'true',
      :dynamic_capability     => 'true',
      :ebgp_multihop          => '2',
      :local_as               => '42',
      :log_neighbor_changes   => 'enable',
      :low_memory_exempt      => 'true',
      :remote_as              => '12.1',
      :remove_private_as      => 'all',
      :shutdown               => 'true',
      :suppress_4_byte_as     => 'true',
      :timers_keepalive       => '90',
      :timers_holdtime        => '270',
      :update_source          => 'ethernet1/1',
    }
    if neighbor == '1.1.1.1'
      tests[id][:manifest_props][:transport_passive_only] = 'true'
      tests[id][:manifest_props][:maximum_peers] = nil
    else
      tests[id][:manifest_props][:transport_passive_only] = nil
      tests[id][:manifest_props][:maximum_peers] = '2'
    end

    create_bgpneighbor_manifest(tests, id)
    # In this case, nothing changed, we would expect the puppet run return 0,
    tests[id][:code] = [0]
    test_manifest(tests, id)

    tests[id][:desc] =
      '1.3 Update manifest and test harness'
    tests[id][:manifest_props] = {
      :ensure                 => :present,
      :asn                    => asn,
      :vrf                    => vrf,
      :neighbor               => neighbor,
      :description            => '',
      :connected_check        => 'false',
      :capability_negotiation => 'false',
      :dynamic_capability     => 'false',
      :ebgp_multihop          => 'default',
      :local_as               => 1.1,
      :log_neighbor_changes   => 'disable',
      :low_memory_exempt      => 'false',
      :remote_as              => 1.1,
      :remove_private_as      => 'disable',
      :shutdown               => 'false',
      :suppress_4_byte_as     => 'false',
      :timers_keepalive       => '30',
      :timers_holdtime        => '90',
      :update_source          => 'ethernet1/2',
    }
    tests[id][:resource] = {
      'ensure'                 => :present,
      'connected_check'        => 'false',
      'capability_negotiation' => 'false',
      'dynamic_capability'     => 'false',
      'ebgp_multihop'          => 'false',
      'local_as'               => '1.1',
      'log_neighbor_changes'   => 'disable',
      'low_memory_exempt'      => 'false',
      'remote_as'              => '1.1',
      'remove_private_as'      => 'disable',
      'shutdown'               => 'false',
      'suppress_4_byte_as'     => 'false',
      'timers_keepalive'       => '30',
      'timers_holdtime'        => '90',
      'update_source'          => 'ethernet1/2',
    }
    tests[id][:show_cmd] = "show run bgp all | section #{neighbor}"
    # when description is empty string, puppet resource will not return
    # its value, we have to use show command to verify its removal
    tests[id][:show_pattern] = [/description/]
    tests[id][:state] = true
    tests[id][:code] = nil
    create_bgpneighbor_manifest(tests, id)
    test_harness_common(tests, id)

    tests[id][:desc] =
      '1.4 Change format of local_as and remote_as, and verify idempotent'
    tests[id][:manifest_props][:local_as] = 65_537
    tests[id][:manifest_props][:remote_as] = 65_537
    tests[id][:code] = [0]
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)
  end
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
