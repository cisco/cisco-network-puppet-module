# Beaker Test Case Writing For Cisco Systems' Puppet providers #


## Beaker Test Cases ##

Each Puppet provider test case is implemented in a single Beaker test script. A test directory will consist of a suite of test scripts that test a single Puppet provider. 

The test case names follow the convention of testdirname-provider-defaults.rb or testdirname-provider-nondefaults.rb or testdirname-provider-negatives.rb. As the naming convention shows, the defaults testcase tests for default attribute values of a Puppet provider resource instance while the non-defaults testcase tests for non-default attribute values of a Puppet provider resource instance. The negative testcase tests for negative attribute values of a Puppet provider resource instance. 

## Beaker Test Case Sections ##

Every Beaker test case is expected to have:

- a test case setup section, 
- a resource creation section and  
- a resource deletion section. 

The setup section sets the switch up for test case execution. 

The creation section creates the Puppet resource instance and performs attribute verification using resource command on switch agent. It also verifies the switch state using NXOS running-config show CLI commands.

The deletion section deletes the Puppet resource instance and performs attribute verification using resource command on switch agent. It also verifies the lack of switch state using NXOS running-config show CLI commands. 

The library file in the test directory is expected to contain the manifest generation methods defined in a module for usage in the test cases.

## Beaker Test Case Writing ##

A new Beaker test case may be added using these instructions:

(1) Add a Setup test step to the test script. This step will consist of setting the Puppet Master's manifest filename as well as cleaning up the switch test state before start of further test steps using a call to `on()` method with the command string set to the vshell command for the feature cleanup for the particular Puppet provider in test.

(2) Add a set of test steps after (1) for the creation of the Puppet provider resource. This section will consist of a `puppet agent` command transaction executed using `on()` method invocation with host set to agent, command set to the `puppet agent` command string to get the creation manifest with `ensure` set to `present` from the master server and the expected exit code for a successful transaction. It will be followed by verification of resource attributes using an `on()` method invocation with command string set to the `puppet resource` command for the resource instance of the Puppet provider. Further verification will involve a call to `on()` method using a command string set to the `vshell` command for the NXOS running-config show CLI. The matching in these test steps will occur for presence of RegExp patterns.

(3) Add another set of test steps after (2) for the deletion of the Puppet provider resource. The list of test steps will be similar to (2) except that the manifest will typically have the `ensure` attribute set to `absent` to delete the resource. The resource attribute verification and show running-config CLI command verification steps will be similar to (2) except that the matching will occur for absence of RegExp patterns.

## Beaker Test Case Template ##

There is a sample Beaker test template located at @cisco-ciscopuppet/docs/ called template-provider-ensurabilitytest.rb that can be used to write test cases for Puppet providers. The test template is written for a sample Cisco Systems' Nexus Puppet provider called cisco_provider. It is a single test case that is implemented in a Beaker test script. 

 