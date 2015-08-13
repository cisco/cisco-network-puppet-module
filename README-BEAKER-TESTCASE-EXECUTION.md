# Beaker Test Case Execution For Cisco Systems' Puppet providers #

## Beaker Test Environment ##

The Beaker execution test environment for Cisco Systems' Puppet provider test cases on Nexus devices assumes that the following prerequisites are satisfied before start of execution:

A. Install Beaker and Bundle software on a test server or VM that can ping both the Puppet master and agent successfully. The test server or VM used to execute Beaker test cases is distinct from the Puppet master and agent. Create the Beaker test environment on the test server or VM using this HTTPs wiki link as a reference: https://github.com/puppetlabs/beaker/wiki/Creating-A-Test-Environment. 

B. Populate the Beaker host configuration file on the test server or VM that is used to execute Beaker test cases. 

C. Enable SSH on the Nexus switch. No other Nexus switch specific configuration steps should be required for executing Beaker tests.  

D. Start the Puppet master.

E. Configure SSL certificate exchange between Puppet master and agent.

## Beaker Test Cases ##

Each Puppet provider test case is implemented in a single Beaker test script. A test directory will consist of a suite of test scripts that test a single Puppet provider. 

The test case names follow the convention of testdirname-provider-defaults.rb or testdirname-provider-nondefaults.rb or testdirname-provider-negatives.rb. As the naming convention shows, the defaults testcase tests for default attribute values of a Puppet provider resource instance while the non-defaults testcase tests for non-default attribute values of a Puppet provider resource instance. The negative testcase tests for negative attribute values of a Puppet provider resource instance. 

## Beaker Test Case Execution ##

A Beaker test case can be executed with these instructions:

(1) cd to the directory that is the top-level for Beaker test directories. This is the repository based path: @cisco-ciscopuppet/tests/beaker_tests.

(2) Execute the 'bundle exec beaker' command string from below with the mentioned options to do a testrun for all test cases under the @cisco-ciscopuppet/tests/beaker_tests directory. This will aggregate all test case results after a single test run.

~~~
beaker --hosts hosts.cfg \
--pre-suite tests/beaker_tests/presuite/presuite-certcheck.rb \
--no-validate --no-configure \
--test tests/beaker_tests/*/*-provider-*.rb
~~~

The --debug option may be added if detailed Beaker testcode debug logs are desired.

The --no-validate option disables validation of the host switch that is performed by default by the Beaker tool. This host validation will currently fail for Nexus platform.

The --no-configure option prevents any host or VM images from being configured on the host switch that is performed by default by the Beaker tool. No such host configuration is necessary for executing Beaker tests. 

 






