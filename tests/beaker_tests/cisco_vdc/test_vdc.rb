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
  resource_name:    'cisco_vdc',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Skip -ALL- tests if being run on a non-default VDC
skip_non_default_vdc(agent)

# Test hash test cases
tests[:non_default] = {
  desc:           '1.1 non default properties',
  title_pattern:  default_vdc_name,

  # This property does not have a meaningful default state because the module
  # types depend on which linecards are installed. Simply set the list to
  # a single common mod type and ensure that is the only type shown.
  manifest_props: { limit_resource_module_type: 'f3' },
}

# class to contain the test_harness_dependencies
class TestVdc < BaseHarness
  def self.test_harness_dependencies(ctx, _tests, id)
    return unless id == :non_default

    # Set module-type to default value
    ctx.limit_resource_module_type_set(ctx.default_vdc_name, nil)
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { vdc_limit_f3_no_intf_needed(:clear) }

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")
  test_harness_run(tests, :non_default, harness_class: TestVdc)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
