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
# BgpNeighbor-Provider-negative.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP Neighbor resource testcase to test negative values
# in the manifest
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a BGP Neighbor resource test that tests for various negative values
# when created with 'ensure' => 'present' to make sure the type validation
# is working
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

# Require UtilityLib.rb and BgpNeighborLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../bgpneighborlib.rb', __FILE__)

result = 'PASS'
testheader = 'BGP Neighbor Resource :: Negative Value Test'
neighbor_name = 'test_green'
UtilityLib.set_manifest_path(master, self)
bgp_neighbor = {
  :master => master,
  :agent => agent,
}

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for provider test'
  node_feature_cleanup(agent, 'bgp', stepinfo, logger)
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  asn = 42
  vrf = 'red'
  title = neighbor_name
  bgp_neighbor[title] = {
    :manifest_props => {
      :ensure => :present,
    },
    :resource => {
      'ensure' => 'present',
    },
    :code => [1],
  }

  bgp_neighbor[title][:log_desc] =
    'apply title pattern of resource name'
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  stepinfo = 'apply a manifest that misses asn'
  title = 'missing_asn'
  bgp_neighbor[title] = {
    :log_desc => stepinfo,
    :manifest_props => {
      :ensure => :present,
      :vrf => vrf,
      :neighbor => '1.1.1.1',
    },
    :code => [1],
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  stepinfo = "apply title pattern of 'asn vrf', missing neighbor"
  title = "#{asn} #{vrf}"
  bgp_neighbor[title] = {
    :log_desc => stepinfo,
    :manifest_props => {
      :ensure => :present,
    },
    :code => [1],
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  stepinfo = 'apply invalid asn'
  title = neighbor_name
  bgp_neighbor[title] = {
    :log_desc => stepinfo,
    :manifest_props => {
      :ensure => :present,
      :asn => '5 12',
      :vrf => vrf,
      :neighbor => '1.1.1.1',
    },
    :code => [1],
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  title = "#{asn} #{vrf} 1.1.1.1"
  bgp_neighbor[title] = {
    :log_desc => 'apply invalid local_as',
    :manifest_props => {
      :ensure => :present,
      :local_as => '5 12'
    },
    :code => [1],
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply invalid remote_as'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :remote_as => '5 12'
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply invalid ebgp_multihop value'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :ebgp_multihop => 256,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply maximum_peers when it is not allowed'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :maximum_peers => 2,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  title = "#{asn} #{vrf} 1.1.1.0/24"
  bgp_neighbor[title] = {
    :log_desc => 'apply invalid maximum_peers number',
    :manifest_props => {
      :ensure => :present,
      :maximum_peers => 1001,
    },
    :code => [1],
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply invalid password'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :password_type => default,
    :password => 32,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply invalid keepalive timer'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :timers_keepalive => 3700,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply invalid holdtime timer'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :timers_holdtime => 3700,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] =
    'apply transport_passive_only when it is not allowed'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :transport_passive_only => true,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] = 'apply invalid update_source'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :update_source => 15,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] =
    'validate password type must be present, if password is configured'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :password => 'test',
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  bgp_neighbor[title][:log_desc] =
    'validate password must be present, if password type is present'
  bgp_neighbor[title][:manifest_props] = {
    :ensure => :present,
    :password_type => :cleartext,
  }
  create_bgpneighbor_manifest(title, bgp_neighbor)
  test_manifest(bgp_neighbor, title)

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  UtilityLib.raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
