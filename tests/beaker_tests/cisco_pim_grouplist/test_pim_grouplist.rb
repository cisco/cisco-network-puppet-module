###############################################################################
# Copyright (c) 2016 Cisco and/or its affiliates.
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
# See README-beaker-script-ref.md for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

testheader = 'Resource cisco_pim_grouplist'

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_pim_grouplist',
}

# Test hash test cases
tests[:title_patterns] = {
  preclean:       'cisco_pim_grouplist',
  manifest_props: {},
  resource:       { 'ensure' => 'present' },
}

titles = {}
titles['T.1'] = {
  title_pattern: 'new_york',
  title_params:  {
    afi: 'ipv4', vrf: 'blue', rp_addr: '1.1.1.1', group: '224.0.0.0/8'
  },
}
titles['T.2'] = {
  title_pattern: 'ipv4',
  title_params:  { vrf: 'cyan', rp_addr: '2.2.2.2', group: '224.0.0.0/8' },
}
titles['T.3'] = {
  title_pattern: 'ipv4 green',
  title_params:  { rp_addr: '3.3.3.3', group: '224.0.0.0/8' },
}
titles['T.4'] = {
  title_pattern: 'ipv4 yellow 4.4.4.4',
  title_params:  { group: '224.0.0.0/8' },
}
titles['T.5'] = {
  title_pattern: 'ipv4 magenta 4.4.4.4 224.0.0.0/8'
}

#################################################################
# HELPER FUNCTIONS
#################################################################

def test_harness_pim_grouplist(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  create_manifest(tests, id)

  resource_absent_cleanup(agent, tests[id][:preclean], 'BGP CLEAN :: ') if
    tests[id][:preclean]

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Title Pattern Testing")
  test_title_patterns(tests, :title_patterns, titles)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_pim_grouplist')
end
logger.info("TestCase :: #{testheader} :: End")
