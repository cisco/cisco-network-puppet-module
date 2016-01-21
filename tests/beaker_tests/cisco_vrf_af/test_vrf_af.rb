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
# test_vrf_af.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet VRF AF resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This VRF AF resource test verifies default values for all properties.
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
# rubocop:disable Style/HashSyntax

require File.expand_path('../../lib/utilitylib.rb', __FILE__)
# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_vrf_af'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:platform] - a regexp pattern to match against supported platforms.
#                    This key can be overridden by a tests[id][:platform] key
#
tests = {
  master:   master,
  agent:    agent,
  platform: 'n(7|9)k',
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:platform] - a regexp pattern to match against supported platforms.
#                        This key overrides a tests[:platform] key
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#   Can be used with :af for mixed title/af testing. If mixing, :af values will
#   be merged with title values and override any duplicates. If omitted,
#   :title_pattern will be set to 'id'.

# default_properties
#
tests['default_properties'] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'blue ipv4 unicast',
  manifest_props: {
    route_target_both_auto:      'default',
    route_target_both_auto_evpn: 'default',
    route_target_import:         'default',
    route_target_import_evpn:    'default',
    route_target_export:         'default',
    route_target_export_evpn:    'default',
  },
  resource:       {
    'route_target_both_auto'      => 'false',
    'route_target_both_auto_evpn' => 'false',
  },
}

routetargetimport     = ['1.1.1.1:55', '1:33']
routetargetimportevpn = ['2.2.2.2:55', '2:33']
routetargetexport     = ['3.3.3.3:55', '3:33']
routetargetexportevpn = ['4.4.4.4:55', '4:33']
tests['non_default_properties_R'] = {
  desc:           '2.1 Non Default Properties R commands',
  title_pattern:  'blue ipv4 unicast',
  manifest_props: {
    route_target_both_auto:      true,
    route_target_both_auto_evpn: true,
    route_target_import:         routetargetimport,
    route_target_import_evpn:    routetargetimportevpn,
    route_target_export:         routetargetexport,
    route_target_export_evpn:    routetargetexportevpn,
  },
  resource:       {
    'route_target_both_auto'      => 'true',
    'route_target_both_auto_evpn' => 'true',
    'route_target_import'         => "#{routetargetimport}",
    'route_target_import_evpn'    => "#{routetargetimportevpn}",
    'route_target_export'         => "#{routetargetexport}",
    'route_target_export_evpn'    => "#{routetargetexportevpn}",
  },
}

tests['title_patterns'] = {
  resource: { 'ensure' => 'present' }
}

# Create actual manifest for a given test scenario.
def build_manifest_vrf_af(tests, id)
  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?

  # Set namevar parts of the manifest first (if present)
  manifest = prop_hash_to_manifest(tests[id][:af])

  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
    # Add the properties
    manifest += prop_hash_to_manifest(tests[id][:manifest_props]) if
      tests[id][:manifest_props]
  end

  logger.debug("build_manifest_vrf_af :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
node default {\n  cisco_vrf_af { '#{tests[id][:title_pattern]}':
    #{state}
    #{manifest}\n  }\n}\nEOF"
end

# Wrapper for vrf_af specific settings prior to calling the
# common test_harness.
def test_harness_vrf_af(tests, id)
  return unless platform_supports_test(tests, id)

  af = af_title_pattern_munge(tests, id, 'vrf_af')
  logger.info("\n--------\nTest Case Address-Family ID: #{af}")

  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = PUPPET_BINPATH +
                             "resource cisco_vrf_af '#{af.values.join(' ')}'"

  # Workaround for (ioctl) facter bug on n7k ***
  tests[id][:code] = [0, 2]

  # Build the manifest for this test
  build_manifest_vrf_af(tests, id)

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  resource_absent_cleanup(agent, 'cisco_vrf', 'VRF_AF :: ')
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  id = 'default_properties'
  test_harness_vrf_af(tests, id)

  tests[id][:ensure] = :absent
  test_harness_vrf_af(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_vrf_af(tests, 'non_default_properties_R')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")

  id = 'title_patterns'
  tests[id][:desc] = '3.1 Title Patterns'
  tests[id][:title_pattern] = 'red'
  tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  test_harness_vrf_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.2 Title Patterns'
  tests[id][:title_pattern] = 'blue ipv4'
  tests[id][:af] = { :safi => 'unicast' }
  test_harness_vrf_af(tests, id)

  # -----------------------------------
  tests[id][:desc] = '3.3 Title Patterns'
  tests[id][:title_pattern] = 'cyan ipv4 unicast'
  test_harness_vrf_af(tests, id)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_vrf', 'VRF_AF :: ')
  skipped_tests_summary(tests, testheader)
end
logger.info("TestCase :: #{testheader} :: End")
