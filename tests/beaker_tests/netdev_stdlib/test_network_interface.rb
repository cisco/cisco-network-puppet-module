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
  ensurable:        false,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'network_interface',
}

tests[:non_default] = {
  desc:           '2.1 Non Default',
  manifest_props: {
    description: 'test_netdev'
    # speed,duplex,mtu are defined by interface_pre_check()
  },
}

tests[:auto] = {
  # Tests speed/duplex 'auto' values. (Not supported on some platforms)
  desc:           '2.2 speed/duplex auto',
  manifest_props: {
    # speed,duplex are defined by interface_pre_check()
  },
}

# This helper method is used for testbed initial setup. It also defines
# some property test values based on the discovered interface capabilities.
def interface_pre_check(tests) # rubocop:disable Metrics/AbcSize
  # Discover a usable test interface
  intf = find_interface(tests)
  tests[:non_default][:title_pattern] = intf
  tests[:auto][:title_pattern] = intf

  # Clean the test interface
  system_default_switchport(agent, false)
  interface_cleanup(agent, intf, 'Initial Cleanup')

  # Get the capabilities and update the caps list with any add'l test values
  caps = interface_capabilities(agent, intf)
  caps['Speed'] += ',auto' unless caps['Speed']['auto']
  caps['Duplex'] += ',auto' unless caps['Duplex']['auto']
  caps['MTU'] = '1600'

  # Create a probe hash to pre-test the properties
  probe = {
    cmd:          PUPPET_BINPATH + 'resource network_interface ',
    intf:         intf,
    caps:         caps,
    probe_props:  %w(Speed Duplex MTU),
    netdev_speed: true,
  }

  caps = interface_probe(tests, probe)[:caps]

  # Fixup the test manifests with usable values
  spd = caps['Speed']
  dup = caps['Duplex']
  mtu = caps['MTU']

  tests[:auto][:manifest_props][:speed] = 'auto' if spd.delete('auto')
  tests[:auto][:manifest_props][:duplex] = 'auto' if dup.delete('auto')

  tests[:non_default][:manifest_props][:speed] = spd.pop unless spd.empty?
  tests[:non_default][:manifest_props][:duplex] = dup.pop unless dup.empty?
  tests[:non_default][:manifest_props][:mtu] = mtu.pop unless mtu.empty?

  logger.info "\n      Pre-Check :non_default hash: #{tests[:non_default]}"\
              "\n      Pre-Check :auto hash: #{tests[:auto]}"
  interface_cleanup(agent, intf, 'Post-Pre-Check Cleanup')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 0. Testbed setup")
  interface_pre_check(tests)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Defaults")
  test_harness_run(tests, :non_default)
  test_harness_run(tests, :auto)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
