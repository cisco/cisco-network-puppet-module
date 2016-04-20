# How To Create and Run Beaker Test Cases

#### Table of Contents

* [Overview](#overview)
* [Pre-Install Tasks](#pre-install)
* [Beaker Configuration](#beaker-config)
* [Running a Beaker Test](#beaker-run)
* [Basic Example: feature tunnel](#basic-example-feature-tunnel)
  * [Step 1. Create the beaker test script](#s1-basic)
  * [Step 2. Run the script](#s2-basic)
* [Complex Example: router eigrp](#complex-example-router-eigrp)
  * [Step 1. Create the beaker test script](#s1-comp)
  * [Step 2. Run the script](#s2-comp)
* [Static Analysis](#sa)
* [Next Steps](#next)
* [**ADDENDUM**: Test Script Variable Reference (** NEW **)](#addendum)

## <a name="overview">Overview</a>

This document describes the process for writing and executing [Beaker](https://github.com/puppetlabs/beaker/blob/master/README.md) Test Cases for cisco puppet providers.

## <a name="pre-install">Pre-Install Tasks</a>

Refer to [README-beaker-prerequisites](README-beaker-prerequisites.md) for required setup steps for Beaker and the node(s) to be tested.

Install and set up the Puppet agent and `cisco_node_utils` gem as described in [README-agent-install.md](README-agent-install.md).

## <a name="beaker-config">Beaker Server Configuration</a>

The following commands should be run on your Beaker workstation.

~~~
$ git clone https://github.com/cisco/cisco-network-puppet-module.git
$ cd cisco-network-puppet-module/tests/beaker_tests/
~~~

### Create `host.cfg` File

Under the `beaker_tests` directory, create file named `host.cfg` and add the following content.

Note: If running puppet on IOS XR, specify the gRPC port number configured on the switch.

Replace the `< >` markers with specific information.

```bash
HOSTS:
    <IOS XR agent>:
        roles:
            - agent
        platform: cisco_ios_xr-6-x86_64
        ip: <fully qualified domain name>
        ssh:
          auth_methods: ["password"]
          # SSHd for third-party network namespace (TPNNS) uses port 57722
          port: 57722
          user: <configured admin username>
          password: <configured admin password>

    <Nexus bash-shell or guestshell agent>:
        roles:
            - agent
        platform: cisco_nexus-7-x86_64
        ip: <fully qualified domain name>
        vrf: <vrf used for beaker workstation and puppet master ip reachability>
        ssh:
          auth_methods: ["password"]
          user: <configured bash-shell username>
          password: <configured bash-shell password>
        #Uncomment the following line to install into the guestshell
        #target: guestshell

    <Nexus open agent container (OAC) agent>:
        roles:
            - agent
        platform: cisco_nexus-oac-i386
        ip: <fully qualified domain name>
        vrf: <vrf used for beaker workstation and puppet master ip reachability>
        ssh:
          auth_methods: ["password"]
          user: <configured bash-shell username>
          password: <configured bash-shell password>
          # SSHd for OAC uses port 2222
          port: 2222

    #<agent3>:
    #  <...>

    #<agent4>:
    #  <...>

    <master>:
        # Note: Only one master configuration block allowed
        roles:
            - master
        platform: <server os-version-architecture>
        ip: <fully qualifed domain name>
        ssh:
          # Root user/password must be configured for master.
          auth_methods: ["password"]
          user: root
          password: <configured root password>
```

Here is a sample `host.cfg` file where `< >` markers have been replaced with actual data.

```bash
HOSTS:
    nx-agent:
        roles:
            - agent
        platform: cisco_nexus-5-x86_64
        ip: nx-agent.domain.com
        vrf: management
        #target: guestshell
        ssh:
          auth_methods: ["password"]
          user: devops
          password: devopspassword

    xr-agent:
        roles:
            - agent
        platform: cisco_ios_xr-6-x86_64
        ip: xr-agent.domain.com
        ssh:
          auth_methods: ["password"]
          port: 57722
          user: admin
          password: adminpassword

    puppetmaster1:
        roles:
            - master
        platform: ubuntu-1404-x86_64
        ip: puppetmaster1.domain.com
        ssh:
          auth_methods: ["password"]
          user: root
          password: rootpassword
```

## <a name="beaker-run">Running a Beaker Test</a>

To run a beaker test from the `beaker_tests` directory, use the following command.

```bash
beaker --hosts hosts.cfg --pre-suite presuite/presuite-certcheck.rb \
--no-validate --no-configure \
--test vtp/vtp-provider-defaults.rb
```

**NOTE:** This runs a vtp test, but any other tests under the `beaker_tests` directory can be run in the same manner.

## <a name="basic-example-feature-tunnel">Basic Example: feature tunnel</a>

This example is a continuation of the examples used in other developer guides: [README-develop-node-utils-APIs.md](https://github.com/cisco/cisco-network-node-utils/blob/develop/docs/README-develop-node-utils-APIs.md) and [README-develop-types-providers.md](docs/README-develop-types-providers.md).

* To review, the NX-OS CLI for `feature tunnel` is a simple on / off style configuration:

`[no] feature tunnel`

This resource has no other properties so it will have limited testing.

## <a name="s1-basic">Step 1. Create the beaker test script: tunnel</a>

* First, create a `tunnel` directory in the `beaker_tests` directory:

~~~bash
mkdir tests/beaker_tests/tunnel
~~~

* There are template files in `/docs` that may help guide development of new beaker test scripts. These templates provide most of the necessary code with a few customizations required for a new resource. Copy the `template-beaker-feature.rb` file to use as the basis for our new `test_tunnel.rb` beaker file:

~~~bash
cp docs/template-beaker-feature.rb  tests/beaker_tests/tunnel/test_tunnel.rb
~~~

* Edit `test_tunnel.rb` and substitute the placeholder text as shown here:

~~~bash
/X__RESOURCE_NAME__X/tunnel/
~~~

#### Example: test_tunnel.rb test script

This is the completed beaker script for the tunnel resource, based on `template-beaker-feature.rb`:

```ruby
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
###############################################################################
# TestCase Name:
# -------------
# test-tunnel.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet tunnel resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This tunnel resource test verifies default values for all properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_tunnel'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
#
tests = {
  :master => master,
  :agent => agent,
  :show_cmd => 'show run section tunnel',
}

# tests[id] keys set by caller and used by test_harness_common:
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
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#   Can be used with :af for mixed title/af testing. If mixing, :af values will
#   be merged with title values and override any duplicates. If omitted,
#   :title_pattern will be set to 'id'.
#
tests['default_properties'] = {
  :manifest_props => "
    # PLEASE NOTE: The feature template has no additional properties so these
    # hash entries are intentionally commented out and included here solely
    # as an example of where properties would be defined.

    # bar                            => 'default',
  ",
  :resource_props => {
    # 'bar'                          => 'default',
  },
}

tests['non_default_properties'] = {
  :manifest_props => "
    # bar                            => true,
  ",
  :resource_props => {
    # 'bar'                          => 'true',
  }
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  UtilityLib::PUPPET_BINPATH + 'resource cisco_tunnel'
end

def build_manifest_tunnel(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    manifest = ''
    tests[id][:resource] = { 'ensure' => 'absent' }
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_tunnel :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_tunnel { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_tunnel(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_tunnel(tests, id)

  # For full test support of properties use test_harness_common; as an
  # alternative use direct calls to individual test_* wrapper methods:
  # test_harness_common(tests, id)
  test_manifest(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  node_feature_cleanup(agent, 'tunnel', 'disable feature', false)

  # -----------------------------------
  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_tunnel(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_tunnel(tests, id)

  # -------------------------------------------------------------------
  # FUTURE:
  # logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  # node_feature_cleanup(agent, 'tunnel', 'disable feature', false)
  # tests[id][:desc] = "2.1 Non Default Properties"
  # test_harness_tunnel(tests, 'non_default_properties')
end

logger.info("TestCase :: #{testheader} :: End")
```

## <a name="s2-basic">Step 2. Run the script: tunnel</a>

The beaker tool must have access to the `beaker_tests` directory. This could mean running beaker directly from your development workspace or from an entirely different server. For example, some developers prefer to use a dedicated beaker workstation in which case sshfs can be used to softlink the `beaker_tests` directory from the beaker workstation.

Run the beaker tool against the `test_tunnel` script:

_(Some output truncated for brevity)_

```bash
beaker --host hosts.cfg --no-validate --no-configure --test beaker_tests/tunnel/test_tunnel.rb

Beaker!
      wWWWw
      |o o|
      | O |  2.18.3!
      |(")|
     / \X/ \
    |   V   |
    |   |   |
{
         ...text removed for brevity...
}
Beaker::Hypervisor, found some none boxes to create
No tests to run for suite 'pre_suite'
Begin beaker_tests/tunnel/test_tunnel.rb

TestCase :: Resource cisco_tunnel

------------------------------------------------------------
Section 1. Default Property Testing

  * TestStep :: disable feature

  * TestStep :: 1.1 Default Properties [ensure => present] :: MANIFEST
1.1 Default Properties [ensure => present] :: MANIFEST     :: PASS

  * TestStep :: 1.1 Default Properties [ensure => present] :: IDEMPOTENCE
1.1 Default Properties [ensure => present] :: IDEMPOTENCE  :: PASS

  * TestStep :: 1.2 Default Properties [ensure => absent] :: MANIFEST
1.2 Default Properties [ensure => absent] :: MANIFEST     :: PASS

  * TestStep :: 1.2 Default Properties [ensure => absent] :: IDEMPOTENCE
1.2 Default Properties [ensure => absent] :: IDEMPOTENCE  :: PASS
TestCase :: Resource cisco_tunnel :: End
beaker_tests/tunnel/test_tunnel.rb passed in 37.28 seconds
      Test Suite: tests @ 2015-10-02 10:55:55 -0400

      - Host Configuration Summary -


              - Test Case Summary for suite 'tests' -
       Total Suite Time: 37.28 seconds
      Average Test Time: 37.28 seconds
              Attempted: 1
                 Passed: 1
                 Failed: 0
                Errored: 0
                Skipped: 0
                Pending: 0
                  Total: 1

      - Specific Test Case Status -

Failed Tests Cases:
Errored Tests Cases:
Skipped Tests Cases:
Pending Tests Cases:


No tests to run for suite 'post_suite'
Cleanup: cleaning up after successful run
Warning: ssh connection to 10.122.84.157 has been terminated
Warning: ssh connection to 10.122.84.53 has been terminated
Beaker completed successfully, thanks.
```

## <a name="complex-example-router-eigrp">Complex Example: router eigrp</a>

This example is a continuation of the examples used in other developer guides: [README-develop-node-utils-APIs.md](https://github.com/cisco/cisco-network-node-utils/blob/develop/docs/README-develop-node-utils-APIs.md) and [README-develop-types-providers.md](docs/README-develop-types-providers.md).

* To review, the NX-OS CLI for `router eigrp` is a multi-level, multiple instance configuration. For the purposes of this example the test will focus on testing a single router instance and just two properties:

~~~
[no] feature eigrp
[no] router eigrp [name]    (string)
       maximum-paths [n]    (integer)
  [no] shutdown             (boolean)
~~~

Note that the `router eigrp` provider doesn't require any knowledge of `feature eigrp` because the feature configuration is controlled automatically by the `router eigrp` node_utils API.


## <a name="s1-comp">Step 1. Create the beaker test script: eigrp</a>

* First, create an `eigrp` directory in the `beaker_tests` directory:

~~~bash
mkdir tests/beaker_tests/eigrp
~~~

* There are template files in `/docs` that may help guide development of new beaker test scripts. These templates provide most of the necessary code with a few customizations required for a new resource. Copy the `template-beaker-router.rb` file to use as the basis for our new `test_eigrp.rb` beaker file:

~~~bash
cp docs/template-beaker-router.rb  tests/beaker_tests/tunnel/test_eigrp.rb
~~~

* Edit `test_eigrp.rb` and substitute the placeholder text as shown here:

~~~bash
/X__RESOURCE_NAME__X/eigrp/
~~~

#### Example: test_eigrp.rb test script

This is the completed beaker script for the `router eigrp` resource, based on `template-beaker-router.rb`:

```ruby
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
###############################################################################
# TestCase Name:
# -------------
# test-eigrp.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a Puppet eigrp resource testcase for Puppet Agent on
# Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
#   - Host configuration file contains agent and master information.
#   - SSH is enabled on the N9K Agent.
#   - Puppet master/server is started.
#   - Puppet agent certificate has been signed on the Puppet master/server.
#
# TestCase:
# ---------
# This Tunnel resource test verifies default values for all properties.
#
# The following exit_codes are validated for Puppet, Vegas shell and
# Bash shell commands.
#
# Vegas and Bash Shell Commands:
# 0   - successful command execution
# > 0 - failed command execution.
#
# Puppet Commands:
# 0 - no changes have occurred
# 1 - errors have occurred,
# 2 - changes have occurred
# 4 - failures have occurred and
# 6 - changes and failures have occurred.
#
# NOTE: 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
#
# The test cases use RegExp pattern matching on stdout or output IO
# instance attributes to verify resource properties.
#
###############################################################################

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# -----------------------------
# Common settings and variables
# -----------------------------
testheader = 'Resource cisco_router_eigrp'

# Define PUPPETMASTER_MANIFESTPATH.
UtilityLib.set_manifest_path(master, self)

# The 'tests' hash is used to define all of the test data values and expected
# results. It is also used to pass optional flags to the test methods when
# necessary.

# 'tests' hash
# Top-level keys set by caller:
# tests[:master] - the master object
# tests[:agent] - the agent object
# tests[:show_cmd] - the common show command to use for test_show_run
#
tests = {
  :master => master,
  :agent => agent,
  :show_cmd => 'show run section eigrp',
}

# tests[id] keys set by caller and used by test_harness_common:
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
# These keys are local use only and not used by test_harness_common:
#
# tests[id][:manifest_props] - This is essentially a master list of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the list
# tests[id][:resource_props] - This is essentially a master hash of properties
#   that permits re-use of the properties for both :present and :absent testing
#   without destroying the hash
# tests[id][:title_pattern] - (Optional) defines the manifest title.
#   Can be used with :af for mixed title/af testing. If mixing, :af values will
#   be merged with title values and override any duplicates. If omitted,
#   :title_pattern will be set to 'id'.
# tests[id][:af] - (Optional) defines the address-family values.
#   Must use :title_pattern if :af is not specified. Useful for testing mixed
#   title/af manifests
#
tests['default_properties'] = {
  :title_pattern => '1',
  :manifest_props => "
    maximum_paths                  => 'default',
    shutdown                       => 'default',
  ",
  :resource_props => {
    'maximum_paths'                => '8',
    'shutdown'                     => 'false',
  },
}

tests['non_default_properties_M'] = {
  :desc => "2.1 Non Default Properties 'M' commands",
  :title_pattern => '1',
  :manifest_props => "
    maximum_paths                  => '5',
  ",
  :resource_props => {
    'maximum_paths'                => '5',
  }
}

tests['non_default_properties_S'] = {
  :desc => "2.2 Non Default Properties 'S' commands",
  :title_pattern => '1',
  :manifest_props => "
    shutdown                       => 'true',
  ",
  :resource_props => {
    'shutdown'                     => 'true',
  }
}

#################################################################
# HELPER FUNCTIONS
#################################################################

# Full command string for puppet resource command
def puppet_resource_cmd
  UtilityLib::PUPPET_BINPATH + 'resource cisco_router_eigrp'
end

def build_manifest_eigrp(tests, id)
  if tests[id][:ensure] == :absent
    state = 'ensure => absent,'
    tests[id][:resource] = {}
  else
    state = 'ensure => present,'
    manifest = tests[id][:manifest_props]
    tests[id][:resource] = tests[id][:resource_props]
  end

  tests[id][:title_pattern] = id if tests[id][:title_pattern].nil?
  logger.debug("build_manifest_eigrp :: title_pattern:\n" +
               tests[id][:title_pattern])
  tests[id][:manifest] = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
  node 'default' {
    cisco_router_eigrp { '#{tests[id][:title_pattern]}':
      #{state}
      #{manifest}
    }
  }
EOF"
end

def test_harness_eigrp(tests, id)
  tests[id][:ensure] = :present if tests[id][:ensure].nil?
  tests[id][:resource_cmd] = puppet_resource_cmd
  tests[id][:desc] += " [ensure => #{tests[id][:ensure]}]"

  # Build the manifest for this test
  build_manifest_eigrp(tests, id)

  # FUTURE
  # test_harness_common(tests, id)

  test_manifest(tests, id)
  test_resource(tests, id)
  test_idempotence(tests, id)

  tests[id][:ensure] = nil
end

#################################################################
# TEST CASE EXECUTION
#################################################################
test_name "TestCase :: #{testheader}" do
  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 1. Default Property Testing")
  node_feature_cleanup(agent, 'eigrp')

  # -----------------------------------
  id = 'default_properties'
  tests[id][:desc] = '1.1 Default Properties'
  test_harness_eigrp(tests, id)

  tests[id][:desc] = '1.2 Default Properties'
  tests[id][:ensure] = :absent
  test_harness_eigrp(tests, id)

  # -------------------------------------------------------------------
  logger.info("\n#{'-' * 60}\nSection 2. Non Default Property Testing")
  node_feature_cleanup(agent, 'eigrp')

  test_harness_eigrp(tests, 'non_default_properties_M')
  test_harness_eigrp(tests, 'non_default_properties_S')

  # -------------------------------------------------------------------
  # FUTURE
  # logger.info("\n#{'-' * 60}\nSection 3. Title Pattern Testing")
  # node_feature_cleanup(agent, 'eigrp')

  # id = 'title_patterns'
  # tests[id][:desc] = '3.1 Title Patterns'
  # tests[id][:title_pattern] = '2'
  # tests[id][:af] = { :vrf => 'default', :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_eigrp(tests, id)

  # id = 'title_patterns'
  # tests[id][:desc] = '3.2 Title Patterns'
  # tests[id][:title_pattern] = '2 blue'
  # tests[id][:af] = { :afi => 'ipv4', :safi => 'unicast' }
  # test_harness_eigrp(tests, id)
end

logger.info("TestCase :: #{testheader} :: End")
```

## <a name="s2-comp">Step 2. Run the script: eigrp</a>

As noted earlier, the beaker tool must have access to the `beaker_tests` directory.

Run the beaker tool against the `test_eigrp` script:

_(Some output truncated for brevity)_

```bash
beaker --host hosts.cfg --no-validate --no-configure --test beaker_tests/tunnel/test_tunnel.rb

Beaker!
      wWWWw
      |o o|
      | O |  2.18.3!
      |(")|
     / \X/ \
    |   V   |
    |   |   |
{
         ...text removed for brevity...
}
Beaker::Hypervisor, found some none boxes to create
No tests to run for suite 'pre_suite'
Begin beaker_tests/eigrp/test_eigrp.rb

TestCase :: Resource cisco_eigrp

------------------------------------------------------------
Section 1. Default Property Testing

  * TestStep :: feature cleanup

  * TestStep :: 1.1 Default Properties [ensure => present] :: MANIFEST
1.1 Default Properties [ensure => present] :: MANIFEST     :: PASS

  * TestStep :: 1.1 Default Properties [ensure => present] :: RESOURCE
1.1 Default Properties [ensure => present] :: RESOURCE     :: PASS

  * TestStep :: 1.1 Default Properties [ensure => present] :: IDEMPOTENCE
1.1 Default Properties [ensure => present] :: IDEMPOTENCE  :: PASS

  * TestStep :: 1.2 Default Properties [ensure => absent] :: MANIFEST
1.2 Default Properties [ensure => absent] :: MANIFEST     :: PASS

  * TestStep :: 1.2 Default Properties [ensure => absent] :: RESOURCE
1.2 Default Properties [ensure => absent] :: RESOURCE     :: PASS

  * TestStep :: 1.2 Default Properties [ensure => absent] :: IDEMPOTENCE
1.2 Default Properties [ensure => absent] :: IDEMPOTENCE  :: PASS

------------------------------------------------------------
Section 2. Non Default Property Testing

  * TestStep :: feature cleanup

  * TestStep :: 2.1 Non Default Properties 'M' commands [ensure => present] :: MANIFEST
2.1 Non Default Properties 'M' commands [ensure => present] :: MANIFEST     :: PASS

  * TestStep :: 2.1 Non Default Properties 'M' commands [ensure => present] :: RESOURCE
2.1 Non Default Properties 'M' commands [ensure => present] :: RESOURCE     :: PASS

  * TestStep :: 2.1 Non Default Properties 'M' commands [ensure => present] :: IDEMPOTENCE
2.1 Non Default Properties 'M' commands [ensure => present] :: IDEMPOTENCE  :: PASS

  * TestStep :: 2.2 Non Default Properties 'S' commands [ensure => present] :: MANIFEST
2.2 Non Default Properties 'S' commands [ensure => present] :: MANIFEST     :: PASS

  * TestStep :: 2.2 Non Default Properties 'S' commands [ensure => present] :: RESOURCE
2.2 Non Default Properties 'S' commands [ensure => present] :: RESOURCE     :: PASS

  * TestStep :: 2.2 Non Default Properties 'S' commands [ensure => present] :: IDEMPOTENCE
2.2 Non Default Properties 'S' commands [ensure => present] :: IDEMPOTENCE  :: PASS
TestCase :: Resource cisco_eigrp :: End
beaker_tests/eigrp/test_eigrp.rb passed in 85.15 seconds
      Test Suite: tests @ 2015-10-02 11:17:26 -0400

      - Host Configuration Summary -


              - Test Case Summary for suite 'tests' -
       Total Suite Time: 85.15 seconds
      Average Test Time: 85.15 seconds
              Attempted: 1
                 Passed: 1
                 Failed: 0
                Errored: 0
                Skipped: 0
                Pending: 0
                  Total: 1

      - Specific Test Case Status -

Failed Tests Cases:
Errored Tests Cases:
Skipped Tests Cases:
Pending Tests Cases:


No tests to run for suite 'post_suite'
Cleanup: cleaning up after successful run
Warning: ssh connection to 10.122.84.157 has been terminated
Warning: ssh connection to 10.122.84.53 has been terminated
Beaker completed successfully, thanks.
```

## <a name="sa">Static Analysis</a>

As noted in the other developer documents, you will need to run [rubocop](https://rubygems.org/gems/rubocop) prior to committing your new code:

~~~bash
% rubocop tunnel/test_tunnel.rb eigrp/test_eigrp.rb
Inspecting 2 files
..

2 files inspected, no offenses detected
~~~

## <a name="next">Next Steps</a>

Please see the [CONTRIBUTING](../CONTRIBUTING.md) document for workflow instructions.


--
## <a name="addendum">**ADDENDUM**: Test Script Variable Reference</a>

*-- This ADDENDUM is here temporarily until the entire document is rewritten.--*

--

# Beaker: Test Script Variable Reference

#### Table of Contents

* [Overview](#overview)
* [Test Prerequisites](#tp)
* [Return Codes](#rc)
* [The `tests` Hash](#tests)
 * [Top-level Keys](#tlk)
 * [Test Case Keys](#tck)
* [Title Pattern Testing](#tpt)

## <a name="overview">Overview</a>

The beaker test scripts have gone through a number of rewrites in an effort to reduce the time required to develop new test scripts. The current revision uses a `tests` hash as a container for all of the inputs required to fully run each test case. This document is a common reference for the `tests` hash and other required test variables.

## <a name="tp">Test Prerequisites</a>

Each test case in each test file makes basic assumptions about the state of the test environment:

* The beaker host configuration file is set up with proper access credentials for agent and master
* The Puppet Master daemon is running
* SSH is enabled in the agent environment
* The agent SSL certificate has been generated and signed by the Puppet Master

## <a name="rc">Return Codes</a>

The beaker tests will validate tests using return codes from bash and puppet commands:

#### Bash Command Return Codes

* `0` = successful command execution
* `> 0` = unsuccessful command execution

#### Puppet Command Return Codes

* `0` = No Changes have occurred (idempotence tests)
* `1` = An Error has been raised
* `2` = Changes have occurred (manifest tests)
* `4` = A Failure has occurred
* `6` = A Change and Failure has occurred

*Note: The beaker `on()` method has an optional `options` parameter, which allows the caller to specify `:acceptable_exit_codes`. If this is not specified it will default to `0`.*

## <a name="tests">The `tests` hash</a>

The `tests` hash is a convenient container for common and custom test variables. Common variables that are used by all test cases are defined as top-level keys, while each test case is a top-level key with the test case variables defined as the key-value; for example:

```ruby
# A top-level key for common variables
tests = {
  resource_name: 'cisco_bgp_neighbor_af',
}

# A test-case key with test variables within
tests[:bgp_weight] = {
  manifest_props: { weight: '30' },
}
```

Custom keys may be added for various unique test requirements but they should be documented in this guide.

### <a name="tlk">Top-level Keys</a>

##### Required Top-level keys

| Key Name         | Value and Usage
|:-----------------|:---------------
| `:agent`         | The `agent` object variable name. It is used for accessing the agent environment.
| `:master`        | The `master` object variable name. It is used for accessing the puppet master environment.
| `:resource_name` | The resource name used in the test. This is primarily used with the `puppet resource` command.

##### Optional Top-level keys

| Key Name         | Value and Usage
|:-----------------|:---------------
| `:asn`           | An Autonomous-System number. Used in some routing protocol tests.
| `:encap_prof_global` | The global encapsulation profile configuration. This configuration is a dependency for testing with `cisco_interface_service_vni`.
| `:ensurable`     | True/False. Defines whether a provider supports ensurable; typically only used to specify false, which prevents the test_harness from inserting an ensure value into the manifest. Also see Test Case key `:ensure`.
| `:intf_type`     | The interface type string, e.g. `ethernet`. Used in tests that require an interface, in which case the test will discover the first interface of that type to use for the tests.
| `:platform`      | A regexp pattern to match against the agent's product-id value. This is used to skip tests that don't support a feature or parameter. This key can be specified as a common top-level key or on a test-by-test basis.
| `:preclean`      | The resource name used to remove a configuration as part of testbed pre-cleanup. The resource does not have to be the same as the one being tested; for example, the `'cisco_bgp_af'` test might use `'cisco_bgp'` for `:preclean` if a full bgp cleanup is needed instead of just removing the `'cisco_bgp_af'` configuration. This key can be specified as a common top-level key or on a test-by-test basis.
| `:sid`           | The service ID (Integer). Used in `cisco_interface_service_vni` tests.

##### Example: Top-level Keys

```ruby
tests = {
  master:        master,
  agent:         agent,
  platform:      'n(3|9)k',          # Restrict testing to N3k & N9k
  resource_name: 'cisco_interface',
  intf_type:     'ethernet',
}
```

### <a name="tck">Test Case Keys</a>

The keys are all optional. Most test cases will typically only use `:desc` and `:manifest_props`.

| Key Name    | Value and Usage
|:------------|:---------------
| `:desc`           | A text description for the test case. This is used for logging and debugs.
| `:manifest_props` | A hash of property names and their values. The script will generate a manifest from this hash and create it as a file on the puppet master. If the `:resource` key is not specified then this hash will also be used to generate a hash of expected values for use by the `puppet resource` command validation test.
| `:platform`       | A regexp pattern to match against the agent's product-id value. This is used to skip tests that don't support a feature or parameter. This key can be specified as a common top-level key or on a test-by-test basis.
| `:preclean`       | The resource name used to remove a configuration as part of testbed pre-cleanup. The resource does not have to be the same as the one being tested; for example, the `'cisco_bgp_af'` test might use `'cisco_bgp'` for `:preclean` if a full bgp cleanup is needed instead of just removing the `'cisco_bgp_af'` configuration. This key can be specified as a common top-level key or on a test-by-test basis.
| `:resource`       | A hash of expected values from the `puppet resource` command. This is only needed when the expected values differ from the values defined by `:manifest_props`; for example: default testing may specify a value of `'default'` in the manifest but an expected value of `'true'` for the `puppet resource` command.
| `:ensure`         | The ensure value: `'present'` or `'absent'`. If not specified the test case will default to `'present'`. Also see Top-level key `:ensurable`.
| `:code`           | An array of acceptable return codes; e.g. `[0, 2]`. This is used to override the default return codes expected by the common test harness. It is rarely needed but some platforms / properties require this override.
| `:title_pattern`  | The title string to use in the manifest. Most providers use simple title patterns, in which case this is a simple string value. Providers like bgp_neighbor_af use complex title patterns, in which case they will use this key by itself for general property testing, then use it in combination with the `:title_params` key to perform complex title pattern testing.
| `:remote_as`      | An Autonomous-System number. Used in BGP tests to set up an eBGP configuraton to test eBGP-only properties.
| `:title_params` | A hash of title parameters. See [Title Pattern Testing](#tpt) below.


##### Example: Test Case: basic

```ruby
tests[:basic_1] = {
  manifest_props: {
    'allowas_in' => 'false',
  }
}
```

This simple test case definition tells the test harness to:

* set `:title_pattern` and `:desc` to key name (`'basic_1'`)
* ignore any platform checks (`:platform` is not specified)
* skip pre cleaning (`:preclean` is not specified)
* create a `:resource` expected values hash from `:manifest_props` since the expect values from `puppet resource` will be the same as those in the manifest


This test case can be called with the following syntax:

```ruby
test_harness_run(tests, :basic_1)
```

##### Example: Test Case: bgp_neighbor_af (defaults)


```ruby
tests[:default] = {
  desc:           'Default Properties',
  preclean:       'cisco_bgp',
  title_pattern:  '2 default 1.1.1.1 ipv4 unicast',
  manifest_props: {
    allowas_in:  'default',
  }
  resource:
    'allowas_in' => 'false',
  }
}
```

This test requires extra keys:

* An explicit `:desc` string is desired though not required
* bgp_neighbor_af has complex title patterns so using the test case key name won't work
* precleaning is required because it's the first test of many and the testbed state will be unknown
* `:manifest_props` is using `'default'` values so a `:resource` hash is needed to defined different expect values for `puppet resource`

This test case can be called with the following syntax:


```ruby
test_harness_run(tests, :default)
```

##### Example: Test Case: bgp_neighbor_af (non defaults)

```ruby
tests[:non_def_M] = {
  desc:           'Non Default: (M) max-prefix',
  manifest_props: {
    'allowas_in' => 'false',
  }
}
```

This tests the same property as the 'defaults' test before it but in this case it's just explicitly setting the property value so it just needs `:manifest_props` defined. The `:desc` is helpful but not required.

This test case can be called with the following syntax:

```ruby
test_harness_run(tests, :non_def_M)
```


### <a name="tpt">Title Pattern Testing</a>

Some providers support complex title patterns, in which case parameters (*these are the `newparameter()` methods found in the resource type files*) can obtain their values from
 either explicit assignments or from the title pattern itself; e.g.

```ruby
# Example A. parameters from the title string only

cisco_bgp { '55 red': }

# Example B. parameters from both the title string and explicit assignment

cisco_bgp { '55':
  vrf => 'red'
}
```

The `puppet resource` command requires a full title string that contains all of the required parameters, so the title string in Example A will not work by itself and the string must be merged appropriately with the explicit parameters to use it with `puppet resource`.

General property testing will not need this special title pattern munging but there should be additional testing for just the title patterns. This can be accomplished by using the `:title_params` key to define explicit title parameters to munge with a less explicit `:title_pattern`, resulting in a complete title string for puppet resource.

##### Example: bgp_neighbor_af `title_pattern` test cases

```ruby
tests[:title_patterns_1] = {
  desc:          'T.1 Title Pattern',
  preclean:      'cisco_vrf',
  title_pattern: 'new_york',
  title_params:  { vrf: 'red', afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
  # This test will result in a manifest title string: 'new_york'
  # and a puppet resource title string: 'red ipv4 unicast'
}

tests[:title_patterns_2] = {
  desc:          'T.2 Title Pattern',
  title_pattern: 'blue',
  title_params:  { afi: 'ipv4', safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
  # This test will result in a manifest title string: 'blue'
  # and a puppet resource title string: 'blue ipv4 unicast'
}

tests[:title_patterns_3] = {
  desc:          'T.3 Title Pattern',
  title_pattern: 'cyan ipv4',
  title_params:  { safi: 'unicast' },
  resource:      { 'ensure' => 'present' },
  # This test will result in a manifest title string: 'cyan ipv4'
  # and a puppet resource title string: 'cyan ipv4 unicast'
}
```
The title pattern tests can now be called with this syntax:

```ruby
  test_harness_run(tests, :title_patterns_1)
  test_harness_run(tests, :title_patterns_2)
  test_harness_run(tests, :title_patterns_3)
```
