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
# test_interface.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet cisco_interface testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
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
testheader = 'Resource cisco_interface'

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:platform] - a regexp pattern to match against supported platforms.
#                    This key can be overridden by a tests[id][:platform] key
#
tests = {
  master:   master,
  agent:    agent,
  svi_name: 'vlan13',
}

# tests[id] keys set by caller and used by test_harness_common:
#
# tests[id] keys set by caller:
# tests[id][:platform] - a regexp pattern to match against supported platforms.
#                        This key overrides a tests[:platform] key
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
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
# tests[id][:sys_def_switchport] - (Optional) Specifies state of 'system default switchport'
# tests[id][:sys_def_sw_shut] - (Optional) Specifies state of 'system default switchport shutdown'.
#    This is only meaningful for L2 interfaces.
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#
tests['L3_default'] = {
  desc:               '1.1 (L3) Default Properties',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: false,
  manifest_props:     {
    duplex:                        'default',
    ipv4_pim_sparse_mode:          'default',
    ipv4_proxy_arp:                'default',
    ipv4_redirects:                'default',
    shutdown:                      'default',
    switchport_autostate_exclude:  'default',
    switchport_mode:               'default',
    switchport_trunk_allowed_vlan: 'default',
    switchport_trunk_native_vlan:  'default',
    switchport_vtp:                'default',
  },
  resource:           {
    'duplex'                        => 'auto',
    'ipv4_pim_sparse_mode'          => 'false',
    'ipv4_proxy_arp'                => 'false',
    'ipv4_redirects'                => 'true',
    'shutdown'                      => 'false',
    'switchport_autostate_exclude'  => 'false',
    'switchport_mode'               => 'disabled',
    'switchport_trunk_allowed_vlan' => '1-4094',
    'switchport_trunk_native_vlan'  => '1',
    'switchport_vtp'                => 'false',
  },
}

# Note: This test should follow the L3_default test as it requires an
# L3 parent interface and this makes it easy to set up.
tests['L3_sub_int'] = {
  desc:           '1.2 (L3) Sub-interface',
  intf_type:      'dot1q',
  manifest_props: {
    encapsulation_dot1q: 30
  },
  resource:       {
    'encapsulation_dot1q' => '30'
  },
}

tests['L3_misc'] = {
  desc:               '1.3 (L3) Misc Properties',
  intf_type:          'ethernet',
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode:               'disabled',
    description:                   'Configured with Puppet',
    shutdown:                      true,
    ipv4_address:                  '1.1.1.1',
    ipv4_netmask_length:           31,
    ipv4_address_secondary:        '2.2.2.2',
    ipv4_netmask_length_secondary: 31,
    ipv4_pim_sparse_mode:          true,
    ipv4_proxy_arp:                true,
    ipv4_redirects:                false,
    vrf:                           'test1',
  },
  resource:           {
    'switchport_mode'               => 'disabled',
    'description'                   => 'Configured with Puppet',
    'shutdown'                      => 'true',
    'ipv4_address'                  => '1.1.1.1',
    'ipv4_netmask_length'           => '31',
    'ipv4_address_secondary'        => '2.2.2.2',
    'ipv4_netmask_length_secondary' => '31',
    'ipv4_pim_sparse_mode'          => 'true',
    'ipv4_proxy_arp'                => 'true',
    'ipv4_redirects'                => 'false',
    'vrf'                           => 'test1',
  },
}

tests['L3_ACL'] = {
  desc:               '1.4 (L3) ACL Properties',
  intf_type:          'ethernet',
  sys_def_switchport: false,
  acl:                {
    'v4_in'  => 'ipv4',
    'v4_out' => 'ipv4',
    'v6_in'  => 'ipv6',
    'v6_out' => 'ipv6',
  },
  manifest_props:     {
    switchport_mode: 'disabled',
    ipv4_acl_in:     'v4_in',
    ipv4_acl_out:    'v4_out',
    ipv6_acl_in:     'v6_in',
    ipv6_acl_out:    'v6_out',
  },
  resource:           {
    'ipv4_acl_in'  => 'v4_in',
    'ipv4_acl_out' => 'v4_out',
    'ipv6_acl_in'  => 'v6_in',
    'ipv6_acl_out' => 'v6_out',
  },
}

