###############################################################################
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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
PUPPETMASTER_MANIFESTPATH = '/etc/puppetlabs/code/environments/production/manifests/site.pp'

# The remaining methods are defined outside of the UtilityLib module so that
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

# Full command string for puppet agent
def puppet_agent_cmd
  cmd = PUPPET_BINPATH + 'agent -t'
  get_namespace_cmd(agent, cmd, options)
end

# Auto generation of properties for manifests
# attributes: hash of property names and values
# return: a manifest friendly string of property names / values
def prop_hash_to_manifest(attributes)
  manifest_str = ''
  attributes.each do |k, v|
    next if v.nil?
    if v.is_a?(String)
      manifest_str += "       #{k} => '#{v.strip}',\n"
    else
      manifest_str += "       #{k} => #{v},\n"
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
  cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
      "resource #{res_name}", options)
  on(agent, cmd_str, acceptable_exit_codes: [0])
  names = stdout.scan(/#{res_name} { '(.+)':/).flatten
  names
end

# Method to clean by putting a resource in absent state
# @param agent [String] the agent that is going to run the test
# @param res_name [String] the resource name that will be cleaned up
def resource_absent_cleanup(agent, res_name, stepinfo='absent clean')
  # Don't forget to UtilityLib.set_manifest_path(master, self)
  step "TestStep :: #{stepinfo}" do
    # set each resource to ensure=absent
    get_current_resource_instances(agent, res_name).each do |title|
      cmd_str = UtilityLib.get_namespace_cmd(agent, UtilityLib::PUPPET_BINPATH +
        "resource #{res_name} '#{title}' ensure=absent", options)
      on(agent, cmd_str, acceptable_exit_codes: [0])
    end
  end
end

# Method to clean up a feature on the test node
# @param agent [String] the agent that is going to run the test
# @param feature [String] the feature name that will be cleaned up
def node_feature_cleanup(agent, feature, stepinfo='feature cleanup',
                         enable=true)
  step "TestStep :: #{stepinfo}" do
    logger.debug("#{stepinfo} disable feature")
    clean = get_vshell_cmd("conf t ; no feature #{feature}")
    on(agent, clean, acceptable_exit_codes: [0, 2])
    show_cmd = get_vshell_cmd('show running-config section feature')
    on(agent, show_cmd) do
      search_pattern_in_output(stdout, [/feature #{feature}/],
                               true, self, logger)
    end

    return unless enable
    logger.debug("#{stepinfo} re-enable feature")
    clean = get_vshell_cmd("conf t ; feature #{feature}")
    on(agent, clean, acceptable_exit_codes: [0, 2])
    show_cmd = get_vshell_cmd('show running-config section feature')
    on(agent, show_cmd) do
      search_pattern_in_output(stdout, [/feature #{feature}/],
                               false, self, logger)
    end
  end
end

# Helper to remove all IP address configs from interfaces
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

# If a [:title] exists merge it with the [:af] values to create a complete af.
def bgp_title_pattern_munge(tests, id, provider=nil)
  title = tests[id][:title_pattern]
  af = tests[id][:af]

  if title.nil?
    puts 'no title'
    return af
  end

  tests[id][:af] = {} if af.nil?
  t = {}

  case provider
  when 'bgp_af'
    t[:asn], t[:vrf], t[:afi], t[:safi] = title.split
  when 'bgp_neighbor_af'
    t[:asn], t[:vrf], t[:neighbor], t[:afi], t[:safi] = title.split
  end
  t.merge!(tests[id][:af])
  t[:vrf] = 'default' if t[:vrf].nil?
  t
end
