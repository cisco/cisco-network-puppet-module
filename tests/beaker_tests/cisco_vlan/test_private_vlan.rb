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
# The platform: key below must use an end of string anchor '$' in order to
# distinguish between 'n9k' and 'n9k-f' platform flavors.
tests = {
  agent:            agent,
  master:           master,
  resource_name:    'cisco_vlan',
  operating_system: 'nexus',
  platform:         'n(3|5|6|7|9)k$',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:primary] = {
  desc:           '1.1 Primary',
  title_pattern:  '100',
  manifest_props: {
    pvlan_type:        'primary',
    pvlan_association: '101, 102, 98-99, 105',
  },
  resource:       {
    pvlan_type:        'primary',
    pvlan_association: "['98-99', '101-102', '105']",
  },
}

tests[:community] = {
  desc:           '1.2 Community',
  title_pattern:  '100',
  manifest_props: {
    pvlan_type: 'community'
  },
}

tests[:isolated] = {
  desc:           '1.3 Isolated',
  title_pattern:  '100',
  manifest_props: {
    pvlan_type: 'isolated'
  },
}

def cleanup(agent)
  remove_all_vlans(agent)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    cleanup(agent)
    vdc_limit_f3_no_intf_needed(:clear)
  end
  cleanup(agent)
  vdc_limit_f3_no_intf_needed(:set)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Property Testing")
  test_harness_run(tests, :primary)

  remove_all_vlans(agent)
  test_harness_run(tests, :community)

  remove_all_vlans(agent)
  test_harness_run(tests, :isolated)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
