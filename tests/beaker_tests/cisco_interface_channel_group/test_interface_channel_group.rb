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
  intf_type:     'ethernet',
  resource_name: 'cisco_interface_channel_group',
}

intf = find_interface(tests)

tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  code:           [0, 2],
  manifest_props: {
    channel_group:      'default',
    channel_group_mode: 'default',
    description:        'default',
    shutdown:           'default',
  },
  resource:       {
    'channel_group'      => 'false',
    'channel_group_mode' => 'false',
    'shutdown'           => 'true',
  },
}

tests[:non_default_no_mode] = {
  desc:           '2.1 Non Default Properties with no channel group mode',
  title_pattern:  intf,
  manifest_props: {
    channel_group: 201,
    description:   'chan group desc',
    shutdown:      'false',
  },
  resource:       {
    'channel_group' => '201',
    'description'   => 'chan group desc',
    'shutdown'      => 'false',
  },
}

tests[:non_default_mode] = {
  desc:           '2.2 Non Default Properties with channel group mode',
  title_pattern:  intf,
  manifest_props: {
    channel_group:      201,
    channel_group_mode: 'active',
    description:        'chan group desc',
    shutdown:           'false',
  },
  resource:       {
    'channel_group'      => '201',
    'channel_group_mode' => 'active',
    'description'        => 'chan group desc',
    'shutdown'           => 'false',
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { interface_cleanup(agent, intf) }
  interface_cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default_no_mode)
  test_harness_run(tests, :non_default_mode)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
