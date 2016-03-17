# Automated Puppet Agent Installation Using Beaker:

#### Table of Contents

1. [Overview](#overview)
1. [Pre-Install Tasks](#pre-install)
1. [Beaker Installer Configuration](#beaker-install-config)
1. [Automated Puppet Agent Install: bash-shell](#install-bs)
1. [Automated Puppet Agent Install: guestshell](#install-gs)
1. [License Information](#license-information)

## <a name="overview">Overview</a>

This document describes automated Puppet agent installation and setup on Cisco Nexus switches using Puppet Labs [Beaker](https://github.com/puppetlabs/beaker/blob/master/README.md).

## <a name="pre-install">Pre-Install Tasks</a>

Refer to [README-beaker-prerequisites](RADME-beaker-prerequisites.md) for required setup steps for Beaker and the target agent node.

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

## <a name="license-information">License Information</a>

~~~
Copyright (c) 2014-2016 Cisco and/or its affiliates.

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
