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
testheader = 'Resource cisco_encapsulation'

# Define PUPPETMASTER_MANIFESTPATH.

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# Top-level keys set by caller:
tests = {
  master:           master,
  agent:            agent,
  resource_name:    'cisco_encapsulation',
  operating_system: 'nexus',
}

mapping = Array['100-151,200-250', '5100-5150,6000,5151-5201']
tests['non_default_properties_change_mapping'] = {
  desc:           '1.1 Non Default Properties change dot1q mapping',
  title_pattern:  'cisco',
  manifest_props: {
    dot1q_map: mapping
  },
}

mapping = Array['100-151,200-250', '8000-8001,5102-5150,6000,5151-5201']
tests['non_default_properties_change_mapping_of_existing_profile'] = {
  desc:           "1.2 Non Default Properties again change dot1q mapping of same profile'",
  title_pattern:  'cisco',
  manifest_props: {
    dot1q_map: mapping
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")
  test_harness_run(tests, 'non_default_properties_change_mapping')
  test_harness_run(tests, 'non_default_properties_change_mapping_of_existing_profile')

  resource_absent_cleanup(agent, 'cisco_encapsulation', 'Encapsulation CLEANUP :: ')
end

logger.info('TestCase :: # {testheader} :: End')
