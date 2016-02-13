###############################################################################
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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

# TestCase Utility Library:
# --------------------------
# utilitylib.rb
#
# This is the utility library for the Cisco provider Beaker test cases that
# contains the common methods used across the testsuite's cases. The library
# is implemented as a module with related methods and constants defined inside
# it for use as a namespace. All of the methods are defined as module methods.
#
# Every Beaker test script that runs an instance of TestCase requires this lib.
#
# The library has 4 sets of methods:
# -- Methods to get VRF namespace specific command strings and VSH command
#    strings from basic command strings.
# -- Method to define PUPPETMASTER_MANIFESTPATH constant using puppet
#    config command output on puppet master.
# -- Method to search for RegExp patterns in command execution output and
#    raise fail_test exceptions for failed pattern matches in the output.
# -- Method to raise pass_test or fail_test exception based on testcase
#    result.

# Define various CONSTANTS used by beaker tests
PUPPET_BINPATH = '/opt/puppetlabs/bin/puppet '
FACTER_BINPATH = '/opt/puppetlabs/bin/facter '
PUPPETMASTER_MANIFESTPATH = '/etc/puppetlabs/code/environments/production/manifests/site.pp'

# These methods are defined outside of a module so that
# they can access the Beaker DSL API's.

# Method to return the VRF namespace specific command string from basic
# command string. VRF is declared in hosts.cfg.
# @param host [String] Host on which to act upon.
# @param cmdstr [String] The command string to execute on host.
# @param options [Hash] Options hash literal to get configured VRF.
# @result namespacestr [String] Returns 'sudo ip netns exec vrf <cmd>'
# command string for 'cisco' platform.
def get_namespace_cmd(host, cmdstr, options)
  case host['platform']
  when /cisco/
    agentvrf = options[:HOSTS][host.to_s.to_sym]['vrf']
    return "sudo ip netns exec #{agentvrf} " + cmdstr
  else
    return cmdstr
  end
end

# Method to return the Vegas shell command string for a NXOS CLI command.
# @param nxosclistr [String] The NXOS CLI command string to execute on host.
# @result vshellcmd [String] Returns 'vsh -c <cmd>' command string.
def get_vshell_cmd(nxosclistr)
  "/isan/bin/vsh -c '#{nxosclistr}'"
end

