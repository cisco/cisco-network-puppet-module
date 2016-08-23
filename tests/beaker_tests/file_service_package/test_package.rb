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

case image?
when /7.0.3.I2.1/
  filename = 'n9000_sample-1.0.0-7.0.3.x86_64.rpm'
  name =     'n9000_sample'
  version =  '1.0.0-7.0.3'
when /7.0.3.I3.1/
  filename = 'CSCuxdublin-1.0.0-7.0.3.I3.1.lib32_n9000.rpm'
  name =     'CSCuxdublin'
  version =  '1.0.0-7.0.3.I3.1'
when /7.0.3.I4.1/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.1.lib32_n9000.rpm'
  name =     'nxos.sample-n9k_EOR'
  version =  '1.0.0-7.0.3.I4.1'
when /7.0.3.I5/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I5.1.lib32_n9000.rpm'
  name =     'nxos.sample-n9k_EOR'
  version =  '1.0.0-7.0.3.I5.1'
else
  raise_skip_exception("No patch specified for image #{image?}", self)
end

unless resource_present?(agent, 'file', "/bootflash/#{filename}")
  raise_skip_exception("RPM file /bootflash/#{filename} not found", self)
end

tests = {
  agent:         agent,
  master:        master,
  platform:      'n(3|8|9)k',
  resource_name: 'package',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

tests[:yum_patch] = {
  desc:                 "1.1 Apply sample patch to image #{image?}",
  title_pattern:        name,
  ensure_prop_override: true,
  manifest_props: {
    name:             filename,
    provider:         'cisco',
    source:           "/bootflash/#{filename}",
    package_settings: { 'target' => 'host' },
  },
  resource:       {
    'ensure' => version
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { resource_absent_by_title(agent, 'package', name) }
  resource_absent_by_title(agent, 'package', name)

  # -------------------------------------------------------------------
  test_harness_run(tests, :yum_patch)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
