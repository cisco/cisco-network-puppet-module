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

# Group of constants for use by the Beaker::TestCase instances.
# Binary executable path for puppet on master and agent.
PUPPET_BINPATH = '/opt/puppetlabs/bin/puppet '
# Binary executable path for facter on master and agent.
FACTER_BINPATH = '/opt/puppetlabs/bin/facter '
# Location of the main Puppet manifest
PUPPETMASTER_MANIFESTPATH = '/etc/puppetlabs/code/environments/production/manifests/site.pp'
# Indicates that we want to ignore the value when matching (essentially
# testing the presence of a key, regardless of value)
IGNORE_VALUE = :ignore_value

# These methods are defined outside of a module so that
# they can access the Beaker DSL API's.

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
  when /bdi/
    intf = tests[:bdi_name]
  end
  logger.info("\nUsing interface: #{intf}")
  tests[id][:title_pattern] = intf
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
    if value == IGNORE_VALUE
      regexparr << Regexp.new("#{key}\s+=>?")
      next
    end
    value = value.to_s
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
    match_kind = inverse ? 'Inverse ' : ''
    if match
      logger.debug("TestStep :: #{match_kind}Match #{pattern} :: PASS")
    else
      testcase.fail_test("TestStep :: #{match_kind}Match #{pattern} :: FAIL")
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
  PUPPET_BINPATH + 'agent -t'
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
#
# tests[id] keys set by caller:
# tests[id][:desc] - a string to use with logs & debugs
# tests[id][:manifest] - the complete manifest, as used by test_harness_common
# tests[id][:resource] - a hash of expected states, used by test_resource
# tests[id][:resource_cmd] - 'puppet resource' command to use with test_resource
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
    logger.debug("test_manifest :: check puppet agent cmd (code: #{code})")
    on(tests[:agent], puppet_agent_cmd, acceptable_exit_codes: code)
    test_stderr(tests, id) if tests[id][:stderr_pattern]
  end
  logger.info("#{stepinfo} :: PASS")
  tests[id].delete(:log_desc)
end

# Wrapper for 'puppet resource' command tests
def test_resource(tests, id, state=false)
  stepinfo = format_stepinfo(tests, id, 'RESOURCE')
  step "TestStep :: #{stepinfo}" do
    logger.debug("test_resource :: cmd:\n#{tests[id][:resource_cmd]}")
    on(tests[:agent], tests[id][:resource_cmd]) do
      search_pattern_in_output(
        stdout, supported_property_hash(tests, id, tests[id][:resource]),
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
  cmd_str = PUPPET_BINPATH + "resource #{res_name}"
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
      # Some resources have exceptions
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
      cmd_str = PUPPET_BINPATH + "resource #{res_name} '#{title}' ensure=absent"
      logger.info("  * #{stepinfo} Removing #{res_name} '#{title}'")
      on(agent, cmd_str, acceptable_exit_codes: [0])
    end
  end
end

# Helper to clean a specific resource by title name
def resource_absent_by_title(agent, res_name, title)
  res_cmd = PUPPET_BINPATH + "resource #{res_name}"
  on(agent, "#{res_cmd} '#{title}' ensure=absent")
end

# Helper to find all titles of a given resource name.
# Optionally remove all titles found.
# Returns an array of titles.
def resource_titles(agent, res_name, action=:find)
  res_cmd = PUPPET_BINPATH + "resource #{res_name}"
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
    cmd = PUPPET_BINPATH + cmd
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
    cmd = PUPPET_BINPATH + cmd
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
    cmd = PUPPET_BINPATH + cmd
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
def puppet_resource_title_pattern_munge(tests, id) # rubocop:disable Metrics/AbcSize
  title = tests[id][:title_pattern]
  params = tests[id][:title_params]
  return params if title.nil?

  tests[id][:title_params] = {} if params.nil?
  t = {}
  case tests[:resource_name]
  when 'cisco_acl'
    t[:afi], t[:acl_name] = title.split
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

  if t[:vrf].nil?
    case tests[:resource_name]
    when 'cisco_acl'
    else
      t[:vrf] = 'default'
    end
  end
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
    tests[id][:resource_cmd] = cmd
  end
end

# Create manifest and resource command strings for a given test scenario.
# Returns true if a valid/non-empty manifest was created, false otherwise.
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
  state = ''
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,' unless tests[:ensurable] == false
    tests[id][:resource]['ensure'] = nil unless
      tests[id][:resource].nil? || tests[:ensurable] == false

    manifest_props = tests[id][:manifest_props]
    if manifest_props
      manifest_props = supported_property_hash(tests, id, manifest_props)

      # we shouldn't continue if all properties were removed
      return false if
        manifest_props.empty? && !tests[id][:manifest_props].empty?

      # Create the property string for the manifest
      manifest += prop_hash_to_manifest(manifest_props) if manifest_props
    end

    # Automatically create a hash of expected states for puppet resource
    # -or- use a static hash
    # TBD: Need a prop_hash_to_resource to handle array patterns
    tests[id][:resource] = manifest_props unless tests[id][:resource]
  end

  tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
  \nnode default {
  #{dependency_manifest(tests, id)}
  #{tests[:resource_name]} { '#{tests[id][:title_pattern]}':
    #{state}\n#{manifest}
  }\n}\nEOF"

  true
