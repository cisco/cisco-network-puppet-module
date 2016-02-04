###############################################################################
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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
# See README-beaker-script-ref.md for information regarding:
#  - test script general prequisites
#  - command return codes
#  - A description of the 'tests' hash and its usage
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

testheader = 'Resource cisco_bgp_neighbor'

# Test hash top-level keys
tests = {
  master:        master,
  agent:         agent,
  resource_name: 'cisco_bgp_neighbor',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  '2 default 1.1.1.1',
  preclean:       'cisco_bgp',
  manifest_props: {
    ebgp_multihop:      'default',
    local_as:           'default',
    low_memory_exempt:  'default',
    remote_as:          'default',
    suppress_4_byte_as: 'default',
    timers_keepalive:   'default',
    timers_holdtime:    'default',

  },
  resource:       {
    'ebgp_multihop'          => 'false',
    'local_as'               => '0',
    'low_memory_exempt'      => 'false',
    'maximum_peers'          => '0',
    'remote_as'              => '0',
    'suppress_4_byte_as'     => 'false',
    'timers_keepalive'       => '60',
    'timers_holdtime'        => '180',
    'transport_passive_only' => 'false',
  },
}

tests[:non_def_uber] = {
  desc:           'Non Default: (UBER)',
  preclean:       'cisco_bgp_neighbor',
  title_pattern:  '2 blue 1.1.1.1',
  manifest_props: {
    description:            'tested by beaker',
    connected_check:        'true',
    capability_negotiation: 'true',
    dynamic_capability:     'true',
    ebgp_multihop:          '2',
    log_neighbor_changes:   'enable',
    low_memory_exempt:      'true',
    remove_private_as:      'all',
    shutdown:               'true',
    suppress_4_byte_as:     'true',
    timers_keepalive:       '90',
    timers_holdtime:        '270',
  },
}

tests[:non_def_local_remote_as] = {
  preclean:       'cisco_bgp_neighbor',
  title_pattern:  '2 blue 1.1.1.1',
  desc:           'Non Default: (AS) local-as, remote-as',
  manifest_props: {
    local_as:  '42',
    remote_as: '12.1',
  },
}

tests[:non_def_update_source] = {
  desc:           'Non Default: (update-source)',
  title_pattern:  '2 blue 1.1.1.1',
  intf_type:      'ethernet',
  manifest_props: {
    # update_source: find_interface(tests, id) # Set dynamically at run time
  },
}

tests[:title_patterns] = {
  preclean:       'cisco_bgp',
  manifest_props: {},
  resource:       { 'ensure' => 'present' },
}

# Title Pattern Test Hash
titles = {}
titles['T.1'] = {
  title_pattern: '2',
  title_params:  { vrf: 'blue', neighbor: '1.1.1.1' },
}
titles['T.2'] = {
  title_pattern: '2 blue',
  title_params:  { neighbor: '1.1.1.1' },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  tests[:default][:ensure] = :absent
  tests[:default].delete(:preclean)
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_def_uber)
  test_harness_run(tests, :non_def_local_remote_as)

  id = :non_def_update_source
  tests[id][:manifest_props] = {
    update_source: find_interface(tests, id)
  }
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  test_title_patterns(tests, :title_patterns, titles)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_bgp')
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{testheader} :: End")
