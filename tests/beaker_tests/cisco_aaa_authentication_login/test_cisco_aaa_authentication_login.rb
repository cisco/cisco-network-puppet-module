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
  resource_name: 'cisco_aaa_authentication_login',
  ensurable:     false,
}

# Skip -ALL- tests if a top-level platform/os key exludes this platform
skip_unless_supported(tests)

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Default Properties',
  title_pattern:  'default',
  manifest_props: {
    ascii_authentication: 'default',
    chap:                 'default',
    error_display:        'default',
    mschap:               'default',
    mschapv2:             'default',
  },
  resource:       {
    ascii_authentication: 'false',
    chap:                 'false',
    error_display:        'false',
    mschap:               'false',
    mschapv2:             'false',
  },
  code:           [0, 2],
}

tests[:default_symbol] = {
  desc:           '1.2 Default Symbol Properties',
  title_pattern:  'default',
  manifest_props: {
    ascii_authentication: :default,
    chap:                 :default,
    error_display:        :default,
    mschap:               :default,
    mschapv2:             :default,
  },
  resource:       {
    ascii_authentication: 'false',
    chap:                 'false',
    error_display:        'false',
    mschap:               'false',
    mschapv2:             'false',
  },
  code:           [0, 2],
}

tests[:invalid_name] = {
  desc:           '2.1 Apply id pattern of resource name',
  title_pattern:  'not_default',
  manifest_props: {
    ascii_authentication: 'false',
    chap:                 'false',
    error_display:        'false',
    mschap:               'false',
    mschapv2:             'false',
  },
  stderr_pattern: /only 'default' is accepted as a valid name/,
  code:           [0, 2],
}

tests[:multiple_auths] = {
  desc:           '2.2 Attempt to set multiple auth login methods',
  title_pattern:  'default',
  manifest_props: {
    ascii_authentication: 'true',
    chap:                 'true',
    error_display:        'false',
    mschap:               'false',
    mschapv2:             'false',
  },
  stderr_pattern: /Only one authentication login method can be configured at a time/,
  code:           [1],
}

def non_bool_tests(tests, prop)
  tests[:non_booleans] = {
    desc:           "2.3 Apply non-bool value to #{prop} property",
    title_pattern:  'default',
    manifest_props: {
      prop => 42,
    },
    stderr_pattern: /Invalid value 42. Valid values are true, false, default./,
    code:           [1],
  }
end

def non_bool_symbol_tests(tests, prop)
  tests[:non_boolean_symbols] = {
    desc:           "2.3a Apply invalid symbol to #{prop} property",
    title_pattern:  'default',
    manifest_props: {
      prop => :invalid,
    },
    stderr_pattern: /Invalid value|syntax error/,
    code:           [1],
  }
end

def non_default_symbol_tests(tests, vals)
  ascii, chap, mschap, mschapv2 = vals
  tests[:non_default_symbols] = {
    desc:           '3.1 Apply manifest with non-default symbols, and test harness',
    title_pattern:  'default',
    manifest_props: {
      ascii_authentication: ascii,
      chap:                 chap,
      error_display:        :true,
      mschap:               mschap,
      mschapv2:             mschapv2,
    },
    resource:       {
      ascii_authentication: ascii.to_s,
      chap:                 chap.to_s,
      error_display:        'true',
      mschap:               mschap.to_s,
      mschapv2:             mschapv2.to_s,
    },
    code:           [0, 2],
  }
end

def non_default_tests(tests, vals)
  ascii, chap, mschap, mschapv2 = vals

  tests[:non_default] = {
    desc:           '3.2 Apply manifest with string format non-default',
    title_pattern:  'default',
    manifest_props: {
      ascii_authentication: ascii.to_s,
      chap:                 chap.to_s,
      error_display:        'true',
      mschap:               mschap.to_s,
      mschapv2:             mschapv2.to_s,
    },
    code:           [0, 2],
  }
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1.1 Default Property Testing")
  test_harness_run(tests, :default)

  if tests[:agent]
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 1.2 Default Symbol Property Testing")
    test_harness_run(tests, :default_symbol)
  end

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2.1 Apply id pattern of resource name")
  create_manifest_and_resource(tests, :invalid_name)
  test_manifest(tests, :invalid_name)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2.2 Attempt to set multiple auth login methods")
  create_manifest_and_resource(tests, :multiple_auths)
  test_manifest(tests, :multiple_auths)

  [:ascii_authentication, :chap, :mschap, :mschapv2].each do |prop|
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 2.3 Apply non-bool value to #{prop} property")
    non_bool_tests(tests, prop)
    create_manifest_and_resource(tests, :non_booleans)
    test_manifest(tests, :non_booleans)

    next unless tests[:agent]
    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\nSection 2.3a Apply invalid symbol to #{prop} property")
    non_bool_symbol_tests(tests, prop)
    create_manifest_and_resource(tests, :non_boolean_symbols)
    test_manifest(tests, :non_boolean_symbols)
  end

  # set each of the authentication methods to true, in turn
  vals = [:true, :false, :false, :false]
  ['ascii-authentication', 'chap', 'mschap', 'mschapv2'].each do |prop|
    if tests[:agent]
      # -------------------------------------------------------------------
      logger.info("\n#{'-' * 60}\n3.1 Apply manifest with non-default #{prop}, and test harness")
      non_default_symbol_tests(tests, vals)
      test_harness_run(tests, :non_default_symbols)
    end

    # -------------------------------------------------------------------
    logger.info("\n#{'-' * 60}\n3.2 Apply manifest with string format non-default #{prop}")
    non_default_tests(tests, vals)
    test_harness_run(tests, :non_default)

    vals.rotate!(-1)
  end
end
logger.info("TestCase :: #{tests[:resource_name]} :: End")
