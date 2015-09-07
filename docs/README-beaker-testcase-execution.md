# Beaker Test Case Execution For Cisco Systems' Puppet providers #

## Beaker Test Environment ##

The Beaker execution test environment for Cisco Systems' Puppet provider test cases on Nexus devices assumes that the following prerequisites are satisfied before start of execution:

A. Install the Beaker and Bundler gems on a workstation (VM, server, etc) that has network connectivity to both the Puppet master and agent: `gem install beaker` and `gem install bundler`. This 'beaker' workstation may be a separate device from the Puppet master and agent. Create the Beaker test environment on the workstation using the following reference: https://github.com/puppetlabs/beaker/wiki/Creating-A-Test-Environment. 

B. Populate the Beaker host configuration file on the workstation.

C. Nexus switch setup: Enable SSH and create a 'devops' userid with sudo privileges and access to the `bash-shell` environment. No other Nexus switch specific configuration steps should be required for executing Beaker tests.

**Example:**

```bash
configure terminal
  feature ssh
  username devops password devopspassword role network-admin
  username devops shelltype bash
end
```

D. Start the Puppet master.

E. Configure SSL certificate exchange between Puppet master and agent.

## Beaker Test Case Execution ##

A Beaker test case can be executed with these instructions:

(1) cd to the directory that is the top-level for Beaker test directories. This is the repository based path: @cisco-ciscopuppet/tests/beaker_tests.

(2) Execute the 'beaker' command string shown below with the mentioned options to do a testrun for all test cases under the @cisco-ciscopuppet/ directory. This will aggregate all test case results after a single test run.

~~~
beaker --hosts hosts.cfg \
--pre-suite tests/beaker_tests/presuite/presuite-certcheck.rb \
--no-validate --no-configure \
--test tests/beaker_tests/
~~~

The --debug option may be added if detailed Beaker testcode debug logs are desired.

The --no-validate option disables validation of the host switch that is performed by default by the Beaker tool. This host validation will currently fail for Nexus platform.

The --no-configure option prevents any host or VM images from being configured on the host switch that is performed by default by the Beaker tool. No such host configuration is necessary for executing Beaker tests. 

 






