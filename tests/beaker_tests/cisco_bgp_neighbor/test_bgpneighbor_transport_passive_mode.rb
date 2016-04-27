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
# test_bgpneighbor_transport_passive_mode.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet BGP Neighbor resource testcase for Puppet Agent on Nexus
# and XR devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Host configuration file contains agent and master information.
# B. SSH is enabled on the Agent.
# C. Puppet master/server is started.
# D. Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This is a BGP Neighbor resource test that tests valid values for the
# transport-passive-mode property.
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

id = 'transport_passive_mode'
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_bgp_neighbor',
}

test_name "TestCase :: #{tests[:resource_name]} - #{id}" do
  resource_absent_cleanup(agent, 'cisco_bgp')

  os = on(agent, facter_cmd('-p os.name')).stdout.chomp
  vrf = 'red'
  neighbor = '1.1.1.1'

  modes = [:passive_only]
  if os == 'ios_xr'
    modes << :active_only
    modes << :both
  end
  modes << :none

  modes.each do |mode|
    tests[id] = {
      title_pattern:  "2 #{vrf} #{neighbor}",
      desc:           "1.1 Test mode '#{mode}'",
      manifest_props: {
        remote_as:              99,
        transport_passive_mode: mode,
      },
    }

    test_harness_run(tests, id)
  end

  tests[id][:desc] = '1.2 Verify :default is the same as :none'
  tests[id][:manifest_props] = {
    transport_passive_mode: :default
  }
  # In this case, nothing changed, we would expect the puppet run to return 0.
  tests[id][:code] = [0]
  create_manifest_and_resource(tests, id)
  test_manifest(tests, id)
  test_resource(tests, id)

  resource_absent_cleanup(agent, 'cisco_bgp')

  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} - #{id} :: End")
