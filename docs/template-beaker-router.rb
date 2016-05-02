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
# test_X__RESOURCE_NAME__X.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet X__RESOURCE_NAME__X resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This X__RESOURCE_NAME__X resource test verifies all properties.
#
# The following exit_codes are validated for Puppet and Bash shell commands.
#
# Bash Shell Commands:
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
testheader = 'Resource cisco_router_X__RESOURCE_NAME__X'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.
def generate_tests_hash(agent)
  # 'tests' hash
  # Top-level keys set by caller:
  # tests[:master] - the master object
  # tests[:agent] - the agent object
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
  # tests[id][:af] - (Optional) defines the address-family values.
  #   Must use :title_pattern if :af is not specified. Useful for testing mixed
  #   title/af manifests
  tests['preclean'] = {
    title_pattern:  '1',
    ensure:         :absent,
    manifest_props: '',
    resource_props: {},
    code:           [0, 2],
  }

  tests['default_properties'] = {
    title_pattern:  '1',
    # Input:  maximum_paths => 'default',
    #         shutdown      => 'default',
    # Output: maximum_paths  => 8,
    #         shutdown      => false,
    default_values: {
      'maximum_paths' => 8,
      'shutdown'      => false,
    },
  }

  tests['non_default_properties_M'] = {
    # Input:  maximum_paths => 5,
    # Output: maximum_paths  => 5,
    desc:               "2.1 Non Default Properties 'M' commands",
    title_pattern:      '1',
    non_default_values: {
      'maximum_paths' => 5
    },
  }

  tests['non_default_properties_S'] = {
    # Input:  shutdown => true,
    # Output: shutdown => true,
    desc:               "2.2 Non Default Properties 'S' commands",
    title_pattern:      '1',
    non_default_values: {
      'shutdown' => true
    },
  }

  tests
end

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  UtilityLib::PUPPET_BINPATH + 'resource cisco_router_X__RESOURCE_NAME__X'
end

def build_default_values(testcase)
  return if testcase[:default_values].nil?
  testcase[:default_values].each do |key, value|
    testcase[:manifest_props] += "\n#{key} => 'default',"
    value_s = value.is_a?(String) ? "'#{value}'" : value.to_s
    testcase[:default_values][key] = value_s
    # remove key if no corresponding resource_prop
    testcase[:default_values].delete(key) if value.nil?
  end
  testcase[:resource].merge!(testcase[:default_values])
end

def build_non_default_values(testcase)
  return if testcase[:non_default_values].nil?
  testcase[:non_default_values].each do |key, value|
    value_s = value.is_a?(String) ? "'#{value}'" : value.to_s
    testcase[:non_default_values][key] = value_s
    testcase[:manifest_props] += "\n#{key} => #{value_s},"
  end
  testcase[:resource].merge!(testcase[:non_default_values])
end

def build_manifest_X__RESOURCE_NAME__X(tests, id)
  tests[id][:manifest_props] = '' if tests[id][:manifest_props].nil?
  tests[id][:resource] = {}
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:manifest_props] = ''
  else
    state = 'ensure => present,'
    res_props = tests[id][:resource_props]
    tests[id][:resource] = res_props unless res_props.nil?
    build_default_values(tests[id])
    build_non_default_values(tests[id])
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_X__RESOURCE_NAME__X :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_router_X__RESOURCE_NAME__X { '#{tests[id][:title_pattern]}':
      #{state}
      #{tests[id][:manifest_props]}
    }
  }
EOF"
end

def test_harness_X__RESOURCE_NAME__X(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_X__RESOURCE_NAME__X(tests, id)

  # FUTURE
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
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  tests = generate_tests_hash(agent)
  id = 'preclean'
  tests[id][:desc] = 'Preclean'
  test_harness_X__RESOURCE_NAME__X(tests, id)

  # -----------------------------------
  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_X__RESOURCE_NAME__X(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_X__RESOURCE_NAME__X(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  node_feature_cleanup(agent, 'X__RESOURCE_NAME__X')

  test_harness_X__RESOURCE_NAME__X(tests, 'non_default_properties_M')
  test_harness_X__RESOURCE_NAME__X(tests, 'non_default_properties_S')

  # -------------------------------------------------------------------
  # FUTURE
  # logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  # node_feature_cleanup(agent, 'X__RESOURCE_NAME__X')

  # id = 'title_patterns'
  # tests[id][:desc] = '3.1 Title Patterns'
  # tests[id][:title_pattern] = '2'
  # tests[id][:af] = { :vrf => 'default', :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_X__RESOURCE_NAME__X(tests, id)

  # id = 'title_patterns'
  # tests[id][:desc] = '3.2 Title Patterns'
  # tests[id][:title_pattern] = '2 blue'
  # tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_X__RESOURCE_NAME__X(tests, id)
end

logger.info('TestCase :: # {testheader} :: End')
