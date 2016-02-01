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
# test-stp_global.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet stp_global resource testcase for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This stp_global resource test verifies default values for all
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
testheader = 'Resource cisco_stp_global'

# Define PUPPETMASTER_MANIFESTPATH.

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
#

tests['default_properties'] = {
  title_pattern:  'default',
  manifest_props: "
    bpdufilter               => 'default',
    bpduguard                => 'default',
    bridge_assurance         => 'default',
    loopguard                => 'default',
    mode                     => 'default',
    pathcost                 => 'default',
    vlan_designated_priority => 'default',
    vlan_forward_time        => 'default',
    vlan_hello_time          => 'default',
    vlan_max_age             => 'default',
    vlan_priority            => 'default',
    vlan_root_priority       => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'bpdufilter'       => 'false',
    'bpduguard'        => 'false',
    'bridge_assurance' => 'true',
    'loopguard'        => 'false',
    'mode'             => 'rapid-pvst',
    'pathcost'         => 'short',
    # 'vlan_designated_priority' is nil when default
    # 'vlan_forward_time' is nil when default
    # 'vlan_hello_time' is nil when default
    # 'vlan_max_age' is nil when default
    # 'vlan_priority' is nil when default
    # 'vlan_root_priority' is nil when default
  },
}

tests['default_properties_mst'] = {
  title_pattern:  'default',
  manifest_props: "
    mode                    => 'mst',
    mst_designated_priority => 'default',
    mst_forward_time        => 'default',
    mst_hello_time          => 'default',
    mst_inst_vlan_map       => 'default',
    mst_max_age             => 'default',
    mst_max_hops            => 'default',
    mst_name                => 'default',
    mst_priority            => 'default',
    mst_revision            => 'default',
    mst_root_priority       => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'mode'             => 'mst',
    # 'mst_designated_priority' is nil when default
    'mst_forward_time' => '15',
    'mst_hello_time'   => '2',
    # 'mst_inst_vlan_map' is nil when default
    'mst_max_age'      => '20',
    'mst_max_hops'     => '20',
    'mst_name'         => 'false',
    # 'mst_priority' is nil when default
    'mst_revision'     => '0',
    # 'mst_root_priority' is nil when default
  },
}

tests['non_default_properties'] = {
  title_pattern:  'default',
  manifest_props: "
    bpdufilter               => 'true',
    bpduguard                => 'true',
    bridge_assurance         => 'false',
    loopguard                => 'true',
    mode                     => 'mst',
    mst_designated_priority  => [['2-42', '4096'], ['83-92,100-230', '53248']],
    mst_forward_time         => '25',
    mst_hello_time           => '5',
    mst_inst_vlan_map        => [['2', '6-47'], ['92', '120-400']],
    mst_max_age              => '35',
    mst_max_hops             => '200',
    mst_name                 => 'nexus',
    mst_priority             => [['2-42', '4096'], ['83-92,100-230', '53248']],
    mst_revision             => '34',
    mst_root_priority        => [['2-42', '4096'], ['83-92,100-230', '53248']],
    pathcost                 => 'long',
    vlan_designated_priority => [['1-42', '40960'], ['83-92,100-230', '53248']],
    vlan_forward_time        => [['1-42', '19'], ['83-92,100-230', '13']],
    vlan_hello_time          => [['1-42', '10'], ['83-92,100-230', '6']],
    vlan_max_age             => [['1-42', '21'], ['83-92,100-230', '13']],
    vlan_priority            => [['1-42', '40960'], ['83-92,100-230', '53248']],
    vlan_root_priority       => [['1-42', '40960'], ['83-92,100-230', '53248']],
  ",
  resource_props: {
    'bpdufilter'               => 'true',
    'bpduguard'                => 'true',
    'bridge_assurance'         => 'false',
    'loopguard'                => 'true',
    'mode'                     => 'mst',
    'mst_designated_priority'  => "[['2-42', '4096'], ['83-92,100-230', '53248']]",
    'mst_forward_time'         => '25',
    'mst_hello_time'           => '5',
    'mst_inst_vlan_map'        => "[['2', '6-47'], ['92', '120-400']]",
    'mst_max_age'              => '35',
    'mst_max_hops'             => '200',
    'mst_name'                 => 'nexus',
    'mst_priority'             => "[['2-42', '4096'], ['83-92,100-230', '53248']]",
    'mst_revision'             => '34',
    'mst_root_priority'        => "[['2-42', '4096'], ['83-92,100-230', '53248']]",
    'pathcost'                 => 'long',
    'vlan_designated_priority' => "[['1-42', '40960'], ['83-92,100-230', '53248']]",
    'vlan_forward_time'        => "[['1-42', '19'], ['83-92,100-230', '13']]",
    'vlan_hello_time'          => "[['1-42', '10'], ['83-92,100-230', '6']]",
    'vlan_max_age'             => "[['1-42', '21'], ['83-92,100-230', '13']]",
    'vlan_priority'            => "[['1-42', '40960'], ['83-92,100-230', '53248']]",
    'vlan_root_priority'       => "[['1-42', '40960'], ['83-92,100-230', '53248']]",
  },
}

