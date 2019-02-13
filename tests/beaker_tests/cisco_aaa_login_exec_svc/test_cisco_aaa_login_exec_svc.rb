###############################################################################
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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
  agent:         agent,
  master:        master,
  resource_name: 'cisco_aaa_authorization_login_exec_svc',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
def generate_default_test(tests, title)
  tests[:default_default] = {
    desc:           "1.1 Apply default manifest with 'default' as a string in attributes",
    title_pattern:  title,
    manifest_props: {
      ensure: 'present',
      groups: 'default',
      method: 'default',
    },
    resource:       {
      ensure: 'present',
      method: 'local',
    },
    code:           [0, 2],
  }

  tests[:default_absent] = {
    desc:           '1.2 Test resource absent manifest',
    title_pattern:  title,
    manifest_props: {
      ensure: 'absent',
    },
    # can't *actually* remove authorization, that would crater the box,
    # but check to see if defaults have been restored
    resource:       {
      ensure: 'present',
      method: 'local',
    },
    code:           [0, 2],
  }
end

def generate_default_symbols_test(tests, title)
  tests[:default_symbols] = {
    desc:           '1.1a Default Symbol Properties',
    title_pattern:  title,
    manifest_props: {
      ensure: 'present',
      groups: :default,
      method: :default,
    },
    resource:       {
      ensure: 'present',
      method: 'local',
    },
    code:           [0, 2],
  }
end

tests[:invalid_name] = {
  desc:           '2.1 Apply id pattern of resource name',
  title_pattern:  'invalid_name',
  manifest_props: {
    ensure: 'present',
  },
  stderr_pattern: /Parameter name failed/,
  code:           [1],
}

def generate_nondefault_test(tests, title)
  tests[:nondefault] = {
    desc:           '3.1 Apply manifest with non-default attributes, and test',
    title_pattern:  title,
    manifest_props: {
      ensure: 'present',
      groups: ['group1'],
      method: 'local',
    },
    code:           [0, 2],
  }
end

def generate_nondefault_symbols_test(tests, title)
  tests[:nondefault_symbols] = {
    desc:           '3.2 Apply manifest with symbol format non-default attributes',
    title_pattern:  title,
    manifest_props: {
      ensure: :present,
      groups: ['group1'],
      method: :unselected,
    },
    code:           [0, 2],
  }
end

def cleanup(agent)
  resource_absent_cleanup(agent, 'cisco_aaa_authorization_login_exec_svc')
  test_set(agent, 'no feature tacacs+')
end

# class to contain the test_dependencies specific to this test case
class TestCiscoAaaLoginExecSvc < BaseHarness
  def self.unsupported_properties(ctx, _tests, _id)
    unprops = []
    unprops << :groups if ctx.platform[/n7k/] # 'aaa auth commands' will hang test

    ctx.logger.info("  unprops: #{unprops}") unless unprops.empty?
    unprops
  end

  # Overridden to properly handle dependencies for this test file.
  def self.dependency_manifest(ctx, _tests, id)
    if [:nondefault, :nondefault_symbols].include?(id)
      dep = %(
            cisco_tacacs_server { 'default':
              ensure => present,
              encryption_type     => clear,
              encryption_password => 'testing123',
              source_interface    => 'mgmt0',
            }
            cisco_tacacs_server_host { '1.1.1.1':
              encryption_type     => 'encrypted',
              encryption_password => 'testing123',
              require             => Cisco_tacacs_server['default'],
            }
            cisco_aaa_authentication_login { 'default':
              ascii_authentication => true,
            }
            cisco_aaa_group_tacacs { 'group1':
              ensure           => present,
              vrf_name         => 'management',
              source_interface => 'mgmt0',
              server_hosts     => ['1.1.1.1'],
              require          => Cisco_tacacs_server_host['1.1.1.1'],
            }
      )
    else
      dep = %(
        cisco_tacacs_server      { 'default': ensure => present }
      )
    end
    ctx.logger.info("\n  * dependency_manifest\n#{dep}")
    dep
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  teardown { cleanup(agent) }
  cleanup(agent)

  %w(default console).each do |title|
    generate_default_test(tests, title)
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
    test_harness_run(tests, :default_default, harness_class: TestCiscoAaaLoginExecSvc)
    if tests[:agent]
      generate_default_symbols_test(tests, title)
      test_harness_run(tests, :default_symbols, harness_class: TestCiscoAaaLoginExecSvc)
    end
    # Absent tests do not set to absent, cannot test idempotency
    create_manifest_and_resource(tests, :default_absent, harness_class: TestCiscoAaaLoginExecSvc)
    test_manifest(tests, :default_absent)
    test_resource(tests, :default_absent)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Negative Value Test")
  create_manifest_and_resource(tests, :invalid_name, harness_class: TestCiscoAaaLoginExecSvc)
  test_manifest(tests, :invalid_name)

  %w(default console).each do |title|
    generate_nondefault_test(tests, title)
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 3. Non-Default Property Testing")
    # Tacacs server from dependency can re-encrypt passwords, cannot test idempotency
    create_manifest_and_resource(tests, :nondefault, harness_class: TestCiscoAaaLoginExecSvc)
    test_manifest(tests, :nondefault)
    test_resource(tests, :nondefault)
    next unless tests[:agent]
    # configuring method unselected for default will lock us out, skip that
    next if title == 'default'
    generate_nondefault_symbols_test(tests, title)
    create_manifest_and_resource(tests, :nondefault_symbols, harness_class: TestCiscoAaaLoginExecSvc)
    test_manifest(tests, :nondefault_symbols)
    test_resource(tests, :nondefault_symbols)
  end
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
