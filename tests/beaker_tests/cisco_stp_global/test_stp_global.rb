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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  resource_name:    'cisco_stp_global',
  ensurable:        false,
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    bpdufilter:               'default',
    bpduguard:                'default',
    bridge_assurance:         'default',
    loopguard:                'default',
    mode:                     'default',
    pathcost:                 'default',
    vlan_designated_priority: 'default',
    vlan_forward_time:        'default',
    vlan_hello_time:          'default',
    vlan_max_age:             'default',
    vlan_priority:            'default',
    vlan_root_priority:       'default',
  },
  code:           [0, 2],
  resource:       {
    'bpdufilter'       => 'false',
    'bpduguard'        => 'false',
    'bridge_assurance' => 'true',
    'loopguard'        => 'false',
    'mode'             => 'rapid-pvst',
    'pathcost'         => 'short',
    # 'vlan_designated_priority' is nil when default
    # 'vlan_forward_time' is nil when default
    # 'vlan_hello_time' is nil when default
    # 'vlan_max_age' is nil when default
    # 'vlan_priority' is nil when default
    # 'vlan_root_priority' is nil when default
  },
}

tests[:default_mst] = {
  desc:           '1.3 Default mst Properties',
  title_pattern:  'default',
  manifest_props: {
    mode:                    'mst',
    mst_designated_priority: 'default',
    mst_forward_time:        'default',
    mst_hello_time:          'default',
    mst_inst_vlan_map:       'default',
    mst_max_age:             'default',
    mst_max_hops:            'default',
    mst_name:                'default',
    mst_priority:            'default',
    mst_revision:            'default',
    mst_root_priority:       'default',
  },
  code:           [0, 2],
  resource:       {
    'mode'             => 'mst',
    # 'mst_designated_priority' is nil when default
    'mst_forward_time' => '15',
    'mst_hello_time'   => '2',
    # 'mst_inst_vlan_map' is nil when default
    'mst_max_age'      => '20',
    'mst_max_hops'     => '20',
    'mst_name'         => 'false',
    # 'mst_priority' is nil when default
    'mst_revision'     => '0',
    # 'mst_root_priority' is nil when default
  },
}

mst_dp = Array[%w(2-42 4096), %w(83-92,100-230 53248)]
mst_ivm = Array[%w(2 6-47), %w(92 120-400)]
mst_pri = Array[%w(2-42 4096), %w(83-92,100-230 53248)]
mst_rpri = Array[%w(2-42 4096), %w(83-92,100-230 53248)]
vlan_dp = Array[%w(1-42 40960), %w(83-92,100-230 53248)]
vlan_ft = Array[%w(1-42 19), %w(83-92,100-230 13)]
vlan_ht = Array[%w(1-42 10), %w(83-92,100-230 6)]
vlan_ma = Array[%w(1-42 21), %w(83-92,100-230 13)]
vlan_pri = Array[%w(1-42 40960), %w(83-92,100-230 53248)]
vlan_rpri = Array[%w(1-42 40960), %w(83-92,100-230 53248)]
tests[:non_default] = {
  desc:           '2.1 Non Default Properties',
  title_pattern:  'default',
  manifest_props: {
    bpdufilter:               'true',
    bpduguard:                'true',
    bridge_assurance:         'false',
    loopguard:                'true',
    mode:                     'mst',
    mst_designated_priority:  mst_dp,
    mst_forward_time:         '25',
    mst_hello_time:           '5',
    mst_inst_vlan_map:        mst_ivm,
    mst_max_age:              '35',
    mst_max_hops:             '200',
    mst_name:                 'nexus',
    mst_priority:             mst_pri,
    mst_revision:             '34',
    mst_root_priority:        mst_rpri,
    pathcost:                 'long',
    vlan_designated_priority: vlan_dp,
    vlan_forward_time:        vlan_ft,
    vlan_hello_time:          vlan_ht,
    vlan_max_age:             vlan_ma,
    vlan_priority:            vlan_pri,
    vlan_root_priority:       vlan_rpri,
  },
  resource:       {
    mst_designated_priority:  "#{mst_dp}",
    mst_inst_vlan_map:        "#{mst_ivm}",
    mst_priority:             "#{mst_pri}",
    mst_root_priority:        "#{mst_rpri}",
    vlan_designated_priority: "#{vlan_dp}",
    vlan_forward_time:        "#{vlan_ft}",
    vlan_hello_time:          "#{vlan_ht}",
    vlan_max_age:             "#{vlan_ma}",
    vlan_priority:            "#{vlan_pri}",
    vlan_root_priority:       "#{vlan_rpri}",
  },
}

