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
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  platform:         'n7k',
  resource_name:    'cisco_encapsulation',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  manifest_props: {
    dot1q_map: 'default'
  },
  resource:       {},
}

mapping = Array['100-151,200-250', '5100-5150,6000,5151-5201']
tests[:non_default] = {
  desc:           '2.1 Non Default Properties change dot1q mapping',
  title_pattern:  'cisco',
  manifest_props: {
    dot1q_map: mapping
  },
}

# TEST PRE-REQUISITES
#   - F3 linecard assigned to admin vdc
def dependency_manifest(*)
  "
    cisco_vdc { '#{default_vdc_name}':
      ensure                     => present,
      limit_resource_module_type => 'f3',
    }
  "
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  skip_unless_supported(tests)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  id = :default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")
  test_harness_run(tests, :non_default)

  # -------------------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_encapsulation')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
