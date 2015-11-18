# How To Create Beaker Test Cases

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

## <a name="overview">Overview</a>

This document describes the process for writing [Beaker](https://github.com/puppetlabs/beaker/blob/master/README.md) Test Cases for cisco puppet providers.

## <a name="pre-install">Pre-Install Tasks</a>

### Platform and Software Support

Beaker Release 2.14.1 and later.

### Disk space

400MB of free disk space on bootflash is recommended before installing the
puppet agent software on the target agent node.

### Environment
NX-OS supports two possible environments for running 3rd party software:
`bash-shell` and `guestshell`. Choose one environment for running the
puppet agent software. You may run puppet from either environment but not both
at the same time.

* `bash-shell`
  * This is the native WRL linux environment underlying NX-OS. It is disabled by default.
* `guestshell`
  * This is a secure linux container environment running CentOS. It is enabled by default.

Access the following [link](README-agent-install.md) for more information on enabling these environments.

### Install Beaker

[Install Beaker](https://github.com/puppetlabs/beaker/wiki/Beaker-Installation) on your designated beaker server.

### Configure NX-OS

You must enable the ssh feature and give sudo access to the 'devops' user for the Beaker workstation to access the Puppet agent during testing.

**Example:**

~~~bash
configure terminal
  feature ssh
  username devops password devopspassword role network-admin
  username devops shelltype bash
end
~~~

## <a name="beaker-config">Beaker Server Configuration</a>

The following commands should be run on your Beaker workstation.

~~~
$ git clone https://github.com/cisco/cisco-network-puppet-module.git
$ cd cisco-network-puppet-module/tests/beaker_tests/
~~~

### Create `host.cfg` File

Under the `beaker_tests` directory, create file named `host.cfg` and add the following content.

Note: If running puppet on XR, specify the gRPC port number configured on the switch.

Replace the `< >` markers with specific information.

```bash
HOSTS:
    <agent1>:
        roles:
            - agent
        platform: cisco-7-x86_64
        ip: <fully qualified domain name>
        grpc_port <grpc port number for XR switch>
        vrf: <vrf used for beaker workstation and puppet master ip reachability>
        ssh:
          auth_methods: ["password"]
          user: <configured bash-shell username>
          password: <configured bash-shell password>
        #Uncomment the following line to install into the guestshell
        #target: guestshell


    #<agent2>:
    #  <...>

    #<agent3>:
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
    agent1:
        roles:
            - agent
        platform: cisco-7-x86_64
        ip: agent1.domain.com
        vrf: management
        #target: guestshell
        ssh:
          auth_methods: ["password"]
          user: devops
          password: devopspassword

    xr-agent:
        roles:
            - agent
        platform: cisco-7-x86_64
        ip: xr_agent.domain.com
        vrf: tpnns
        grpc_port: 57777
        ssh:
          auth_methods: ["password"]
          user: root
          password: password

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
  cmd = UtilityLib::PUPPET_BINPATH + 'resource cisco_tunnel'
  UtilityLib.get_namespace_cmd(agent, cmd, options)
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
  cmd = UtilityLib::PUPPET_BINPATH + 'resource cisco_router_eigrp'
  UtilityLib.get_namespace_cmd(agent, cmd, options)
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
