###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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
# test_acl.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet acl resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This ACL resource test verifies default values for all properties.
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
testheader = 'Resource cisco_acl'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
#
tests = {
  master:   master,
  agent:    agent,
  show_cmd: 'show run section ip',
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:show_pattern] - array of regexp patterns to use with test_show_cmd
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
# tests[id][:af] - (Optional) defines the address-family values.
#   Must use :title_pattern if :af is not specified. Useful for testing mixed
#   title/af manifests
#
tests['default_properties_ipv4'] = {
  title_pattern:  'ipv4 beaker_1',
  manifest_props: "
    stats_per_entry                  => 'false',
    fragments                        => 'default',
  ",
  resource_props: {
    'stats_per_entry' => 'false'
  },
}

tests['default_properties_ipv6'] = {
  title_pattern:  'ipv6 beaker_2',
  manifest_props: "
    stats_per_entry                  => 'false',
    fragments                        => 'default',
  ",
  resource_props: {
    'stats_per_entry' => 'false'
  },
}

tests['non_default_properties_ipv4'] = {
  title_pattern:  'ipv4 beaker_3',
  manifest_props: "
    stats_per_entry                  => 'true',
    fragments                        => 'permit-all',
  ",
  resource_props: {
    'stats_per_entry' => 'true',
    'fragments'       => 'permit-all',
  },
}

tests['non_default_properties_ipv6'] = {
  title_pattern:  'ipv6 beaker_4',
  manifest_props: "
    stats_per_entry                  => 'true',
    fragments                        => 'deny-all',
  ",
  resource_props: {
    'stats_per_entry' => 'true',
    'fragments'       => 'deny-all',
  },
}

tests['title_patterns_afi_only'] = {
  manifest_props:        "
    acl_name                         => 'beaker_afi_only',
    stats_per_entry                  => 'false',
    fragments                        => 'default',
  ",
  manifest_props_absent: "
    acl_name                         => 'beaker_afi_only',
  ",
  resource_props:        {
    'stats_per_entry' => 'false'
  },
}

tests['title_patterns_acl_name_only'] = {
  manifest_props:        "
    afi                              => 'ipv4',
    stats_per_entry                  => 'false',
    fragments                        => 'default',
  ",
  manifest_props_absent: "
    afi                              => 'ipv4',
  ",
  resource_props:        {
    'stats_per_entry' => 'false'
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH + 'resource cisco_acl'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_acl(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    manifest = tests[id][:manifest_props_absent]
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_acl :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_acl { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_acl(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_acl(tests, id)

  test_harness_common(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  resource_absent_cleanup(agent, 'cisco_acl',
                          'Setup switch for cisco_acl provider test')

  # -----------------------------------
  id = 'default_properties_ipv4'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_acl(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)

  id = 'default_properties_ipv6'
  tests[id][:desc] = '1.3 Default Properties'
  test_harness_acl(tests, id)

  tests[id][:desc] = '1.4 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  id = 'non_default_properties_ipv4'
  tests[id][:desc] = '2.1 Non Default Properties'
  test_harness_acl(tests, id)

  tests[id][:desc] = '2.2 Non Default Properties'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)

  id = 'non_default_properties_ipv6'
  tests[id][:desc] = '2.3 Non Default Properties'
  test_harness_acl(tests, id)

  tests[id][:desc] = '2.4 Non Default Properties'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)

  # -------------------------------------------------------------------
  # logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")

  id = 'title_patterns_afi_only'
  tests[id][:desc] = '3.1 Title Patterns'
  tests[id][:title_pattern] = 'ipv4'
  test_harness_acl(tests, id)

  tests[id][:desc] = '3.2 Title Patterns'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)

  id = 'title_patterns_afi_only'
  tests[id][:desc] = '3.3 Title Patterns'
  tests[id][:title_pattern] = 'ipv6'
  test_harness_acl(tests, id)

  tests[id][:desc] = '3.4 Title Patterns'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)

  id = 'title_patterns_acl_name_only'
  tests[id][:desc] = '3.5 Title Patterns'
  tests[id][:title_pattern] = 'beaker_acl_name_only'
  test_harness_acl(tests, id)

  tests[id][:desc] = '3.6 Title Patterns'
  tests[id][:ensure] = :absent
  test_harness_acl(tests, id)
end

logger.info('TestCase :: # {testheader} :: End')
