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
  master:        master,
  agent:         agent,
  ensurable:     false,
  resource_name: 'package',
}

tests[:install] = {
  desc:           'Install package',
  title_pattern:  'xrv9k-ospf-1.0.0.0-r61107I',
  manifest_props: {
    description:        'present',
    ensure:             'present',
    name:               'xrv9k-ospf-1.0.0.0-r61107I.x86_64.rpm-XR-DEV-16.03.24C',
    provider:           'cisco',
    source:             '/disk0:/xrv9k-ospf-1.0.0.0-r61107I.x86_64.rpm-XR-DEV-16.03.24C',
    platform:           'x86_64',
    package_settings:   {},
  },
  resource:       {
    'ensure' => 'present',
  },
}

tests[:uninstall] = {
  desc:           'Uninstall package',
  title_pattern:  'xrv9k-ospf-1.0.0.0-r61107I',
  manifest_props: {
    description:        'absent',
    ensure:             'absent',
    name:               'xrv9k-ospf-1.0.0.0-r61107I.x86_64.rpm-XR-DEV-16.03.24C',
    provider:           'cisco',
    source:             '/disk0:/xrv9k-ospf-1.0.0.0-r61107I.x86_64.rpm-XR-DEV-16.03.24C',
    platform:           'x86_64',
    package_settings:   {},
  },
  resource:       {
    'ensure' => 'absent',
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: Source Present" do

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Install package testing")
  id = :install
  tests[id][:code] = [0, 2]
  test_harness_run(tests, id)
  logger.info("\n#{'-' * 60}\nTest Complete")
  skipped_tests_summary(tests)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Uninstall package testing")
  id = :uninstall
  tests[id][:code] = [0, 2]
  test_harness_run(tests, id)
  logger.info("\n#{'-' * 60}\nTest Complete")
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
