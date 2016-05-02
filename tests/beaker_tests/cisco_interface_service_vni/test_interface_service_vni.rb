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
  sid:              22,
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  manifest_props: {
    encapsulation_profile_vni: 'default',
    shutdown:                  'default',
  },
  resource:       {
    # 'encapsulation_profile_vni' is nil
    'shutdown' => 'true'
  },
}

tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  manifest_props: {
    encapsulation_profile_vni: 'vni_500_5000',
    shutdown:                  'false',
  },
}

# TEST PRE-REQUISITES
#   - F3 linecard assigned to admin vdc
#   - Global encap profile vni config
def dependency_manifest(*)
  "
    cisco_vdc { '#{default_vdc_name}':
      ensure                     => present,
      limit_resource_module_type => 'f3',
    }

    cisco_encapsulation { 'vni_500_5000':
      dot1q_map => #{Array['500', '5000']}
    }
  "
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  skip_unless_supported(tests)
  if (intf = mt_full_interface).nil?
    prereq_skip(nil, self,
                'MT-full tests require F3 or compatible line module')
  end

  # Clean up any stale pre-req configs that might conflict with our test
  resource_absent_cleanup(agent, 'cisco_encapsulation')
  interface_cleanup(agent, intf)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  id = :default
  tests[id][:title_pattern] = "#{intf} #{tests[:sid]}"
  test_harness_run(tests, id)

  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -----------------------------------
  resource_absent_cleanup(agent, 'cisco_interface_service_vni')
  resource_absent_cleanup(agent, 'cisco_encapsulation')

  interface_cleanup(agent, intf, 'Post-test cleanup: ')
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
