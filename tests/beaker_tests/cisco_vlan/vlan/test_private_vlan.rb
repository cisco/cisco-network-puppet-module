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

require File.expand_path('../../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource private_vlan'

# Top-level keys set by caller:
tests = {
  master:           master,
  agent:            agent,
  resource_name:    'cisco_vlan',
  operating_system: 'nexus',
  platform:         'n(3|5|6|7|9)k',
}

tests[:primary] = {
  desc:           '2.1 configure pvlan primary type',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'primary'
  },
}

tests[:community] = {
  desc:           '2.2 change type: primary to community',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'community'
  },
}

tests[:isolated] = {
  desc:           '2.3 change type: community to isolated',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'isolated'
  },
}

tests[:isolated_101] = {
  desc:           '2.4 configured isolated vlan',
  title_pattern:  '101',
  manifest_props: {
    private_vlan_type: 'isolated'
  },
}

tests[:community_102] = {
  desc:           '2.5 configured community vlan',
  title_pattern:  '102',
  manifest_props: {
    private_vlan_type: 'community'
  },
}

vlan_assoc = %w(99 101 102 105)
tests[:association] = {
  desc:           '2.6 configured private vlan association',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_association: ['99,101-102,105']
  },
  resource:       {
    'private_vlan_association' => "#{vlan_assoc}"
  },
}

tests[:association_default] = {
  desc:           '2.7 private vlan association default',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_association: 'default'
  },
  resource:       {
  },
}

tests[:type_default] = {
  desc:           '2.8 private vlan type default',
  title_pattern:  '100',
  manifest_props: {
    private_vlan_type: 'default'
  },
  resource:       {
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Property Testing")
  resource_absent_cleanup(agent, 'cisco_vlan', 'private-vlan CLEANUP :: ')
  test_harness_run(tests, :primary)
  test_harness_run(tests, :community)
  test_harness_run(tests, :isolated)
  test_harness_run(tests, :primary)
  test_harness_run(tests, :isolated_101)
  test_harness_run(tests, :community_102)
  test_harness_run(tests, :association)
  test_harness_run(tests, :association_default)
  test_harness_run(tests, :type_default)
  resource_absent_cleanup(agent, 'cisco_vlan', 'private-vlan CLEANUP :: ')
end

logger.info('TestCase :: # {testheader} :: End')
