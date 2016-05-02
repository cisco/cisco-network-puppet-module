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
# test-portchannel_global.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet portchannel_global resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This portchannel_global resource test verifies default values for all
# properties.
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
testheader = 'Resource cisco_portchannel_global'

# Define PUPPETMASTER_MANIFESTPATH.

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
#
tests = {
  master: master,
  agent:  agent,
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
#

tests['default_properties_asym'] = {
  title_pattern:  'default',
  manifest_props: "
    asymmetric                   => 'default',
    bundle_hash                  => 'default',
    bundle_select                => 'default',
    hash_distribution            => 'default',
    load_defer                   => 'default',
    rotate                       => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'asymmetric'        => 'false',
    'bundle_hash'       => 'ip',
    'bundle_select'     => 'src-dst',
    'hash_distribution' => 'adaptive',
    'load_defer'        => '120',
    'rotate'            => '0',
  },
}

tests['non_default_properties_asym'] = {
  title_pattern:  'default',
  manifest_props: "
    asymmetric                   => 'true',
    bundle_hash                  => 'ip-l4port',
    bundle_select                => 'dst',
    hash_distribution            => 'fixed',
    load_defer                   => '1000',
    rotate                       => '4',
  ",
  resource_props: {
    'asymmetric'        => 'true',
    'bundle_hash'       => 'ip-l4port',
    'bundle_select'     => 'dst',
    'hash_distribution' => 'fixed',
    'load_defer'        => '1000',
    'rotate'            => '4',
  },
}

tests['default_properties_eth'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'default',
    bundle_select                => 'default',
    hash_poly                    => 'CRC10b',
  ",
  code:           [0, 2],
  resource_props: {
    'bundle_hash'   => 'ip',
    'bundle_select' => 'src-dst',
    'hash_poly'     => 'CRC10b',
  },
}

tests['non_default_properties_eth'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'mac',
    bundle_select                => 'dst',
    hash_poly                    => 'CRC10c',
  ",
  resource_props: {
    'bundle_hash'   => 'mac',
    'bundle_select' => 'dst',
    'hash_poly'     => 'CRC10c',
  },
}

tests['default_properties_sym'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'default',
    bundle_select                => 'default',
    concatenation                => 'default',
    resilient                    => 'default',
    rotate                       => 'default',
    symmetry                     => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'bundle_hash'   => 'ip-l4port',
    'bundle_select' => 'src-dst',
    'concatenation' => 'false',
    'resilient'     => 'false',
    'rotate'        => '0',
    'symmetry'      => 'false',
  },
}

tests['non_default_properties_sym'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'ip',
    bundle_select                => 'src-dst',
    concatenation                => 'true',
    resilient                    => 'true',
    rotate                       => '4',
    symmetry                     => 'true',
  ",
  resource_props: {
    'bundle_hash'   => 'ip',
    'bundle_select' => 'src-dst',
    'concatenation' => 'true',
    'resilient'     => 'true',
    'rotate'        => '4',
    'symmetry'      => 'true',
  },
}

tests['default_properties_no_hash'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'default',
    bundle_select                => 'default',
    rotate                       => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'bundle_hash'   => 'ip-l4port',
    'bundle_select' => 'src-dst',
    'rotate'        => '0',
  },
}

tests['non_default_properties_no_hash'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'ip',
    bundle_select                => 'dst',
    rotate                       => '4',
  ",
  resource_props: {
    'bundle_hash'   => 'ip',
    'bundle_select' => 'dst',
    'rotate'        => '4',
  },
}

tests['default_properties_no_rotate'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'default',
    bundle_select                => 'default',
    resilient                    => 'default',
    symmetry                     => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'bundle_hash'   => 'ip',
    'bundle_select' => 'src-dst',
    'resilient'     => 'true',
    'symmetry'      => 'false',
  },
}