end

# test_harness_dependencies
#
# This method is used for additional testbed setup beyond the basics
# used by most tests.
# Override this in a particular test file as needed.
def test_harness_dependencies(tests, id)
  # default is to do nothing
end

# dependency_manifest
#
# This method returns a string representation of a manifest that contains
# any dependencies needed for a particular test to run.
# Override this in a particular test file as needed.
def dependency_manifest(_tests, _id)
  nil # indicates no manifest dependencies
end

# unsupported_properties
#
# Returns an array of properties that are not supported for
# a particular operating_system or platform.
# Override this in a particular test file as needed.
def unsupported_properties(_tests, _id)
  [] # defaults to no unsupported properties
end

# supported_property_hash
#
# This method creates a clone of the specified property
# hash containing only the key/values of properties
# that are supported for the specified test (based on
# operating_system, platform, etc.).
def supported_property_hash(tests, id, property_hash)
  return nil if property_hash.nil?
  copy = property_hash.clone
  unsupported_properties(tests, id).each do |prop_symbol|
    copy.delete(prop_symbol)
    # because :resource hash currently uses strings for keys
    copy.delete(prop_symbol.to_s)
  end
  copy
end

# test_harness_run
#
# This method is a front-end for test_harness_common.
# - Creates manifests
# - Creates puppet resource title strings
# - Cleans resource
def test_harness_run(tests, id)
  return unless platform_supports_test(tests, id)

  tests[id][:ensure] = :present if tests[id][:ensure].nil?

  # Build the manifest for this test
  unless create_manifest_and_resource(tests, id)
    logger.error("\n#{tests[id][:desc]} :: #{id} :: SKIP")
    logger.error('No supported properties remain for this test.')
    return
  end

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
# rubocop:disable Metrics/AbcSize
def setup_mt_full_env(tests, testcase)
  # MT-full tests require a specific linecard. Search for a compatible
  # module and enable it.

  testheader = tests[:resource_name]
  mod = tests[:vdc_limit_module]
  mod = 'f3' if mod.nil?

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
    break if limit_resource_module_type_get(vdc, mod, :exact)
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

# setup_fabricpath_env
# Check and set up prerequisites for fabricpath testing.
# Fabricpath requires an F series line module. This method will update
# the tests hash with the names of the default vdc and also an appropriate
# test interface name to use for testing.
# tests[:vdc] The default vdc name
# tests[:intf] A compatible interface to use for Fabricpath testing.
def setup_fabricpath_env(tests, testcase)
  # Fabricpath tests require a specific linecard. Search for a compatible
  # module and enable it.

  return unless platform == 'n7k'

  testheader = tests[:resource_name]
  mod = tests[:vdc_limit_module]
  mod = 'f2e f3' if mod.nil?

  step 'Check for Compatible Line Module' do
    tests[:intf_type] = 'ethernet'
    tests[:intf] = fabricpath_interface
    break if tests[:intf]
    prereq_skip(testheader, testcase,
                "Fabricpath tests require #{mod} or compatible line module")
  end if tests[:intf].nil?
  intf = tests[:intf]
  logger.info("Test interface name is '#{intf}'")

  step 'Get default VDC name' do
    tests[:vdc] = default_vdc_name
    break if tests[:vdc]
    prereq_skip(testheader, testcase, 'Unable to determine default vdc name')
  end if tests[:vdc].nil?
  vdc = tests[:vdc]

  step "Set 'limit-resource module-type #{mod}'" do
    limit_resource_module_type_set(vdc, mod)
    break if limit_resource_module_type_get(vdc, mod)
    prereq_skip(testheader, testcase,
                "Unable to set limit-resource module-type to '#{mod}'")
  end
end
# rubocop:enable Metrics/AbcSize

# Helper for command_config calls
def command_config(agent, cmd, msg='')
  logger.info("\n#{msg}")
  cmd = "resource cisco_command_config 'cc' command='#{cmd}'"
  cmd = PUPPET_BINPATH + cmd
  on(agent, cmd, acceptable_exit_codes: [0, 2])
