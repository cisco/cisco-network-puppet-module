require 'puppet'
require 'puppet/util/network_device/config'
require 'cisco_node_utils'

###############################################################################
# Copyright (c) 2014-2018 Cisco and/or its affiliates.
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
# Temporary manifest for agentless tests
TEMP_AGENTLESS_MANIFEST_PREFIX = 'temp_test_apply'
@temp_agentless_manifest = nil
# Indicates that we want to ignore the value when matching (essentially
# testing the presence of a key, regardless of value)
IGNORE_VALUE = :ignore_value

# A simple baseclass for test harnesses, following the NullObject pattern
# Using this alleviates the necessity of checking for presence or capabilities of
# the harness class.
class BaseHarness
  # This method returns a string representation of a manifest that contains
  # any dependencies needed for a particular test to run.
  # Override this in a particular test file as needed.
  def self.dependency_manifest(_ctx, _tests, _id)
    nil # indicates no manifest dependencies
  end

  # This method is used for additional testbed setup beyond the basics
  # used by most tests.
  # Override this in a particular test file as needed.
  def self.test_harness_dependencies(_ctx, _tests, _id)
    # default is to do nothing
  end

  # Returns an array of properties that are not supported for
  # a particular operating_system or platform.
  # Override this in a particular test file as needed.
  def self.unsupported_properties(_ctx, _tests, _id)
    [] # defaults to no unsupported properties
  end

  # Returns an array of properties that are not supported for
  # a particular operating_system or platform for a particular
  # software version.
  # Override this in a particular test file as needed.
  # Ex: If property 'ipv4_sub_option_circuit_id_string' is
  # supported on n9k only on version '7.0.3.I6.1' or higher
  # then add this line in the overridden method.
  # unprops[:ipv4_sub_option_circuit_id_string] = '7.0.3.I6.1' if
  #   platform[/n9k$/]
  def self.version_unsupported_properties(_ctx, _tests, _id)
    {} # defaults to no version_unsupported properties
  end
end

# Monkeypatch all our utility functions into beaker's TestCase, so that we don't poison the global namespace
class Beaker::TestCase
  # Current agentless nexus host
  @nexus_host = nil

  # Executable base command for puppet agentless
  def agentless_command
    "bundle exec puppet device --verbose --trace --strict=error --modulepath spec/fixtures/modules --deviceconfig #{@device_conf_file.path} --target sut --libdir lib/ "
  end

  # Method to create agentless device.conf and
  # appropriate credentials.conf
  #
  # Assumes that the beaker configuration contains a Nexus host with role default
  # Raises an error if not the case.
  def create_agentless_device_conf
    raise 'Could not find default Nexus host' unless default && default.host_hash[:platform].match(%r{cisco_nexus.*})
    @nexus_host = default

    @credentials_file = Tempfile.new(['acceptance-credentials', '.conf'])
    @device_conf_file = Tempfile.new(['acceptance-device', '.conf'])

    @credentials_file.write <<CREDENTIALS
host: "#{beaker_config_connection_address}"
user: "#{@nexus_host.host_hash[:ssh][:user] || 'admin'}"
port: #{@nexus_host.host_hash[:ssh][:port] || 80}
password: "#{@nexus_host.host_hash[:ssh][:password] || 'admin'}"
CREDENTIALS
    @credentials_file.close

    @device_conf_file.write <<DEVICE
