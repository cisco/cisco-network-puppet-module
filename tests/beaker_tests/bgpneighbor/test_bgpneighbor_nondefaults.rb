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
  tests[id] = {}
  init_bgp(tests, id)
  stepinfo = 'Setup switch for provider test'
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  platform = fact_on(agent, 'os.name')

  vrf = 'red'
  addrs = ['1.1.1.1', '2000::2']
  update_source = 'fastethernet1/1/1/1'
  if platform != 'ios_xr'
    addrs << '2.2.2.0/24'
    update_source = 'ethernet1/1'
  end
  addrs.each do |neighbor|
    tests[id] = {
      :manifest_props => {
        :ensure             => :present,
        :asn                => BgpLib::ASN,
        :vrf                => vrf,
        :neighbor           => neighbor,
        :description        => 'tested by beaker',
        :connected_check    => :true,
        :ebgp_multihop      => 2,
        :local_as           => 43,
        :remote_as          => 12.1,
        :shutdown           => :true,
        :suppress_4_byte_as => :true,
        :timers_keepalive   => 90,
        :timers_holdtime    => 270,
        :update_source      => update_source,
      },
      :resource       => {
        'ensure'             => 'present',
        'description'        => 'tested by beaker',
        'connected_check'    => 'true',
        'ebgp_multihop'      => '2',
        'local_as'           => '43',
        'remote_as'          => '12.1',
        'shutdown'           => 'true',
        'suppress_4_byte_as' => 'true',
        'timers_keepalive'   => '90',
        'timers_holdtime'    => '270',
        'update_source'      => update_source,
      },
    }

    if platform != 'ios_xr' # add properties not supported on XR
      tests[id][:manifest_props][:capability_negotiation] = :true
      tests[id][:manifest_props][:dynamic_capability] = :true
      tests[id][:manifest_props][:log_neighbor_changes] = :enable
      tests[id][:manifest_props][:low_memory_exempt] = :true
      tests[id][:manifest_props][:remove_private_as] = :all
      tests[id][:resource]['capability_negotiation'] = 'true'
      tests[id][:resource]['dynamic_capability'] = 'true'
      tests[id][:resource]['log_neighbor_changes'] = 'enable'
      tests[id][:resource]['low_memory_exempt'] = 'true'
      tests[id][:resource]['remove_private_as'] = 'all'
      # maximum_peers handled below
    end

    resource_cmd_str =
      UtilityLib::PUPPET_BINPATH +
      "resource cisco_bgp_neighbor '#{BgpLib::ASN} #{vrf} #{neighbor}'"
    tests[id][:resource_cmd] =
      UtilityLib.get_namespace_cmd(agent, resource_cmd_str, options)
    # transport_passive_only attribute is only available in neighbor ip address
    # format, maximum_peers option is only available in neighbor ip/prefix
    # format.
    if neighbor.split('/')[1].nil?
      tests[id][:manifest_props][:transport_passive_only] = :true
      tests[id][:resource]['transport_passive_only'] = 'true'
      tests[id][:manifest_props][:maximum_peers] = nil
      tests[id][:resource]['maximum_peers'] = '0' if platform != 'ios_xr'
    else
      tests[id][:manifest_props][:transport_passive_only] = nil
      tests[id][:resource]['transport_passive_only'] = 'false'
      tests[id][:manifest_props][:maximum_peers] = 2 if platform != 'ios_xr'
      tests[id][:resource]['maximum_peers'] = '2' if platform != 'ios_xr'
    end

    tests[id][:desc] =
      '1.1 Apply manifest with non-default attributes, and test harness'
    create_bgpneighbor_manifest(tests, id)
    test_harness_common(tests, id)

    tests[id][:desc] =
      '1.2 Apply manifest with string format non-default attributes'
    tests[id][:manifest_props] = {
      :ensure             => :present,
      :asn                => BgpLib::ASN,
      :vrf                => vrf,
      :neighbor           => neighbor,
      :description        => 'tested by beaker',
      :connected_check    => 'true',
      :ebgp_multihop      => '2',
      :local_as           => '43',
      :remote_as          => '12.1',
      :shutdown           => 'true',
      :suppress_4_byte_as => 'true',
      :timers_keepalive   => '90',
      :timers_holdtime    => '270',
      :update_source      => update_source,
    }

    if platform != 'ios_xr' # add properties not supported on XR
      tests[id][:manifest_props][:capability_negotiation] = 'true'
      tests[id][:manifest_props][:dynamic_capability] = 'true'
      tests[id][:manifest_props][:log_neighbor_changes] = 'enable'
      tests[id][:manifest_props][:low_memory_exempt] = 'true'
      tests[id][:manifest_props][:remove_private_as] = 'all'
      # maximum_peers handled below
    end

    if neighbor.split('/')[1].nil?
      tests[id][:manifest_props][:transport_passive_only] = 'true'
      tests[id][:manifest_props][:maximum_peers] = nil if platform != 'ios_xr'
    else
      tests[id][:manifest_props][:transport_passive_only] = nil
      tests[id][:manifest_props][:maximum_peers] = '2' if platform != 'ios_xr'
    end

    create_bgpneighbor_manifest(tests, id)
    # In this case, nothing changed, we would expect the puppet run return 0,
    tests[id][:code] = [0]
    test_manifest(tests, id)

    update_source = 'ethernet1/2'
    update_source = 'fastethernet1/2/1/1' if platform == 'ios_xr'

    tests[id][:desc] =
      '1.3 Update manifest and test harness'
    tests[id][:manifest_props] = {
      :ensure             => :present,
      :asn                => BgpLib::ASN,
      :vrf                => vrf,
      :neighbor           => neighbor,
      :description        => '',
      :connected_check    => 'false',
      :ebgp_multihop      => 'default',
      :local_as           => 1.1,
      :remote_as          => 1.2,
      :shutdown           => 'false',
      :suppress_4_byte_as => 'false',
      :timers_keepalive   => '30',
      :timers_holdtime    => '90',
      :update_source      => update_source,
    }
    tests[id][:resource] = {
      'ensure'             => :present,
      'connected_check'    => 'false',
      'ebgp_multihop'      => 'false',
      'local_as'           => '1.1',
      'remote_as'          => '1.2',
      'shutdown'           => 'false',
      'suppress_4_byte_as' => 'false',
      'timers_keepalive'   => '30',
      'timers_holdtime'    => '90',
      'update_source'      => update_source,
    }

    if platform != 'ios_xr' # add properties not supported on XR
      tests[id][:manifest_props][:capability_negotiation] = 'false'
      tests[id][:manifest_props][:dynamic_capability] = 'false'
      tests[id][:manifest_props][:log_neighbor_changes] = 'disable'
      tests[id][:manifest_props][:low_memory_exempt] = 'false'
      tests[id][:manifest_props][:remove_private_as] = 'disable'
      tests[id][:resource]['capability_negotiation'] = 'false'
      tests[id][:resource]['dynamic_capability'] = 'false'
      tests[id][:resource]['log_neighbor_changes'] = 'disable'
      tests[id][:resource]['low_memory_exempt'] = 'false'
      tests[id][:resource]['remove_private_as'] = 'disable'
    end

    # when description is empty string, puppet resource will not return
    # its value, we have to check for its absence.
    tests[id][:code] = nil
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)
    stash_resource = tests[id][:resource]
    tests[id][:resource] = { 'description' => UtilityLib::IGNORE_VALUE }
    test_resource(tests, id, true)
    tests[id][:resource] = stash_resource # restore

    tests[id][:desc] =
      '1.4 Change format of local_as and remote_as, and verify idempotent'
    tests[id][:manifest_props][:local_as] = 65_537
    tests[id][:manifest_props][:remote_as] = 65_538
    tests[id][:code] = [0]
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)
  end

  cleanup_bgp(tests, id)

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
