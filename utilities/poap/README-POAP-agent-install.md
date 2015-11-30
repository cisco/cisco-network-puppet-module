# POAP: Puppet Agent Installation & Setup
#### Table of Contents

1. [Overview](#overview)
1. [Pre-Install Tasks](#pre-install)
1. [Script Parameters](#parms)
1. [Script Execution](#execute)
1. [Non-POAP Installation Methods](#nonpoap)
1. [References](#references)

## <a name="overview">Overview</a>

This document describes automated Puppet agent installation and setup on Cisco Nexus switches using PowerOn Auto Provisioning (POAP). See the [Non-POAP Installation](#nonpoap) section for other puppet agent installation methods.

Automated installation is achieved with a python script that performs the following tasks in the agent environment:

1. Set up basic networking and verify reachability
1. Install the Puppet Agent RPM
1. Set up the `puppet.conf` file
1. Execute an initial puppet agent run to generate SSL certificates

## <a name="pre-install">Pre-Install Tasks</a>

**Platform Requirements**

Please reference the **Pre-Install Tasks** section of the [README-agent-install.md][agent doc] document for a list of minimum platform and software requirements.

**POAP Infrastructure**

This document focuses on Puppet Agent installation and setup only. For more information regarding POAP Installation and Usage please see [Using PowerOn Auto Provisioning][poap doc]. This document assumes that the appropriate network infrastructure is present for POAP automation, ie. a DHCP server for bootstrapping the cisco device and a script server (TFTP/HTTP) containing device images and configuration scripts.

**Puppet Install Script**

The script is a python file found under the utilities directory:

```
cisco-network-puppet-module/utilities/poap/puppet_agent_install.py
```

Copy the script to your script server and modify your POAP configuration script to call `puppet_agent_install.py`. See [Script Parameters](#script) for guidance on modifying the `puppet_agent_install.py` settings to reflect your requirements.

## <a name="parms">Script Parameters</a>

The script has a number of required and optional parameters. Change these parameters in the script or set environment variables to override the script values.

##### MD5 Checksum

Please note that the md5 checksum should be recalculated if any changes are made to the `puppet_agent_install.py` script. The checksum is specified on line 2 of the script; it will be automatically updated by issuing the following command after making any changes:

```
f=puppet_agent_install.py ; cat $f | sed '/^#md5sum/d' > $f.md5 ; sed -i "s/^#md5sum=.*/#md5sum=$(md5sum $f.md5 | sed 's/ .*//')/" $f
```

##### Required Parameters

* `RPM_NAME` This is the puppet agent release RPM, specific to the agent environment (bash shell or guestshell environment). The following RPM names are shown as examples, please check http://yum.puppetlabs.com for the latest rpm names.
  * *bash shell*: `RPM_NAME = 'puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm'`
  * *guestshell*: `RPM_NAME = 'puppetlabs-release-pc1-el-7.noarch.rpm'`

* `RPM_URI` Specify the download URI for `RPM_NAME`.
  * *Example*: `RPM_URI = 'http://yum.puppetlabs.com/'`
  * *Example*: `RPM_URI = 'ftp://1.2.3.4/'`

* `PUPPET_SERVER` Specify the DNS name or IP address of the agent's puppet server.
  * *Example*: `PUPPET_SERVER = 'mypuppetsrvr.mycompany.com'`

##### Optional Parameters

* `DOMAIN` Optionally specify a domain name to be used with hostname to form the certname in the agent's puppet.conf; e.g. if the agent hostname is 'blue10' and DOMAIN is set to 'mycompany.com', then the certname in puppet.conf will become 'certname = blue10.mycompany.com'. If DOMAIN is not specified then the certname will simply become 'blue10'.
  * *Example*: `DOMAIN = 'mycompany.com'`

* `DNS` Optionally specify the text to populate the `/etc/resolv.conf` file. Use python's triple-quote syntax to specify multiple lines:
  * *Example*:

  ```
  DNS = '''
  nameserver 1.2.3.4
  nameserver 5.6.7.8
  domain mycompany.com
  search mycompany.com
  '''
  ```

* `VRF` Optionally specify the agent's VRF to use for the RPM install. This will typically be set to `management` or not used at all.
  * *Example*: `VRF = 'management'`

* `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` Optionally specify local proxy server settings.
  * *Example*: `HTTP_PROXY = 'http://proxy.mycompany.com:8080'`
  * *Example*: `HTTPS_PROXY = 'https://proxy.mycompany.com:8080'`
  * *Example*: `NO_PROXY = ''`


## <a name="execute">Script Execution</a>

The script may be also be run manually for test purposes. Simply copy the script file to the agent environment (bash_shell or guestshell) and call the script with python:

```
python puppet_agent_install.py
```

## <a name="nonpoap">Non-POAP Installation Methods</a>

[Manual][agent doc] - Manual installation and configuration of Puppet Agent

[Beaker](../../docs/README-beaker-agent-install.md) - Installing and Configuring Puppet Agent Using the Beaker Tool

## <a name="references">References</a>

[Using PowerOn Auto Provisioning][poap doc] - How to deploy and use POAP

[Cisco Nexus Puppet Modules](../../README.md) - Types, Providers, Utilities

[Cisco Nexus Programmability Guide](http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html) - Guestshell Documentation


[agent doc]: ../../docs/README-agent-install.md
[poap doc]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus3000/sw/fundamentals/503_U3_1/b_Nexus_3000_Fundamentals_Guide_Release_503_U3_1/using_power_on_auto_provisioning.pdf
----
~~~
Copyright (c) 2014-2015 Cisco and/or its affiliates.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
~~~
