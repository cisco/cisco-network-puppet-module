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
  resource_name: 'syslog_settings',
  intf_type:     'mgmt',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

intf = find_interface(tests)

# Test hash test cases
tests[:defaults] = {
  title_pattern:  'default',
  manifest_props: {
    console:          2,
    monitor:          5,
    source_interface: ['unset'],
    time_stamp_units: 'seconds',
  },
  code:           [0, 2],
}

# Test hash test cases
tests[:non_default] = {
  title_pattern:  'default',
  manifest_props: {
    console:                2,
    monitor:                5,
    source_interface:       ["#{intf}"],
    time_stamp_units:       'milliseconds',
    logfile_name:           'testlogfile',
    logfile_severity_level: 3,
    logfile_size:           4098,
  },
}

# Test hash test cases
tests[:unsetting] = {
  title_pattern:  'default',
  manifest_props: {
    console:                2,
    monitor:                5,
    source_interface:       ['unset'],
    time_stamp_units:       'seconds',
    logfile_name:           'unset',
    logfile_severity_level: 'unset',
    logfile_size:           'unset',
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default settings")
  test_harness_run(tests, :defaults)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default settings")
  test_harness_run(tests, :non_default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Unsetting settings")
  test_harness_run(tests, :unsetting)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
