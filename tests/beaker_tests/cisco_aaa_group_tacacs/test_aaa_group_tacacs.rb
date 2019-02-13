###############################################################################
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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
#
# See README-develop-beaker-scripts.md (Section: Test Script Variable Reference)
# for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:         agent,
  master:        master,
  resource_name: 'cisco_aaa_group_tacacs',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default',
  title_pattern:  'beaker',
  preclean:       'cisco_aaa_group_tacacs',
  manifest_props: {
    deadtime:         'default',
    source_interface: 'default',
    server_hosts:     'default',
    vrf_name:         'default',
  },
  resource:       {
    deadtime: '0',
    # source_interface: nil,
    # server_hosts:     nil,
    vrf_name: 'default',
  },
}

# Test hash test cases
tests[:non_default] = {
  desc:           '2.1 Non Default',
  title_pattern:  'bkr_grp',
  manifest_props: {
    deadtime:         '30',
    source_interface: 'loopback42',
    server_hosts:     ['bkrhost', '1.1.1.1'],
    vrf_name:         'beaker',
  },
}

# class to contain the test_dependencies specific to this test case
class TestAaaGroupTacacs < BaseHarness
  # Overridden to properly handle dependencies for this test file.
  def self.dependency_manifest(ctx, _tests, id)
    dep = ''
    if id == :non_default
      dep = %(
        cisco_tacacs_server      { 'default': ensure => present }
        cisco_tacacs_server_host { 'bkrhost': ensure => present }
        cisco_tacacs_server_host { '1.1.1.1': ensure => present }
      )
    end
    ctx.logger.info("\n  * dependency_manifest\n#{dep}")
    dep
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default
  test_harness_run(tests, id, harness_class: TestAaaGroupTacacs)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  id = :non_default
  test_harness_run(tests, id, harness_class: TestAaaGroupTacacs)
  tests[id][:ensure] = :absent
  test_harness_run(tests, id, harness_class: TestAaaGroupTacacs)

  # -------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_aaa_group_tacacs')
  resource_absent_cleanup(agent, 'cisco_tacacs_server')
  resource_absent_cleanup(agent, 'cisco_tacacs_server_host')
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
