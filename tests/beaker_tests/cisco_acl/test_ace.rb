###############################################################################
# Copyright (c) 2016 Cisco and/or its affiliates.
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
  master:        master,
  agent:         agent,
  resource_name: 'cisco_ace',
}

# Test hash test cases
tests[:seq_5_remark] = {
  preclean:       'cisco_acl',
  title_pattern:  'ipv4 beaker 5',
  manifest_props: {
    # 'remark' is a standalone property
    remark: 'seq_5 remark'
  },
}

tests[:seq_10_v4] = {
  title_pattern:  'ipv4 beaker 10',
  manifest_props: {
    action:   'permit',
    proto:    'tcp',
    src_addr: '1.2.3.4 2.3.4.5',
    dst_addr: '9.9.0.4/32',
  },
}

tests[:seq_10_v6] = {
  desc:           'IPv6 Seq 10',
  title_pattern:  'ipv6 beaker6 10',
  manifest_props: {
    action:   'permit',
    proto:    'tcp',
    src_addr: '1:1::1/128',
    dst_addr: '1:1::2/128',
  },
}

tests[:seq_20_v4] = {
  title_pattern:  'ipv4 beaker 20',
  manifest_props: {
    action:        'deny',
    proto:         'tcp',
    src_addr:      'any',
    src_port:      'eq 40',
    dst_addr:      'any',
    dst_port:      'range 32 56',

    established:   'true',
    log:           'true',
    packet_length: 'range 80 1000',
    precedence:    'flash',
    redirect:      'port-channel1,port-channel2',
    tcp_flags:     'ack syn fin',
    time_range:    'my_range',

    # TBD: ttl is currently broken on NX platforms
    # ttl:           '127',
  },
}
tests[:seq_20_v6] = tests[:seq_20_v4].clone
tests[:seq_20_v6][:title_pattern] = 'ipv6 beaker6 20'

tests[:seq_30_v4] = {
  desc:           'IPv4 Seq 30',
  title_pattern:  'ipv4 beaker 30',
  manifest_props: {
    action:            'deny',
    proto:             'tcp',
    src_addr:          'any',
    dst_addr:          'any',

    # These v4-only properties are not compatible with some of the props
    # in seq 20 so they are tested separately.
    dscp:              'af12',
    http_method:       'post',
    tcp_option_length: '24',
  },
}

# Overridden to properly handle unsupported properties for this test file.
def unsupported_properties(tests, id)
  unprops = []

  if operating_system == 'ios_xr'
    # unprops << TBD: XR Support

  else
    if tests[id][:title_pattern][/ipv6/]
      unprops <<
        :http_method <<
        :precedence <<
        :redirect <<
        :tcp_option_length
    end
    if platform[/n(5|6)k/]
      unprops <<
        :packet_length <<
        :time_range
    end
    if platform[/n(5|6|7)k/]
      unprops <<
        :http_method <<
        :redirect <<
        :tcp_option_length <<
        :ttl
    end
  end

  unprops
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  logger.info("\n#{'-' * 60}\nSection 1. ACE Testing")

  test_harness_run(tests, :seq_5_remark)
  test_harness_run(tests, :seq_10_v4)
  test_harness_run(tests, :seq_10_v6)
  test_harness_run(tests, :seq_20_v4)
  test_harness_run(tests, :seq_20_v6)
  test_harness_run(tests, :seq_30_v4)

  # ---------------------------------------------------------
  resource_absent_cleanup(agent, 'cisco_acl', 'ACL CLEANUP :: ')
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
