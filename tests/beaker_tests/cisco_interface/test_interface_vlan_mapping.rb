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
#
# 'test_interface_vlan_mapping' tests vlan-mapping interface properties.
#
#        ****************************************
#        ** IMPORTANT ADDITIONAL PREREQUISITES **
#        ****************************************
#
# The vlan_mapping properties are "Multi-Tenancy Full" properties which
# currently have limited platform and linecard support. This test script will
# look for these requirements and fail if they are not present:
#
#  - VDC support
#  - F3 linecard
#
# This test will need to be updated as the product matures.
#
###############################################################################
require File.expand_path('../interfacelib.rb', __FILE__)

tests = {
  agent:            agent,
  master:           master,
  operating_system: 'nexus',
  platform:         'n7k',
  resource_name:    'cisco_interface',
  intf_type:        'ethernet',
  bridge_domain:    '100',
  switchport_mode:  'trunk',
  # On N7k, feature vni requires solely F3 cards in the vdc
  vdc_limit_module: 'f3',
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Assign a test interface.
if platform[/n7k/]
  unless mt_full_interface
    prereq_skip(nil, self, 'Test requires F3 or compatible line module')
  end
  setup_mt_full_env(tests, self)
  # Use test interface discovered by setup_mt_full_env().
  intf = tests[:intf]
else
  intf = find_interface(tests)
end

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  intf,
  # :preclean_intf not needed since setup_mt_full_env will clean intf
  code:           [0],
  manifest_props: {
    vlan_mapping_enable: 'default',
    vlan_mapping:        'default',
  },
  resource:       {
    vlan_mapping_enable: 'true',
    # 'vlan_mapping' is nil when default
  },
}

vlan_maps = Array[%w(20 21), %w(30 31)]
tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  intf,
  manifest_props: {
    vlan_mapping_enable: 'false',
    vlan_mapping:        vlan_maps,
  },
  resource:       {
    vlan_mapping_enable: 'false',
    vlan_mapping:        "#{vlan_maps}",
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -----------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  test_harness_run(tests, :default)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default)

  # -------------------------------------------------------------------
  interface_cleanup(agent, intf)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
