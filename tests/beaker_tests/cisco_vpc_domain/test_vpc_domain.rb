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
# TestCase Name:
# -------------
# test_vpc_domain.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet cisco_vpc_domain resource testset for Puppet Agent
# on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the Nexus Switch Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This portchannel_global resource test verifies default values for all
# properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_vpc_domain'

# Define PUPPETMASTER_MANIFESTPATH.

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
#
tests = {
  master: master,
  agent:  agent,
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
# tests[id][:show_pattern] - array of regexp patterns to use with test_show_cmd
# tests[id][:ensure] - (Optional) set to :present or :absent before calling
# tests[id][:code] - (Optional) override the default exit code in some tests.
#
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#   Can be used with :af for mixed title/af testing. If mixing, :af values will
#   be merged with title values and override any duplicates. If omitted,
#   :title_pattern will be set to 'id'.
#

tests['default_properties'] = {
  title_pattern:  '200',
  manifest_props: "
    auto_recovery_reload_delay                         => 'default',
    delay_restore                                      => 'default',
    delay_restore_interface_vlan                       => 'default',
    graceful_consistency_check                         => 'default',
    peer_gateway                                       => 'default',
    role_priority                                      => 'default',
    system_priority                                    => 'default',

  ",
  code:           [0, 2],
  resource_props: {
    'auto_recovery_reload_delay'   => '240',
    'delay_restore'                => '30',
    'delay_restore_interface_vlan' => '10',
    'graceful_consistency_check'   => 'true',
    'peer_gateway'                 => 'false',
    'role_priority'                => '32667',
    'system_priority'              => '32667',
  },
}

tests['non_default_properties'] = {
  title_pattern:  '200',
  manifest_props: "
    auto_recovery_reload_delay                         => '300',
    delay_restore                                      => '250',
    delay_restore_interface_vlan                       => '300',
    dual_active_exclude_interface_vlan_bridge_domain   => '10-30, 500',
    graceful_consistency_check                         => 'true',
    peer_keepalive_dest                                => '1.1.1.1',
    peer_keepalive_hold_timeout                        => 5,
    peer_keepalive_interval                            => 1000,
    peer_keepalive_interval_timeout                    => 3,
    peer_keepalive_precedence                          => 5,
    peer_keepalive_src                                 => '1.1.1.2',
    peer_keepalive_udp_port                            => 3200,
    peer_keepalive_vrf                                 => 'management',
    peer_gateway                                       => 'true',
    role_priority                                      => '1024',
    system_mac                                         => '00:0c:0d:11:22:33',
    system_priority                                    => '3000',

  ",
  code:           [0, 2],
  resource_props: {
    'auto_recovery_reload_delay'                       => '300',
    'delay_restore'                                    => '250',
    'delay_restore_interface_vlan'                     => '300',
    'dual_active_exclude_interface_vlan_bridge_domain' => '10-30,500',
    'graceful_consistency_check'                       => 'true',
    'peer_keepalive_dest'                              => '1.1.1.1',
    'peer_keepalive_hold_timeout'                      => '5',
    'peer_keepalive_interval'                          => '1000',
    'peer_keepalive_interval_timeout'                  => '3',
    'peer_keepalive_precedence'                        => '5',
    'peer_keepalive_src'                               => '1.1.1.2',
    'peer_keepalive_udp_port'                          => '3200',
    'peer_keepalive_vrf'                               => 'management',
    'peer_gateway'                                     => 'true',
    'role_priority'                                    => '1024',
    'system_mac'                                       => '00:0c:0d:11:22:33',
    'system_priority'                                  => '3000',
  },
}

tests['default_properties_n6k7k'] = {
  title_pattern:  '200',
  manifest_props: "
    layer3_peer_routing                                => 'default',
    shutdown                                           => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'layer3_peer_routing' => 'false',
    'shutdown'            => 'false',
  },
}

tests['non_default_properties_n6k7k'] = {
  title_pattern:  '200',
  manifest_props: "
    layer3_peer_routing                                => 'true',
    peer_gateway_exclude_vlan                          => '500-510, 1100, 1120',
    shutdown                                           => 'true',

  ",
  code:           [0, 2],
  resource_props: {
    'layer3_peer_routing'       => 'true',
    'peer_gateway_exclude_vlan' => '500-510,1100,1120',
    'shutdown'                  => 'true',
  },
}

tests['default_properties_n7k'] = {
  title_pattern:  '200',
  manifest_props: "
    auto_recovery                                      => 'default',
    self_isolation                                     => 'default',
  ",
  code:           [0, 2],
  resource_props: {
    'auto_recovery'  => 'true',
    'self_isolation' => 'false',
  },
}

tests['non_default_properties_n7k'] = {
  title_pattern:  '200',
  manifest_props: "
    auto_recovery                                      => 'false',
    self_isolation                                     => 'true',
  ",
  code:           [0, 2],
  resource_props: {
    'auto_recovery'  => 'false',
    'self_isolation' => 'true',
  },
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  cmd = PUPPET_BINPATH +
        'resource cisco_vpc_domain'
  get_namespace_cmd(agent, cmd, options)
end

def build_manifest_vpc_domain(tests, id)
  manifest = tests[id][:manifest_props]
  tests[id][:resource] = tests[id][:resource_props]

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug(
    "build_manifest_vpc_domain :: title_pattern:\n" +
             tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_vpc_domain { '200':
      #{manifest}
    }
  }
EOF"
end

def test_harness_vpc_domain(tests, id)
  tests[id][:resource_cmd] = puppet_resource_cmd

  # Build the manifest for this test
  build_manifest_vpc_domain(tests, id)

  # test_harness_common(tests, id)
  test_manifest(tests, id)
  test_resource(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties on All Nexus Platforms'
  test_harness_vpc_domain(tests, id)

  # Add device specifics
  if device =~ /(n6k|n7k)/
    id = 'default_properties_n6k7k'
    tests[id][:desc] = '1.2 Default Properties exclusive to N6K and N7K'
    test_harness_vpc_domain(tests, id)
  end
  if device == 'n7k'
    id = 'default_properties_n7k'
    tests[id][:desc] = '1.3 Default Properties exclusive to N7K'
    test_harness_vpc_domain(tests, id)
  end

  id = 'default_properties'
  tests[id][:desc] = '1.4 Default Properties (absent)'
  tests[id][:ensure] = :absent
  test_harness_vpc_domain(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  id = 'non_default_properties'
  tests[id][:desc] = '2.1 Non Default Properties on All Nexus Platforms'
  test_harness_vpc_domain(tests, id)

  # Add device specifics
  if device =~ /(n6k|n7k)/
    id = 'non_default_properties_n6k7k'
    tests[id][:desc] = '2.2 Non Default Properties exclusive to N6K and N7K'
    test_harness_vpc_domain(tests, id)
  end
  if device == 'n7k'
    id = 'non_default_properties_n7k'
    tests[id][:desc] = '2.3 Non Default Properties exclusive to N7K'
    test_harness_vpc_domain(tests, id)
  end

  id = 'non_default_properties'
  tests[id][:desc] = '2.4 Non Default Properties (absent)'
  tests[id][:ensure] = :absent
  test_harness_vpc_domain(tests, id)
end

logger.info("TestCase :: #{testheader} :: End")
