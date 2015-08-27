# Puppet Agent Installation & Setup: Cisco Nexus

#### Table of Contents

1. [Overview](#overview)
2. [Pre-Install Tasks](#pre-install)
3. [Puppet Agent Environment: bash-shell](#env-bs)
4. [Puppet Agent Environment: guestshell](#env-gs)
5. [Puppet Agent Installation, Configuration and Usage](#agent-config)
6. [Optional: Guestshell & High Availability (HA) Platforms](#ha)
7. [Optional: Puppet Agent Persistence](#persistence)
8. [Optional: Automated Installation Options](#auto-install)
9. [References](#references)

## <a name="overview">Overview</a>

This document describes Puppet agent installation and setup on Cisco Nexus switches. These instructions focus on manual setup. See the [Automated Installation](#auto-install) section for documentation regarding alternative installation methods.

![1](puppet_outline.png)

## <a name="pre-install">Pre-Install Tasks</a>

#### Platform and Software Minimum Requirements

* The Cisco NX-OS Puppet implementation requires open source Puppet version 4.0 or Puppet Enterprise 2015.2
* Cisco NX-OS release 7.0(3)I2(1)
* Supported Platforms: Cisco Nexus 95xx, Nexus 93xx, Nexus 30xx, Nexus 31xx

#### Disk space

400MB of free disk space on bootflash is recommended before installing the
Puppet agent software.

#### Environment

NX-OS supports two possible environments for running third party software:
`bash-shell` and `guestshell`. Choose one environment for running the
Puppet agent software. You may run Puppet from either environment but not from both
at the same time.

* `bash-shell`
  * This is the native WRL Linux environment underlying NX-OS. It is disabled by default.
* `guestshell`
  * This is a secure Linux container environment running CentOS. It is enabled by default in most platforms.

#### Set Up the Network

Ensure that you have network connectivity prior to Puppet installation. Some basic NX-OS cli configuration may be necessary.

**Example:** Connectivity via management interface

_Note: The management interface exists in a separate VRF context and requires additional configuration as shown._

~~~
config term
  ntp server 10.0.0.201 use-vrf management

  vrf context management
    ip name-server 10.0.0.202
    ip domain-name mycompany.com
    ip route 0.0.0.0/0 10.0.0.1

  interface mgmt0
    vrf member management
    ip address 10.0.0.99/24
end
~~~

## <a name="env-bs">Puppet Agent Environment: bash-shell</a>

This section is only necessary if Puppet will run from the `bash-shell`.

#### Set Up NX-OS

The `bash-shell` is disabled by default. Enable it with the feature configuration command.

~~~
config term
  feature bash-shell
end
~~~

#### Install Puppet Agent in bash-shell

Enter the `bash-shell` environment and become root:

~~~bash
n3k# run bash
bash-4.2$
bash-4.2$  sudo su -
~~~

If you're using the management interface, you must next switch to the management namespace:

~~~bash
ip netns exec management bash
~~~

Then set up DNS configuration:

~~~
cat >> /etc/resolv.conf << EOF
nameserver 10.0.0.202
domain mycompany.com
search mycompany.com
EOF
~~~

Optionally, configure a proxy server:

~~~bash
export http_proxy=http://proxy.yourdomain.com:<port>
export https_proxy=https://proxy.yourdomain.com:<port>
~~~

## <a name="env-gs">Puppet Agent Environment: guestshell</a>

This section is only necessary if Puppet will run from the `guestshell`.

#### Set Up NX-OS

The `guestshell` container environment is enabled by default on most platforms; however, the default disk and memory resources allocated to the guestshell container might be too small to support Puppet agent requirements. These resource limits can be increased with the NX-OS CLI `guestshell resize` commands as shown below.

The recommended minimum values are currently:

~~~bash
  Disk   : 400MB
  Memory : 300MB
~~~
  
Use the `show guestshell detail` command to display the current state of the guestshell:

~~~
n3k# show guestshell detail
Virtual service guestshell+ detail
  State                 : Activated
 ...
    Resource reservation
    Disk                : 150 MB
    Memory              : 128 MB

~~~

To resize the guestshell filesystem, use the `guestshell resize rootfs` command. To resize the guestshell memory allocation, use the `guestshell resize memory` command. These commands can be executed even when the guestshell is not yet enabled. Note that the resize command does not take effect until after the guestshell container is (re)started with the `guestshell reboot` or `guestshell enable` command.

**Example.** Guestshell is currently enabled. Resize guestshell filesystem to 400MB and memory to 300MB:

~~~
n3k# guestshell resize rootfs ?
  <158-600>  New root filesystem size (in MB)

n3k# guestshell resize rootfs 400
Note: Please disable/enable or reboot the Guest shell for root filesystem to be resized

n3k# guestshell resize memory 300
Note: Please disable/enable or reboot the Guest shell for system memory to be resized

n3k# guestshell reboot
Access to the guest shell will be temporarily disabled while it reboots.
Are you sure you want to reboot the guest shell? (y/n) [n] y
~~~

**Example.** Guestshell is currently disabled. Resize guestshell filesystem to 400MB and memory to 300MB:

~~~
n3k# guestshell resize rootfs 400
Note: Root filesystem will be resized on Guest shell enable

n3k# guestshell resize memory 300
Note: System memory will be resized on Guest shell enable

n3k# guestshell enable
~~~

See [References](#references) for more guestshell documentation.

#### Set Up Guestshell Network

The `guestshell` is an independent CentOS container that doesn't inherit settings from NX-OS; thus it requires additional network configuration.

~~~bash
# Enter the guestshell environment using the 'guestshell' command
guestshell

# If using the management interface, you must enter the management namespace
sudo su -
chvrf management

# Set up hostname and DNS configuration
hostname n3k

echo 'n3k' > /etc/hostname

cat >> /etc/resolv.conf << EOF
nameserver 10.0.0.202
domain mycompany.com
search mycompany.com
EOF
~~~

## <a name="agent-config">Puppet Agent Installation, Configuration, and Usage</a>

This section is common to both `bash-shell` and `guestshell`.

#### Install Puppet Agent

The `bash-shell` and `guestshell` environments use different puppet RPMs.

* For `bash-shell` use:

~~~bash
yum install http://yum.puppetlabs.com/puppetlabs-release-pc1-nxos-5.noarch.rpm
yum install puppet
~~~

* For `guestshell` use:

~~~bash
yum install http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet
~~~

Update PATH var:

~~~bash
export PATH=$PATH:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/puppet/lib
~~~

####Edit the Puppet config file:

**/etc/puppetlabs/puppet/puppet.conf**

This file can be used to override the default Puppet settings. At a minimum, the following settings should be used:

~~~bash
[main]
  server = mypuppetmaster.mycompany.com

[agent]
  pluginsync  = true
  ignorecache = true
~~~

See the following references for more puppet.conf settings:

<https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html>
<https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html>
<https://docs.puppetlabs.com/puppet/latest/reference/config_file_main.html>
<https://docs.puppetlabs.com/references/latest/configuration.html>

#### Run the Puppet Agent

~~~bash
puppet agent -t
~~~

## <a name="ha">Guestshell & High Availability (HA) Platforms</a>

Optional. This section discusses `guestshell` usage on HA platforms. This section does not apply to the bash-shell environment or to single-sup platforms.

The `guestshell` container does not automatically sync filesystem changes from the active processor to the standby processor. This means that Puppet installation files and related file changes performed in the earlier steps will not be present on the standby until they are manually synced with the following NX-OS exec command:

~~~
guestshell sync
~~~

## <a name="persistence">Puppet Agent Persistence</a>

Optional. This section discusses Puppet agent persistence after system restarts.

1. [Service Management in bash-shell using init.d](#svc-mgmt-bs)
2. [Service Management in guestshell using systemd](#svc-mgmt-gs)

#### Service Management

It may be desirable to set up automatic restart of the Puppet agent in the event of a system reset. The bash and guestshell environments use different methods to achieve this.

#### <a name="svc-mgmt-bs">Optional: bash-shell / init.d</a>

The `bash-shell` environment uses **init.d** for service management.
The Puppet agent provides a generic init.d script when installed, but a slight
modification is needed to ensure that Puppet runs in the management namespace:

~~~diff
--- /etc/init.d/puppet.old
+++ /etc/init.d/puppet
@@ -38,7 +38,7 @@
 
 start() {
     echo -n $"Starting puppet agent: "
-    daemon $daemonopts $puppetd ${PUPPET_OPTS} ${PUPPET_EXTRA_OPTS}
+    daemon $daemonopts ip netns exec management $puppetd ${PUPPET_OPTS} ${PUPPET_EXTRA_OPTS}
     RETVAL=$?
     echo
         [ $RETVAL = 0 ] && touch ${lockfile}
~~~

Next, enable the puppet service to be automatically started at boot time, and optionally start it now:

~~~bash
chkconfig --add puppet
chkconfig --level 345 puppet on

service puppet start
~~~

#### <a name="svc-mgmt-gs">Optional: guestshell / systemd</a>

The `guestshell` environment uses **systemd** for service management.
The Puppet agent provides a generic systemd script when installed, but a slight modification
is needed to ensure that Puppet runs in the management namespace:

~~~diff
--- /usr/lib/systemd/system/puppet.service.old
+++ /usr/lib/systemd/system/puppet.service
@@ -7,7 +7,7 @@
 EnvironmentFile=-/etc/sysconfig/puppetagent
 EnvironmentFile=-/etc/sysconfig/puppet
 EnvironmentFile=-/etc/default/puppet
-ExecStart=/opt/puppetlabs/puppet/bin/puppet agent $PUPPET_EXTRA_OPTS --no-daemonize
+ExecStart=/bin/nsenter --net=/var/run/netns/management /opt/puppetlabs/puppet/bin/puppet agent $PUPPET_EXTRA_OPTS --no-daemonize
 KillMode=process
 
 [Install]
~~~

Now enable your Puppet systemd service (the `enable` command adds it to systemd for autostarting the next time you boot) and optionally start it.

~~~bash

systemctl enable my_puppet
systemctl start my_puppet

~~~

## <a name="auto-install">Automated Installation Options</a>

[Beaker](README-beaker-agent-install.md) - Installing and Configuring Puppet Agent Using the Beaker Tool

## <a name="references">References</a>

[Cisco Nexus Puppet Modules](../README.md) - Types, Providers, Utilities

[Cisco Nexus Programmability Guide](http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html) - Guestshell Documentation


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
