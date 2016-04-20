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

# Capabilities-to-Manifest syntax converter
def manifest_speed(speed)
  case speed.to_s
  when '100' then '100m'
  when '1000' then '1g'
  when '10000' then '10g'
  when '40000' then '40g'
  when '100000' then '100g'
  else speed
  end
end

# This helper method is used for testbed initial setup. It also defines
# some property test values based on the discovered interface capabilities.
def interface_pre_check(tests)
  # Discover a usable test interface
  intf = find_interface(tests)
  [:non_default, :auto].each { |t| tests[t][:title_pattern] = intf }
  resource_cmd = PUPPET_BINPATH + "resource network_interface '#{intf}' "

  # Clean the test interface
  agent = tests[:agent]
  system_default_switchport(agent, false)
  interface_cleanup(agent, intf, 'Initial Cleanup')

  cap = interface_capabilities(agent, intf)
  precheck_testable_non_defaults(tests, resource_cmd, cap)
  precheck_testable_auto(tests, resource_cmd)
  interface_cleanup(agent, intf, 'Post-Pre-Check Cleanup')
end

# Discover testable non-default property values
def precheck_testable_non_defaults(tests, cmd, cap)
  agent = tests[:agent]
  testable = {}
  cap['Speed'].to_s.split(',').each do |cap_speed|
    man_speed = manifest_speed(cap_speed)
    on(agent, cmd + "speed=#{man_speed}",
       acceptable_exit_codes: [0, 2, 1], pty: true)
    next if stdout[/error/i]
    testable[:speed] = man_speed
    break
  end

  cap['Duplex'].to_s.split(',').each do |duplex|
    on(agent, cmd + "duplex=#{duplex}",
       acceptable_exit_codes: [0, 2, 1], pty: true)
    next if stdout[/error/i]
    testable[:duplex] = duplex
    break
  end

  # MTU isn't provided by interface_capabilities
  mtu = 1600
  on(agent, cmd + "mtu=#{mtu}",
     acceptable_exit_codes: [0, 2, 1], pty: true)
  testable[:mtu] = mtu unless stdout[/error/i]

  # Update the :non_default test with the testable values
  testable.keys.each do |k|
    tests[:non_default][:manifest_props][k] = testable[k]
  end
  logger.info "\n    Pre-Check :non_default hash: #{tests[:non_default]}"
end

# Discover testable 'auto' property values
def precheck_testable_auto(tests, cmd)
  agent = tests[:agent]

  on(agent, cmd + "speed='auto'",
     acceptable_exit_codes: [0, 2, 1], pty: true)
  tests[:auto][:manifest_props][:speed] = 'auto' unless stdout[/error/i]

  on(agent, cmd + "duplex='auto'",
     acceptable_exit_codes: [0, 2, 1], pty: true)
  tests[:auto][:manifest_props][:duplex] = 'auto' unless stdout[/error/i]

  logger.info "\n    Pre-Check :auto hash: #{tests[:auto]}"
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
