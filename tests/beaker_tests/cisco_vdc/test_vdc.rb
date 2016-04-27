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

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  mod_type:         'f3',
  operating_system: 'nexus',
  platform:         'n7k',
  resource_name:    'cisco_vdc',
}

# Test hash test cases
tests[:non_default] = {
  desc:           '1.1 non default properties',
  title_pattern:  default_vdc_name,

  # This property does not have a meaningful default state because the module
  # types depend on which linecards are installed. Simply set the list to
  # a single common mod type and ensure that is the only type shown.
  manifest_props: { limit_resource_module_type: tests[:mod_type] },
}

def current_module_type
  cmd = PUPPET_BINPATH + 'resource cisco_vdc'
  # sample output:
  #   limit_resource_module_type => 'f3'
  out = on(agent, cmd, pty: true).stdout[/limit_resource_module_type => '(.*)'/]
  type = out.nil? ? '' : Regexp.last_match[1]
  logger.info("\nCurrent module type: '#{type}'\n")
  type
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  skip_unless_supported(tests)

  # initial setup
  orig_type = current_module_type
  if orig_type == tests[:mod_type]
    logger.info("\nReset module type to default\n")
    limit_resource_module_type_set(default_vdc_name, nil, true)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Non Default Property Testing")
  test_harness_run(tests, :non_default)

  # Restore original testbed settings
  logger.info("\nRestore module type to '#{orig_type}'\n")
  limit_resource_module_type_set(default_vdc_name, orig_type)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
