###############################################################################
# Copyright (c) 2017 Cisco and/or its affiliates.
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
if platform[/n9k/] && full_version.to_s.strip[/I9/]
  @version = full_version.to_s.strip.split('I', 2)[0]
else
  @version = full_version.to_s.strip
end
# Test hash top-level keys
tests = {
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  ensurable:        false,
  resource_name:    'cisco_upgrade',
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default
tests[:non_default] = {
  desc:           '1.1 Non_Defaults',
  code:           [0],
  title_pattern:  'image',
  platform:       'n(3|9)k',
  manifest_props: {
    package:           package,
    force_upgrade:     false,
    delete_boot_image: false,
  },
  resource:       {
    package: package,
    version: @version,
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection Non Default Property Testing")
  test_harness_run(tests, :non_default)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
