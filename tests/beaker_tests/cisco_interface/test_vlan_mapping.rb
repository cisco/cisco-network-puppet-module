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
# TestCase Name:
# -------------
# test_vlan_mapping.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet Interface resource testcase of vlan_mapping properties,
# for use with Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
###############################################################################
#
#        ****************************************
#        ** IMPORTANT ADDITIONAL PREREQUISITES **
#        ****************************************
#
# The vlan_mapping properties are "Multi-Tenancy Full" properties which
# currently have limited platform and linecard support. This test script will
# look for these requirements and fail if they are not present:
#
#  - VDC support
#  - F3 linecard
#
# This test will need to be updated as the product matures.
#
###############################################################################
#
# TestCase:
# ---------
# This resource test verifies default values for all properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_interface: vlan_mapping properties'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:bridge_domain] - the bridge-domain configuration
# tests[:switchport_mode] - the interface switchport mode type
#
tests = {
  master:          master,
  agent:           agent,
  resource_name:   'cisco_interface',
  bridge_domain:   '199',
  switchport_mode: 'trunk',
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#

tests['default_properties'] = {
  desc:           '1.1 Default Properties',
  manifest_props: {
    vlan_mapping_enable: 'default',
    vlan_mapping:        'default',
  },
  resource:       {
    'vlan_mapping_enable' => 'true',
    # 'vlan_mapping' is nil when default
  },
}

vlan_maps = [%w(20 21), %w(30 31)]
tests['non_default_properties'] = {
  desc:           '2.1 Non Default Properties',
  manifest_props: {
    vlan_mapping_enable: 'false',
    vlan_mapping:        vlan_maps,
  },
  resource:       {
    'vlan_mapping_enable' => 'false',
    'vlan_mapping'        => "#{vlan_maps}",
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

def build_manifest_vlan_mapping(tests, id)
  intf = tests[:intf]
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node default {
    cisco_interface { '#{intf}':\n
    #{prop_hash_to_manifest(tests[id][:manifest_props])}
  }\n      }\nEOF"

  cmd = PUPPET_BINPATH + "resource cisco_interface '#{intf}'"
  tests[id][:resource_cmd] =
    get_namespace_cmd(agent, cmd, options)
end

def test_harness_vlan_mapping(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_vlan_mapping(tests, id)

  # Workaround for (ioctl) facter bug on n7k ***
  tests[id][:code] = [0, 2] if platform[/n7k/]

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 0. Testbed Initialization")
  # -------------------------------------------------------------------
  setup_mt_full_env(tests, self)

  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = 'default_properties'
  test_harness_vlan_mapping(tests, id)

  tests[id][:ensure] = :absent
  test_harness_vlan_mapping(tests, id)
  tests[id][:ensure] = :present

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_vlan_mapping(tests, 'non_default_properties')
end

logger.info("TestCase :: #{testheader} :: End")
