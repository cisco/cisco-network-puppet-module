###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
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
  master:           master,
  agent:            agent,
  operating_system: 'nexus',
  platform:         'n[35679]k(?!-ex)', # TBD: All except n9k-ex
  resource_name:    'cisco_portchannel_global',
  ensurable:        false,
}

tests[:default] = {
  desc:           '1.1 Defaults',
  title_pattern:  'default',
  manifest_props: {
    asymmetric:        'default',
    bundle_hash:       'default',
    bundle_select:     'default',
    concatenation:     'default',
    hash_distribution: 'default',
    hash_poly:         'CRC10b',
    load_defer:        'default',
    resilient:         'default',
    rotate:            'default',
    symmetry:          'default',
  },
  code:           [0, 2],
  resource:       {
    asymmetric:        'false',
    bundle_hash:       'ip',
    bundle_select:     'src-dst',
    concatenation:     'false',
    hash_distribution: 'adaptive',
    hash_poly:         'CRC10b',
    load_defer:        '120',
    resilient:         'false',
    rotate:            '0',
    symmetry:          'false',
  },
}

# Per platform default values
resource = {
  n3k: {
    resilient: 'true'
  },
  n9k: {
    bundle_hash: 'ip-l4port'
  },
}

tests[:default][:resource].merge!(resource[:n3k]) if platform[/n3k/]
tests[:default][:resource].merge!(resource[:n9k]) if platform[/n9k/]

tests[:non_default] = {
  desc:           '2.1 Non Defaults',
  title_pattern:  'default',
  manifest_props: {
    asymmetric:        'true',
    bundle_hash:       'ip-l4port',
    bundle_select:     'dst',
    concatenation:     'true',
    hash_distribution: 'fixed',
    hash_poly:         'CRC10c',
    load_defer:        '1000',
    resilient:         'true',
    rotate:            '4',
    symmetry:          'true',
  },
}

# Per platform non default values
manifest_non = {
  n3k:  {
    bundle_hash:   'ip-only',
    bundle_select: 'src-dst',
    resilient:     'false',
  },
  n56k: {
    bundle_hash: 'mac'
  },
  n9kf: {
    bundle_hash: 'ip'
  },
  n9k:  {
    bundle_hash:   'ip',
    bundle_select: 'src-dst',
  },
}

tests[:non_default][:manifest_props].merge!(manifest_non[:n3k]) if platform[/n3k$/]
tests[:non_default][:manifest_props].merge!(manifest_non[:n56k]) if platform[/n(5|6)k/]
tests[:non_default][:manifest_props].merge!(manifest_non[:n9kf]) if platform[/n(3|9)k-f/]
tests[:non_default][:manifest_props].merge!(manifest_non[:n9k]) if platform[/n9k$/]

if platform[/n3k$/]
  pattern = 'ERROR: This feature is not supported on this platform'
  cmd = agent ? 'cisco_portchannel_global default resilient=true' : 'port-channel load-balance resilient'
  tests[:resilient_unsupported] = resource_probe(agent, cmd, pattern)
end

