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
###############################################################################

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
    regexparr = Array[]
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
      (match) ? logger.debug("TestStep :: Match #{pattern} :: PASS") \
        : testcase.fail_test("TestStep :: Match #{pattern} :: FAIL")
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
    (testresult == 'PASS') \
      ? testcase.pass_test("\nTestCase :: #{message} :: PASS") \
      : testcase.fail_test("\nTestCase :: #{message} :: FAIL")
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

# Wrapper for manifest tests
# Pass code = [0], to test idempotence
# Alternative to 'test_idempotence'
def test_manifest(master, agent, manifest, stepinfo = nil, code = [2])
  stepinfo = 'Manifest Test: ' + stepinfo
  step "TestStep :: #{stepinfo}" do
    on(master, manifest)
    on(agent, puppet_agent_cmd, :acceptable_exit_codes => code)
    logger.info("#{stepinfo} :: PASS")
  end
end

# Wrapper for 'puppet resource' command tests
def test_resource(agent, puppet_cmd, exp, stepinfo)
  stepinfo = 'Puppet Resource Test: ' + stepinfo
  step "TestStep :: #{stepinfo}" do
    on(agent, puppet_cmd) do
      UtilityLib.search_pattern_in_output(stdout, exp, false, self, logger)
    end
    logger.info("#{stepinfo} :: PASS")
  end
end

# Wrapper for config pattern-match tests
def test_show_run(agent, show_cmd, pattern, stepinfo, absent = false)
  stepinfo = 'Agent Show Test: ' + stepinfo
  show_run_bgp = UtilityLib.get_vshell_cmd(show_cmd)
  step "TestStep :: #{stepinfo}" do
    on(agent, show_run_bgp) do
      UtilityLib.search_pattern_in_output(stdout, pattern, absent, self, logger)
    end
    logger.info("#{stepinfo} :: PASS")
  end
end

# Wrapper for idempotency tests
def test_idempotence(agent, stepinfo)
  stepinfo = 'Idempotence Test: ' + stepinfo
  step "TestStep :: #{stepinfo}" do
    on(agent, puppet_agent_cmd, :acceptable_exit_codes => [0])
    logger.info("#{stepinfo} :: PASS")
  end
end

# Wrapper for absent tests
def test_absent(master, agent, manifest, stepinfo = nil)
  stepinfo = 'Absent Test: ' + stepinfo
  step "TestStep :: #{stepinfo}" do
    on(master, manifest)
    on(agent, puppet_agent_cmd, :acceptable_exit_codes => [2])
    logger.info("#{stepinfo} :: PASS")
  end
end

# Common BGP cleanup
def node_cleanup_bgp(agent, stepinfo)
  step "TestStep :: #{stepinfo}" do
    clean = UtilityLib.get_vshell_cmd('conf t ; no feature bgp')
    on(agent, clean, :acceptable_exit_codes => [0, 2])
    show_cmd = UtilityLib.get_vshell_cmd('show running-config section bgp')
    on(agent, show_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/feature bgp/],
                                          true, self, logger)
    end

    clean = UtilityLib.get_vshell_cmd('conf t ; feature bgp')
    on(agent, clean, :acceptable_exit_codes => [0, 2])
    show_cmd = UtilityLib.get_vshell_cmd('show running-config section bgp')
    on(agent, show_cmd) do
      UtilityLib.search_pattern_in_output(stdout, [/feature bgp/],
                                          false, self, logger)
    end
  end
end
