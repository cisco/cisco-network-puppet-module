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
  platform:      'n(3|9)k',
  resource_name: 'package',
  agent_only:    true,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)
skip_nexus_image(%w(I2 I3), tests)

name = 'nxos.sample-n9k_EOR'
case image?
when /7.0.3.I2.1/
  # Version 7.0.3.I2.1 needs this specific patch.  Attempts to build
  # new patches for this version with the patch tool don't work.
  name =     'n9000_sample'
  filename = 'n9000_sample-1.0.0-7.0.3.x86_64.rpm'
  version =  '1.0.0-7.0.3'
when /7.0.3.I2.2e/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I2.2e.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I2.2e'
when /7.0.3.I2.5/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I2.5.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I2.5'
when /7.0.3.I3.1/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I3.1.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I3.1'
when /7.0.3.I4.1/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.1.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I4.1'
when /7.0.3.I4.2/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.2.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I4.2'
when /7.0.3.I4.5/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.5.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I4.5'
when /7.0.3.I4.6/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.6.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I4.6'
when /7.0.3.I4.8/
  filename = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.8.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I4.8'
when /7.0.3.I5.1/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I5.1.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I5.1'
when /7.0.3.I5.2/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I5.2.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I5.2'
when /7.0.3.I5.3/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I5.3.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I5.3'
when /7.0.3.I6.1/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I6.1.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I6.1'
when /7.0.3.I7.1/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I7.1.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I7.1'
when /7.0.3.I7.2/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I7.2.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I7.2'
when /7.0.3.I7.3/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I7.3.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I7.3'
when /7.0.3.I7.4/
  name = 'nxos.sample-n9k_ALL'
  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I7.4.lib32_n9000.rpm'
  version =  '1.0.0-7.0.3.I7.4'
when /7.0.3.F1/
  name = 'nxos.sample-n8k_EOR'
  filename = 'nxos.sample-n8k_EOR-1.0.0-7.0.3.F1.1.lib32_nxos.rpm'
  version =  '1.0.0-7.0.3.F1.1'
else
  raise_skip_exception("No patch available for image #{image?}", self)
end

unless resource_present?(agent, 'file', "/bootflash/#{filename}")
  raise_skip_exception("RPM file /bootflash/#{filename} not found", self)
end

tests[:yum_patch_install] = {
  desc:           "1.1 Apply sample patch #{name} to image #{image?}",
  title_pattern:  name,
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

tests[:yum_patch_remove] = {
  desc:           "1.2 Remove sample patch #{name}",
  code:           [0, 2],
  ensure:         :absent,
  title_pattern:  name,
  manifest_props: {
    name:             filename,
    provider:         'cisco',
    package_settings: { 'target' => 'host' },
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # The puppet resource command cannot be used in the guestshell
  # to query patches that are applied to the host.  This test will
  # call explicit api's to test the following for both the native
  # and guestshell workflow:
  # 1) Apply manifest.
  # 2) Verify patch is applied on the host.
  # 3) Idempotence Test.
  create_package_manifest_resource(tests, :yum_patch_install)
  create_package_manifest_resource(tests, :yum_patch_remove)

  teardown { test_manifest(tests, :yum_patch_remove) }
  test_manifest(tests, :yum_patch_remove)

  test_manifest(tests, :yum_patch_install)
  test_patch_version(tests, :yum_patch_install, name, version)
  test_idempotence(tests, :yum_patch_install)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