# Method to parse a Hash literal into an array of RegExp literals.
# @param hash [hash] Comma-separated list of key/value pairs.
# @result regexparr [Array] Array of RegExp literals.
def hash_to_patterns(hash)
  regexparr = []
  hash.each do |key, value|
    # Need to escape '[', ']', '"' characters for nested array of arrays.
    # Example:
    #   [["192.168.5.0/24", "nrtemap1"], ["192.168.6.0/32"]]
    # Becomes:
    #   \[\['192.168.5.0\/24', 'nrtemap1'\], \['192.168.6.0\/32'\]\]
    if /^\[.*\]$/.match(value)
      value.gsub!(/[\[\]]/) { |s| '\\' + "#{s}" }.gsub!(/\"/) { |_s| '\'' }
    end
    regexparr << Regexp.new("#{key}\s+=>\s+'?#{value}'?")
  end
  regexparr
end

# Method to check if RegExp pattern array exists in Beaker::Result object's
# stdout or output instance attributes.
# @param output [IO] IO attribute output or stdout of Result object.
# @param patarr [Array, Hash] Array of RegExp patterns or Hash of key/value
# pairs to search in output object.
# @param inverse [Boolean] Boolean flag to indicate Boolean NOT matching op.
# @param testcase [TestCase] An instance of Beaker::TestCase.
# @param logger [Logger] A default instance of Beaker::Logger.
# @result none [None] Returns no object.
def search_pattern_in_output(output, patarr, inverse, testcase,\
                             logger)
  patarr = hash_to_patterns(patarr) if patarr.instance_of?(Hash)
  patarr.each do |pattern|
    inverse ? (match = (output !~ pattern)) : (match = (output =~ pattern))
    if match
      logger.debug("TestStep :: Match #{pattern} :: PASS")
    else
      testcase.fail_test("TestStep :: Match #{pattern} :: FAIL")
    end
  end
end

# Method to raise and handle Beaker::DSL::Outcomes::PassTest or
# Beaker::DSL::Outcomes::FailTest exception based on testresult value.
# @param testresult [String] String object set to 'PASS' or 'FAIL'.
# @param message [String] String object to represent testcase.
# @param testcase [TestCase] An instance of Beaker::TestCase.
# @param logger [Logger] A default instance of Beaker::Logger.
# @result none [None] Returns no object.
def raise_passfail_exception(testresult, message, testcase, logger)
  if testresult == 'PASS'
    testcase.pass_test("\nTestCase :: #{message} :: PASS")
  else
    testcase.fail_test("\nTestCase :: #{message} :: FAIL")
  end
rescue Beaker::DSL::Outcomes::PassTest
  logger.success("TestCase :: #{message} :: PASS")
rescue Beaker::DSL::Outcomes::FailTest
  logger.error("TestCase :: #{message} :: FAIL")
end

# Raise a Beaker::DSL::Outcomes::SkipTest exception.
# @param message [String] String object to represent testcase.
# @param testcase [TestCase] An instance of Beaker::TestCase.
# @result none [None] Returns no object.
def raise_skip_exception(message, testcase)
  testcase.skip_test("\nTestCase :: #{message} :: SKIP")
end

# Full command string for puppet agent
def puppet_agent_cmd
  cmd = PUPPET_BINPATH + 'agent -t'
  get_namespace_cmd(agent, cmd, options)
end

# Auto generation of properties for manifests
# attributes: hash of property names and values
# return: a manifest friendly string of property names / values
def prop_hash_to_manifest(attributes)
  return '' if attributes.nil?
  manifest_str = ''
  attributes.each do |k, v|
    next if v.nil?
    if v.is_a?(String)
      manifest_str += sprintf("    %-40s => '#{v.strip}',\n", k)
    else
      manifest_str += sprintf("    %-40s => #{v},\n", k)
    end
  end
  manifest_str
end

# Wrapper for processing all tests for each test scenario.
#
# Inputs:
# tests - a hash of control values
# id - identifies the specific test case hash key
#
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
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
# Reserved keys
# tests[id][:log_desc] - the final form of the log description
#
def test_harness_common(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:state] = false if tests[id][:state].nil?
  tests[id][:desc] = '' if tests[id][:desc].nil?
  tests[id][:log_desc] = tests[id][:desc] + " [ensure => #{tests[id][:ensure]}]"
  logger.info("\n--------\n#{tests[id][:log_desc]}")

  test_manifest(tests, id)
  test_resource(tests, id)
  test_show_cmd(tests, id, tests[id][:state]) unless tests[id][:show_pattern].nil?
  test_idempotence(tests, id)
  tests[id].delete(:log_desc)
end

# Wrapper for formatting test log entries
def format_stepinfo(tests, id, test_str)
  logger.debug("format_stepinfo :: (#{tests[id][:desc]}) (#{test_str})")
  tests[id][:log_desc] = tests[id][:desc] if tests[id][:log_desc].nil?
  tests[id][:log_desc] + sprintf(' :: %-12s', test_str)
end

# helper to match stderr buffer against :stderr_pattern
def test_stderr(tests, id)
  if stderr =~ tests[id][:stderr_pattern]
    logger.debug("TestStep :: Match #{tests[id][:stderr_pattern]} :: PASS")
  else
    fail_test("TestStep :: Match #{tests[id][:stderr_pattern]} :: FAIL")
  end
end

# Wrapper for manifest tests
# Pass code = [0], as an alternative to 'test_idempotence'
def test_manifest(tests, id)
  stepinfo = format_stepinfo(tests, id, 'MANIFEST')
  step "TestStep :: #{stepinfo}" do
    logger.debug("test_manifest :: manifest:\n#{tests[id][:manifest]}")
    on(tests[:master], tests[id][:manifest])
    code = tests[id][:code] ? tests[id][:code] : [2]
    logger.debug('test_manifest :: check puppet agent cmd')
    on(tests[:agent], puppet_agent_cmd, acceptable_exit_codes: code)
    test_stderr(tests, id) if tests[id][:stderr_pattern]
  end
  logger.info("#{stepinfo} :: PASS")
  tests[id].delete(:log_desc)
end

# Wrapper for 'puppet resource' command tests
def test_resource(tests, id)
  stepinfo = format_stepinfo(tests, id, 'RESOURCE')
  step "TestStep :: #{stepinfo}" do
    logger.debug("test_resource :: cmd:\n#{tests[id][:resource_cmd]}")
    on(tests[:agent], tests[id][:resource_cmd]) do
      search_pattern_in_output(stdout, tests[id][:resource],
                               false, self, logger)
    end
    logger.info("#{stepinfo} :: PASS")
    tests[id].delete(:log_desc)
  end
end

# Wrapper for config pattern-match tests
def test_show_cmd(tests, id, state=false)
  stepinfo = format_stepinfo(tests, id, 'SHOW CMD')
  show_cmd = get_vshell_cmd(tests[:show_cmd])
  step "TestStep :: #{stepinfo}" do
    logger.debug('test_show_cmd :: BEGIN')
    on(tests[:agent], show_cmd) do
      logger.debug("test_show_cmd :: cmd:\n#{show_cmd}")
      logger.debug("test_show_cmd :: pattern:\n#{tests[id][:show_pattern]}")
      search_pattern_in_output(stdout, tests[id][:show_pattern],
                               state, self, logger)
    end
    logger.info("#{stepinfo} :: PASS")
    tests[id].delete(:log_desc)
  end
end

# Wrapper for idempotency tests
def test_idempotence(tests, id)
  stepinfo = format_stepinfo(tests, id, 'IDEMPOTENCE')
  step "TestStep :: #{stepinfo}" do
    logger.debug('test_idempotence :: BEGIN')
    on(tests[:agent], puppet_agent_cmd, acceptable_exit_codes: [0])
    logger.info("#{stepinfo} :: PASS")
    tests[id].delete(:log_desc)
  end
end

# Helper to retrieve all instances of a given resource
# @param agent [String] the agent to be queried
# @param res_name [String] the resource to retrieve instances of
# @return [Array] an array of string names of instances
def get_current_resource_instances(agent, res_name)
  cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource #{res_name}", options)
  on(agent, cmd_str, acceptable_exit_codes: [0])
  names = stdout.scan(/#{res_name} { '(.+)':/).flatten
  names
end

# Method to clean *all* resources of a given resource name, by
# calling puppet resource with 'ensure=absent'.
# @param agent [String] the agent that is going to run the test
# @param res_name [String] the resource name that will be cleaned up
def resource_absent_cleanup(agent, res_name, stepinfo='absent clean')
  step "\n--------\n * TestStep :: #{stepinfo}" do
    # set each resource to ensure=absent
    get_current_resource_instances(agent, res_name).each do |title|
      case res_name
      when /cisco_bgp$/
        # cleaning default cleans them all
        next unless title[/default/]
      when /^cisco_interface$/
        next if title[/ethernet/i]
      when /cisco_snmp_user/
        next if title[/devops/i]
      when /cisco_vlan/
        next if title == '1'
      when /cisco_vrf/
        next if title[/management/]
      end
      cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
        "resource #{res_name} '#{title}' ensure=absent", options)
      logger.info("  * #{stepinfo} Removing #{res_name} '#{title}'")
      on(agent, cmd_str, acceptable_exit_codes: [0])
    end
  end
end

# Helper to clean a specific resource by title name
def resource_absent_by_title(agent, res_name, title)
  res_cmd =
    get_namespace_cmd(agent, PUPPET_BINPATH + "resource #{res_name}", options)
  on(agent, "#{res_cmd} '#{title}' ensure=absent")
end

# Helper to find all titles of a given resource name.
# Optionally remove all titles found.
# Returns an array of titles.
def resource_titles(agent, res_name, action=:find)
  res_cmd =
    get_namespace_cmd(agent, PUPPET_BINPATH + "resource #{res_name}", options)
  on(agent, res_cmd)

  titles = []
  stdout.scan(/'.*':/).each { |title| titles << title.gsub(/[':]/, '') }
  if action == :clean
    titles.each { |title| resource_absent_by_title(agent, res_name, title) }
  end
  titles
end

# Helper to configure switchport mode
def config_switchport_mode(agent, mode, stepinfo='switchport mode: ')
  step "TestStep :: #{stepinfo}" do
    cmd = "switchport ; switchport mode #{mode}"
    command_config(agent, cmd, cmd)
  end
end

# Helper to toggle 'system default switchport'
def system_default_switchport(agent, state=false,
                              stepinfo='system default switchport')
  step "TestStep :: #{stepinfo}" do
    state = state ? ' ' : 'no '
    cmd = "#{state}system default switchport"
    command_config(agent, cmd, cmd)
  end
end

# Helper to toggle 'system default switchport shutdown'
def system_default_switchport_shutdown(agent, state=false,
                                       stepinfo='system default switchport shutdown')
  step "TestStep :: #{stepinfo}" do
    state = state ? ' ' : 'no '
    cmd = "#{state}system default switchport shutdown"
    command_config(agent, cmd, cmd)
  end
end

# Helper for creating / removing an ACL
def config_acl(agent, afi, acl, state, stepinfo='ACL:')
  step "TestStep :: #{stepinfo}" do
    state = state ? 'present' : 'absent'
    cmd = "resource cisco_acl '#{afi} #{acl}' ensure=#{state}"
    logger.info("Setup: puppet #{cmd}")
    cmd = get_namespace_cmd(agent, PUPPET_BINPATH + cmd, options)
    on(agent, cmd, acceptable_exit_codes: [0, 2])
  end
end

# Helper for creating / removing bridge-domain configs
# 1. Remove any existing bridge-domain config unless it contains our test_bd
# 2. Remove vlan with test_bd id
# 3. Add bridge-domain configs
def config_bridge_domain(agent, test_bd, stepinfo='bridge-domain config:')
  step stepinfo do
    # Find current bridge-domain
    # NOTE: This should convert to using puppet resource, however, the cli
    # does not allow changes to bridge-domain without removing existing BD's,
    # which means we are stuck with vsh for now.
    cmd = get_vshell_cmd('show run bridge-domain')
    out = on(agent, cmd).stdout
    bds = out.scan(/^bridge-domain \d+ /)
    return if bds.include?("bridge-domain #{test_bd} ")

    bds.each do |bd|
      command_config(agent, "no #{bd}", "remove #{bd}")
    end

    if (sys_bd = out[/^system bridge-domain .*/])
      command_config(agent, "no #{sys_bd}", "remove #{sys_bd}")
    end

    # Remove vlan
    cmd = "resource cisco_vlan '#{test_bd}' ensure=absent"
    cmd = get_namespace_cmd(agent, PUPPET_BINPATH + cmd, options)
    on(agent, cmd, acceptable_exit_codes: [0, 2])

    # Configure bridge-domain
    cmd = "system bridge-domain #{test_bd} ; bridge-domain #{test_bd}"
    command_config(agent, cmd, cmd)
  end
end

# Helper for creating / removing encap profile vni (global) configs
def config_encap_profile_vni_global(agent, cmd,
                                    stepinfo='encap profile vni global:')
  step stepinfo do
    command_config(agent, cmd, cmd)
  end
end

# Helper to nuke a single interface. This is needed to remove all
# configurations from the interface.
def interface_cleanup(agent, intf, stepinfo='Pre Clean:')
  step "TestStep :: #{stepinfo}" do
    cmd = "resource cisco_command_config 'interface_cleanup' "\
          "command='default interface #{intf}'"
    cmd = get_namespace_cmd(agent, PUPPET_BINPATH + cmd, options)
    logger.info("  * #{stepinfo} Set '#{intf}' to default state")
    on(agent, cmd, acceptable_exit_codes: [0, 2])
  end
end

# Helper to remove all IP address configs from all interfaces. This is
# needed to avoid IP conflicts with our test interface.
def interface_ip_cleanup(agent, stepinfo='Pre Clean:')
  logger.debug("#{stepinfo} Interface IP cleanup")
  show_cmd = get_vshell_cmd('show ip interface brief')

  # Find the interfaces with IP addresses; build a removal config.
  # Note mgmt0 will not appear in the show cmd output.
  on(agent, show_cmd)
  clean = stdout.split("\n").map do |line|
    "interface #{Regexp.last_match[:intf]} ; no ip addr" if
      line[/^(?<intf>\S+)\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/]
  end.compact
  return if clean.empty?
  clean = clean.join(' ; ').prepend('conf t ; ')
  logger.debug("#{stepinfo} Clean string:\n#{clean}")
  # exit codes: 0 = no changes, 2 = changes have occurred
  on(agent, get_vshell_cmd(clean), acceptable_exit_codes: [0, 2])
end

# bgp neighbor remote-as configuration helper
def bgp_nbr_remote_as(agent, remote_as)
  asn, vrf, nbr, remote = remote_as.split
  vrf = (vrf == 'default') ? '' : "vrf #{vrf} ;"
  cfg_str = "conf t ; router bgp #{asn} ; #{vrf} " \
            "neighbor #{nbr} ; remote-as #{remote}"
  on(agent, get_vshell_cmd(cfg_str))
end

# puppet_resource_title_pattern_munge
# Some providers support complex title patterns, in which case parameters
# ('newparameter' methods from the type file) can obtain their values from
# either explicit assignments or from the title pattern itself; e.g.
#
#  (params from title)                        (non-title params)
# cisco_bgp { '55 red':    -equivalent to-   cisco_bgp { '55':
#                                              vrf => 'red'
#
# The 'puppet resource' tests need the "title params" syntax, so this helper
# is used to create an appropriate title by merging a partial title from
# [:title_pattern] with the [:title_params] values.
#
def puppet_resource_title_pattern_munge(tests, id)
  title = tests[id][:title_pattern]
  params = tests[id][:title_params]
  return params if title.nil?

  tests[id][:title_params] = {} if params.nil?
  t = {}
  case tests[:resource_name]
  when 'cisco_bgp'
    t[:asn], t[:vrf] = title.split
  when 'cisco_bgp_af'
    t[:asn], t[:vrf], t[:afi], t[:safi] = title.split
  when 'cisco_bgp_neighbor'
    t[:asn], t[:vrf], t[:neighbor] = title.split
  when 'cisco_bgp_neighbor_af'
    t[:asn], t[:vrf], t[:neighbor], t[:afi], t[:safi] = title.split
  when 'cisco_pim'
    t[:afi], t[:vrf] = title.split
  when 'cisco_pim_grouplist'
    t[:afi], t[:vrf], t[:rp_addr], t[:group] = title.split
  when 'cisco_pim_rp_address'
    t[:afi], t[:vrf], t[:rp_addr] = title.split
  when 'cisco_vrf_af'
    t[:vrf], t[:afi], t[:safi] = title.split
  end
  t.merge!(tests[id][:title_params])
  t[:vrf] = 'default' if t[:vrf].nil?
  t
end

# Helper method to create a puppet resource command string for providers
# that use complex title patterns (bgp, vrf_af, etc).
# [:title_pattern] (required) This string will become the entire cmd string
#                  if there are no :title_params
# [:title_params] (optional) This hash will be merged with the :title_pattern
#                  to create the cmd string
def puppet_resource_cmd_from_params(tests, id)
  fail 'tests[:resource_name] is not defined' unless tests[:resource_name]
  params = tests[id][:title_params]
  stepinfo = 'Create resource command title string:'\
             "\n  [:resource_name] '#{tests[:resource_name]}'"\
             "\n  [:title_pattern] '#{tests[id][:title_pattern]}'"
  stepinfo += "\n  [:title_params]  #{params}" if params

  step "\n--------\n#{stepinfo}" do
    # Create puppet resource cmd string. This is used to test
    # a specific resource instance output using 'puppet resource'
    if params
      title_string = puppet_resource_title_pattern_munge(tests, id).values.join(' ')
    else
      title_string = tests[id][:title_pattern]
    end

    cmd = PUPPET_BINPATH + "resource #{tests[:resource_name]} '#{title_string}'"

    logger.info("\ntitle_string: '#{title_string}'")
    tests[id][:resource_cmd] = get_namespace_cmd(agent, cmd, options)
  end
end

# Create manifest and resource command strings for a given test scenario.
# Test hash keys used by this method:
# [:resource_name] (REQUIRED) This is the resource name to use in the manifest
#   the for puppet resource command strings
# [:manifest_props] (REQUIRED) This is a hash of properties to use in building
#   the manifest; they are also used to populate [:resource] when that key is
#   not defined.
# [:resource] (OPTIONAL) This is a hash of properties to use for validating the
#   output from puppet resource.
# [:title_pattern] (OPTIONAL) The title pattern to use in the manifest
# [:title_params] (OPTIONAL) Complex title patterns can be combined with
#   parameter keys in the manifest. When these are used the puppet resource
#   command string becomes a combination of the title pattern and these params.
#
def create_manifest_and_resource(tests, id)
  fail 'tests[:resource_name] is not defined' unless tests[:resource_name]
  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?

  # Create the cmd string for puppet_resource
  puppet_resource_cmd_from_params(tests, id)

  # Create any title-params manifest entries. Typically only used
  # for title-pattern testing
  manifest = prop_hash_to_manifest(tests[id][:title_params])

  # Setup the ensure state, manifest string, and resource command state
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
    # Create the property string for the manifest
    manifest += prop_hash_to_manifest(tests[id][:manifest_props]) if
      tests[id][:manifest_props]

    # Automatically create a hash of expected states for puppet resource
    # -or- use a static hash
    tests[id][:resource] = tests[id][:manifest_props] unless
      tests[id][:resource]
  end

  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  \nnode default {
  #{tests[:resource_name]} { '#{tests[id][:title_pattern]}':
    #{state}\n#{manifest}
  }\n}\nEOF"
end

# test_harness_dependencies
#
# This method is used for additional testbed setup beyond the basics
# used by most tests.
def test_harness_dependencies(tests, id)
  # BGP remote-as configuration
  bgp_nbr_remote_as(agent, tests[id][:remote_as]) if tests[id][:remote_as]
end

# test_harness_run
#
# This method is a front-end for test_harness_common.
# - Creates manifests
# - Creates puppet resource title strings
# - Cleans resource
# - Sets up additional dependencies
def test_harness_run(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  create_manifest_and_resource(tests, id)

  resource_absent_cleanup(agent, tests[id][:preclean]) if
    tests[id][:preclean]

  # Check for additional pre-requisites
  test_harness_dependencies(tests, id)

  test_harness_common(tests, id)
  tests[id][:ensure] = nil
end

# setup_mt_full_env
# Check and set up prerequisites for Multi-Tenancy Full (MT-full) testing.
# MT-full currently requires an F3 line module. This method will update
# the tests hash with the names of the default vdc and also an appropriate
# test interface name to use for testing.
# tests[:vdc] The default vdc name
# tests[:intf] A compatible interface to use for MT-full testing.
def setup_mt_full_env(tests, testcase)
  # MT-full tests require a specific linecard. Search for a compatible
  # module and enable it.

  testheader = tests[:resource_name]
  mod = 'f3'
  step 'Check for Compatible Line Module' do
    tests[:intf] = mt_full_interface
    break if tests[:intf]
    prereq_skip(testheader, testcase,
                "MT-full tests require #{mod} or compatible line module")
  end if tests[:intf].nil?
  intf = tests[:intf]
  logger.info("Test interface name is '#{intf}'")

  step 'Get default VDC name' do
    tests[:vdc] = default_vdc_name
    break if tests[:vdc]
    prereq_skip(testheader, testcase, 'Unable to determine default vdc name')
  end if tests[:vdc].nil?
  vdc = tests[:vdc]

  step "Check for 'limit-resource module-type #{mod}'" do
    break if limit_resource_module_type_get(vdc, mod)
    logger.info("limit-resource module-type does not include '#{mod}', "\
                'update it now...')
    limit_resource_module_type_set(vdc, mod)
    break if limit_resource_module_type_get(vdc, mod)
    prereq_skip(testheader, testcase,
                "Unable to set limit-resource module-type to '#{mod}'")
  end

  step "Verify that '#{intf}' is allocated to VDC" do
    break if vdc_allocate_interface_get(vdc, intf)
    logger.info("'#{intf}' is not allocated to VDC, allocate it now...")
    vdc_allocate_interface_set(vdc, intf)
    break if vdc_allocate_interface_get(vdc, intf)
    prereq_skip(testheader, testcase,
                "Unable to allocate interface '#{intf}' to VDC")
  end

  interface_cleanup(tests[:agent], intf)

  config_switchport_mode(agent, tests[:switchport_mode]) if
    tests[:switchport_mode]

  config_bridge_domain(agent, tests[:bridge_domain]) if
    tests[:bridge_domain]

  config_encap_profile_vni_global(agent, tests[:encap_prof_global]) if
    tests[:encap_prof_global]
end
# rubocop:enable Metrics/AbcSize

# Helper for command_config calls
def command_config(agent, cmd, msg='')
  logger.info("\n#{msg}")
  cmd = "resource cisco_command_config 'cc' command='#{cmd}'"
  cmd = get_namespace_cmd(agent, PUPPET_BINPATH + cmd, options)
  on(agent, cmd, acceptable_exit_codes: [0, 2])
end

# Helper to set properties using the puppet resource command.
def resource_set(agent, resource, msg='')
  logger.info("\n#{msg}")
  cmd = "resource #{resource[:name]} '#{resource[:title]}' " \
                  "#{resource[:property]}='#{resource[:value]}'"
  cmd = get_namespace_cmd(agent, PUPPET_BINPATH + cmd, options)
  on(agent, cmd, acceptable_exit_codes: [0, 2])
end

# Helper to raise skip when prereqs are not met
def prereq_skip(testheader, testcase, message)
  testheader = '' if testheader.nil?
  logger.error("** PLATFORM PREREQUISITE NOT MET: #{message}")
  raise_skip_exception(testheader, testcase)
end

# Return an interface name from the first MT-full compatible line module found
def mt_full_interface
  # Search for F3 card on device, create an interface name if found
  cmd = get_vshell_cmd('sh mod')
  out = on(agent, cmd, pty: true).stdout[/^(\d+)\s.*N7K-F3/]
  slot = out.nil? ? nil : Regexp.last_match[1]
  "ethernet#{slot}/1" unless slot.nil?
end

# Return the default vdc name
def default_vdc_name
  cmd = get_vshell_cmd('sh run vdc')
  out = on(agent, cmd, pty: true).stdout[/^vdc (\S+) id 1$/]
  out.nil? ? nil : Regexp.last_match[1]
end

# Check for presence of limit-resource module-type
def limit_resource_module_type_get(vdc, mod)
  cmd = get_vshell_cmd("sh vdc #{vdc} detail")
  pat = Regexp.new("vdc supported linecards:.*(#{mod})")
  out = on(agent, cmd, pty: true).stdout.match(pat)
  out.nil? ? nil : Regexp.last_match[1]
end

# Set limit-resource module-type
def limit_resource_module_type_set(vdc, mod, default=false)
  # Turn off prompting
  cmd = get_vshell_cmd('terminal dont-ask persist')
  on(agent, cmd, pty: true)

  if default
    cmd = get_vshell_cmd("conf t ; vdc #{vdc} ; "\
                         'no limit-resource module-type')
  else
    cmd = get_vshell_cmd("conf t ; vdc #{vdc} ; "\
                         "limit-resource module-type #{mod}")
  end
  on(agent, cmd, pty: true)

  # Reset dont-ask to default setting
  cmd = get_vshell_cmd('no terminal dont-ask persist')
  on(agent, cmd, pty: true)
end

# Check for presence of interface in vdc allocated interfaces
def vdc_allocate_interface_get(vdc, intf)
  intf_pat = "(#{intf}) " # note trailing space
  cmd = get_vshell_cmd("sh vdc #{vdc} membership")
  out = on(agent, cmd, pty: true).stdout.match(
    Regexp.new(intf_pat, Regexp::IGNORECASE))
  out.nil? ? nil : Regexp.last_match[1]
end

# Add interface to vdc's allocated interfaces
def vdc_allocate_interface_set(vdc, intf)
  # Turn off prompting
  cmd = get_vshell_cmd('terminal dont-ask persist')
  on(agent, cmd, pty: true)

  cmd = get_vshell_cmd("conf t ; vdc #{vdc} ; "\
                       "allocate interface #{intf}")
  on(agent, cmd, pty: true)

  # Reset prompting to default state
  cmd = get_vshell_cmd('no terminal dont-ask persist')
  on(agent, cmd, pty: true)
end

# Facter command builder helper method
def facter_cmd(cmd)
  get_namespace_cmd(agent, FACTER_BINPATH + cmd, options)
end

# Used to cache the operation system information
@cisco_os = nil
# Use facter to return cisco operating system information
def operating_system
  return @cisco_os unless @cisco_os.nil?
  @cisco_os = on(agent, facter_cmd('os.name')).stdout.chomp
end

# Used to cache the cisco hardware type
@cisco_hardware = nil
# Use facter to return cisco hardware type
def platform
  return @cisco_hardware unless @cisco_hardware.nil?
  pi = on(agent, facter_cmd('-p cisco.hardware.type')).stdout.chomp
  if pi.empty?
    logger.debug 'Unable to query Cisco hardware type using the ' \
      "'cisco.hardware.type' custom factor key"
    # Some platforms do not respond correctly to the first command;
    # make another attempt using a broader search.
    on(agent, facter_cmd('-p cisco | egrep -A1 hardware'))
    # Sample output:
    #   hardware => {
    #     type => "NX-OSv Chassis",
    pi = Regexp.last_match[1] if stdout[/type => "(.*)"/]
    fail 'Unable to query Cisco hardware type using facter commands' if
      pi.empty?
  end

  # The following kind of string info is returned for Nexus.
  # - Nexus9000 C9396PX Chassis
  # - Nexus7000 C7010 (10 Slot) Chassis
  # - Nexus 6001 Chassis
  # - NX-OSv Chassis
  case pi
  when /Nexus\s?3\d\d\d/
    @cisco_hardware = 'n3k'
  when /Nexus\s?5\d\d\d/
    @cisco_hardware = 'n5k'
  when /Nexus\s?6\d\d\d/
    @cisco_hardware = 'n6k'
  when /Nexus\s?7\d\d\d/
    @cisco_hardware = 'n7k'
  when /Nexus\s?9\d\d\d/
    @cisco_hardware = 'n9k'
  when /NX-OSv/
    @cisco_hardware = 'n9k'
  else
    fail "Unrecognized platform type: #{pi}\n"
  end
  logger.info "\nFound Platform string: '#{pi}', Alias to: '#{@cisco_hardware}'"
  @cisco_hardware
end

# Helper to skip tests on unsupported platforms.
# tests[:platform] - A platform regexp pattern for all tests (caller set)
# tests[id][:platform] - A platform regexp pattern for specific test (caller set)
# tests[:skipped] - A list of skipped tests (set by this method)
def platform_supports_test(tests, id)
  # Prefer specific test key over the all tests key
  plat = tests[id][:platform] || tests[:platform]
  return true if plat.nil? || platform.match(plat)
  logger.error("\n#{tests[id][:desc]} :: #{id} :: SKIP")
  logger.error("Platform type does not match testcase platform regexp: /#{plat}/")
  tests[:skipped] ||= []
  tests[:skipped] << tests[id][:desc]
  false
end

def skipped_tests_summary(tests)
  return unless tests[:skipped]
  logger.info("\n#{'-' * 60}\n  SKIPPED TESTS SUMMARY\n#{'-' * 60}")
  tests[:skipped].each do |desc|
    logger.error(sprintf('%-40s :: SKIP', desc))
  end
  raise_skip_exception(tests[:resource_name], self)
end

# Find a test interface on the agent.
# Callers should include the following hash keys:
#   [:agent]
#   [:intf_type]
#   [:resource_name]
def find_interface(tests, id=nil, skipcheck=true)
  # Prefer specific test key over the all tests key
  if id
    type = tests[id][:intf_type] || tests[:intf_type]
  else
    type = tests[:intf_type]
  end

  case type
  when /ethernet/i, /dot1q/
    all = get_current_resource_instances(tests[:agent], 'cisco_interface')
    intf = all.grep(%r{ethernet\d+/\d+})[0]
  end

  if skipcheck && intf.nil?
    msg = 'Unable to find suitable interface module for this test.'
    prereq_skip(tests[:resource_name], self, msg)
  end
  intf
end