end

# Helper to set properties using the puppet resource command.
def resource_set(agent, resource, msg='')
  logger.info("\n#{msg}")
  cmd = "resource #{resource[:name]} '#{resource[:title]}' " \
                  "#{resource[:property]}='#{resource[:value]}'"
  cmd = PUPPET_BINPATH + cmd
  on(agent, cmd, acceptable_exit_codes: [0, 2])
end

# Helper to raise skip when prereqs are not met
def prereq_skip(testheader, testcase, message)
  testheader = '' if testheader.nil?
  logger.error("** PLATFORM PREREQUISITE NOT MET: #{message}")
  raise_skip_exception(testheader, testcase)
end

# Some specific platform models do not support nv_overlay
def skip_if_nv_overlay_rejected(agent)
  logger.info('Check for nv overlay support')
  cmd = get_vshell_cmd('config t ; feature nv overlay')
  on(agent, cmd, pty: true)
  # Failure message taken from 6001
  msg = 'NVE Feature NOT supported on this Platform'
  banner = '#' * msg.length
  raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self) if
    stdout.match(msg)
end

# Return an interface name from the first MT-full compatible line module found
def mt_full_interface
  # Search for F3 card on device, create an interface name if found
  cmd = get_vshell_cmd('sh mod')
  out = on(agent, cmd, pty: true).stdout[/^(\d+)\s.*N7K-F3/]
  slot = out.nil? ? nil : Regexp.last_match[1]
  "ethernet#{slot}/1" unless slot.nil?
end

# Return an interface name from the first Fabricpath compatible line module
# found
def fabricpath_interface
  # Search for F2E/F3 cards on device, create an interface name if found
  cmd = '-p cisco.feature_compatible_module_iflist.fabricpath'
  if_array_str = on(agent, facter_cmd(cmd)).stdout.chomp
  if_array_str.gsub!(/[\[\]\n\s"]/, '')
  if_array = if_array_str.split(',')
  if_array[0] unless if_array.empty?
end

# Return the default vdc name
def default_vdc_name
  cmd = get_vshell_cmd('sh run vdc')
  out = on(agent, cmd, pty: true).stdout[/^vdc (\S+) id 1$/]
  out.nil? ? nil : Regexp.last_match[1]
end

# Check for presence of limit-resource module-type
# The lookup is a loose match by default but some features like 'vni' are
# required to use a specific set of modules only, in which case specify
# ':exact' for a strict match of the current modules.
def limit_resource_module_type_get(vdc, mod, match=nil)
  cmd = get_vshell_cmd("sh vdc #{vdc} detail")
  if match == :exact
    # Must be this list of modules only
    pat = Regexp.new("vdc supported linecards: (#{mod})")
  else
    # Just make sure module type is in list
    pat = Regexp.new("vdc supported linecards:.*(#{mod})")
  end
  out = on(agent, cmd, pty: true).stdout.match(pat)
  out.nil? ? nil : Regexp.last_match[1]
end

# Set limit-resource module-type
def limit_resource_module_type_set(vdc, mod, default=false)
  mod = 'default' if default || mod.nil?
  resource_vdc_mod = {
    name:     'cisco_vdc',
    title:    vdc,
    property: 'limit_resource_module_type',
    value:    mod,
  }
  resource_set(agent, resource_vdc_mod, "Enable module-type #{mod}")
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
  FACTER_BINPATH + cmd
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
  #
  # The following kind of string info is returned for IOS XR.
  # - Cisco XRv9K Virtual Router
  case pi
  when /Nexus\s?3\d\d\d/
    @cisco_hardware = 'n3k'
  when /Nexus\s?5\d\d\d/
    @cisco_hardware = 'n5k'
  when /Nexus\s?6\d\d\d/
    @cisco_hardware = 'n6k'
  when /Nexus\s?7\d\d\d/
    @cisco_hardware = 'n7k'
  when /Nexus\s?8\d\d\d/
    @cisco_hardware = 'n8k'
  when /NX-OSv8K/
    @cisco_hardware = 'n8k'
  when /Nexus\s?9\d\d\d/
    @cisco_hardware = 'n9k'
  when /NX-OSv Chassis/
    @cisco_hardware = 'n9k'
  when /XRv9K/i
    @cisco_hardware = 'xrv9k'
  else
    fail "Unrecognized platform type: #{pi}\n"
  end
  logger.info "\nFound Platform string: '#{pi}', Alias to: '#{@cisco_hardware}'"
  @cisco_hardware
end

# Check if this image is an I2 image
@i2_image = nil # Cache the lookup result
def nexus_i2_image
  return @i2_image unless @i2_image.nil?
  on(agent, facter_cmd('-p cisco.images.system_image'))
  @i2_image = stdout[/7.0.3.I2/] ? true : false
  @i2_image
end

# This is a skip-all-testcases-if-I2-image check.
# Do not use this for skipping individual properties.
def skip_nexus_i2_image(tests)
  return unless nexus_i2_image
  msg = "Skipping all tests; '#{tests[:resource_name]}' "\
        'is not supported on 7.0.3(I2) images'
  banner = '#' * msg.length
  raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self)
end

# Helper to skip tests on unsupported platforms.
# tests[:operating_system] - An OS regexp pattern for all tests (caller set)
# tests[:platform] - A platform regexp pattern for all tests (caller set)
# tests[id][:operating_system] - An OS regexp pattern for specific test (caller set)
# tests[id][:platform] - A platform regexp pattern for specific test (caller set)
# tests[:skipped] - A list of skipped tests (set by this method)
def platform_supports_test(tests, id)
  # Prefer specific test key over the all tests key
  os = tests[id][:operating_system] || tests[:operating_system]
  plat = tests[id][:platform] || tests[:platform]
  if os && !operating_system.match(os)
    logger.error("\n#{tests[id][:desc]} :: #{id} :: SKIP")
    logger.error("Operating system does not match testcase os regexp: /#{os}/")
  elsif plat && !platform.match(plat)
    logger.error("\n#{tests[id][:desc]} :: #{id} :: SKIP")
    logger.error("Platform type does not match testcase platform regexp: /#{plat}/")
  else
    return true
  end
  tests[:skipped] ||= []
  tests[:skipped] << tests[id][:desc]
  false
end

# This is a simple top-level skip similar to what exists in the minitests.
# Callers will skip all tests when true.
# tests[:platform] - regex of supported platforms
# tests[:resource_name] - provider name (e.g. 'cisco_vxlan_vtep')
def skip_unless_supported(tests)
  pattern = tests[:platform]
  return false if pattern.nil? || platform.match(tests[:platform])
  msg = "Skipping all tests; '#{tests[:resource_name]}' "\
        'is unsupported on this node'
  banner = '#' * msg.length
  raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self)
