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
# test_interface_service_vni.rb
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
# The interface service vni provider has additional prerequisites.
#
#  - VDC support
#  - F3 linecard
#  - N7 platforms only
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
testheader = 'Resource cisco_interface_service_vni'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:encap_prof_global] - the encap profile vni global configuration
#
tests = {
  master:            master,
  agent:             agent,
  resource_name:     'cisco_interface_service_vni',
  sid:               22,
  encap_prof_global: 'encapsulation profile vni vni_500_5000 ; '\
                     'dot1q 500 vni 5000',
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
    encapsulation_profile_vni: 'default',
    shutdown:                  'default',
  },
  resource:       {
    # 'encapsulation_profile_vni' is nil
    'shutdown' => 'true'
  },
}

tests['non_default_properties'] = {
  desc:           '2.1 Non Default Properties',
  manifest_props: {
    encapsulation_profile_vni: 'vni_500_5000',
    shutdown:                  'false',
  },
  resource:       {
    'encapsulation_profile_vni' => 'vni_500_5000',
    'shutdown'                  => 'false',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

def build_manifest_interface_service_vni(tests, id)
  intf = tests[:intf]
  sid = tests[:sid]
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node default {
    cisco_interface_service_vni { '#{intf} #{sid}':
    \n#{prop_hash_to_manifest(tests[id][:manifest_props])}
    }\n  }\nEOF"

  cmd = PUPPET_BINPATH + "resource cisco_interface_service_vni '#{intf} #{sid}'"
  tests[id][:resource_cmd] =
    get_namespace_cmd(agent, cmd, options)
end

def test_harness_interface_service_vni(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_interface_service_vni(tests, id)

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
  test_harness_interface_service_vni(tests, id)

  tests[id][:ensure] = :absent
  test_harness_interface_service_vni(tests, id)
  tests[id][:ensure] = :present

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_interface_service_vni(tests, 'non_default_properties')
end

logger.info("TestCase :: #{testheader} :: End")
