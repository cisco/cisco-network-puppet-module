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
  platform:      'n(7|9)k',
  resource_name: 'cisco_itd_device_group',
}

# Test hash test cases
tests[:default] = {
  desc:           '1.1 Defaults',
  title_pattern:  'icmpGroup',
  preclean:       'cisco_itd_device_group',
  manifest_props: {
    probe_type: 'default'
  },
  code:           [0, 2],
  resource:       {
    'probe_type' => 'false'
  },
}

tests[:default_icmp] = {
  desc:           '1.2 Defaults for type icmp',
  title_pattern:  'icmpGroup',
  preclean:       'cisco_itd_device_group',
  manifest_props: {
    probe_frequency:  'default',
    probe_retry_down: 'default',
    probe_retry_up:   'default',
    probe_timeout:    'default',
    probe_type:       'icmp',
  },
  code:           [0, 2],
  resource:       {
    'probe_frequency'  => '10',
    'probe_retry_down' => '3',
    'probe_retry_up'   => '3',
    'probe_timeout'    => '5',
  },
}

# Non-default Tests. NOTE: [:resource] = [:manifest_props] for all non-default

tests[:non_default_icmp] = {
  desc:           '2.1 Non Defaults for type icmp',
  title_pattern:  'icmpGroup',
  preclean:       'cisco_itd_device_group',
  manifest_props: {
    probe_frequency:  '1800',
    probe_retry_down: '4',
    probe_retry_up:   '4',
    probe_timeout:    '1200',
    probe_type:       'icmp',
  },
}

tests[:non_default_dns] = {
  desc:           '2.2 Non Defaults for type dns',
  title_pattern:  'dnsGroup',
  preclean:       'cisco_itd_device_group',
  manifest_props: {
    probe_frequency:  '1800',
    probe_dns_host:   '8.8.8.8',
    probe_retry_down: '4',
    probe_retry_up:   '4',
    probe_timeout:    '1200',
    probe_type:       'dns',
  },
}

tests[:non_default_tcp] = {
  desc:           '2.3 Non Defaults for type tcp',
  title_pattern:  'tcpGroup',
  preclean:       'cisco_itd_device_group',
  manifest_props: {
    probe_frequency:  '1800',
    probe_control:    'true',
    probe_port:       '6666',
    probe_retry_down: '4',
    probe_retry_up:   '4',
    probe_timeout:    '1200',
    probe_type:       'tcp',
  },
}

tests[:non_default_udp] = {
  desc:           '2.4 Non Defaults for type udp',
  title_pattern:  'udpGroup',
  preclean:       'cisco_itd_device_group',
  manifest_props: {
    probe_frequency:  '1800',
    probe_control:    'true',
    probe_port:       '6666',
    probe_retry_down: '4',
    probe_retry_up:   '4',
    probe_timeout:    '1200',
    probe_type:       'udp',
  },
}

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{tests[:resource_name]}" do
  # -------------------------------------------------------------------
  device = platform
  logger.info("#### This device is of type: #{device} #####")
  skip_nexus_i2_image(tests)
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")

  test_harness_run(tests, :default)
  test_harness_run(tests, :default_icmp)

  id = :default
  tests[id][:ensure] = :absent
  tests[id].delete(:preclean)
  test_harness_run(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")

  test_harness_run(tests, :non_default_icmp)
  test_harness_run(tests, :non_default_dns)
  test_harness_run(tests, :non_default_tcp)
  test_harness_run(tests, :non_default_udp)
  resource_absent_cleanup(agent, 'cisco_itd_device_group')
  skipped_tests_summary(tests)
end

logger.info("TestCase :: #{tests[:resource_name]} :: End")