end

def skipped_tests_summary(tests)
  return unless tests[:skipped]
  logger.info("\n#{'-' * 60}\n  SKIPPED TESTS SUMMARY\n#{'-' * 60}")
  tests[:skipped].each do |desc|
    logger.error(sprintf('%-40s :: SKIP', desc))
  end
  raise_skip_exception(tests[:resource_name], self)
end

# TBD: This needs to be more selective when used with modular platforms,
# particularly to ignore L2-only F2 cards on N7k.
#
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
    # Skip the first interface we find in case it's our access interface.
    # TODO: check the interface IP address like we do in node_utils
    intf = all.grep(%r{ethernet\d+/\d+$})[1]
  end

  if skipcheck && intf.nil?
    msg = 'Unable to find suitable interface module for this test.'
    prereq_skip(tests[:resource_name], self, msg)
  end
  intf
end

# Find an array of test interface on the agent.
# Callers should include the following hash keys:
#   [:agent]
#   [:intf_type]
#   [:resource_name]
def find_interface_array(tests, id=nil, skipcheck=true)
  # Prefer specific test key over the all tests key
  if id
    type = tests[id][:intf_type] || tests[:intf_type]
  else
    type = tests[:intf_type]
  end

  case type
  when /ethernet/i, /dot1q/
    all = get_current_resource_instances(tests[:agent], 'cisco_interface')
    # Skip the first interface we find in case it's our access interface.
    # TODO: check the interface IP address like we do in node_utils
    array = all.grep(%r{ethernet\d+/\d+})
  end

  if skipcheck && array.nil? && array.empty?
    msg = 'Unable to find suitable interface module for this test.'
    prereq_skip(tests[:resource_name], self, msg)
  end
  array
end

