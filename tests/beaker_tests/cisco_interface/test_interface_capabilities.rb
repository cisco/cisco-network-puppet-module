###############################################################################
# Copyright (c) 2016-2018 Cisco and/or its affiliates.
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
#
# 'test_interface_capabilities' tests platform/linecard variable interface
# properties such as speed, duplex, mtu, negotiate.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:            agent,
  master:           master,
  ensurable:        false,
  intf_type:        'ethernet',
  operating_system: 'nexus',
  resource_name:    'cisco_interface',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Find a usable interface for this test
intf = find_interface(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  code:           [0, 2],
  manifest_props: {
    description:     'Testing default properties',
    switchport_mode: 'disabled',
    # interface_pre_check() will define add'l properties
  },
}

tests[:non_default] = {
  desc:           '1.2 Misc. Non Default Properties',
  title_pattern:  intf,
  manifest_props: {
    switchport_mode: 'disabled',
    # interface_pre_check() will define add'l properties
  },
}

# This method will probe the test interface to determine testable values.
def interface_pre_check(tests, intf) # rubocop:disable Metrics/AbcSize
  # Clean the test interface
  system_default_switchport(agent, false)
  interface_cleanup(agent, intf, 'Initial Cleanup')

  # Get the capabilities and update the caps list with any add'l test values
  caps = interface_capabilities(agent, intf)

  if caps.empty?
    tests[:skipped] ||= []
    tests[:skipped] << tests[:default][:desc]
    tests[:skipped] << tests[:non_default][:desc]
    return false
  end

  caps['Speed'] += ',auto' unless caps['Speed']['auto']
  caps['Duplex'] += ',auto' unless caps['Duplex']['auto']
  caps['MTU'] = '1600'

  # Create a probe hash to pre-test the properties
  probe = {
    cmd:         PUPPET_BINPATH + 'resource cisco_interface ',
    intf:        intf,
    caps:        caps,
    probe_props: %w(Speed Duplex MTU),
  }
  caps = interface_probe(tests, probe)[:caps]

  # Fixup the test manifests with usable values
  spd = caps['Speed']
  dup = caps['Duplex']
  mtu = caps['MTU']

  tests[:default][:manifest_props][:negotiate_auto] = 'true' unless platform[/n7k/]
  tests[:default][:manifest_props][:duplex] = 'auto' if dup.delete('auto')
  tests[:default][:manifest_props][:speed] = 'auto' if spd.delete('auto')

  tests[:non_default][:manifest_props][:duplex] = dup.shift unless dup.empty?
  tests[:non_default][:manifest_props][:speed] = spd.shift unless spd.empty?
  tests[:non_default][:manifest_props][:mtu] = mtu.shift unless mtu.empty?

  # Cannot turn off auto-negotiate for speeds 10G+
  non_default_speed = tests[:non_default][:manifest_props][:speed]
  tests[:non_default][:manifest_props][:negotiate_auto] = 'false' unless platform[/n7k/] || non_default_speed.to_i >= 10_000

  logger.info("\n      Pre-Check :default hash: #{tests[:default]}"\
              "\n      Pre-Check :non_default hash: #{tests[:non_default]}")
  interface_cleanup(agent, intf, 'Post-Pre-Check Cleanup')
  true
end

def parse_capabilities(agent, cmd, resource_command: false)
  stdout = if resource_command && agent
             on(agent, cmd).output
           elsif resource_command
             `#{cmd}`
           elsif agent
             on(agent, get_vshell_cmd(cmd)).output
           else
             test_get(agent, cmd, is_a_running_config_command: false)
           end
  caps = {}
  caps['Speed'] = Regexp.last_match[1] if stdout[/Speed:\s+([\w,]+)/]
  caps['Duplex'] = Regexp.last_match[1] if stdout[%r{Duplex:\s+([\w/,-]+)}]
  logger.info("\ncapabilities hash: #{caps}")
  caps
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { interface_cleanup(agent, intf) }
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Platform/Linecard Variable Properties")

  if interface_pre_check(tests, intf)
    test_harness_run(tests, :default)
    test_harness_run(tests, :non_default)
  else
    msg = 'Could not find interface capabilities'
    logger.error("\n#{tests[:default][:desc]} :: default :: SKIP\n#{msg}")
    logger.error("\n#{tests[:non_default][:desc]} :: non_def :: SKIP\n#{msg}")
  end

  # -------------------------------------------------------------------
  # Section 2 & 3 test the cisco_interface_capabilities provider itself.
  logger.info("\n#{'-' * 60}\nSection 2. Test puppet resource vs vsh results")

  vsh_cmd = "show interface #{intf} capabilities"
  # Note: vsh output is 'raw' command output (as opposed to the processed hash)
  vsh_caps = parse_capabilities(agent, vsh_cmd)

  resource_cmd = if agent
                   PUPPET_BINPATH + "resource cisco_interface_capabilities '#{intf}'"
                 else
                   agentless_command + "--resource cisco_interface_capabilities '#{intf}'"
                 end
  resource_caps = parse_capabilities(agent, resource_cmd, resource_command: true)

  unless vsh_caps == resource_caps
    logger.error("vsh_caps: #{vsh_caps}, resource_caps: #{resource_caps}")
    fail_test('puppet resource mismatch with vsh :: FAIL')
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. Test with utilitylib helper results")
  util_caps = interface_capabilities(agent, intf)

  vsh_caps.keys.each do |k|
    next if k[/Duplex/] && vsh_caps[k][%r{half/full}] # noise
    next if vsh_caps[k] == util_caps[k]
    logger.error("vsh_caps[#{k}]=#{vsh_caps[k]}, util_caps[#{k}]=#{util_caps[k]}")
    fail_test('utilitylib helper results mismatch with vsh')
  end
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
