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

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_bridge_domain'

# Top-level keys set by caller:
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_bridge_domain',
  platform:      'n7k',
}

tests[:non_default] = {
  desc:           "1.1 Non Default Properties 'change name, state and fabric_control",
  title_pattern:  '100',
  manifest_props: {
    bd_name:        'PepsiCo',
    fabric_control: true,
    shutdown:       true,
  },
}

tests[:non_default_change_state] = {
  desc:           "1.2 Non Default Properties 'change state of previous bridge-domain'",
  title_pattern:  '100',
  manifest_props: {
    bd_name:        'PepsiCo',
    fabric_control: true,
    shutdown:       false,
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")
  test_harness_run(tests, :non_default)
  test_harness_run(tests, :non_default_change_state)
  resource_absent_cleanup(agent, 'cisco_bridge_domain', 'bridge-domain CLEANUP :: ')
end

logger.info('TestCase :: # {testheader} :: End')
