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
  resource_name:    'cisco_interface_capabilities',
}

def parse_capabilities(agent, cmd)
  on(agent, cmd)
  caps = {}
  caps['Speed'] = Regexp.last_match[1] if stdout[/Speed:\s+([\w,]+)/]
  caps['Duplex'] = Regexp.last_match[1] if stdout[/Duplex:\s+([\w,-]+)/]
  logger.debug("\ncapabilities hash: #{caps}")
  caps
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  skip_unless_supported(tests)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\n1.1 Test puppet resource vs vsh results")

  intf = find_interface(tests)

  vsh_cmd = get_vshell_cmd("show interface #{intf} capabilities")
  vsh_caps = parse_capabilities(agent, vsh_cmd)

  resource_cmd = PUPPET_BINPATH + "resource cisco_interface_capabilities '#{intf}'"
  resource_caps = parse_capabilities(agent, resource_cmd)

  fail_test('puppet resource mismatch with vsh :: FAIL') unless
    vsh_caps == resource_caps

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\n1.2 Test with utilitylib helper results")
  util_caps = interface_capabilities(agent, intf)

  vsh_caps.keys.each do |k|
    next if vsh_caps[k] == util_caps[k]
    fail_test('utilitylib helper results mismatch with vsh')
  end
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
