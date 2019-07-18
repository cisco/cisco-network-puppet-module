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
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  platform:         'n7k',
  resource_name:    'cisco_bridge_domain_vni',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Skip -ALL- tests if being run on a non-default VDC
skip_non_default_vdc(agent)

tests[:default] = {
  title_pattern:  '100-110',
  manifest_props: {
    member_vni: ''
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default',
  title_pattern:  '100-110',
  manifest_props: {
    member_vni: '5100-5105,6050,7000-7001,5050,8000'
  },
}

tests[:non_default_random] = {
  desc:           '2.2 Non Default Properties for random member vni',
  title_pattern:  '100-105,150,200-203',
  manifest_props: {
    member_vni: '5100-5105,6050,7000-7001,5050,8000'
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  teardown do
    remove_all_vlans(agent)
    vdc_limit_f3_no_intf_needed(:clear)
  end
  remove_all_vlans(agent)
  vdc_limit_f3_no_intf_needed(:set)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default)
  resource_absent_cleanup(agent, 'cisco_bridge_domain_vni')

  test_harness_run(tests, :non_default_random)
end
logger.info('TestCase :: # {testheader} :: End')