tests['L2_access_default'] = {
  desc:               '2.1 (L2) Access Default',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:        'default',
    switchport_mode: 'access',
  },
  resource:           {
    'shutdown'        => 'true',
    'switchport_mode' => 'access',
  },
}

tests['L2_access'] = {
  desc:               '2.2 (L2) Access Properties',
  intf_type:          'ethernet',
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    access_vlan:     '128',
    shutdown:        'false',
    switchport_mode: 'access',

  },
  resource:           {
    'access_vlan'     => '128',
    'shutdown'        => 'false',
    'switchport_mode' => 'access',
  },
}

tests['L2_trunk_default'] = {
  desc:               '3.1 (L2) Trunk Default',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: true,
  sys_def_sw_shut:    true,
  manifest_props:     {
    shutdown:                      'default',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: 'default',
    switchport_trunk_native_vlan:  'default',

  },
  resource:           {
    'shutdown'                      => 'true',
    'switchport_mode'               => 'trunk',
    'switchport_trunk_allowed_vlan' => '1-4094',
    'switchport_trunk_native_vlan'  => '1',
  },
}

tests['L2_trunk'] = {
  desc:               '3.2 (L2) Trunk',
  intf_type:          'ethernet',
  sys_def_switchport: true,
  manifest_props:     {
    shutdown:                      'false',
    switchport_mode:               'trunk',
    switchport_trunk_allowed_vlan: '30,40',
    switchport_trunk_native_vlan:  '20',
    switchport_vtp:                'false',

  },
  resource:           {
    'shutdown'                      => 'false',
    'switchport_mode'               => 'trunk',
    'switchport_trunk_allowed_vlan' => '30,40',
    'switchport_trunk_native_vlan'  => '20',
  },
}

tests['SVI_default'] = {
  desc:           '4.1 (SVI) Default Properties',
  intf_type:      'vlan',
  manifest_props: {
    svi_management: 'default'
  },
  resource:       {
    'svi_management' => 'false'
  },
}

tests['SVI'] = {
  desc:           '4.2 (SVI) Non Default Properties',
  intf_type:      'vlan',
  manifest_props: {
    svi_management: 'true'
  },
  resource:       {
    'svi_management' => 'true'
  },
}

# Fabric Forwarding Anycast Gateway
if platform[/n9k/]
  tests['SVI_default'][:manifest_props][:fabric_forwarding_anycast_gateway] = 'default'
  tests['SVI'][:manifest_props][:fabric_forwarding_anycast_gateway] = 'true'
  tests['SVI'][:resource][:fabric_forwarding_anycast_gateway] = 'true'
end

tests['SVI_autostate_default'] = {
  desc:           '4.3 (SVI) Default SVI Autostate Property',
  platform:       'n(3|7|9)k',
  intf_type:      'vlan',
  manifest_props: {
    svi_autostate: 'default'
  },
  resource:       {
    'svi_autostate' => 'true'
  },
}

tests['SVI_autostate'] = {
  desc:           '4.4 (SVI) Non Default SVI Autostate Property',
  platform:       'n(3|7|9)k',
  intf_type:      'vlan',
  manifest_props: {
    svi_autostate: 'false'
  },
  resource:       {
    'svi_autostate' => 'false'
  },
}

tests['negotiate'] = {
  desc:               '5.1 negotiate-auto',
  platform:           'n(5|6|7)k',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode: 'disabled',
    # negotiate_auto:  'false',, # TBD: Needs plat awareness
  },
  resource:           {
    # 'negotiate_auto' => 'false'
  },
}

tests['speed_dup_mtu'] = {
  desc:               '5.2 Speed/Duplex/MTU',
  intf_type:          'ethernet',
  preclean:           true,
  sys_def_switchport: false,
  manifest_props:     {
    switchport_mode: 'disabled',
    mtu:             1556,
    # speed:           100, # TBD: Needs plat awareness
    duplex:          'full',
  },
  resource:           {
    'mtu'    => '1556',
    # 'speed'  => '100',
    'duplex' => 'full',
  },
}

resource_cisco_overlay_global = {
  name:     'cisco_overlay_global',
  title:    'default',
  property: 'anycast_gateway_mac',
  value:    '1.1.1',
}