# Use puppet resource to get interface capability information.
# TBD: Facter may be a better home for this method but the performance hit
# appears to be 2s per hundred interfaces so it works better for now as an
# on-demand method.
def interface_capabilities(agent, intf)
  cmd = PUPPET_BINPATH + "resource cisco_interface_capabilities '#{intf}'"
  on(agent, cmd, pty: true)

  # Sample raw output:
  # "cisco_interface_capabilities { 'ethernet9/1':\n  capabilities =>
  # ['Model: N7K-F312FQ-25', '', 'Type (SFP capable):    QSFP-40G-4SFP10G', '',
  # 'Speed: 10000,40000', '', 'Duplex: full', ''], }

  str = stdout[/\[(.*)\]/]
  return {} if str.nil?
  str = str[1..-2]
  return {} if str.nil?
  str = str[1..-2]
  return {} if str.nil?

  # 'Model: N7K-F312FQ-25', '', 'Type (SFP capable):    QSFP-40G-4SFP10G', '',
  # 'Speed: 10000,40000', '', 'Duplex: full', ''
  str.delete!("'")

  # Model: N7K-F312FQ-25, , Type (SFP capable):    QSFP-40G-4SFP10G, ,
  # Speed: 10000,40000, , Duplex: full, ,
  hash = {}
  str.split(', ,').each do |line|
    k, v = line.split(':')
    next if k.nil? || v.nil?
    k.gsub!(/ \(.*\)/, '') # Remove any parenthetical text from key
    k.strip!
    v.strip!
    hash[k] = v
  end
  hash
end

# Capabilities-to-Netdev-Manifest syntax converter
def netdev_speed(speed)
  case speed.to_s
  when '100' then '100m'
  when '1000' then '1g'
  when '10000' then '10g'
  when '40000' then '40g'
  when '100000' then '100g'
  else speed
  end
end

# 'interface_probe' tests reported capabilities. Why? Speed, duplex, and mtu
# are somewhat unreliably reported (ie. some values still raise errors when
# used) so this method tries each value to eliminate the ambiguity.
# The probe options are passed in as a hash, either as a standalone argument or
# via tests[:probe], in which case the successfully probed caps will overwrite
# the tests[:probe][:caps] value.
# Note that this function is only useful with ethernet interfaces.
#
# probe = A hash of probe arguments:
#    :cmd = The puppet resource command to use with the probe.
#    :intf = The interface to test. If not present one will be discovered.
#    :caps = A hash of interface capabilities, typically the output from
#            interface_capabilities(). If not present the capabilities will be
#            discovered by this method. On completion, :caps will be updated
#            with the successful values.
#    :probe_props = An array of capabilities to probe.
#    :netdev_speed = Set to True for syntax conversion (netdev only)
#
# Example:
#   tests[:probe] = {
#     cmd:         '<PUPPET_BINPATH> resource network_interface ',
#     intf:        'ethernet1/1',
#     caps:        {'Speed' => '10,100,1000', 'Duplex' => 'auto,half,full'},
#     probe_props: %w(Speed Duplex)
#
def interface_probe(tests, probe={})
  agent = tests[:agent]

  # Use tests[:probe] if caller does not supply a separate probe hash
  probe = tests[:probe] if probe.empty?
  fail 'interface_probe: probe hash not found' if probe.nil?

  # Find a usable interface
  probe[:intf] = find_interface(tests) if probe[:intf].nil?
  intf = probe[:intf]
  fail 'interface_probe: interface not found' if intf.nil?

  # Create the puppet resource command syntax
  fail 'interface_probe: resource command not found' if probe[:cmd].nil?
  cmd = probe[:cmd] + " '#{intf}' "

  # Get the interface capabilities
  probe[:caps] = interface_capabilities(agent, intf) if probe[:caps].nil?
  fail 'interface_probe: capabilities data not present' if probe[:caps].nil?

  debug_probe(probe, 'Probe Begin')
  probe[:probe_props].each do |prop|
    success = []
    probe[:caps][prop].to_s.split(',').each do |val|
      val = netdev_speed(val) if prop[/Speed/] && probe[:netdev_speed]
      on(agent, cmd + "#{prop}=#{val}",
         acceptable_exit_codes: [0, 2, 1], pty: true)
      next if stdout[/error/i]
      success << val
    end
    probe[:caps][prop] = success
  end
  # probe[:caps]=>{"Speed"=>["100", "1000"], "Duplex"=>["full"],
  debug_probe(probe, 'Probe Complete')
  probe
end

def debug_probe(probe, msg)
  dbg = ''
  probe[:probe_props].each { |p| dbg += "'#{p}' => #{probe[:caps][p]}, " }
  logger.info("\n      #{msg}: #{dbg}")
end

def remove_all_vlans(agent, stepinfo='Remove all vlans & bridge-domains')
  step "\n--------\n * TestStep :: #{stepinfo}" do
    resource_absent_cleanup(agent, 'cisco_bridge_domain', 'bridge domains')
    cmd = 'system bridge-domain none'
    command_config(agent, cmd, cmd)
    resource_absent_cleanup(agent, 'cisco_vlan', 'vlans')
  end
end
