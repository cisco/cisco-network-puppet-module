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

# Require UtilityLib.rb path.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Monkeypatch all our utility functions into beaker's TestCase, so that we don't poison the global namespace
class Beaker::TestCase
  # This helper tests a test case in vrf context. This allows for testing a vrf
  # while an existing config is present in vrf default.
  def test_harness_bgp_vrf(tests, id, vrf, harness_class: BaseHarness)
    orig_desc = tests[id][:desc]
    tests[id][:desc] += " (vrf #{vrf})"

    orig_title_pattern = tests[id][:title_pattern]
    words = orig_title_pattern.split
    if words.length > 1
      words[1] = vrf
      tests[id][:title_pattern] = words.join(' ')
    elsif tests[id][:manifest_props] && tests[id][:manifest_props][:vrf]
      orig_vrf = tests[id][:manifest_props][:vrf]
      tests[id][:manifest_props][:vrf] = vrf
    end

    test_harness_run(tests, id, harness_class: harness_class)

    # put the original values back
    tests[id][:desc] = orig_desc
    tests[id][:title_pattern] = orig_title_pattern
    tests[id][:manifest_props][:vrf] = orig_vrf
  end

  # Returns the vrf being tested by the specified test.
  def vrf(test)
    return test[:title_params][:vrf] if
      test[:title_params] && test[:title_params][:vrf]

    if test[:title_pattern]
      words = test[:title_pattern].split(' ')
      return words[1] unless words.length < 2
    end

    'default'
  end
end
