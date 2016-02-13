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
# test_ace.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet ACE resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This ACE resource test verifies cisco_ace title patterns.
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

# Require UtilityLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_ace'

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

tests['ipv4_seq_10'] = {
  desc:           '1.1 ipv4 beaker_1 seq 10',
  title_pattern:  'ipv4 beaker_1 10',
  manifest_props: "
    action          => 'permit',
    proto           => 'tcp',
    src_addr        => '1.2.3.4 2.3.4.5',
    src_port        => 'eq 40',
    dst_addr        => '9.9.0.4/32',
    dst_port        => 'range 32 56',
  ",
  resource:       {
    'action'   => 'permit',
    'proto'    => 'tcp',
    'src_addr' => '1.2.3.4 2.3.4.5',
    'src_port' => 'eq 40',
    'dst_addr' => '9.9.0.4/32',
    'dst_port' => 'range 32 56',
  },
}

tests['ipv4_seq_20'] = {
  desc:           '1.2 ipv4 beaker_1 seq 20',
  title_pattern:  'ipv4 beaker_1 20',
  manifest_props: "
    action          => 'deny',
    proto           => 'tcp',
    src_addr        => 'any',
    dst_addr        => 'any',
  ",
  resource:       {
    'action'   => 'deny',
    'proto'    => 'tcp',
    'src_addr' => 'any',
    'dst_addr' => 'any',
  },
}

tests['ipv6_seq_10'] = {
  desc:           '2.1 ipv6 beaker_6 seq 10',
  title_pattern:  'ipv6 beaker_6 10',
  manifest_props: "
    action          => 'deny',
    proto           => 'tcp',
    src_addr        => 'any',
    dst_addr        => 'any',
  ",
  resource:       {
    'action'   => 'deny',
    'proto'    => 'tcp',
    'src_addr' => 'any',
    'dst_addr' => 'any',
  },
}

tests['ipv6_seq_20'] = {
  desc:           '2.2 ipv6 beaker_6 seq 20',
  title_pattern:  'ipv6 beaker_6 20',
  manifest_props: "
    remark          => 'test remark',
  ",
  resource:       {
    'remark' => 'test remark'
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH + 'resource cisco_ace'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_ace(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    # manifest = tests[id][:manifest_props_absent]
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_ace :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_ace { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_ace(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] = " #{tests[id][:desc]}"

  # Build the manifest for this test
  build_manifest_ace(tests, id)

  test_harness_common(tests, id)
  # add case
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  logger.info("\n#{'-' * 60}\nSection 0. Clean testbed")
  resource_absent_cleanup(agent, 'cisco_acl', 'ACL CLEANUP :: ')

  # ---------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. IPv4 ACE")
  test_harness_ace(tests, 'ipv4_seq_10')

  id = 'ipv4_seq_20'
  test_harness_ace(tests, id)
  tests[id][:ensure] = :absent
  test_harness_ace(tests, id)

  # ---------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. IPv6 ACE")
  # ---------------------------------------------------------
  test_harness_ace(tests, 'ipv6_seq_10')

  id = 'ipv6_seq_20'
  test_harness_ace(tests, id)
  tests[id][:ensure] = :absent
  test_harness_ace(tests, id)
  # ---------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_acl', 'ACL CLEANUP :: ')
end

logger.info('TestCase :: # {testheader} :: End')