# cisco_interface uses the interface name as the title.
# Find an available interface and create an appropriate title.
def create_interface_title(tests, id)
  return tests[id][:title_pattern] if tests[id][:title_pattern]

  # Prefer specific test key over the all tests key
  type = tests[id][:intf_type] || tests[:intf_type]
  case type
  when /ethernet/i
    if tests[:ethernet]
      intf = tests[:ethernet]
    else
      intf = find_interface(tests, id)
      # cache for later tests
      tests[:ethernet] = intf
    end
  when /dot1q/
    if tests[:ethernet]
      intf = "#{tests[:ethernet]}.1"
    else
      intf = find_interface(tests, id)
      # cache for later tests
      tests[:ethernet] = intf
      intf = "#{intf}.1" unless intf.nil?
    end
  when /vlan/
    intf = tests[:svi_name]
  end
  logger.info("\nUsing interface: #{intf}")
  tests[id][:title_pattern] = intf
end

# Create actual manifest for a given test scenario.
def build_manifest_interface(tests, id)
  manifest = prop_hash_to_manifest(tests[id][:manifest_props])
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
  end
  create_interface_title(tests, id)

  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  \nnode default {
  cisco_interface { '#{tests[id][:title_pattern]}':
    #{state}\n#{manifest}
  }\n}\nEOF"

  cmd = PUPPET_BINPATH +
        "resource cisco_interface '#{tests[id][:title_pattern]}'"
  tests[id][:resource_cmd] = get_namespace_cmd(agent, cmd, options)
end

# Helper for 'system default switchport'
def sys_def_switchport?(tests, id)
  return unless tests[id].key?(:sys_def_switchport)

  state = tests[id][:sys_def_switchport]
  # cached state
  return if tests[:sys_def_switchport] == state

  system_default_switchport(agent, state)
  # cache for later tests
  tests[:sys_def_switchport] = state
end

# Helper for 'system default switchport shutdown'
def sys_def_switchport_shutdown?(tests, id)
  return unless tests[id].key?(:sys_def_sw_shut)

  state = tests[id][:sys_def_sw_shut]
  # cached state
  return if tests[:sys_def_sw_shut] == state

  system_default_switchport_shutdown(agent, state)
  # cache for later tests
  tests[:sys_def_sw_shut] = state
end

# Helper for setting up ACL dependencies
def acl?(tests, id)
  tests[id][:acl].each { |acl, afi| config_acl(agent, afi, acl, true) } if
    tests[id][:acl]
end

# Wrapper for interface specific settings prior to calling the
# common test_harness.
def test_harness_interface(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  build_manifest_interface(tests, id)

  # Set up system default switchport
  sys_def_switchport?(tests, id)
  sys_def_switchport_shutdown?(tests, id)

  # Set up ACL
  acl?(tests, id)

  tests[id][:code] = [0, 2]

  interface_cleanup(agent, tests[id][:title_pattern]) if tests[id][:preclean]

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. (L3) Property Testing")
  test_harness_interface(tests, 'L3_default')
  test_harness_interface(tests, 'L3_sub_int')
  test_harness_interface(tests, 'L3_misc')
  test_harness_interface(tests, 'L3_ACL')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. (L2) Access Property Testing")
  test_harness_interface(tests, 'L2_access_default')
  test_harness_interface(tests, 'L2_access')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 3. (L2) Trunk Property Testing")
  test_harness_interface(tests, 'L2_trunk_default')
  test_harness_interface(tests, 'L2_trunk')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 4. (SVI) Property Testing")
  resource_set(agent, resource_cisco_overlay_global, 'Overlay Global mac setup')
  interface_cleanup(agent, tests[:svi_name])
  test_harness_interface(tests, 'SVI_default')
  test_harness_interface(tests, 'SVI')
  test_harness_interface(tests, 'SVI_autostate_default')
  test_harness_interface(tests, 'SVI_autostate')

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 5. MISC Property Testing")
  test_harness_interface(tests, 'negotiate')
  # TBD: test_harness_interface(tests, 'speed_dup_mtu')

  # -------------------------------------------------------------------
  interface_cleanup(agent, tests[:ethernet]) if tests[:ethernet]
  skipped_tests_summary(tests)
end
logger.info("TestCase :: #{testheader} :: End")
