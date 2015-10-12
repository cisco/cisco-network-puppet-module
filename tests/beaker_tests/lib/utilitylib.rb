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
# Every Beaker test script that runs an instance of TestCase requires
# UtilityLib module.
#
# The module has 4 sets of methods:
# A. Methods to get VRF namespace specific command strings and VSH command
# strings from basic command strings.
# B. Method to define PUPPETMASTER_MANIFESTPATH constant using puppet
# config command output on puppet master.
# C. Method to search for RegExp patterns in command execution output and
# raise fail_test exceptions for failed pattern matches in the output.
# D. Method to raise pass_test or fail_test exception based on testcase
# result.
module UtilityLib
  # Group of constants for use by the Beaker::TestCase instances.
  # Sleep time of 10 seconds to release any pending puppet agent locks.
  SLEEP_WAIT_TIME = 10
  # Binary executable path for puppet on master and agent.
  PUPPET_BINPATH = '/opt/puppetlabs/bin/puppet '

  # A. Methods to get VRF namespace specific command strings and VSH command
  # strings from basic command strings.

  # Method to return the VRF namespace specific command string from basic
  # command string. VRF is declared in hosts.cfg.
  # @param host [String] Host on which to act upon.
  # @param cmdstr [String] The command string to execute on host.
  # @param options [Hash] Options hash literal to get configured VRF.
  # @result namespacestr [String] Returns 'sudo ip netns exec vrf <cmd>'
  # command string for 'cisco' platform.
  def self.get_namespace_cmd(host, cmdstr, options)
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
  def self.get_vshell_cmd(nxosclistr)
    "/isan/bin/vsh -c '#{nxosclistr}'"
  end

  # B. Method to define PUPPETMASTER_MANIFESTPATH constant using puppet
  # config command output on puppet master.

  # Method to define PUPPETMASTER_MANIFESTPATH constant using puppet config
  # command.
  # @param host [String] Host on which to act upon.
  # @param testcase [TestCase] An instance of Beaker::TestCase.
  # @result none [None] Returns no object.
  def self.set_manifest_path(host, testcase)
    unless UtilityLib.const_defined?(:PUPPETMASTER_MANIFESTPATH)
      # Expected exit_code is 0 since this is puppet config cmd with no change.
      cmd_str = UtilityLib::PUPPET_BINPATH + 'config print manifest'
      testcase.on(host, cmd_str) do
        UtilityLib.const_set(:PUPPETMASTER_MANIFESTPATH, \
                             testcase.stdout.strip + '/site.pp')
      end
    end
  end

  # C. Method to search for RegExp patterns in command execution output and
  # raise fail_test exceptions for failed pattern matches in the output.

  # Method to parse a Hash literal into an array of RegExp literals.
  # @param hash [hash] Comma-separated list of key/value pairs.
  # @result regexparr [Array] Array of RegExp literals.
  def self.hash_to_patterns(hash)
    regexparr = []
    hash.each do |key, value|
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
  def self.search_pattern_in_output(output, patarr, inverse, testcase,\
    logger)
    patarr = UtilityLib.hash_to_patterns(patarr) if patarr.instance_of?(Hash)
    patarr.each do |pattern|
      inverse ? (match = (output !~ pattern)) : (match = (output =~ pattern))
      (match) ? logger.debug("TestStep :: Match #{pattern} :: PASS") : testcase.fail_test("TestStep :: Match #{pattern} :: FAIL")
    end
  end

  # D. Method to raise pass_test or fail_test exception based on testcase
  # result.

  # Method to raise and handle Beaker::DSL::Outcomes::PassTest or
  # Beaker::DSL::Outcomes::FailTest exception based on testresult value.
  # @param testresult [String] String object set to 'PASS' or 'FAIL'.
  # @param message [String] String object to represent testcase.
  # @param testcase [TestCase] An instance of Beaker::TestCase.
  # @param logger [Logger] A default instance of Beaker::Logger.
  # @result none [None] Returns no object.
  def self.raise_passfail_exception(testresult, message, testcase, logger)
    (testresult == 'PASS') ? testcase.pass_test("\nTestCase :: #{message} :: PASS") : testcase.fail_test("\nTestCase :: #{message} :: FAIL")
  rescue Beaker::DSL::Outcomes::PassTest
    logger.success("TestCase :: #{message} :: PASS")
  rescue Beaker::DSL::Outcomes::FailTest
    logger.error("TestCase :: #{message} :: FAIL")
  end
end

### TBD: The helper methods below live outside the module for now,
###      until we solve the 'step' and 'on' references.

# Full command string for puppet agent
def puppet_agent_cmd
  cmd = UtilityLib::PUPPET_BINPATH + 'agent -t'
  UtilityLib.get_namespace_cmd(agent, cmd, options)
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
      UtilityLib.search_pattern_in_output(stdout, tests[id][:resource],
                                          false, self, logger)
    end
    logger.info("#{stepinfo} :: PASS")
    tests[id].delete(:log_desc)
  end
end

# Wrapper for config pattern-match tests
def test_show_cmd(tests, id, state=false)
  stepinfo = format_stepinfo(tests, id, 'SHOW CMD')
  show_cmd = UtilityLib.get_vshell_cmd(tests[:show_cmd])
  step "TestStep :: #{stepinfo}" do
    logger.debug('test_show_cmd :: BEGIN')
    on(tests[:agent], show_cmd) do
      logger.debug("test_show_cmd :: cmd:\n#{show_cmd}")
      logger.debug("test_show_cmd :: pattern:\n#{tests[id][:show_pattern]}")
      UtilityLib.search_pattern_in_output(stdout, tests[id][:show_pattern],
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

# Method to clean up a feature on the test node
# @param agent [String] the agent that is going to run the test
# @param feature [String] the feature name that will be cleaned up
def node_feature_cleanup(agent, feature, stepinfo='feature cleanup',
                         enable=true)
  step "TestStep :: #{stepinfo}" do
    logger.debug("#{stepinfo} disable feature")
    clean = UtilityLib.get_vshell_cmd("conf t ; no feature #{feature}")
    on(agent, clean, acceptable_exit_codes: [0, 2])
    show_cmd = UtilityLib.get_vshell_cmd('show running-config section feature')
    on(agent, show_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/feature #{feature}/],
                                          true, self, logger)
    end

    return unless enable
    logger.debug("#{stepinfo} re-enable feature")
    clean = UtilityLib.get_vshell_cmd("conf t ; feature #{feature}")
    on(agent, clean, acceptable_exit_codes: [0, 2])
    show_cmd = UtilityLib.get_vshell_cmd('show running-config section feature')
    on(agent, show_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/feature #{feature}/],
                                          false, self, logger)
    end
  end
end

# bgp neighbor remote-as configuration helper
def bgp_nbr_remote_as(agent, remote_as)
  asn, vrf, nbr, remote = remote_as.split
  vrf = (vrf == 'default') ? '' : "vrf #{vrf}"
  cfg_str = "conf t ; router bgp #{asn} ; #{vrf} ; " \
            "neighbor #{nbr} ; remote-as #{remote}"
  on(agent, UtilityLib.get_vshell_cmd(cfg_str))
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