[sut]
type cisco_nexus
url file://#{@credentials_file.path}
DEVICE
    @device_conf_file.close
  end

  # Method to return an agent
  # Otherwise, if running agentlessly, call the device configuration creation method
  # if not already called
  def agent
    agent_host = find_host_with_role :agent
    if agent_host.nil?
      if @nexus_host.nil?
        create_agentless_device_conf
      end
      return nil
    else
      agent_host
    end
  end

  # Method to return an proxy_agent
  # if not already called
  # Will skip the test if it does not find the
  # role matching proxy_agent
  def proxy_agent
    find_host_with_role :proxy_agent
  rescue Beaker::DSL::Outcomes::FailTest
    msg = 'Skipping test as it is not supported in this mode'
    banner = '#' * msg.length
    raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self)
  end

  # These methods are defined outside of a module so that
  # they can access the Beaker DSL API's.

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
        # Handle Puppet 5 line wrap issue
        value.gsub!(/^[\[]/, '[\n? *').gsub!(', [', ',\n? +?[')
        # END Handle Puppet 5 line wrap issue
        value.gsub!(/[\[\]]/) { |s| '\\' + "#{s}" }.gsub!(/\"/) { |_s| '\'' }
      end
      value.gsub!(/[\(\)]/) { |s| '\\' + "#{s}" } if /\(.*\)/.match(value)
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
    # Remove certain patterns in output that will cause comparison failures.
    output.gsub!(/\\'|\"/, '')
    patarr = hash_to_patterns(patarr) if patarr.instance_of?(Hash)
    patarr.each do |pattern|
      inverse ? (match = (output !~ pattern)) : (match = (output =~ pattern))
      match_kind = inverse ? 'Inverse ' : ''
      if match
        logger.debug("TestStep :: #{match_kind}Match #{pattern} :: PASS")
      else
        logger.error("output:\n--\n#{output}\n--")
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
    PUPPET_BINPATH + 'agent -t --trace'
  end

  # Full command string for running puppet device on a proxy_agent
  def puppet_device_cmd
    PUPPET_BINPATH + "device --target #{beaker_config_connection_address} --trace --debug"
  end

  # full command string for puppet resource commands
  def puppet_resource_cmd(res_name, title, property, value)
    PUPPET_BINPATH + "resource #{res_name} '#{title}' #{property}=#{value}"
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
  def test_harness_common(tests, id, harness_class: BaseHarness, skip_idempotence_check: false)
    tests[id][:ensure] = :present if tests[id][:ensure].nil?
    tests[id][:state] = false if tests[id][:state].nil?
    tests[id][:desc] = '' if tests[id][:desc].nil?
    tests[id][:log_desc] = tests[id][:desc] + " [ensure => #{tests[id][:ensure]}]"
    logger.info("\n--------\n#{tests[id][:log_desc]}")

    test_manifest(tests, id)
    test_resource(tests, id, harness_class: harness_class)
    test_idempotence(tests, id) unless skip_idempotence_check
    remove_temp_manifest
    tests[id].delete(:log_desc)
  end

  # Wrapper for formatting test log entries
  def format_stepinfo(tests, id, test_str)
    logger.debug("format_stepinfo :: (#{tests[id][:desc]}) (#{test_str})")
    tests[id][:log_desc] = tests[id][:desc] if tests[id][:log_desc].nil?
    tests[id][:log_desc] + sprintf(' :: %-12s', test_str)
  end

  # helper to match stderr buffer against :stderr_pattern
  def test_stderr(tests, id, output=nil)
    if output
      test_output = output
    else
      test_output = stderr
    end
    if test_output =~ tests[id][:stderr_pattern]
      logger.debug("TestStep :: Match #{tests[id][:stderr_pattern]} :: PASS")
    else
      logger.error("output:\n--\n#{test_output}\n--")
      fail_test("TestStep :: Match #{tests[id][:stderr_pattern]} :: FAIL")
    end
  end

  # Function to remove the temporary manifest
  def remove_temp_manifest(manifest=@temp_agentless_manifest)
    return unless manifest
    manifest.close
    manifest.unlink
  end

  # Wrapper for manifest tests
  # Pass code = [0], as an alternative to 'test_idempotence'
  def test_manifest(tests, id)
    stepinfo = format_stepinfo(tests, id, 'MANIFEST')
    step "TestStep :: #{stepinfo}" do
      logger.debug("test_manifest :: manifest:\n#{tests[id][:manifest]}")
      if tests[:master]
        on(tests[:master], tests[id][:manifest])
        code = (tests[id][:code]) ? tests[id][:code] : [2]
        logger.debug("test_manifest :: check puppet agent cmd (code: #{code})")
        if tests[:proxy_agent]
          # system("bundle exec puppet device --verbose --trace --strict=error --modulepath spec/fixtures --target nexus --libdir lib/ --apply apply.pp")
          # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
          # if !code.include?($?.exitstatus)
          #  raise 'Errored test'
          # end
          on(tests[:proxy_agent], puppet_device_cmd, acceptable_exit_codes: [0, 1, 2])
          output = stdout
          if tests[id][:stderr_pattern].nil? && (output[/Error: /] || !output[/Applied catalog/])
            logger.info(tests[id][:manifest])
            logger.info(stdout)
            raise 'Unexpected error while applying catalog'
          end
        else
          on(tests[:agent], puppet_agent_cmd, acceptable_exit_codes: code)
        end
        output = nil
      else
        code = (tests[id][:code]) ? tests[id][:code] : [2]
        logger.debug("test_manifest :: check puppet apply cmd (code: #{code})")
        # system("bundle exec puppet device --verbose --trace --strict=error --modulepath spec/fixtures --target nexus --libdir lib/ --apply apply.pp")
        # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
        # if !code.include?($?.exitstatus)
        #  raise 'Errored test'
        # end
        manifest_data = `cat #{@temp_agentless_manifest.path}`
        logger.debug("test_manifest :: manifest contents :: \n#{manifest_data}")
        logger.debug("test_manifest :: apply manifest command :: #{agentless_command} --apply #{@temp_agentless_manifest.path}")
        output = `#{agentless_command} --apply #{@temp_agentless_manifest.path} 2>&1`
        logger.debug("test_manifest :: output: \n#{output}")
        if tests[id][:stderr_pattern].nil? && (output[/Error: /] || !output[/Applied catalog/])
          logger.info(`cat #{@temp_agentless_manifest.path}`)
          remove_temp_manifest
          logger.info(output)
          raise 'Unexpected error while applying catalog'
        end
      end
      test_stderr(tests, id, output) if tests[id][:stderr_pattern]
    end
    logger.info("#{stepinfo} :: PASS")
    tests[id].delete(:log_desc)
  end

  # Wrapper for 'puppet resource' command tests
  def test_resource(tests, id, harness_class: BaseHarness, state: false)
    stepinfo = format_stepinfo(tests, id, 'RESOURCE')
    step "TestStep :: #{stepinfo}" do
      logger.debug("test_resource :: cmd:\n#{tests[id][:resource_cmd]}")
      if tests[:agent]
        on(tests[:agent], tests[id][:resource_cmd]) do
          search_pattern_in_output(
            stdout, supported_property_hash(tests, id, tests[id][:resource], harness_class: harness_class),
            state, self, logger
          )
        end
      else
        output = `#{tests[id][:resource_cmd]}`
        search_pattern_in_output(
          output, supported_property_hash(tests, id, tests[id][:resource], harness_class: harness_class),
          state, self, logger
        )
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
      if tests[:agent]
        on(tests[:agent], puppet_agent_cmd, acceptable_exit_codes: [0])
      elsif tests[:proxy_agent]
        # system("bundle exec puppet device --verbose --trace --strict=error --modulepath spec/fixtures --target nexus --libdir lib/ --apply apply.pp")
        # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
        # if !$?.exitstatus == 0
        #   raise 'Errored idempotence test'
        # end
        on(tests[:proxy_agent], puppet_device_cmd, acceptable_exit_codes: [0, 1, 2])
        if stdout.include? "#{tests[:resource_name]}[#{tests[id][:title_pattern]}]: Updating:"
          raise 'Errored idempotence test'
        end
      else
        # system("bundle exec puppet device --verbose --trace --strict=error --modulepath spec/fixtures --target nexus --libdir lib/ --apply apply.pp")
        # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
        # if !$?.exitstatus == 0
        #   raise 'Errored idempotence test'
        # end
        cmd = "#{agentless_command} --apply #{@temp_agentless_manifest.path}"
        output = `#{cmd}`
        logger.debug("test_idempotence :: output: \n#{output}")
        pattern = "#{tests[:resource_name]}[#{tests[id][:title_pattern]}]: "
        if output.include?(pattern + 'Updating') || output.include?('Error: ')
          logger.info("Idempotence Command: #{cmd}")
          logger.info("Command Result: #{output}")
          raise 'Errored idempotence test'
        end
      end
      logger.info("#{stepinfo} :: PASS")
      tests[id].delete(:log_desc)
    end
  end

  # Helper to retrieve all instances of a given resource
  # @param agent [String] the agent to be queried
  # @param res_name [String] the resource to retrieve instances of
  # @return [Array] an array of string names of instances
  def get_current_resource_instances(agent, res_name)
    if agent
      cmd_str = PUPPET_BINPATH + "resource #{res_name}"
      on(agent, cmd_str, acceptable_exit_codes: [0])
      names = stdout.scan(/#{res_name} { '(.+)':/).flatten
    else
      output = `#{agentless_command} --resource #{res_name}`
      names = output.scan(/#{res_name} { '(.+)':/).flatten
    end
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
          # TBD: Per-vlan cleanup is too slow. Consider 'no vlan 1-4095'
          next if title == '1'
        when /cisco_vrf/
          next if title[/management/]
        end
        logger.info("  * #{stepinfo} Removing #{res_name} '#{title}'")
        if agent
          cmd_str = PUPPET_BINPATH + "resource #{res_name} '#{title}' ensure=absent"
          on(agent, cmd_str, acceptable_exit_codes: [0])
        else
          create_and_apply_test_manifest(res_name, title, 'ensure', 'absent')
        end
      end
    end
  end

  # TBD: dead method
  # Helper to clean a specific resource by title name
  def resource_absent_by_title(agent, res_name, title)
    res_cmd = PUPPET_BINPATH + "resource #{res_name}"
    on(agent, "#{res_cmd} '#{title}' ensure=absent")
  end

  # TBD: dead method
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

  # Helper to determine if a resource is present
  def resource_present?(agent, name, title)
    res_name = "#{name} #{title}"
    if agent
      out = on(agent, PUPPET_BINPATH + "resource #{res_name}").stdout
    else
      out = `#{agentless_command} --resource #{res_name}`
    end
    out[/ensure => 'absent'/] ? false : true
  end

  # Helper to configure switchport mode
  def config_switchport_mode(agent, intf, mode, stepinfo='switchport mode: ')
    step "TestStep :: #{stepinfo}" do
      cmd = "interface #{intf} ; switchport ; switchport mode #{mode}"
      command_config(agent, cmd, cmd, ignore_errors: false)
    end
  end

  # Helper to toggle 'system default switchport'
  def system_default_switchport(agent, state=false,
                                stepinfo='system default switchport')
    step "TestStep :: #{stepinfo} (state: #{state})" do
      state = state ? ' ' : 'no '
      cmd = "#{state}system default switchport"
      command_config(agent, cmd, cmd, ignore_errors: false)
    end
  end

  # Helper for checking/setting 'system default switchport'
  def config_system_default_switchport?(tests, id)
    return unless tests[id].key?(:sys_def_switchport)

    state = tests[id][:sys_def_switchport]
    # cached state
    return if tests[:sys_def_switchport] == state

    system_default_switchport(agent, state)
    # cache for later tests
    tests[:sys_def_switchport] = state
  end

  # Helper to toggle 'system default switchport shutdown'
  def system_default_switchport_shutdown(agent, state=false,
                                         stepinfo='system default switchport shutdown')
    step "TestStep :: #{stepinfo}" do
      state = state ? ' ' : 'no '
      cmd = "#{state}system default switchport shutdown"
      command_config(agent, cmd, cmd, ignore_errors: false)
    end
  end

  # Helper for checking/setting 'system default switchport shutdown'
  def config_system_default_switchport_shutdown?(tests, id)
    return unless tests[id].key?(:sys_def_sw_shut)

    state = tests[id][:sys_def_sw_shut]
    # cached state
    return if tests[:sys_def_sw_shut] == state

    system_default_switchport_shutdown(agent, state)
    # cache for later tests
    tests[:sys_def_sw_shut] = state
  end

  # Helper for creating / removing an ACL
  def config_acl(_agent, afi, acl, state, stepinfo='ACL:')
    step "TestStep :: #{stepinfo}" do
      state = state ? 'present' : 'absent'
      create_and_apply_test_manifest('cisco_acl', "#{afi} #{acl}", 'ensure', state)
    end
  end

  # Helper for checking/setting ACLs
  def config_acl?(tests, id)
    tests[id][:acl].each { |acl, afi| config_acl(agent, afi, acl, true) } if
      tests[id][:acl]
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
      cmd = 'show run bridge-domain'
      if agent
        out = on(agent, get_vshell_cmd(cmd)).stdout
      else
        out = nxapi_test_get(cmd, false)
      end
      bds = out.scan(/^bridge-domain \d+/)
      return if bds.include?("bridge-domain #{test_bd}")

      bds.uniq.each do |bd|
        command_config(agent, "no #{bd}", "remove #{bd}", ignore_errors: true)
      end
      if (sys_bd = out[/^system bridge-domain .*/])
        command_config(agent, "no #{sys_bd}", "remove #{sys_bd}", ignore_errors: false)
      end

      # Remove vlan
      cmd = "no vlan #{test_bd}"
      command_config(agent, cmd, cmd, ignore_errors: true)

      # Configure bridge-domain
      cmd = "system bridge-domain #{test_bd} ; bridge-domain #{test_bd}"
      command_config(agent, cmd, cmd, ignore_errors: false)
    end
  end

  def config_bridge_domain?(tests, _id)
    return unless platform[/n7k/] && tests.key?(:bridge_domain)

    bd = tests[:bridge_domain]
    agent = tests[:agent]
    cmd = 'show runn bridge-domain'
    if agent
      out = on(agent, get_vshell_cmd(cmd), pty: true).stdout
    else
      out = nxapi_test_get(cmd, false)
    end
    config_bridge_domain(agent, bd) unless
      out.match(Regexp.new("^bridge-domain #{bd}"))

    # Delete the key to prevent having to set this for every test case
    tests.delete(:bridge_domain)
  end

  # Helper for creating / removing encap profile vni (global) configs
  def config_encap_profile_vni_global(agent, cmd,
                                      stepinfo='encap profile vni global:')
    step stepinfo do
      command_config(agent, cmd, cmd)
    end
  end

  # Helper function to obtain the connection address
  # from the hash obtained from the beaker config
  # As per beaker SSH connection methods preference
  # we try to find the following, in order:
  # - ip
  # - vmhostname
  # - hostname
  # If neither of these 3 values are found, log an error
  # and return nil
  #
  # Otherwise return the first value found from the
  # preference ordering
  def beaker_config_connection_address
    if @nexus_host[:ip]
      @nexus_host[:ip]
    elsif @nexus_host[:vmhostname]
      @nexus_host[:vmhostname]
    elsif @nexus_host[:hostname]
      @nexus_host[:hostname]
    else
      logger.error("stdout:\n--\nip, vmhostname or hostname not found, check beaker hosts configuration\n--")
      nil
    end
  end

  # Helper to nuke a single interface. This is needed to remove all
  # configurations from the interface.
  def interface_cleanup(agent, intf, stepinfo='Interface Clean:')
    return if intf.empty?
    step "TestStep :: #{stepinfo}" do
      logger.info("  * #{stepinfo} Set '#{intf}' to default state")
      cmd = "default interface #{intf}"
      if agent
        cmd = PUPPET_BINPATH + "resource cisco_command_config 'interface_cleanup' command='#{cmd}'"
        on(agent, cmd, acceptable_exit_codes: [0, 2])
      else
        nxapi_test_set(cmd)
      end
    end
  end

  # Helper to clean up a range of interfaces
  def interface_cleanup_range(tests)
    step 'TestStep :: clean up interface range' do
      logger.info("  * Set '#{tests[:intf_range]}' to default state")
      cmd = "default interface #{tests[:intf_range]}"
      if agent
        cmd = PUPPET_BINPATH + "resource cisco_command_config 'interface_cleanup_range' command='#{cmd}'"
        on(agent, cmd, acceptable_exit_codes: [0, 2])
      else
        nxapi_test_set(cmd)
      end
    end
  end

  # Helper to remove all IP address configs from all interfaces. This is
  # needed to avoid IP conflicts with our test interface.
  def interface_ip_cleanup(agent, stepinfo='Pre Clean:')
    logger.debug("#{stepinfo} Interface IP cleanup")

    # Find the interfaces with IP addresses; build a removal config.
    # Note mgmt0 will not appear in the show cmd output.
    cmd = 'show ip interface brief'
    if agent
      out = on(agent, get_vshell_cmd(cmd)).stdout
    else
      out = nxapi_test_get(cmd, false)
    end

    clean = out.split("\n").map do |line|
      "interface #{Regexp.last_match[:intf]} ; no ip addr" if
        line[/^(?<intf>\S+)\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/]
    end.compact
    return if clean.empty?
    clean = clean.join(' ; ').prepend('conf t ; ')
    logger.debug("#{stepinfo} Clean string:\n#{clean}")

    if agent
      # exit codes: 0 = no changes, 2 = changes have occurred
      on(agent, get_vshell_cmd(clean), acceptable_exit_codes: [0, 2])
    else
      nxapi_test_set(clean, ignore_errors: true)
    end
  end

  # TBD: dead method
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

      cmd = if tests[:agent]
              PUPPET_BINPATH + "resource #{tests[:resource_name]} '#{title_string}'"
            else
              "#{agentless_command} --resource #{tests[:resource_name]} '#{title_string}'"
            end

      logger.info("\ntitle_string: '#{title_string}'")
      tests[id][:resource_cmd] = cmd
    end
  end

  def create_agentless_manifest(tests, resource_name, id, state, manifest, harness_class: BaseHarness)
    @temp_agentless_manifest = Tempfile.new(TEMP_AGENTLESS_MANIFEST_PREFIX)
    @temp_agentless_manifest.write("#{harness_class.dependency_manifest(self, tests, id)}
                                   #{resource_name} { '#{tests[id][:title_pattern]}':
                               #{state}\n#{manifest}
                             }\n")
    @temp_agentless_manifest.rewind
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
  def create_manifest_and_resource(tests, id, harness_class: BaseHarness)
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
      if tests[id][:resource] && tests[id][:resource].include?(:ensure)
        state = "ensure => #{tests[id][:resource][:ensure]},"
        tests[id][:resource] = { 'ensure' => "#{tests[id][:resource][:ensure]}" }
      else
        state = 'ensure => absent,'
        tests[id][:resource] = { 'ensure' => 'absent' }
      end
    else
      state = 'ensure => present,' unless tests[:ensurable] == false

      tests[id][:resource]['ensure'] = nil unless
          tests[id][:resource].nil? || tests[:ensurable] == false

      manifest_props = tests[id][:manifest_props]
      if manifest_props
        manifest_props = supported_property_hash(tests, id, manifest_props, harness_class: harness_class)

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

    tests[id][:manifest] = if tests[:agent]
                             "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
                           \nnode default {
                           #{harness_class.dependency_manifest(self, tests, id)}
                           #{tests[:resource_name]} { '#{tests[id][:title_pattern]}':
                             #{state}\n#{manifest}
                           }\n}\nEOF"
                           elsif tests[:proxy_agent]
                             "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
                             \nnode '#{beaker_config_connection_address}' {
                             #{harness_class.dependency_manifest(self, tests, id)}
                             #{tests[:resource_name]} { '#{tests[id][:title_pattern]}':
                               #{state}\n#{manifest}
                             }\n}\nEOF"
                           else
                             create_agentless_manifest(tests, tests[:resource_name], id, state, manifest, harness_class: harness_class)
                             # logger.debug("Agentless Manifest:\n" + manifest)
                           end
    true
  end

  # Special create manifest/resource method for yum packages only.
  def create_package_manifest_resource(tests, id, harness_class: BaseHarness)
    puppet_resource_cmd_from_params(tests, id)
    state = ''
    manifest = ''
    if tests[id][:ensure] == :absent
      state = 'ensure => absent,'
    else
      state = 'ensure => present,'
    end

    manifest_props = tests[id][:manifest_props]
    manifest += prop_hash_to_manifest(manifest_props)
    tests[id][:resource] = manifest_props
    tests[id][:manifest] = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
    \nnode default {
    #{harness_class.dependency_manifest(self, tests, id)}
    #{tests[:resource_name]} { '#{tests[id][:title_pattern]}':
      #{state}\n#{manifest}
    }\n}\nEOF"

    true
  end

  # supported_property_hash
  #
  # This method creates a clone of the specified property
  # hash containing only the key/values of properties
  # that are supported for the specified test (based on
  # operating_system, platform, etc.).
  def supported_property_hash(tests, id, property_hash, harness_class: BaseHarness)
    return nil if property_hash.nil?
    copy = property_hash.clone
    unsupported_properties = harness_class.unsupported_properties(self, tests, id)
    unless unsupported_properties.nil?
      unsupported_properties.each do |prop_symbol|
        next unless prop_symbol
        copy.delete(prop_symbol)
        # because :resource hash currently uses strings for keys
        copy.delete(prop_symbol.to_s)
      end
    end

    lim = full_version.split[0].tr('(', '.').tr(')', '.').chomp('.')
    # due to a bug in Gem::Version, we need to append a letter
    # to the version field if the to be compared version
    # has a letter at the end
    # For ex:
    # 7.0.3.I2.2e < 7.0.3.I2.2 is TRUE instead of FALSE
    # Once we add a letter 'a' to the end,
    # 7.0.3.I2.2e < 7.0.3.I2.2a is FALSE
    append_a = false
    append_a = true if lim[-1, 1] =~ /[[:alpha:]]/
    version_unsupported_properties = harness_class.version_unsupported_properties(self, tests, id)
    unless version_unsupported_properties.nil?
      version_unsupported_properties.each do |key, val|
        next unless key
        val << 'a' if append_a
        append_a = false
        next unless Gem::Version.new(lim) < Gem::Version.new(val)
        copy.delete(key)
        # because :resource hash currently uses strings for keys
        copy.delete(key.to_s)
      end
    end
    copy
  end

  # test_harness_run
  #
  # This method is a front-end for test_harness_common.
  # - Creates manifests
  # - Creates puppet resource title strings
  # - Cleans resource
  def test_harness_run(tests, id, harness_class: BaseHarness, skip_idempotence_check: false)
    return unless platform_supports_test(tests, id)
    logger.info("\n  * Process test_harness_run")
    tests[id][:ensure] = :present if tests[id][:ensure].nil?

    # Build the manifest for this test
    unless create_manifest_and_resource(tests, id, harness_class: harness_class)
      logger.error("\n#{tests[id][:desc]} :: #{id} :: SKIP")
      logger.error('No supported properties remain for this test.')
      return
    end

    resource_absent_cleanup(agent, tests[id][:preclean]) if
      tests[id][:preclean]

    # Check for additional pre-requisites
    harness_class.test_harness_dependencies(self, tests, id)

    test_harness_common(tests, id, harness_class: harness_class, skip_idempotence_check: skip_idempotence_check)
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

    logger.info('Process setup_mt_full_env')
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
      # Skip this step only when intf set to non-default port
    end if tests[:intf].nil? || tests[:intf].match('ethernet\d+/1$')

    interface_cleanup(agent, intf)

    config_switchport_mode(agent, intf, tests[:switchport_mode]) if
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

  # Given a configuration command (or array of commands), search the device
  # and remove any configs that match. Optionally include a show command filter.
  #
  # Example:
  #  config_find_remove(agent, 'interface loopback42')
  #  config_find_remove(agent, ['interface loopback42', 'feature foo'])
  #  config_find_remove(agent, ['feature foo', 'feature bar'], 'incl ^feature')
  #
  def config_find_remove(agent, find=[], filter='incl .*')
    find = [find] if find.is_a?(String)
    remove = []
    current = test_get(agent, filter)
    # a fresh VM instance does not seem to have
    # the filter in the running configuration,
    # possibly an existing test has configured it
    # and is only seen when running all the tests
    # to make the test work independently, returning
    # when there is no config for the filter
    return unless current
    find.each do |cfg|
      remove << "no #{cfg}" if current.match(Regexp.new("^#{cfg}"))
    end
    return if remove.empty?

    # Clean up all configs with one call
    logger.info(' * Remove existing config')
    test_set(agent, remove.join(' ; '))
  end

  # Helper method to create nxapi client connection object (agentless)
  def nxapi_test_client
    env = {
      host:     beaker_config_connection_address,
      port:     @nexus_host[:ssh][:port] || 80,
      username: @nexus_host[:ssh][:user],
      password: @nexus_host[:ssh][:password],
      cookie:   nil
    }
    Cisco::Environment.add_env('remote', env)
    Cisco::Client.create('remote')
  end

  # Helper method for nxapi client test_get (agentless)
  def nxapi_test_get(filter, is_a_running_config_command)
    filter.gsub!(/["']/, "'")
    filter = "show running-config all | #{filter}" if is_a_running_config_command
    test_client = nxapi_test_client
    test_client.get(data_format: :cli, command: filter)
  end

  # Get raw configuration from the device using command_config's test_get.
  # test_get does a 'show running-config all' but requires a filter.
  # Example:
  #  test_get(agent, 'incl ^vlan')
  #
  # opt = :raw, return raw output from puppet resource command
  # opt = :array, return array of test_get property data only
  def test_get(agent, filter, opt=:raw, is_a_running_config_command: true)
    if agent
      # need to triple escape any embedded quotes
      cmd = PUPPET_BINPATH + %(resource cisco_command_config 'cc' test_get='#{filter}')
      command = on(agent, cmd).output
    else
      command = nxapi_test_get(filter, is_a_running_config_command)
    end
    case opt
    when :raw
      return command
    when :array
      # clean up the output and return as array of commands
      # stdout: " cisco_command_config { 'cc':\n  test_get => '\n foo\n bar\n',\n}"
      # array:  [' foo', ' bar']
      command.split("\n")[2..-3] if command
    end
  end

  # Helper method for nxapi client test_set (agentless)
  def nxapi_test_set(cmd, ignore_errors: false)
    test_client = nxapi_test_client
    test_client.set(values: cmd)
  rescue Cisco::CliError => e
    # The cmd may generate an error on the switch that can be safely ignored.
    raise unless ignore_errors
    logger.info("nxapi_test_set: Cisco::CliError detected\n#{e}\nignore_errors: true")
    e.to_s
  end

  # Add arbitrary configurations using command_config's test_set property.
  # Example:
  #  test_set(agent, 'no feature foo ; no feature bar')
  def test_set(agent, cmd, ignore_errors: false)
    return if cmd.empty?
    logger.info(cmd)
    if agent
      cmd_prefix = PUPPET_BINPATH + "resource cisco_command_config 'cc' "
      on(agent, cmd_prefix + "test_set='#{cmd}'")
    else
      nxapi_test_set(cmd, ignore_errors: ignore_errors)
    end
  end

  # Check's whether the test's are being run on a non-default vdc and
  #   skip's them if they are.
  def skip_non_default_vdc(agent)
    # Return unless you are on a non-defaut vdc
    return unless platform[/n7/i] && non_default_vdc?(agent)
    msg = 'Skipping all tests; they cannot be run on a non default VDC'
    banner = '#' * msg.length
    raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self)
  end

  # Returns `True` if the agent you are accessing is a non-default VDC
  def non_default_vdc?(agent)
    cmd = 'show vdc'
    result = command_config(agent, cmd)
    # The command show vdc returns information on all current vdcs in a set format
    # When on the default vdc all current vdcs will be shown, if on a non-default vdc
    #   only the current vdc will be shown.
    result.split(/\n+/).each do |line|
      # This checks the vdc ID, if it is `1` then it is the default vdc
      return false if line[0] == '1'
    end

    true
  end

  # Helper for command_config calls
  def command_config(agent, cmd, msg='', ignore_errors: false)
    logger.info("\n#{msg}")
    if agent
      cmd = "resource cisco_command_config 'cc' command='#{cmd}'"
      cmd = PUPPET_BINPATH + cmd
      on(agent, cmd, acceptable_exit_codes: [0, 2])
    else
      nxapi_test_set(cmd, ignore_errors: ignore_errors)
    end
  end

  # Helper to set properties using the puppet resource command.
  def resource_set(_agent, resource, msg='')
    logger.info("\nresource_set: #{msg}")
    if resource.is_a?(Array)
      type = resource[0]
      title = resource[1]
      property = resource[2]
      value = resource[3]
    else
      type = resource[:name]
      title = resource[:title]
      property = resource[:property]
      value = resource[:value]
    end
    create_and_apply_test_manifest(type, title, property, value)
  end

  # Helper to raise skip when prereqs are not met
  def prereq_skip(testheader, testcase, message)
    testheader = '' if testheader.nil?
    logger.error("** PLATFORM PREREQUISITE NOT MET: #{message}")
    raise_skip_exception(testheader, testcase)
  end

  # Some vxlan_vtep attrs reject if the TCAM has not allocated resources for
  # arp-ether acl (ie. it is set to 0). A config change will fix this but that
  # requires a reboot so normally just skip attrs that have this dependency.
  # Return true if arp-ether is 0.
  # To manually config this dependency:
  #   hardware access-list tcam region vacl 0         # free resources from vacl
  #   hardware access-list tcam region arp-ether 256  # allocate to arp-ether
  def tcam_arp_ether_acl_is_0(agent)
    logger.info('Check TCAM arp-ether acl dependency')
    filter = 'incl tcam.region.arp-ether.0$'
    out = test_get(agent, filter)
    out && out[/tcam region arp-ether 0/] ? true : false
  end

  # Some specific platform models do not support nv_overlay
  def skip_if_nv_overlay_rejected(agent)
    logger.info('Check for nv overlay support')
    cmd = 'feature nv overlay'
    out = test_set(agent, cmd, ignore_errors: true)
    return unless out[/NVE Feature NOT supported/]

    # Failure message taken from 6001
    msg = 'NVE Feature NOT supported on this Platform'
    banner = '#' * msg.length
    raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self) if
      out.match(msg)
  end

  # Return an interface name from the first MT-full compatible line module found
  def mt_full_interface
    # Search for F3 card on device, create an interface name if found
    pattern = %r{^(\d+)\s.*N7[K7]-F3}
    cmd = 'sh mod'
    if agent
      out = on(agent, get_vshell_cmd(cmd), pty: true).stdout[pattern]
    else
      out = nxapi_test_get(cmd, false)[pattern]
    end
    slot = out.nil? ? nil : Regexp.last_match[1]
    return nil unless slot

    # Use an existing member intf if possible; default to port 1 if not.
    intf = vdc_module_intf_members(default_vdc_name, slot)
    return intf.downcase unless intf.nil?
    "ethernet#{slot}/1"
  end

  # Return vdc membership interfaces for given module
  # Default: return only the first interface unless all_members is true.
  def vdc_module_intf_members(vdc, mod, all_members: false)
    cmd = "show vdc #{vdc} membership module #{mod} | incl Ethernet"
    if agent
      out = on(agent, get_vshell_cmd(cmd), pty: true).stdout
    else
      out = nxapi_test_get(cmd, false)
    end
    return nil unless out
    return out.split if all_members
    out.split[0]
  end

  # TBD: Used for vPC+ only
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
    cmd = 'show run vdc'
    pattern = %r{^vdc (\S+) id 1$}
    if agent
      out = on(agent, get_vshell_cmd(cmd), pty: true).stdout[pattern]
    else
      out = nxapi_test_get(cmd, false)[pattern]
    end
    out.nil? ? nil : Regexp.last_match[1]
  end

  # Check for presence of limit-resource module-type
  # The lookup is a loose match by default but some features like 'vni' are
  # required to use a specific set of modules only, in which case specify
  # ':exact' for a strict match of the current modules.
  def limit_resource_module_type_get(vdc, mod, match=nil)
    if match == :exact
      # Must be this list of modules only
      pat = Regexp.new("vdc supported linecards: (#{mod})")
    else
      # Just make sure module type is in list
      pat = Regexp.new("vdc supported linecards:.*(#{mod})")
    end
    cmd = "sh vdc #{vdc} detail"
    if agent
      out = on(agent, get_vshell_cmd(cmd), pty: true).stdout.match(pat)
    else
      out = nxapi_test_get(cmd, false).match(pat)
    end
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
    cmd = "sh vdc #{vdc} membership"
    if agent
      out = on(agent, get_vshell_cmd(cmd), pty: true).stdout
    else
      out = nxapi_test_get(cmd, false)
    end
    out.match(Regexp.new(intf_pat, Regexp::IGNORECASE))
    out.nil? ? nil : Regexp.last_match[1]
  end

  # Add interface to vdc's allocated interfaces
  def vdc_allocate_interface_set(vdc, intf)
    # Turn off prompting
    tdap = 'terminal dont-ask persist'
    cmd = "conf t ; vdc #{vdc} ; allocate interface #{intf}"
    if agent
      on(agent, get_vshell_cmd(tdap), pty: true)
      on(agent, get_vshell_cmd(cmd), pty: true)
      on(agent, get_vshell_cmd('no ' + tdap), pty: true)
    else
      nxapi_test_set(tdap, false)
      nxapi_test_set(cmd, false)
      nxapi_test_set('no ' + tdap, false)
    end
  end

  # VDC post-test cleanup
  def teardown_vdc
    return if mt_full_interface

    # Testbeds without F3 cards should be set back to their default state;
    # failure to do so will leave the testbed without usable interfaces.
    # Assume that F3 testbeds should be left with module-type set to F3.
    logger.info("\n* Teardown VDC: Reset limit-resource module-type")
    limit_resource_module_type_set(default_vdc_name, nil)
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
    if agent
      @cisco_os = on(agent, facter_cmd('os.name')).stdout.chomp
    else
      output = `#{agentless_command} --facts | grep operatingsystem`
      @cisco_os = output.match(%r{"operatingsystem": "(.*)"})[1]
    end
    @cisco_os
  end

  @os_family = nil
  def os_family
    return @os_family unless @os_family.nil?
    @os_family = on(agent, facter_cmd('os.family')).stdout.chomp
  end

  @virtual = nil
  def virtual
    return @virtual unless @virtual.nil?
    @virtual = on(agent, facter_cmd('virtual')).stdout.chomp
  end

  @system_manager = nil
  def system_manager
    return @system_manager unless @system_manager.nil?
    system_manager = on(agent, 'ls -l /proc/1/exe').stdout.chomp
    # On NXOS hosting environments use different system_managers
    # 1) Native bash-shell uses init
    # 2) GuestShell uses systemd
    # 3) OAC uses redhat
    if system_manager[/systemd/]
      @system_manager = 'systemd'
    elsif platform[/n5k|n6k|n7k/]
      @system_manager = 'redhat'
    else
      @system_manager = 'init'
    end
    @system_manager
  end

  # Used to cache the cisco hardware type
  @cisco_hardware = nil
  # Use facter to return cisco hardware type
  def platform
    return @cisco_hardware unless @cisco_hardware.nil?
    if agent
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
    else
      output = `#{agentless_command} --facts | grep type`
      pi = output.nil? ? '' : output.match(%r{"type": "(.*)"})[1]
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
      @cisco_hardware = fretta? ? 'n3k-f' : 'n3k'
    when /Nexus\s?5\d\d\d/
      @cisco_hardware = 'n5k'
    when /Nexus\s?6\d\d\d/
      @cisco_hardware = 'n6k'
    when /Nexus\s?7\d\d\d/
      @cisco_hardware = 'n7k'
    when /Nexus\s?9\d+\s\S+-EX/
      @cisco_hardware = 'n9k-ex'
    when /(Nexus\s?9\d\d\d|NX-OSv Chassis)/
      @cisco_hardware = fretta? ? 'n9k-f' : 'n9k'
    when /XRv9K/i
      @cisco_hardware = 'xrv9k'
    else
      fail "Unrecognized platform type: #{pi}\n"
    end
    logger.info "\nFound Platform string: '#{pi}', Alias to: '#{@cisco_hardware}'"
    @cisco_hardware
  end

  # fretta check
  @fretta_slot = nil
  def fretta?(reset_cache=false)
    return @fretta_slot unless @fretta_slot.nil? || reset_cache
    if agent
      data = on(agent, facter_cmd('-p cisco.inventory')).output.split("\n")
    else
      data = `#{agentless_command} --facts`
      inventory_facts = data.match(%r{inventory.*(\n.*)*?(?=virtual_service)})
      data = inventory_facts.to_s.split("\n")
    end
    @fretta_slot = false
    data.each do |line|
      next unless line.include?('pid =>')
      @fretta_slot = true if line[/-R/]
    end
    @fretta_slot
  end

  @image = nil # Cache the lookup result
  def nexus_image
    image_regexp = /(\S+)/
    if agent
      data = on(agent, facter_cmd('-p cisco.images.full_version')).output
    else
      output = `#{agentless_command} --facts | grep full_version`
      data = output.nil? ? '' : output.match(%r{"full_version": "(.*)"})[1]
    end
    darr = data.split("\n")
    darr.each do |line|
      next if line.include?('stty') || line.include?('WARN')
      data = line
    end
    @image ||= image_regexp.match(data)[1]
  end

  @hostname = nil # Cache the lookup result
  def hostname
    if agent
      data = test_get(agent, 'inc ^hostname')
      data = data.nil? ? '' : data.match(/hostname (\S+)/)[1].gsub(/\\n\",/, '')
    else
      output = `#{agentless_command} --facts | grep hostname`
      data = output.nil? ? '' : output.match(%r{"hostname": "(.*)"})[1]
    end
    @hostname ||= data
  end

  # Gets the version of the image running on a device
  # same as full_version - so might not be required anymore
  # as full_version supports dual mode.
  @version = nil
  def image_version
    facter_opt = '-p os.release.full'
    data = on(agent, facter_cmd(facter_opt)).stdout.chomp
    @version ||= data
  end

  # Gets the full version of the image running on a device
  @full_ver = nil
  def full_version
    return @full_ver unless @full_ver.nil?
    if agent
      facter_opt = '-p cisco.images.full_version'
      data = on(agent, facter_cmd(facter_opt)).stdout.chomp
    else
      full_version_output = `#{agentless_command} --facts | grep full_version`
      data = full_version_output.nil? ? '' : full_version_output.match(%r{"full_version": "(.*)"})[1]
    end
    @full_ver ||= data
  end

  # Check if image matches pattern
  @cached_img = nil
  def image?(reset_cache=false)
    return @cached_img unless @cached_img.nil? || reset_cache
    @cached_img = full_version
  end

  # Gets the package version running on a device
  @package_info = nil
  def package
    if agent
      facter_opt = '-p cisco.images.system_image'
      data = on(agent, facter_cmd(facter_opt)).stdout.chomp
    else
      output = `#{agentless_command} --facts | grep system_image`
      data = output.nil? ? '' : output.match(%r{"system_image": "(.*)"})[1]
    end
    @package_info ||= data.chomp
  end

  # On match will skip all testcases
  # Do not use this for skipping individual properties.
  def skip_nexus_image(image, tests)
    return unless nexus_image.match(Regexp.union(image))
    msg = "Skipping all tests; '#{tests[:resource_name]}' "\
          "is not supported on #{image} images"
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
      unless agent.nil?
        platform
      end

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
    agent_only = tests[:agent_only] | false
    if agent_only && agent.nil?
      msg = "Skipping all tests; '#{tests[:resource_name]}' "\
          '(or test file) is not supported agentlessly'
      banner = '#' * msg.length
      raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self)
    end
    return false if pattern.nil? || platform.match(tests[:platform])
    msg = "Skipping all tests; '#{tests[:resource_name]}' "\
          '(or test file) is not supported on this node'
    banner = '#' * msg.length
    raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self)
  end

  # This is a simple top-level skip similar to what exists in the minitests.
  # Callers will skip all tests when true.
  # tests[:proxy_agent] - if the proxy_agent is present
  # tests[:resource_name] - provider name (e.g. 'cisco_vxlan_vtep')
  def skip_unless_proxy_agent(tests)
    msg = "Skipping all tests; '#{tests[:resource_name]}' "\
        '(or test file) is not supported without a proxy agent'
    banner = '#' * msg.length
    raise_skip_exception("\n#{banner}\n#{msg}\n#{banner}\n", self) unless proxy_agent
  end

  def skipped_tests_summary(tests)
    return unless tests[:skipped]
    logger.info("\n#{'-' * 60}\n  SKIPPED TESTS SUMMARY\n#{'-' * 60}")
    tests[:skipped].each do |desc|
      logger.error(sprintf('%-40s :: SKIP', desc))
    end
    # There are many tests now that skip a sub-test or two while the majority
    # are still processed. We prefer to see the overall result as Pass instead
    # of skip so skip the raise below.
    # raise_skip_exception(tests[:resource_name], self)
  end

  # TBD: This needs to be more selective when used with modular platforms,
  # particularly to ignore L2-only F2 cards on N7k.
  # TBD: Remove the :intf_type requirement & change this to find_ethernet()
  #
  # Find a test interface on the agent.
  # Callers should include the following hash keys:
  #   [:agent]
  #   [:intf_type]
  #   [:resource_name]
  def find_interface(tests, id=nil, skipcheck=true)
    logger.info("\n#{'-' * 60}\n  Find a suitable interface\n#{'-' * 60}")
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

    when /mgmt/i
      all = get_current_resource_instances(tests[:agent], 'network_interface')
      # TODO: check the interface IP address like we do in node_utils
      intf = all.grep(/mgmt\d+$/)[0]
    end

    if skipcheck && intf.nil?
      msg = 'Unable to find suitable interface module for this test.'
      prereq_skip(tests[:resource_name], self, msg)
    end
    logger.info("\n  * Found #{intf}")
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
    when /all/
      array = get_current_resource_instances(tests[:agent], 'cisco_interface')

    when /ethernet/i, /dot1q/
      all = get_current_resource_instances(tests[:agent], 'cisco_interface')
      # TODO: check the interface IP address like we do in node_utils
      array = all.grep(%r{ethernet\d+/\d+})
    end

    if skipcheck && array.nil? && array.empty?
      msg = 'Unable to find suitable interface module for this test.'
      prereq_skip(tests[:resource_name], self, msg)
    end
    msg = "find_interface_array found: #{array.length} interfaces"
    logger.info("\n#{'-' * 60}\n#{msg}\n#{'-' * 60}")
    array
  end

  # Use puppet resource to get interface capability information.
  # TBD: Facter may be a better home for this method but the performance hit
  # appears to be 2s per hundred interfaces so it works better for now as an
  # on-demand method.
  def interface_capabilities(agent, intf)
    if agent
      cmd = PUPPET_BINPATH + "resource cisco_interface_capabilities '#{intf}'"
      output = on(agent, cmd, pty: true).stdout
    else
      output = `#{agentless_command} --resource cisco_interface_capabilities '#{intf}'`
    end

    # Sample raw output:
    # "cisco_interface_capabilities { 'ethernet9/1':\n  capabilities =>
    # ['Model: N7K-F312FQ-25', '', 'Type (SFP capable):    QSFP-40G-4SFP10G', '',
    # 'Speed: 10000,40000', '', 'Duplex: full', ''], }

    str = output[/\[(.*)\]/]
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
      v.gsub!(%r{half/full}, 'half,full') if k[/Duplex/]
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

  def create_and_apply_test_manifest(type, title, property, value)
    temp_manifest = Tempfile.new('temp_manifest')
    unless value.match(/^(\d)+$/)
      value = "'#{value}'"
    end
    temp_manifest.write("#{type} { '#{title}':
                               #{property.to_s.downcase} => #{value},
                             }\n")
    temp_manifest.rewind

    if agent
      on(agent, puppet_resource_cmd(type, title, property, value), acceptable_exit_codes: [0, 1, 2])
    else
      output = `#{agentless_command} --apply #{temp_manifest.path} 2>&1`
    end

    remove_temp_manifest(temp_manifest)
    output
  end

  def create_and_apply_generic_manifest(manifest, code=[2])
    # This method is similar to create_and_apply_test_manifest but
    # whereas that method restricts usage to a single resource,
    # this method allows caller to provide a raw manifest.
    if agent
      manifest = "cat <<EOF >#{PUPPETMASTER_MANIFESTPATH}
                 \nnode default {\n#{manifest} }\nEOF"
      on(master, manifest)
      on(agent, puppet_agent_cmd, acceptable_exit_codes: code)
      output = stdout
    else
      temp_manifest = Tempfile.new('temp_manifest')
      temp_manifest.write(manifest)
      temp_manifest.rewind
      output = `#{agentless_command} --apply #{temp_manifest.path} 2>&1`
      remove_temp_manifest(temp_manifest)
    end
    output
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
    test_agent = tests[:agent]

    # Use tests[:probe] if caller does not supply a separate probe hash
    probe = tests[:probe] if probe.empty?
    fail 'interface_probe: probe hash not found' if probe.nil?

    # Find a usable interface
    probe[:intf] = find_interface(tests) if probe[:intf].nil?
    intf = probe[:intf]
    fail 'interface_probe: interface not found' if intf.nil?

    # Create the puppet resource command syntax
    fail 'interface_probe: resource command not found' if probe[:cmd].nil?

    if test_agent
      cmd = probe[:cmd] + " '#{intf}' "
    else
      cmd = "#{agentless_command} #{probe[:cmd].match(%r{.*\/puppet (.*)})} #{intf}"
    end

    # Get the interface capabilities
    probe[:caps] = interface_capabilities(test_agent, intf) if probe[:caps].nil?
    fail 'interface_probe: capabilities data not present' if probe[:caps].nil?

    debug_probe(probe, 'Probe Begin')
    probe[:probe_props].each do |prop|
      success = []
      probe[:caps][prop].to_s.split(',').each do |val|
        val = netdev_speed(val) if prop[/Speed/] && probe[:netdev_speed]
        if test_agent
          output = on(test_agent, cmd + "#{prop}=#{val}", acceptable_exit_codes: [0, 2, 1], pty: true).stdout
        else
          output = create_and_apply_test_manifest(probe[:cmd].match(%r{.*\/puppet resource (.*) })[1], intf, prop, val)
        end
        next if output[/error/i]
        if val.match(/^(\d)+$/)
          val = val.to_i
        end
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

  # Remove a single dynamic interface (Vlan, Loopback, Port-channel, etc).
  def remove_interface(agent, intf)
    logger.info('remove_interface')
    cmd = "    no interface #{intf.capitalize}"
    command_config(agent, cmd, cmd, ignore_errors: true)
  end

  # nxapi_probe (agentless)
  # This method is used within the resource_probe method for agentless
  # workflows.  The resource command cannot be used to set values on the
  # device in this context.
  def nxapi_probe(cmd)
    test_client = nxapi_test_client
    out = test_client.set(values: cmd)
    out.to_s
  rescue Cisco::CliError => e
    e.to_s
  end

  # Issue a command on the agent and check stdout for a pattern.
  # Useful for checking if hardware supports properties, etc.
  def resource_probe(agent, cmd, pattern)
    logger.info("--\nResource Probe: cmd: " + cmd)
    if agent
      out = on(agent, PUPPET_BINPATH + 'resource ' + cmd, acceptable_exit_codes: [0, 2, 1], pty: true).stdout
    else
      out = nxapi_probe(cmd)
    end
    logger.info('Resource Probe: out: ' + out)
    out.match(pattern) ? true : false
  end

  # Wrapper for common resource probes
  def resource_probe_named(agent, type)
    case type
    when :nve
      pattern = 'NVE Feature NOT supported on this Platform'
      cmd = 'feature nv overlay'
    end
    resource_probe(agent, cmd, pattern)
  end

  def vdc_limit_f3_no_intf_needed(action=:set)
    # This is a special-use method for N7Ks that don't have a physical F3.
    #  1) There are some features that refuse to load unless the VDC is
    #     limited to F3 only, but they will actually load if the config is
    #     present, despite the fact that there are no physical F3s.
    #  2) We have some tests that need these features but don't need interfaces.
    #
    # action = :set (enable limit F3 config), :clear (default limit config)
    #
    # The limit config should be removed after testing if the device does not
    # have an actual F3.
    return unless platform[/n7k/]
    logger.info('vdc_limit_f3_no_intf_needed')
    case action
    when :set
      #  limit_resource_module_type => 'f3',
      if agent
        cmd = PUPPET_BINPATH + "resource cisco_vdc '#{default_vdc_name}' "
        out = on(agent, cmd, pty: true).stdout[/limit_resource.*'(f3)'/]
        mods = out.nil? ? nil : Regexp.last_match[1]
        return if mods == 'f3'
        cmd += "limit_resource_module_type='f3'"
        logger.info("\n* Setup VDC: #{cmd}")
        on(agent, cmd, pty: true).stdout[/limit_resource.*'(f3)'/]
      else
        cmd = "#{agentless_command} --resource cisco_vdc '#{default_vdc_name}' "
        out = `#{cmd}`[/limit_resource.*(f3)/]
        mods = out.nil? ? nil : Regexp.last_match[1]
        return if mods == 'f3'
        cfg = "terminal dont-ask ; vdc #{default_vdc_name} ; limit-resource module-type f3"
        nxapi_test_set(cfg, ignore_errors: false)
        `#{cmd}`[/limit_resource.*(f3)/]
      end
    when :clear
      # Reset to default only if no physical F3 is present
      teardown_vdc
    end
  end

  def remove_all_vlans(agent, stepinfo='Remove all vlans & bridge-domains')
    # TBD: Modify this cleanup to use faster test_get / test_set:
    #  test_get('i ^vlan|^bridge')
    #  test_set('no vlan <range> ; no bridge <range> ; system bridge-domain none')
    logger.info('remove_all_vlans')
    step "\n--------\n * TestStep :: #{stepinfo}" do
      resource_absent_cleanup(agent, 'cisco_bridge_domain', 'bridge domains')
      # bridge_domain feature is available only on n7k
      command_config(agent, 'system bridge-domain none', 'system bridge-domain none',
                     ignore_errors: true) if platform == 'n7k'
      test_set(agent, 'no feature interface-vlan')
      test_set(agent, 'no feature private-vlan')
      test_set(agent, 'no vlan 2-3967', ignore_errors: true)
    end
  end

  def remove_all_vrfs(agent)
    # The output of test_get has changed in Puppet5 and newer versions of Puppet.
    # Old output:
    # cisco_command_config { 'cc':
    #   test_get => '
    # vrf context blue
    # ',
    # }
    # New output:
    # cisco_command_config { 'cc':
    #   test_get => "\nvrf context blue\n",
    # }
    logger.info('remove_all_vrfs')
    # The following logic handles both output styles.
    found = test_get(agent, 'incl vrf.context | excl management')
    return if found.nil?
    found.gsub!(/\\n/, ' ')
    vrfs = found.scan(/(vrf context \S+)/)
    return if vrfs.empty?
    vrfs.flatten!.map! { |cmd| "no #{cmd}" if cmd[/^?\n?vrf context/] }
    test_set(agent, vrfs.compact.join(' ; '))
  end

  # Return yum patch version from host
  def get_patch_version(name)
    cmd = get_vshell_cmd("show install packages | inc #{name}")
    # Sample Output:
    # nxos.sample-n9k_EOR.lib32_n9000   1.0.0-7.0.3.I5.1    @patching
    out = on(agent, cmd, pty: true).stdout[/\S+\s+(\S+).*@patching/]
    out.nil? ? nil : Regexp.last_match[1]
  end

  # Test yum version
  def test_patch_version(tests, id, name, ver)
    stepinfo = format_stepinfo(tests, id, 'YUM PACKAGE VERSION')
    step "TestStep :: #{stepinfo}" do
      logger.debug("test_yum_version :: #{ver}")
      iv = get_patch_version(name)
      if iv == ver
        logger.info("#{stepinfo} :: PASS")
      else
        msg = "Installed version: #{iv}, does not match expected ver: #{ver}"
        fail_test("TestStep :: #{msg} :: FAIL")
      end
    end
  end

  # Add double quotes to string.
  #
  # Helper method to add a double quote to the beginning
  # and end of a string.
  #
  # Nxapi adds an escape character to config lines that
  # nvgen in this way in some but not all nxos releases.
  #
  # Input: String (Example 'foo')
  # Returns: String with double quotes: (Example: '"foo"'
  #
  def add_quotes(string)
    return string if image?[/7.3/]
    string = "\"#{string}\""
    string
  end
end
