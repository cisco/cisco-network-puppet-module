###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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

tests = {
  agent:         agent,
  master:        master,
  resource_name: 'cisco_interface_portchannel',
}

intf = 'port-channel100'

tests[:default_asym] = {
  desc:           '1.1 Default Properties (asym)',
  title_pattern:  intf,
  platform:       'n7k',
  code:           [0, 2],
  manifest_props: {
    bfd_per_link:              'default',
    lacp_graceful_convergence: 'default',
    lacp_max_bundle:           'default',
    lacp_min_links:            'default',
    lacp_suspend_individual:   'default',
    port_hash_distribution:    'default',
    port_load_defer:           'default',
  },
  resource:       {
    'bfd_per_link'              => 'false',
    'lacp_graceful_convergence' => 'true',
    'lacp_max_bundle'           => '16',
    'lacp_min_links'            => '1',
    'lacp_suspend_individual'   => 'true',
    'port_hash_distribution'    => 'false',
    'port_load_defer'           => 'false',
  },
}

tests[:non_default_asym] = {
  desc:           '2.1 Non Default Properties (asym)',
  platform:       'n7k',
  title_pattern:  intf,
  manifest_props: {
    bfd_per_link:              'true',
    lacp_graceful_convergence: 'false',
    lacp_max_bundle:           '10',
    lacp_min_links:            '3',
    lacp_suspend_individual:   'false',
    port_hash_distribution:    'fixed',
    port_load_defer:           'true',
  },
}

tests[:default_sym] = {
  desc:           '1.2 Default Properties (sym)',
  title_pattern:  intf,
  platform:       'n(3|9)k',
  code:           [0, 2],
  manifest_props: {
    bfd_per_link:              'default',
    lacp_graceful_convergence: 'default',
    lacp_max_bundle:           'default',
    lacp_min_links:            'default',
    lacp_suspend_individual:   'default',
    port_hash_distribution:    'default',
    port_load_defer:           'default',
  },
  resource:       {
    'bfd_per_link'              => 'false',
    'lacp_graceful_convergence' => 'true',
    'lacp_max_bundle'           => '32',
    'lacp_min_links'            => '1',
    'lacp_suspend_individual'   => platform[/n3k$/] ? 'false' : 'true',
    'port_hash_distribution'    => 'false',
    'port_load_defer'           => 'false',
  },
}

tests[:non_default_sym] = {
  desc:           '2.2 Non Default Properties (sym)',
  title_pattern:  intf,
  platform:       'n(3|9)k',
  manifest_props: {
    bfd_per_link:              'true',
    lacp_graceful_convergence: 'false',
    lacp_max_bundle:           '10',
    lacp_min_links:            '3',
    lacp_suspend_individual:   platform[/n3k$/] ? 'true' : 'false',
    port_hash_distribution:    'fixed',
    port_load_defer:           'true',
  },
}

tests[:default_eth] = {
  desc:           '1.3 Default Properties (eth)',
  title_pattern:  intf,
  platform:       'n(5|6)k',
  code:           [0, 2],
  manifest_props: {
    bfd_per_link:              'default',
    lacp_graceful_convergence: 'default',
    lacp_max_bundle:           'default',
    lacp_min_links:            'default',
    lacp_suspend_individual:   'default',
  },
  resource:       {
    'bfd_per_link'              => 'false',
    'lacp_graceful_convergence' => 'true',
    'lacp_max_bundle'           => '16',
    'lacp_min_links'            => '1',
    'lacp_suspend_individual'   => 'true',
  },
}

tests[:non_default_eth] = {
  desc:           '2.3 Non Default Properties (eth)',
  platform:       'n(5|6)k',
  title_pattern:  intf,
  manifest_props: {
    bfd_per_link:              'true',
    lacp_graceful_convergence: 'false',
    lacp_max_bundle:           '10',
    lacp_min_links:            '3',
    lacp_suspend_individual:   'false',
  },
}

def cleanup(agent, intf)
  test_set(agent, "no feature bfd ; no interface #{intf}")
  resource_absent_cleanup(agent, 'cisco_interface_portchannel')
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent, intf) }
  cleanup(agent, intf)
  system_default_switchport(agent, false)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  [:default_asym, :default_sym, :default_eth].each do |id|
    next unless platform_supports_test(tests, id)
    test_harness_run(tests, id)
    tests[id][:ensure] = :absent
    test_harness_run(tests, id)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  test_harness_run(tests, :non_default_asym)
  test_harness_run(tests, :non_default_sym)
  test_harness_run(tests, :non_default_eth)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
