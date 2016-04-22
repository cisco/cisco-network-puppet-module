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

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bridge_domain_vni'

# Top-level keys set by caller:
tests = {
  master:           master,
  agent:            agent,
  resource_name:    'cisco_bridge_domain_vni',
  platform:         'n7k',
  operating_system: 'nexus',
}

tests[:default] = {
  title_pattern:  '100-110',
  manifest_props: {
    member_vni: ''
  },
}

tests[:non_default_properties_change_member_vni] = {
  desc:           '2.1 Non Default Properties for ordered member vni',
  title_pattern:  '100-110',
  manifest_props: {
    member_vni: '5100-5105,6050,7000-7001,5050,8000'
  },
}

tests[:non_default_properties_random_member_vni] = {
  desc:           '3.1 Non Default Properties for random member vni',
  title_pattern:  '100-105,150,200-203',
  manifest_props: {
    member_vni: '5100-5105,6050,7000-7001,5050,8000'
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")

  id = :non_default_properties_change_member_vni
  test_harness_run(tests, id)
  resource_absent_cleanup(agent, 'cisco_bridge_domain_vni', 'bridge-domain CLEANUP :: ')

  id = :non_default_properties_random_member_vni
  test_harness_run(tests, id)
  resource_absent_cleanup(agent, 'cisco_bridge_domain_vni', 'bridge-domain CLEANUP :: ')
end

logger.info('TestCase :: # {testheader} :: End')
