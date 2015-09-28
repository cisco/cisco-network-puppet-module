# Automated Puppet Agent Installation Using Beaker:

#### Table of Contents

1. [Overview](#overview)
2. [Pre-Install Tasks](#pre-install)
3. [Beaker Installer Configuration](#beaker-install-config)
4. [Automated Puppet Agent Install: bash-shell](#install-bs)
5. [Automated Puppet Agent Install: guestshell](#install-gs)
6. [Limitations](#limitations)
7. [License Information](#license-information)

## <a name="overview">Overview</a>

This document describes automated Puppet agent installation and setup on Cisco Nexus switches using Puppet Labs [Beaker](https://github.com/puppetlabs/beaker/blob/master/README.md).

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

[Install Beaker](https://github.com/puppetlabs/beaker/wiki/Beaker-Installation) on your designated server.

### Configure NX-OS

You must enable the ssh feature and give sudo access to the 'devops' user for the Beaker workstation to access and install the Puppet agent software into the `bash-shell` or `guestshell` environment.

**Example:**

~~~bash
configure terminal
  feature ssh
  username devops password devopspassword role network-admin
  username devops shelltype bash
end
~~~

## <a name="beaker-install-config">Beaker Installer Configuration</a>

### Access the automated Puppet agent installer

The following commands should be run on your Beaker workstation.

~~~
$ git clone https://github.com/cisco/cisco-network-puppet-module.git
$ cd cisco-network-puppet-module/utilities/installer/
~~~

### Copy and modify the SAMPLE* configuration files.

Within the `installer` directory, make copies of and modify the following configuration files. Any naming convention can be used when making copies of the files.

SAMPLE_host.cfg (***Mandatory***)

SAMPLE_puppet.conf (***Optional***)

SAMPLE_resolver.conf (***Optional***)

The `installer` directory also contains the **install_puppet.rb** script that is used to install the agent rpm.

### Modify host.cfg

See the SAMPLE_host.cfg file for examples on how to modify the host.cfg file for your network.

### Modify puppet.conf

This is an optional template that can be used to configure the Puppet agent. The `certname` and `server` fields are automatically filled in using the information from the host.cfg file. If the template is not used, the installer configures the default puppet.conf file created as part of the rpm install.

**Example:**

~~~ini
[main]
    vardir = /var/opt/lib/pe-puppet
    logdir = /var/log/pe-puppet
    rundir = /var/run/pe-puppet
    basemodulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules
    user  = pe-puppet
    group = pe-puppet
    archive_files = true


[agent]
    report = true
    classfile = $vardir/classes.txt
    localconfig = $vardir/localconfig
    graph = true
    pluginsync =  true
    environment = production
~~~

Enable use of the puppet.conf template file by setting **`puppet_config_template:`** in the host.cfg file.

### Modify resolver.conf

This is an optional file that contains information that needs to be configured in the `/etc/resolv.conf` file on the Puppet agent.

**Example:**

~~~
nameserver <IP>
domain yourdomain.com
search yourdomain.com
~~~

Enable use of the resolver.conf file by setting **`resolver:`** in the host.cfg file.

## <a name="install-bs">Automated Puppet Agent Install: bash-shell</a>

On the Beaker workstation, run the following command:

~~~bash
beaker --host <path to host.cfg> --pre-suite <path to install_puppet.rb> --no-validate --no-config
~~~

**Note:** Make sure the `target: guestshell` field is commented out in the host.cfg file.

## <a name="install-gs">Automated Puppet Agent Install: guestshell</a>

For installs into the `guestshell`, uncomment the `target: guestshell` field in the host.cfg file and run the Beaker tool.

## <a name="limitations">Limitations</a>

Minimum Requirements:
* Cisco NX-OS Puppet implementation requires open source Puppet version 4.0 or Puppet Enterprise 2015.2
* Supported Platforms:
 * Cisco Nexus 95xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
 * Cisco Nexus 93xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
 * Cisco Nexus 31xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
 * Cisco Nexus 30xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell

## <a name="license-information">License Information</a>

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