tests[:default_plat_1] = {
  desc:           '1.4 Default Properties platform specific part 1',
  platform:       'n9k',
  title_pattern:  'default',
  manifest_props: {
    fcoe: 'default'
  },
  code:           [0, 2],
  resource:       {
    'fcoe' => 'true'
  },
}

tests[:non_default_plat_1] = {
  desc:           '2.3 Non Default Properties platform specific part 1',
  platform:       'n9k',
  title_pattern:  'default',
  manifest_props: {
    fcoe: 'false'
  },
}

tests[:default_plat_2] = {
  desc:           '1.4 Default Properties platform specific part 2',
  platform:       'n(5|6|7)k',
  title_pattern:  'default',
  manifest_props: {
    domain: 'default'
  },
  code:           [0, 2],
  resource:       {
    'domain' => 'false'
  },
}

tests[:non_default_plat_2] = {
  desc:           '2.3 Non Default Properties platform specific part 2',
  platform:       'n(5|6|7)k',
  title_pattern:  'default',
  manifest_props: {
    domain: '100'
  },
}

tests[:default_bd] = {
  desc:           '1.2 bridge-domain Default Properties platform specific',
  platform:       'n7k',
  title_pattern:  'default',
  manifest_props: {
    bd_designated_priority: 'default',
    bd_forward_time:        'default',
    bd_hello_time:          'default',
    bd_max_age:             'default',
    bd_priority:            'default',
    bd_root_priority:       'default',
  },
  code:           [0, 2],
  resource:       {
    # 'bd_designated_priority' is nil when default
    # 'bd_forward_time' is nil when default
    # 'bd_hello_time' is nil when default
    # 'bd_max_age' is nil when default
    # 'bd_priority' is nil when default
    # 'bd_root_priority' is nil when default
  },
}

bd_dp = Array[%w(2-42 40960), %w(83-92,100-2300 53248)]
bd_ft = Array[%w(2-42 26), %w(83-92,100-2300 20)]
bd_ht = Array[%w(2-42 6), %w(83-92,100-2300 9)]
bd_ma = Array[%w(2-42 26), %w(83-92,100-2300 21)]
bd_pri = Array[%w(2-42 40960), %w(83-92,100-2300 53248)]
bd_rpri = Array[%w(2-42 40960), %w(83-92,100-2300 53248)]
tests[:non_default_bd] = {
  desc:           '2.2 bridge-domain Non Default Properties platform specific',
  platform:       'n7k',
  title_pattern:  'default',
  manifest_props: {
    bd_designated_priority: bd_dp,
    bd_forward_time:        bd_ft,
    bd_hello_time:          bd_ht,
    bd_max_age:             bd_ma,
    bd_priority:            bd_pri,
    bd_root_priority:       bd_rpri,
  },
  resource:       {
    bd_designated_priority: "#{bd_dp}",
    bd_forward_time:        "#{bd_ft}",
    bd_hello_time:          "#{bd_ht}",
    bd_max_age:             "#{bd_ma}",
    bd_priority:            "#{bd_pri}",
    bd_root_priority:       "#{bd_rpri}",
  },
}

# Overridden to properly handle dependencies for this test file.
def test_harness_dependencies(_tests, id)
  return unless platform == 'n7k'
  if id == :default_bd || id == :non_default_bd
    cmd = 'system bridge-domain all'
    command_config(agent, cmd, cmd)
  else
    cmd = 'system bridge-domain all ; system bridge-domain none'
    command_config(agent, cmd, cmd)
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  remove_all_vlans(agent)
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default)
  test_harness_run(tests, :default_bd)
  test_harness_run(tests, :default_mst)
  test_harness_run(tests, :default_plat_1)
  test_harness_run(tests, :default_plat_2)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default)
  test_harness_run(tests, :non_default_bd)
  test_harness_run(tests, :non_default_plat_1)
  test_harness_run(tests, :non_default_plat_2)

  remove_all_vlans(agent)
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
