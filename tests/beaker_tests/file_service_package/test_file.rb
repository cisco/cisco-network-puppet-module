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

tests = {
  agent:         agent,
  master:        master,
  resource_name: 'file',
  agent_only:    true,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

testfile = '/tmp/testfile.txt'

tests[:testfile] = {
  title_pattern:  testfile,
  manifest_props: {
    path:     testfile,
    content:  'This is a puppet/beaker test file',
    checksum: 'sha256',
    mode:     'ug+rw',
    owner:    'root',
    provider: 'posix',
  },
  resource:       {
    'ensure'  => 'file',
    'content' => '{md5}[0-9a-fA-F]*',
    'group'   => '0',
    'mode'    => '0664',
    'owner'   => '0',
    'type'    => 'file',
  },
}

def cleanup(agent, testfile)
  on(agent, "rm -f #{testfile}", acceptable_error_codes: [0, 2])
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent, testfile) }
  cleanup(agent, testfile)

  # ----------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Create & Destroy")
  id = :testfile
  tests[id][:desc] = '1.1 Create test file'
  test_harness_run(tests, id)

  tests[id][:desc] = '1.2 Remove test file'
  tests[id][:ensure] = :absent
  test_harness_run(tests, id)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
