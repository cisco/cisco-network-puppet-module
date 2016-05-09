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
#
# See README-develop-beaker-scripts.md (Section: Test Script Variable Reference)
# for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################
#
# 'test_private_vlan' tests *VLAN* related private_vlan properties.
#
# (See 'test_interface_private_vlan' for interface-related private-vlan tests)
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  resource_name:    'cisco_vlan',
  operating_system: 'nexus',
  platform:         'n(3|5|6|7|9)k',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# assoc = %w(99 101 102 105)
tests[:primary] = {
  desc:           '1.1 Primary',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'primary',
    # private_vlan_association: assoc,
  },
  resource:       {
    private_vlan_type: 'primary',
    # TBD: BROKEN (idempotence). It inputs a multi-member list but normalizes to a
    # single index: ['99 100 102 105']. This is wrong but we will keep this
    # temporarily to show the broken behavior.
    # private_vlan_association: "#{assoc}",
  },
}

tests[:community] = {
  desc:           '1.2 Community',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'community'
  },
}

tests[:isolated] = {
  desc:           '1.3 Isolated',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'isolated'
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  remove_all_vlans(agent)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Property Testing")
  test_harness_run(tests, :primary)
  test_harness_run(tests, :community)
  test_harness_run(tests, :isolated)

  remove_all_vlans(agent)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
