###############################################################################
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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
  agent:         agent,
  master:        master,
  platform:      'n9k$|n9k-ex',
  resource_name: 'cisco_ip_multicast',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Skip -ALL- tests if feature is not supported by image version
skip_nexus_image(/I[2-6]/, tests)

# Default values changed between I7.3 and I7.4
spt_default = nexus_image[/7\.0\(3\)I7\([1-3]\)/] ? false : true

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    overlay_distributed_dr: 'default',
    overlay_spt_only:       'default',
  },
  resource:       {
    overlay_distributed_dr: 'false',
    overlay_spt_only:       spt_default.to_s,
  },
}

#
# non_default_properties
#
tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  'default',
  manifest_props: {
    overlay_distributed_dr: 'false',
    overlay_spt_only:       (!spt_default).to_s,
  },
  resource:       {
    overlay_distributed_dr: 'false',
    overlay_spt_only:       (!spt_default).to_s,
  },
}

def cleanup(agent)
  # On some image versions, overlay_distributed_dr cannot be
  # configured if an nve interface is configured and in the
  # 'no shutdown' state.  Remove any nve interfaces before
  # starting this test.
  # NOTE: There can only be one nve interface.
  test_set(agent, 'no interface nve1', ignore_errors: true)
  resource_absent_cleanup(agent, 'cisco_ip_multicast')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = :default
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
