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
  platform:         'n(7|9)k',
  resource_name:    'cisco_bfd_global',
}

default_interval_plat_1 = %w(250 250 3)
default_interval_plat_2 = %w(50 50 3)
non_default_interval = %w(100 100 25)
non_default_ipv4_interval = %w(200 200 50)
non_default_ipv6_interval = %w(500 500 30)
non_default_fabricpath_interval = %w(750 350 35)

# Test hash test cases
tests[:default_plat_1] = {
  desc:           '1.1 Defaults for n3k',
  platform:       'n3k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'default',
    echo_rx_interval:      'default',
    interval:              'default',
    ipv4_echo_rx_interval: 'default',
    ipv4_interval:         'default',
    ipv4_slow_timer:       'default',
    ipv6_echo_rx_interval: 'default',
    ipv6_interval:         'default',
    ipv6_slow_timer:       'default',
    slow_timer:            'default',
    startup_timer:         'default',
  },
  code:           [0, 2],
  resource:       {
    echo_interface:        'false',
    echo_rx_interval:      250,
    interval:              default_interval_plat_1,
    ipv4_echo_rx_interval: 250,
    ipv4_interval:         default_interval_plat_1,
    ipv4_slow_timer:       2000,
    ipv6_echo_rx_interval: 250,
    ipv6_interval:         default_interval_plat_1,
    ipv6_slow_timer:       2000,
    slow_timer:            2000,
    startup_timer:         5,
  },
}

tests[:default_plat_2] = {
  desc:           '1.2 Defaults for n8k, n9k',
  platform:       'n(8|9)k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'default',
    echo_rx_interval:      'default',
    ipv4_echo_rx_interval: 'default',
    ipv4_interval:         'default',
    ipv4_slow_timer:       'default',
    ipv6_echo_rx_interval: 'default',
    ipv6_interval:         'default',
    ipv6_slow_timer:       'default',
    slow_timer:            'default',
    startup_timer:         'default',
  },
  code:           [0, 2],
  resource:       {
    echo_interface:        'false',
    echo_rx_interval:      50,
    ipv4_echo_rx_interval: 50,
    ipv4_interval:         default_interval_plat_2,
    ipv4_slow_timer:       2000,
    ipv6_echo_rx_interval: 50,
    ipv6_interval:         default_interval_plat_2,
    ipv6_slow_timer:       2000,
    slow_timer:            2000,
    startup_timer:         5,
  },
}

tests[:default_plat_3] = {
  desc:           '1.3 Defaults for n5k, n6k',
  platform:       'n(5|6)k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'default',
    fabricpath_interval:   'default',
    fabricpath_slow_timer: 'default',
    fabricpath_vlan:       'default',
    interval:              'default',
    slow_timer:            'default',
  },
  code:           [0, 2],
  resource:       {
    echo_interface:        'false',
    fabricpath_interval:   default_interval_plat_2,
    fabricpath_slow_timer: 2000,
    fabricpath_vlan:       1,
    interval:              default_interval_plat_2,
    slow_timer:            2000,
  },
}

tests[:default_plat_4] = {
  desc:           '1.4 Defaults for n7k',
  platform:       'n7k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'default',
    echo_rx_interval:      'default',
    fabricpath_interval:   'default',
    fabricpath_slow_timer: 'default',
    fabricpath_vlan:       'default',
    interval:              'default',
    ipv4_echo_rx_interval: 'default',
    ipv4_interval:         'default',
    ipv4_slow_timer:       'default',
    ipv6_echo_rx_interval: 'default',
    ipv6_interval:         'default',
    ipv6_slow_timer:       'default',
    slow_timer:            'default',
  },
  code:           [0, 2],
  resource:       {
    echo_interface:        'false',
    echo_rx_interval:      50,
    fabricpath_interval:   default_interval_plat_2,
    fabricpath_slow_timer: 2000,
    fabricpath_vlan:       1,
    interval:              default_interval_plat_2,
    ipv4_echo_rx_interval: 50,
    ipv4_interval:         default_interval_plat_2,
    ipv4_slow_timer:       2000,
    ipv6_echo_rx_interval: 50,
    ipv6_interval:         default_interval_plat_2,
    ipv6_slow_timer:       2000,
    slow_timer:            2000,
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

tests[:non_default_plat_1] = {
  desc:           '2.1 Non Defaults for n3k',
  platform:       'n3k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'loopback10',
    echo_rx_interval:      300,
    interval:              non_default_interval,
    ipv4_echo_rx_interval: 100,
    ipv4_interval:         non_default_ipv4_interval,
    ipv4_slow_timer:       10_000,
    ipv6_echo_rx_interval: 200,
    ipv6_interval:         non_default_ipv6_interval,
    ipv6_slow_timer:       25_000,
    slow_timer:            5000,
    startup_timer:         25,
  },
}

tests[:non_default_plat_2] = {
  desc:           '2.2 Non Defaults for n8k, n9k',
  platform:       'n(8|9)k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'loopback10',
    echo_rx_interval:      300,
    ipv4_echo_rx_interval: 100,
    ipv4_interval:         non_default_ipv4_interval,
    ipv4_slow_timer:       10_000,
    ipv6_echo_rx_interval: 200,
    ipv6_interval:         non_default_ipv6_interval,
    ipv6_slow_timer:       25_000,
    slow_timer:            5000,
    startup_timer:         25,
  },
}

tests[:non_default_plat_3] = {
  desc:           '2.3 Non Defaults for n5k, n6k',
  platform:       'n(5|6)k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'loopback10',
    fabricpath_interval:   non_default_fabricpath_interval,
    fabricpath_slow_timer: 15_000,
    fabricpath_vlan:       100,
    interval:              non_default_interval,
    slow_timer:            5000,
  },
}

tests[:non_default_plat_4] = {
  desc:           '2.4 Non Defaults for n7k',
  platform:       'n7k',
  title_pattern:  'default',
  preclean:       'cisco_bfd_global',
  manifest_props: {
    echo_interface:        'loopback10',
    echo_rx_interval:      300,
    fabricpath_interval:   non_default_fabricpath_interval,
    fabricpath_slow_timer: 15_000,
    fabricpath_vlan:       100,
    interval:              non_default_interval,
    ipv4_echo_rx_interval: 100,
    ipv4_interval:         non_default_ipv4_interval,
    ipv4_slow_timer:       10_000,
    ipv6_echo_rx_interval: 200,
    ipv6_interval:         non_default_ipv6_interval,
    ipv6_slow_timer:       25_000,
    slow_timer:            5000,
  },
}

# Overridden to properly handle dependencies for this test file.
def test_harness_dependencies(_tests, id)
  return unless id[/non_default_/]
  cmd = 'interface loopback 10'
  command_config(agent, cmd, cmd)
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default_plat_1)
  test_harness_run(tests, :default_plat_2)
  test_harness_run(tests, :default_plat_3)
  test_harness_run(tests, :default_plat_4)
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default_plat_1)
  test_harness_run(tests, :non_default_plat_2)
  test_harness_run(tests, :non_default_plat_3)
  test_harness_run(tests, :non_default_plat_4)
  resource_absent_cleanup(agent, 'cisco_bfd_global')
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
