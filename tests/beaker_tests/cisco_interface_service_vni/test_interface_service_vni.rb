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
  operating_system: 'nexus',
  platform:         'n7k',
  resource_name:    'cisco_interface_service_vni',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

if (intf = mt_full_interface)
  tests[:intf] = intf
  setup_mt_full_env(tests, self)
else
  prereq_skip(nil, self, 'MT-full tests require F3 or compatible line module')
end

# Test hash test cases
tests[:default] = {
  desc:               '1.1 Default Properties',
  title_pattern:      "#{intf} 22",
  sys_def_switchport: false,
  manifest_props:     {
    encapsulation_profile_vni: 'default',
    shutdown:                  'default',
  },
  resource:           {
    # encapsulation_profile_vni: nil
    shutdown: 'true'
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  "#{intf} 22",
  manifest_props: {
    encapsulation_profile_vni: 'vni_500_5000',
    shutdown:                  'false',
  },
}

# class to contain the test_dependencies specific to this test case
class TestInterfaceServiceVni < BaseHarness
  def self.dependency_manifest(ctx, tests, id)
    return unless id == :default
    dep = %(
      cisco_encapsulation {'vni_500_5000':
        dot1q_map => ['500', '5000'],
      }
      cisco_interface{ '#{tests[:intf]}':
        switchport_mode => 'disabled',
      }
    )
    ctx.logger.info("\n  * dependency_manifest\n#{dep}")
    dep
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown do
    resource_absent_cleanup(agent, 'cisco_interface_service_vni')
    resource_absent_cleanup(agent, 'cisco_encapsulation')
    interface_cleanup(agent, intf)
  end
  resource_absent_cleanup(agent, 'cisco_encapsulation')
  interface_cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default, harness_class: TestInterfaceServiceVni)
  test_harness_run(tests, :non_default, harness_class: TestInterfaceServiceVni)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
