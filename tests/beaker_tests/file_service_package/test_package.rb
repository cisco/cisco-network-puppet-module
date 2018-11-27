###############################################################################
# Copyright (c) 2016-2018 Cisco and/or its affiliates.
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
  ensurable:     false,
  resource_name: 'package',
  agent_only:    true,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Native mode third-party rpm's require repo setup
tests[:env] = os_family[/cisco-wrlinux/] ? :native : :centos

tests[:centos] = {
  # GS/OAC-only test. Use dos2unix rpm from the wild.
  # dos2unix is a tiny rpm that is not normally present
  title_pattern:  'dos2unix',
  manifest_props: {
    name:          'dos2unix',
    ensure:        'installed',
    provider:      'yum',
    allow_virtual: 'false',
  },
  resource:       { 'ensure' => '[0-9]+' },
}

tests[:native] = {
  # Native-only test. Use local repo for native testing.
  title_pattern:  'demo-one',
  manifest_props: {
    name:          'demo-one',
    ensure:        'installed',
    provider:      'yum',
    allow_virtual: 'false',
  },
  resource:       { 'ensure' => '[0-9]+' },
}

# class to contain the test_dependencies specific to this test case
class TestPackage < BaseHarness
  def self.dependency_manifest(ctx, _tests, id)
    return unless id == :native
    dep = %(
      # Create local repo files
      file { '/tmp/beaker-repo' :
        ensure => 'directory',
      }
      file { '/tmp/beaker-repo/demo-one-1.0-1.x86_64.rpm' :
        ensure  => present,
        source  => 'puppet:///modules/ciscopuppet/demo-one-1.0-1.x86_64.rpm',
        require => File['/tmp/beaker-repo'],
      }
      exec { 'createrepo':
        command => '/usr/bin/createrepo /tmp/beaker-repo',
        unless  => '/bin/ls /tmp/beaker-repo/repodata 2>/dev/null',
        require => File['/tmp/beaker-repo/demo-one-1.0-1.x86_64.rpm'],
      }

      yumrepo { 'beaker':
         # Create beaker repo config on switch
         baseurl  => 'file:///tmp/beaker-repo',
         descr    => "Beaker test rpms",
         enabled  => 1,
         gpgcheck => 0,
         cost     => 505,
         require  => Exec['createrepo'],
         before   => Package['#{ctx.os_family[/cisco-wrlinux/] ? 'demo-one' : 'dos2unix'}'],
      }
    )
    ctx.logger.info("\n  * dependency_manifest\n#{dep}")
    dep
  end
end

def cleanup(tests, id)
  agent = tests[:agent]
  # Remove the test rpm from the switch
  puppet_resource_cmd_from_params(tests, id)
  cmd = tests[id][:resource_cmd] + ' ensure=purged'
  logger.info("Cleanup: #{cmd}")
  on(agent, cmd, acceptable_error_codes: [0, 2])

  return unless id == :native
  # Remove any local repo cruft
  on(agent, 'rm -f /etc/yum/repos.d/beaker.repo', acceptable_error_codes: [0, 2])
  on(agent, 'rm -rf /tmp/beaker-repo/', acceptable_error_codes: [0, 2])
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  id = tests[:env]
  teardown { cleanup(tests, id) }
  cleanup(tests, id)

  # ----------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Install")
  tests[id][:desc] = '1.1 Install RPM'
  test_harness_run(tests, id, harness_class: TestPackage)

  # ----------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Uninstall")
  tests[id][:desc] = '1.2 Uninstall RPM'
  tests[id][:manifest_props][:ensure] = 'purged'
  tests[id][:resource] = { 'ensure' => 'purged' }
  test_harness_run(tests, id, harness_class: TestPackage)
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