# class to contain the test_dependencies specific to this test case
class TestPortChannelGlobal < BaseHarness
  def self.unsupported_properties(ctx, tests, _id)
    unprops = []
    if ctx.platform[/n7k/]
      unprops <<
        :concatenation <<
        :hash_poly <<
        :resilient <<
        :symmetry
    elsif ctx.platform[/n(5|6)k/]
      unprops <<
        :asymmetric <<
        :concatenation <<
        :hash_distribution <<
        :load_defer <<
        :resilient <<
        :rotate <<
        :symmetry
    elsif ctx.platform[/n(3|9)k-f/]
      unprops <<
        :asymmetric <<
        :concatenation <<
        :hash_distribution <<
        :hash_poly <<
        :load_defer <<
        :resilient <<
        :symmetry
    elsif ctx.platform[/n3k/]
      unprops <<
        :asymmetric <<
        :concatenation <<
        :hash_distribution <<
        :hash_poly <<
        :load_defer <<
        :rotate
    elsif ctx.platform[/n9k/]
      unprops <<
        :asymmetric <<
        :hash_distribution <<
        :hash_poly <<
        :load_defer
    end
    unprops << :resilient << :symmetry if tests[:resilient_unsupported]
    unprops
  end
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  device = platform
  teardown do
    test_harness_run(tests, :default, harness_class: TestPortChannelGlobal)
  end
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default, harness_class: TestPortChannelGlobal)

  # no absent test for portchannel_global

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  id = :non_default
  test_harness_run(tests, id, harness_class: TestPortChannelGlobal)
  mhash = tests[id][:manifest_props]
  rhash = tests[id][:resource]
  if device == 'n7k'
    tests[id][:desc] = '2.2 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-l4port-vlan'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.3 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-vlan'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.4 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'l4port'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.5 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'mac'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

  elsif device == 'n5k' || device == 'n6k'
    tests[id][:desc] = '2.2 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'port'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src'
    mhash[:hash_poly] = rhash[:hash_poly] = 'CRC10a' if device == 'n6k'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.3 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'port-only'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src-dst'
    mhash[:hash_poly] = rhash[:hash_poly] = 'CRC10d'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.4 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-only'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

  elsif device == 'n9k'
    tests[id][:desc] = '2.2 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-l4port-vlan'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src'
    mhash[:rotate] = rhash[:rotate] = '0'
    mhash[:symmetry] = rhash[:symmetry] = 'false'
    mhash[:concatenation] = rhash[:concatenation] = 'false'
    mhash[:resilient] = rhash[:resilient] = 'false'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.3 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-vlan'
    mhash[:bundle_select] = rhash[:bundle_select] = 'dst'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.4 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'l4port'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src-dst'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.5 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'mac'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.6 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-gre'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

  elsif device == 'n9k-f'
    tests[id][:desc] = '2.2 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-l4port-vlan'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.3 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-vlan'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.4 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'l4port'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.5 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'mac'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

  elsif device == 'n3k-f'
    tests[id][:desc] = '2.2 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-l4port-vlan'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.3 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-vlan'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.4 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'l4port'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

    tests[id][:desc] = '2.5 Non Defaults'
    mhash[:bundle_hash] = rhash[:bundle_hash] = 'mac'
    mhash[:bundle_select] = rhash[:bundle_select] = 'src'
    test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

  elsif device == 'n3k'
    if tests[:resilient_unsupported]
      tests[id][:desc] = '2.2 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-gre'
      mhash[:bundle_select] = rhash[:bundle_select] = 'src'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.3 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'mac'
      mhash[:bundle_select] = rhash[:bundle_select] = 'dst'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.4 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'port'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.5 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'port-only'
      mhash[:bundle_select] = rhash[:bundle_select] = 'src-dst'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.6 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-gre'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.7 Non Defaults'
      mhash[:bundle_select] = rhash[:bundle_select] = 'dst'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)
    else
      tests[id][:desc] = '2.2 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-gre'
      mhash[:bundle_select] = rhash[:bundle_select] = 'src'
      mhash[:resilient] = rhash[:resilient] = 'true'
      mhash[:symmetry] = rhash[:symmetry] = 'false'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.3 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'mac'
      mhash[:bundle_select] = rhash[:bundle_select] = 'dst'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.4 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'port'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.5 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'port-only'
      mhash[:bundle_select] = rhash[:bundle_select] = 'src-dst'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.6 Non Defaults'
      mhash[:bundle_hash] = rhash[:bundle_hash] = 'ip-gre'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)

      tests[id][:desc] = '2.7 Non Defaults'
      mhash[:bundle_select] = rhash[:bundle_select] = 'dst'
      test_harness_run(tests, id, harness_class: TestPortChannelGlobal)
    end
  end

  # no absent test for portchannel_global
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
