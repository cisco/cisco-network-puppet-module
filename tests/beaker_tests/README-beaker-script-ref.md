# Beaker Test Script Guide to Test Inputs

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

*Note: The `on()` method returns `0` as its default exit code*

## <a name="tests">The `tests` hash</a>

The tests hash is a convenient container for common and custom test variables. Common variables that are used by all test cases are defined as top-level keys, while each test case is a top-level key with the test case variables defined as the key-value; for example:

```
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

*Req = Required, Opt = Optional*

|     | Key Name         | Value and Usage
|:--- |:-----------------|:---------------
| Req | `:agent`         | The `agent` object variable name. It is used for accessing the agent environment.
| Req | `:master`        | The `master` object variable name. It is used for accessing the puppet master environment.
| Req | `:resource_name` | The resource name used in the test. This is used with the `puppet resource` command as well as the testheader value in some tests.
| Opt | `:asn`           | An Autonomous-System number. Used in some routing protocol tests.
| Opt | `:encap_prof_global` | The global encapsulation profile configuration. This configuration is a dependency for testing with `cisco_interface_service_vni`.
| Opt | `:intf_type`     | The interface type string, e.g. `ethernet`. Used in tests that require an interface, in which case the test will discover the first interface of that type to use for the tests.
| Opt | `:platform`      | A regexp pattern to match against the agent's product-id value. This is used to skip tests that don't support a feature or parameter. This key can be specified as a common top-level key or on a test-by-test basis.
| Opt | `:preclean`      | The resource name used to remove a configuration as part of testbed pre-cleanup. The resource does not have to be the same as the one being tested; for example, the `'cisco_bgp_af'` test might use `'cisco_bgp'` for `:preclean` if a full bgp cleanup is needed instead of just removing the `'cisco_bgp_af'` configuration. This key can be specified as a common top-level key or on a test-by-test basis.
| Opt | `:sid`           | The service ID (Integer). Used in `cisco_interface_service_vni` tests.

##### Example: Top-level Keys

```
tests = {
  master:        master,
  agent:         agent,
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
| `:ensure`         | The ensure value: `'present'` or `'absent'`. If not specified the test case will default to `'present'`.
| `:code`           | An array of acceptable return codes; e.g. `[0, 2]`. This is used to override the default return codes expected by the common test harness. It is rarely needed but some platforms / properties require this override.
| `:title_pattern`  | The title string to use in the manifest. Most providers use simple title patterns, in which case this is a simple string value. Providers like bgp_neighbor_af use complex title patterns, in which case they will use this key by itself for general property testing, then use it in combination with the `:title_params` key to perform complex title pattern testing.
| `:remote_as`      | An Autonomous-System number. Used in BGP tests to set up an eBGP configuraton to test eBGP-only properties.
| `:title_params` | A hash of title parameters. See [Title Pattern Testing](#tpt) below.


##### Example: Test Case: basic

```
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

```
test_harness_run(tests, :basic_1)
```

##### Example: Test Case: bgp_neighbor_af (defaults)


```
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


```
test_harness_run(tests, :default)
```

##### Example: Test Case: bgp_neighbor_af (non defaults)

```
tests[:non_def_M] = {
  desc:           'Non Default: (M) max-prefix',
  manifest_props: {
    'allowas_in' => 'false',
  }
}
```

This tests the same property as the 'defaults' test before it but in this case it's just explicitly setting the property value so it just needs `:manifest_props` defined. The `:desc` is helpful but not required.

This test case can be called with the following syntax:

```
test_harness_run(tests, :non_def_M)
```


### <a name="tpt">Title Pattern Testing</a>

Some providers support complex title patterns, in which case parameters (*these are the `newparameter()` methods found in the resource type files*) can obtain their values from
 either explicit assignments or from the title pattern itself; e.g.

```
# Example A. parameters from the title string only

cisco_bgp { '55 red': }

# Example B. parameters from both the title string and explicit assignment

cisco_bgp { '55':
  vrf => 'red'
}
```

The `puppet resource` command requires a full title string that contains all of the required parameters, so the title string in Example A will not work by itself and the string must be merged appropriately with the explicit parameters to use it with `puppet resource`.

General property testing will not need this special title pattern munging but there should be additional testing for just the title patterns. This can be accomplished by creating a `titles` hash
in addition to the tests hash entry for the test case:

##### Example: bgp_neighbor_af `titles` hash

```
tests[:title_patterns] = {
  manifest_props: {},
  resource:       { 'ensure' => 'present' },
}

titles = {}
titles['T.1'] = {
  title_pattern: '2 blue',
  title_params:  { neighbor: '1.1.1.1', afi: 'ipv4', safi: 'unicast' },
}
titles['T.2'] = {
  title_pattern: '2 cyan 2.2.2.2',
  title_params:  { afi: 'ipv4', safi: 'unicast' },
}
titles['T.3'] = {
  title_pattern: '2 green 3.3.3.3 ipv4',
  title_params:  { safi: 'unicast' },
}
```

The title pattern tests can be called with this syntax:

```
  test_title_patterns(tests, :title_patterns, titles)
```