tests['non_default_properties_no_rotate'] = {
  title_pattern:  'default',
  manifest_props: "
    bundle_hash                  => 'ip-only',
    bundle_select                => 'src-dst',
    resilient                    => 'false',
    symmetry                     => 'true',
  ",
  resource_props: {
    'bundle_hash'   => 'ip-only',
    'bundle_select' => 'src-dst',
    'resilient'     => 'false',
    'symmetry'      => 'true',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  PUPPET_BINPATH + 'resource cisco_portchannel_global'
end

def build_manifest_portchannel_global(tests, id)
  manifest = tests[id][:manifest_props]
  tests[id][:resource] = tests[id][:resource_props]

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_portchannel_global :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_portchannel_global { 'default':
      #{manifest}
    }
  }
EOF"
end

def test_harness_portchannel_global(tests, id)
  tests[id][:resource_cmd] = puppet_resource_cmd

  # Build the manifest for this test
  build_manifest_portchannel_global(tests, id)

  # test_harness_common(tests, id)
  test_manifest(tests, id)
  test_resource(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  case device
  when /n7k/
    id = 'default_properties_asym'
  when /n5k|n6k/
    id = 'default_properties_eth'
  when /n9k/
    id = 'default_properties_sym'
  when /n8k/
    id = 'default_properties_no_hash'
  when /n3k/
    id = 'default_properties_no_rotate'
  end

  tests[id][:desc] = '1.1 Default Properties'
  test_harness_portchannel_global(tests, id)

  # no absent test for portchannel_global

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  if device == 'n7k'
    id = 'non_default_properties_asym'
    tests[id][:desc] = '2.1 Non Default Properties'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.2 Non Default Properties'
    tests['non_default_properties_asym'][:manifest_props]['ip-l4port'] = 'ip-l4port-vlan'
    tests['non_default_properties_asym'][:resource_props]['bundle_hash'] = 'ip-l4port-vlan'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.3 Non Default Properties'
    tests['non_default_properties_asym'][:manifest_props]['ip-l4port-vlan'] = 'ip-vlan'
    tests['non_default_properties_asym'][:resource_props]['bundle_hash'] = 'ip-vlan'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.4 Non Default Properties'
    tests['non_default_properties_asym'][:manifest_props]['ip-vlan'] = 'l4port'
    tests['non_default_properties_asym'][:resource_props]['bundle_hash'] = 'l4port'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.5 Non Default Properties'
    tests['non_default_properties_asym'][:manifest_props]['l4port'] = 'mac'
    tests['non_default_properties_asym'][:resource_props]['bundle_hash'] = 'mac'
    tests['non_default_properties_asym'][:manifest_props]['dst'] = 'src'
    tests['non_default_properties_asym'][:resource_props]['bundle_select'] = 'src'
    test_harness_portchannel_global(tests, id)

  elsif device == 'n5k' || device == 'n6k'
    id = 'non_default_properties_eth'
    tests[id][:desc] = '2.1 Non Default Properties'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.2 Non Default Properties'
    tests['non_default_properties_eth'][:manifest_props]['mac'] = 'port'
    tests['non_default_properties_eth'][:resource_props]['bundle_hash'] = 'port'
    tests['non_default_properties_eth'][:manifest_props]['dst'] = 'src'
    tests['non_default_properties_eth'][:resource_props]['bundle_select'] = 'src'
    tests['non_default_properties_eth'][:manifest_props]['CRC10c'] = 'CRC10a' if device == 'n6k'
    tests['non_default_properties_eth'][:resource_props]['hash_poly'] = 'CRC10a' if device == 'n6k'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.3 Non Default Properties'
    tests['non_default_properties_eth'][:manifest_props]['port'] = 'port-only'
    tests['non_default_properties_eth'][:resource_props]['bundle_hash'] = 'port-only'
    tests['non_default_properties_eth'][:manifest_props]['src'] = 'src-dst'
    tests['non_default_properties_eth'][:resource_props]['bundle_select'] = 'src-dst'
    tests['non_default_properties_eth'][:manifest_props]['CRC10a'] = 'CRC10d' if device == 'n6k'
    tests['non_default_properties_eth'][:manifest_props]['CRC10c'] = 'CRC10d' if device == 'n5k'
    tests['non_default_properties_eth'][:resource_props]['hash_poly'] = 'CRC10d'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.4 Non Default Properties'
    tests['non_default_properties_eth'][:manifest_props]['port-only'] = 'ip-only'
    tests['non_default_properties_eth'][:resource_props]['bundle_hash'] = 'ip-only'
    test_harness_portchannel_global(tests, id)

  elsif device == 'n9k'
    id = 'non_default_properties_sym'
    tests[id][:desc] = '2.1 Non Default Properties'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.2 Non Default Properties'
    tests['non_default_properties_sym'][:manifest_props]['true'] = 'false'
    tests['non_default_properties_sym'][:manifest_props]['true'] = 'false'
    tests['non_default_properties_sym'][:manifest_props]['true'] = 'false'
    tests['non_default_properties_sym'][:manifest_props]['4'] = '0'
    tests['non_default_properties_sym'][:manifest_props]['ip'] = 'ip-l4port-vlan'
    tests['non_default_properties_sym'][:resource_props]['bundle_hash'] = 'ip-l4port-vlan'
    tests['non_default_properties_sym'][:manifest_props]['src-dst'] = 'src'
    tests['non_default_properties_sym'][:resource_props]['bundle_select'] = 'src'
    tests['non_default_properties_sym'][:resource_props]['concatenation'] = 'false'
    tests['non_default_properties_sym'][:resource_props]['resilient'] = 'false'
    tests['non_default_properties_sym'][:resource_props]['symmetry'] = 'false'
    tests['non_default_properties_sym'][:resource_props]['rotate'] = '0'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.3 Non Default Properties'
    tests['non_default_properties_sym'][:manifest_props]['ip-l4port-vlan'] = 'ip-vlan'
    tests['non_default_properties_sym'][:resource_props]['bundle_hash'] = 'ip-vlan'
    tests['non_default_properties_sym'][:manifest_props]['src'] = 'dst'
    tests['non_default_properties_sym'][:resource_props]['bundle_select'] = 'dst'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.4 Non Default Properties'
    tests['non_default_properties_sym'][:manifest_props]['ip-vlan'] = 'l4port'
    tests['non_default_properties_sym'][:resource_props]['bundle_hash'] = 'l4port'
    tests['non_default_properties_sym'][:manifest_props]['dst'] = 'src-dst'
    tests['non_default_properties_sym'][:resource_props]['bundle_select'] = 'src-dst'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.5 Non Default Properties'
    tests['non_default_properties_sym'][:manifest_props]['l4port'] = 'mac'
    tests['non_default_properties_sym'][:resource_props]['bundle_hash'] = 'mac'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.6 Non Default Properties'
    tests['non_default_properties_sym'][:manifest_props]['mac'] = 'ip-gre'
    tests['non_default_properties_sym'][:resource_props]['bundle_hash'] = 'ip-gre'
    test_harness_portchannel_global(tests, id)

  elsif device == 'n8k'
    id = 'non_default_properties_no_hash'
    tests[id][:desc] = '2.1 Non Default Properties'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.2 Non Default Properties'
    tests['non_default_properties_no_hash'][:manifest_props]['ip'] = 'ip-l4port-vlan'
    tests['non_default_properties_no_hash'][:resource_props]['bundle_hash'] = 'ip-l4port-vlan'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.3 Non Default Properties'
    tests['non_default_properties_no_hash'][:manifest_props]['ip-l4port-vlan'] = 'ip-vlan'
    tests['non_default_properties_no_hash'][:resource_props]['bundle_hash'] = 'ip-vlan'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.4 Non Default Properties'
    tests['non_default_properties_no_hash'][:manifest_props]['ip-vlan'] = 'l4port'
    tests['non_default_properties_no_hash'][:resource_props]['bundle_hash'] = 'l4port'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.5 Non Default Properties'
    tests['non_default_properties_no_hash'][:manifest_props]['l4port'] = 'mac'
    tests['non_default_properties_no_hash'][:resource_props]['bundle_hash'] = 'mac'
    tests['non_default_properties_no_hash'][:manifest_props]['dst'] = 'src'
    tests['non_default_properties_no_hash'][:resource_props]['bundle_select'] = 'src'
    test_harness_portchannel_global(tests, id)
  elsif device == 'n3k'
    id = 'non_default_properties_no_rotate'
    tests[id][:desc] = '2.1 Non Default Properties'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.2 Non Default Properties'
    tests['non_default_properties_no_rotate'][:manifest_props]['true'] = 'false'
    tests['non_default_properties_no_rotate'][:manifest_props]['false'] = 'true'
    tests['non_default_properties_no_rotate'][:manifest_props]['ip-only'] = 'ip-gre'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_hash'] = 'ip-gre'
    tests['non_default_properties_no_rotate'][:manifest_props]['src-dst'] = 'src'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_select'] = 'src'
    tests['non_default_properties_no_rotate'][:resource_props]['resilient'] = 'true'
    tests['non_default_properties_no_rotate'][:resource_props]['symmetry'] = 'false'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.3 Non Default Properties'
    tests['non_default_properties_no_rotate'][:manifest_props]['ip-gre'] = 'mac'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_hash'] = 'mac'
    tests['non_default_properties_no_rotate'][:manifest_props]['src'] = 'dst'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_select'] = 'dst'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.4 Non Default Properties'
    tests['non_default_properties_no_rotate'][:manifest_props]['mac'] = 'port'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_hash'] = 'port'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.5 Non Default Properties'
    tests['non_default_properties_no_rotate'][:manifest_props]['port'] = 'port-only'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_hash'] = 'port-only'
    tests['non_default_properties_no_rotate'][:manifest_props]['dst'] = 'src-dst'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_select'] = 'src-dst'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.6 Non Default Properties'
    tests['non_default_properties_no_rotate'][:manifest_props]['port-only'] = 'ip-gre'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_hash'] = 'ip-gre'
    test_harness_portchannel_global(tests, id)

    tests[id][:desc] = '2.7 Non Default Properties'
    tests['non_default_properties_no_rotate'][:manifest_props]['src-dst'] = 'dst'
    tests['non_default_properties_no_rotate'][:resource_props]['bundle_select'] = 'dst'
    test_harness_portchannel_global(tests, id)
  end

  # no absent test for portchannel_global
end

logger.info("TestCase :: #{testheader} :: End")