tests['default_properties_fcoe'] = {
  title_pattern:  'default',
  manifest_props: "
    fcoe               => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'fcoe' => 'true'
  },
}

tests['non_default_properties_fcoe'] = {
  title_pattern:  'default',
  manifest_props: "
    fcoe               => 'false',
  ",
  resource_props: {
    'fcoe' => 'false'
  },
}

tests['default_properties_domain'] = {
  title_pattern:  'default',
  manifest_props: "
    domain             => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'domain' => 'false'
  },
}

tests['non_default_properties_domain'] = {
  title_pattern:  'default',
  manifest_props: "
    domain             => '100',
  ",
  resource_props: {
    'domain' => '100'
  },
}

tests['default_properties_bd_domain'] = {
  title_pattern:  'default',
  manifest_props: "
    bd_designated_priority => 'default',
    bd_forward_time        => 'default',
    bd_hello_time          => 'default',
    bd_max_age             => 'default',
    bd_priority            => 'default',
    bd_root_priority       => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    # 'bd_designated_priority' is nil when default
    # 'bd_forward_time' is nil when default
    # 'bd_hello_time' is nil when default
    # 'bd_max_age' is nil when default
    # 'bd_priority' is nil when default
    # 'bd_root_priority' is nil when default
  },
}

tests['non_default_properties_bd_domain'] = {
  title_pattern:  'default',
  manifest_props: "
    bd_designated_priority => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    bd_forward_time        => [['2-42', '26'], ['83-92,1000-2300', '20']],
    bd_hello_time          => [['2-42', '6'], ['83-92,1000-2300', '9']],
    bd_max_age             => [['2-42', '26'], ['83-92,1000-2300', '21']],
    bd_priority            => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    bd_root_priority       => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
  ",
  code:           [0, 2],
  resource_props: {
    'bd_designated_priority' => "[['2-42', '40960'], ['83-92,1000-2300', '53248']]",
    'bd_forward_time'        => "[['2-42', '26'], ['83-92,1000-2300', '20']]",
    'bd_hello_time'          => "[['2-42', '6'], ['83-92,1000-2300', '9']]",
    'bd_max_age'             => "[['2-42', '26'], ['83-92,1000-2300', '21']]",
    'bd_priority'            => "[['2-42', '40960'], ['83-92,1000-2300', '53248']]",
    'bd_root_priority'       => "[['2-42', '40960'], ['83-92,1000-2300', '53248']]",
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH +
        'resource cisco_stp_global'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_stp_global(tests, id)
  manifest = tests[id][:manifest_props]
  tests[id][:resource] = tests[id][:resource_props]

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_stp_global :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_stp_global { 'default':
      #{manifest}
    }
  }
EOF"
end

def test_harness_stp_global(tests, id)
  tests[id][:resource_cmd] = puppet_resource_cmd

  # Build the manifest for this test
  build_manifest_stp_global(tests, id)

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

  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_stp_global(tests, id)

  id = 'default_properties_mst'
  tests[id][:desc] = '1.2 Default mst Properties'
  test_harness_stp_global(tests, id)

  case device
  when /n5k|n6k|n7k/
    id = 'default_properties_domain'
  when /n3k|n9k/
    id = 'default_properties_fcoe'
  end

  tests[id][:desc] = '1.3 Switch specific default Properties'
  test_harness_stp_global(tests, id)

  case device
  when /n7k/
    id = 'default_properties_bd_domain'
    tests[id][:desc] = '1.4 Switch specific bridge domain default Properties'
    # test_harness_stp_global(tests, id)
  end
  # no absent test for stp_global

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  id = 'non_default_properties'
  tests[id][:desc] = '2.1 Non Default Properties'
  test_harness_stp_global(tests, id)

  case device
  when /n5k|n6k|n7k/
    id = 'non_default_properties_domain'
  when /n3k|n9k/
    id = 'non_default_properties_fcoe'
  end

  tests[id][:desc] = '2.2 Switch specific Non Default Properties'
  test_harness_stp_global(tests, id)

  case device
  when /n7k/
    id = 'non_default_properties_bd_domain'
    tests[id][:desc] = '2.3 Switch specific bridge domain non default Properties'
    # test_harness_stp_global(tests, id)
  end
  # no absent test for stp_global
end

logger.info("TestCase :: #{testheader} :: End")
