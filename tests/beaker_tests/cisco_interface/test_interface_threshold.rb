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
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

# Test hash top-level keys
tests = {
  agent:         agent,
  master:        master,
  all:           { intf_type: 'all' },
  resource_name: 'cisco_interface',
}

intf_array = find_interface_array(tests, :all)
threshold = (intf_array.length * 0.15).to_i
msg = "Interface count: #{intf_array.length}, threshold: #{threshold}"
logger.info("\n#{'-' * 60}\n#{msg}\n#{'-' * 60}")

# Create a test manifest with multiple resources
def build_manifest_interface(intf_array, intf_count: 0)
  manifest = ''
  1.upto(intf_count) do |i|
    manifest += "
      cisco_interface { '#{intf_array[i]}':
        description => 'threshold test intf #{i}',
      }
    "
  end
  manifest
end

#################################################################
# TEST CASE EXECUTION
# These tests are mainly concerned with the interface lookup selection
# method so we will not validate individual properties and such.
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nTest prefetch per-interface")
  manifest = build_manifest_interface(intf_array, intf_count: threshold - 1)
  output = create_and_apply_generic_manifest(manifest, [0, 2])
  fail_test('FAILED: prefetch each interface select error') unless
    output[/Cisco_interface::.*prefetch each interface independently/]

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nTest prefetch all-interfaces")
  manifest = build_manifest_interface(intf_array, intf_count: threshold + 1)
  output = create_and_apply_generic_manifest(manifest, [0, 2])
  fail_test('FAILED: prefetch all interfaces select error') unless
    output[/Cisco_interface::.*prefetch all interfaces/]
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
