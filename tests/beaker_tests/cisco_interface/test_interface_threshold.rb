###############################################################################
# Copyright (c) 2014-2019 Cisco and/or its affiliates.
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
# 'test_interface_threshold' primarily tests the prefetch behavior when using
# a manifest that contains more interface resources than the lookup threshold;
# this causes NU to fetch all the interfaces at once with 'show run int',
# versus gathering them one at a time with 'show run int <interface_name>'.
#
# This test has threshold test coverage for these providers:
#  cisco_interface
#  cisco_interface_ospf
#  cisco_interface_channel_group
#
###############################################################################
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:     agent,
  master:    master,
  intf_type: 'all',
}

tests[:intf_array] = intf_array = find_interface_array(tests)
multiplier = platform[/n7/] ? 0.075 : 0.15
tests[:threshold] = threshold = (intf_array.length * multiplier).to_i

# intf_array contains all interfaces. Prefer a smaller range of ethernets
# to make cleanup faster.
if eth_slot ||= intf_array.find { |eth| eth[/ethernet\d+/] }
  # select a range from the first eth slot found
  eth_slot = eth_slot.split('/').first
  range = intf_array.map { |eth| eth[/^#{eth_slot}\/\d+/] }.compact
  if range.count > threshold
    # Sort interfaces by port number: ethernet1/(14) and reduce the range size
    range = range.sort_by { |m| m.split('/').last.to_i }[0..threshold + 1]
    tests[:intf_array] = range
    tests[:intf_range] = range[0] + ' - ' + range[-1].split('/').last
  end
end
msg = "Interface count: #{intf_array.length}, threshold: #{threshold}"
logger.info("\n#{'-' * 60}\n#{msg}\n#{'-' * 60}")

# Create a test manifest with multiple resources
def build_manifest_interface(tests, intf_count: 0)
  intf_array = tests[:intf_array]
  manifest = ''

  0.upto(intf_count - 1) do |i|
    case tests[:resource_name]
    when :cisco_interface
      manifest += "
        cisco_interface { '#{intf_array[i]}':
          ensure => 'present',
        }
      "
    when :cisco_interface_channel_group
      manifest += "
        cisco_interface_channel_group { '#{intf_array[i]}':
          shutdown => false,
        }
      "
    when :cisco_interface_evpn_multisite
      manifest += "
        cisco_interface_evpn_multisite { '#{intf_array[i]}':
          ensure => present,
        }
      "
    when :cisco_interface_ospf
      manifest += "
        cisco_interface_ospf { '#{intf_array[i]} threshold_test':
          area => '0.0.0.0',
        }
      "
    end
  end
  manifest
end

def cleanup(tests)
  logger.info("\n#{'-' * 60}\nTest Cleanup :: Start\n")
  test_set(agent, 'no feature ospf')
  if tests[:intf_range]
    interface_cleanup_range(tests)
  else
    1.upto(tests[:threshold] + 1) do |i|
      interface_cleanup(agent, tests[:intf_array][i])
    end
  end
  logger.info("\n#{'-' * 60}\nTest Cleanup :: End\n")
end

providers = [
  :cisco_interface,
  :cisco_interface_ospf,
  :cisco_interface_channel_group,
]
if platform[/n9k-ex/]
  providers.push(:cisco_interface_evpn_multisite)
else
  logger.info("\n#{'-' * 60}\nNo support on this device for :cisco_interface_evpn_multisite\n")
end

#################################################################
# TEST CASE EXECUTION
# These tests are mainly concerned with the interface lookup selection
# method so we will not validate individual properties and such.
test_name 'TestCase :: cisco_interface* threshold tests :: Start' do
  teardown { cleanup(tests) }
  cleanup(tests)

  # minimize number of test resources
  min_threshold_hosts = (threshold > 2) ? 2 : threshold

  providers.each do |provider|
    tests[:resource_name] = provider
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nTest prefetch per-interface [#{provider}]")
    manifest = build_manifest_interface(tests, intf_count: min_threshold_hosts)
    output = create_and_apply_generic_manifest(manifest, [0, 2])
    logger.info("\ndevice output:\n#{'-' * 60}\n#{output}\n#{'-' * 60}")
    fail_test('FAILED: prefetch each interface select error') unless
      output[/Cisco_interface.*::.*prefetch each interface independently] \(threshold: #{threshold}/]

    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nTest prefetch all-interfaces [#{provider}]")
    manifest = build_manifest_interface(tests, intf_count: threshold + 1)
    output = create_and_apply_generic_manifest(manifest, [0, 2])
    logger.info("\ndevice output:\n#{'-' * 60}\n#{output}\n#{'-' * 60}")
    fail_test('FAILED: prefetch all interfaces select error') unless
      output[/Cisco_interface.*::.*prefetch all interfaces/]
  end
end

logger.info('TestCase :: cisco_interface* threshold tests :: End')
