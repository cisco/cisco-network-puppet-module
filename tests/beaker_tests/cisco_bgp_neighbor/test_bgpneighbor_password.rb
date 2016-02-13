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
# BgpNeighbor-Provider-password.rb
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
# This is a BGP Neighbor resource test that tests for password and type
# attributes when created with 'ensure' => 'present'.
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
testheader = 'BGP Neighbor Resource :: Password and type attributes'
id = 'test_green'

tests = {
  :master => master,
  :agent  => agent,
}

test_name "TestCase :: #{testheader}" do
  stepinfo = 'Setup switch for provider test'
  resource_absent_cleanup(agent, 'cisco_bgp')
  logger.info("TestStep :: #{stepinfo} :: #{result}")

  asn = 42
  vrf = 'red'
  tests[id] = {}
  neighbor = '1.1.1.1'
  passwords = { :default    => 'test',
                'default'   => 'test',
                :cleartext  => 'test',
                'cleartext' => 'test',
              }
  passwords.each do |type, password|
    tests[id] = {
      :manifest_props => { :ensure        => :present,
                           :asn           => asn,
                           :vrf           => vrf,
                           :neighbor      => neighbor,
                           :password_type => type,
                           :password      => password,
                   },
      :resource       => {
        'ensure'   => 'present',
        'password' => '386c0565965f89de',
      },
    }
    resource_cmd_str =
      PUPPET_BINPATH +
      'resource cisco_bgp_neighbor ' + "'#{asn} #{vrf} #{neighbor}'"
    tests[id][:resource_cmd] =
      get_namespace_cmd(agent, resource_cmd_str, options)
    tests[id][:desc] = '1.1 Apply manifest with password attributes'
    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)

    tests[id][:desc] = '1.2 Verify puppet resource'
    test_resource(tests, id)

    tests[id][:desc] = '1.3 Test removing the password'
    tests[id][:manifest_props][:password] = ''

    create_bgpneighbor_manifest(tests, id)
    test_manifest(tests, id)
  end
  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
