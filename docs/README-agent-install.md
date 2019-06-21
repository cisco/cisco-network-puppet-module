# Puppet Agent Installation & Setup: Cisco Nexus

--
#### Table of Contents

1. [Overview](#overview)
1. [Pre-Install Tasks](#pre-install-tasks)
1. [Agent Environments](#env-bs)
  * [bash-shell](#env-bs)
  * [guestshell](#env-gs)
  * [open agent container (OAC)](#env-oac)
1. [Agent Installation, Configuration and Usage](#agent-config)
1. Optional Setups
  * [Guestshell on High Availability (HA) Platforms](#ha)
  * [Agent Persistence](#persistence)

[References](#references)

[How to get a virtual Nexus N9k](#VIRT_9K)

--
## <a name="overview">Overview</a>

This document describes Puppet agent installation and setup on Cisco Nexus switches. These instructions focus on manual setup.

![1](puppet_outline.png)

See [References](#references) for alternative installation methods.

**NOTE:** The Puppet agent is not supported for the `OAC` or `Native Bash` hosting environments on NX-OS beyond Puppet Enterprise 2018.1. The agentless workflow is recommended for managing Cisco NX-OS devices. Agent based workflows will continue to be supported in the NX-OS Guestshell hosting environment.

## <a name="pre-install-tasks">Pre-Install Tasks</a>

#### *Step 1. Platform / Software Minimum Requirements*

Puppet Versions |
:--|
Open Source Puppet 4.0 |
Puppet Enterprise 2015.2 |
<br>

Supported Platforms | OS    | OS Version           |
:-------------------|-------|----------------------|
Cisco Nexus N9k <br>*[How to get a virtual Nexus N9k](#VIRT_9K)* | NX-OS  | 7.0(3)I2(5) and later
Cisco Nexus N3k    | NX-OS  | 7.0(3)I2(5) and later
Cisco Nexus N5k    | NX-OS  | 7.3(0)N1(1) and later
Cisco Nexus N6k    | NX-OS  | 7.3(0)N1(1) and later
Cisco Nexus N7k    | NX-OS  | 7.3(0)D1(1) and later
Cisco Nexus N9k-F  | NX-OS  | 7.0(3)F1(1) and later
Cisco Nexus N3k-F  | NX-OS  | 7.0(3)F3(2) and later
<br>


Resource| Recommended| |
:--|:--:|:--|
Disk   | **400 MB** | Minimum free space before installing Puppet agent |

<br>

#### *Step 2. Choose an environment for running a Puppet agent*

**NOTE:** Starting in release `9.2(1)` and onward, installing a Puppet agent in the `bash-shell` hosting environment is no longer supported.  Instead, the Puppet agent software should be installed on the [`guestshell` hosting environment](#env-gs).

NX-OS Environment | Supported Platforms | |
:--|:--:|:--|
`bash-shell` | N3k, N9k | This is the native WRL Linux environment underlying NX-OS. It is disabled by default on NX-OS. |
`guestshell` | N3k, N9k | This is a secure Linux container environment running CentOS. It is enabled by default in most platforms that support it. |
`open agent`<br>`container (OAC)` | N5k, N6k, N7k | This is a 32-bit CentOS-based container created specifically for running Puppet Agent software. <br><br> **Note:** As of the Cisco NX-OS `8.4.1` release, the Open Agent Container support that was added in the Cisco NX-OS `7.3(0)D1(1) / 7.3(0)N1(1)` release with the purpose of providing an execution space for configuration management agents is being phased out.  It is recommended to use Puppet agent-less workflows, with the N5K, N6k and N7k series of switches.|

* *OAC containers are created for specific platforms and must be downloaded from Cisco (see [OAC Download](#env-oac)). The OAC must be installed before a Puppet agent can be installed.*

* *Running a Puppet agent from multiple environments simultaneously is not supported*


#### *Step 3. Network Connectivity*

* Ensure that IP reachability exists between the agent node and the Puppet Server. Note that connectivity via the management interface is in a separate VRF context which requires some additional configuration.
* Configure NTP to ensure that the agent node time is in sync with the Puppet Server.

_Note: The management interface exists in a separate VRF context and requires additional configuration as shown._

**Example:** Nexus CLI Configuration for connectivity via management interface

~~~
config term
  vrf context management
    ip name-server 10.0.0.202
    ip domain-name mycompany.com
    ip route 0.0.0.0/0 10.0.0.1

  interface mgmt0
    vrf member management
    ip address 10.0.0.99/24

  ntp server 10.0.0.201 use-vrf management
end
~~~

## <a name="env-bs">Agent Environment Setup: bash-shell</a>

**NOTE:** Starting in release `9.2(1)` and onward, installing a Puppet agent in the `bash-shell` hosting environment is no longer supported.  Instead the Puppet agent software should be installed into the [`guestshell` hosting environment](#env-gs).

This section is only required when running Puppet from the `bash-shell`.

#### *Step 1. Enable the bash-shell*

~~~
config term
  feature bash-shell
end
~~~

#### *Step 2. Set up the bash-shell environment*

Use `run bash` to enter the `bash-shell` environment, then become root.<br>*Optional:* Use `ip netns` to switch namespaces to the `management` vrf if connectivity is via management interface.

~~~bash
n3k# run bash
bash-4.2$  sudo su -

bash-4.2$  ip netns exec management bash
~~~

#### *Optional: Add DNS configuration*
~~~
bash-4.2$  cat >> /etc/resolv.conf << EOF
nameserver 10.0.0.202
domain mycompany.com
EOF
~~~

_A Note on Persistence_: The current NX-OS bash-shell implementation does not automatically save the entire linux filesystem. This means that certain files such as `/etc/resolv.conf` will not automatically be persistent after system reloads. Please execute `copy running-config startup-config` from the NX-OS cli after any changes to /etc/resolv.conf, which will trigger a save. This command can also be executed directly from the bash-shell with vsh: `vsh -c 'copy running-config startup-config'`

## <a name="env-gs">Agent Environment Setup: guestshell</a>

This section is only required when running Puppet from the `guestshell`.

#### *Step 1a. Enable the guestshell on low footprint N3ks*

**NOTE:** Skip down to **Step 1b** if the target system is not a low footprint N3k.

Nexus 3xxx switches with 4 GB RAM and 1.6 GB bootflash are advised to use compacted images to reduce the storage resources consumed by the image. As part of the compaction process, the `guestshell.ova` is removed from the system image.  To make use of the guestshell on these systems, the guestshell.ova may be downloaded and used to install the guestshell.

[Guestshell OVA Download Link](https://software.cisco.com/download/home/283970187/type/282088129/release/9.2%25281%2529?catid=268438038)

Starting in release `9.2(1)` and onward, the .ova file can be copied to the `volatile:` directory which frees up more space on `bootflash:`.

Copy the `guestshell.ova` file to `volatile:` if supported, otherwise copy it to `bootflash:`

```
n3xxx# copy scp://admin@1.2.3.4/guestshell.ova volatile: vrf management
guestshell.ova 100% 55MB 10.9MB/s 00:05 
Copy complete, now saving to disk (please wait)...
Copy complete.
```

Use the `guestshell enable` command to install and enable guestshell.

```
n3xxx# guestshell enable package volatile:guestshell.ova
```


#### *Step 1b. Enable the guestshell*

The `guestshell` container environment is enabled by default on most platforms; however, the default disk and memory resources allotted to guestshell are typically too small to support Puppet agent requirements. The resource limits may be increased with the NX-OS CLI `guestshell resize` commands as shown below.

Resource| Recommended|
:--|:--:|
Disk   | **450 MB** |
Memory | **350 MB** |

<p>
`show guestshell detail` displays the current resource limits:

~~~
n3k# show guestshell detail
Virtual service guestshell+ detail
  State                 : Activated
 ...
    Resource reservation
    Disk                : 150 MB
    Memory              : 128 MB

~~~

<p>
`guestshell resize rootfs` sets disk size limits while `guestshell resize memory` sets memory limits. The resize commands do not take effect until after the guestshell container is (re)started by `guestshell reboot` or `guestshell enable`.

**Example.** Allocate resources for guestshell by setting new limits to 450MB disk and 350MB memory.

~~~
n3k# guestshell resize rootfs 450
n3k# guestshell resize memory 350

n3k# guestshell reboot
Are you sure you want to reboot the guest shell? (y/n) [n] y
~~~

#### *Step 2. Set Up Guestshell Network*

The `guestshell` is an independent CentOS container that does not inherit settings from NX-OS.

* Use `guestshell` enter the guestshell environment, then become root.
* *Optional:* Use `chvrf` to specify a vrf namespace; e.g. `sudo chvrf management`

~~~bash
n3k#  guestshell

[guestshell@guestshell ~]$ sudo su -          # Optional: sudo chvrf management
[root@guestshell guestshell]#
~~~

#### *Optional: Set up hostname*

This step is only needed if `certname` will not be specified in `puppet.conf`.

~~~bash
[root@guestshell guestshell]#  hostname n3k

[root@guestshell guestshell]#  echo 'n3k' > /etc/hostname
~~~

#### *Optional: Add DNS configuration*

~~~bash
[root@guestshell guestshell]#  cat >> /etc/resolv.conf << EOF
nameserver 10.0.0.202
domain mycompany.com
EOF
~~~

See [References](#references) for `guestshell` documentation.

## <a name="env-oac">Agent Environment Setup: open agent container (OAC)</a>

This section is only required when running Puppet from the `open agent container`.

**Note:** As of the Cisco NX-OS `8.4.1` release, the Open Agent Container support that was added in the Cisco NX-OS `7.3(0)D1(1) / 7.3(0)N1(1)` release with the purpose of providing an execution space for configuration management agents is being phased out.  It is recommended to use Puppet agent-less workflows, with the N5K, N6k and N7k series of switches.|

#### *Step 1. Download the OAC ova file*

| Platform | OAC Download Link |
:----------|-------------------|
N7k      | [N7k OAC file](https://software.cisco.com/download/release.html?i=!y&mdfid=283748960&softwareid=282088129&release=7.3%280%29D1%281%29&os=) |
N5k, N6k | [N5k N6k OAC file](https://software.cisco.com/download/release.html?i=!y&mdfid=284360574&softwareid=282088130&release=7.3%280%29N1%281%29&os=) |

**NOTE** The download links for OAC above are for specific NX-OS software versions.  Make sure to select the OAC download OVA that corresponds to the version running on the `N5|6|7k` device.

Copy the `ova` file to the `bootflash:` device.

~~~
n7k# dir bootflash:
   45424640    Feb 12 19:37:40 2016  oac.1.0.0.ova
~~~

#### *Step 2. Install and Activate the OAC*

##### Check Resources

Display container resources with `show virtual-service global`.<br>
The OAC will require **400 MB** of disk space on bootflash. Remove unnecessary files if insufficient space is available.

~~~
n7k#  show virtual-service global
 ...
Resource virtualization limits:
Name                        Quota    Committed    Available
-----------------------------------------------------------------------
system CPU (%)                  6            0            6
memory (MB)                  2304            0         2304
bootflash (MB)                600            0          600
~~~

##### Installation

Install the OAC using the `virtual-service install` exec command.

~~~
n7k#  virtual-service install name oac package bootflash:oac.1.0.0.ova

Note: Installing package 'bootflash:/oac.1.0.0.ova' for virtual service 'oac'.
Once the install has finished, the VM may be activated.
Use 'show virtual-service list' for progress.
  %$ VDC-1 %$ %VMAN-2-INSTALL_STATE: Successfully installed virtual service 'oac'

n7k# show virtual-service list
oac                     Installed          oac.1.0.0.ova
~~~

##### Activation

Activate the `virtual-service` using configuration mode.

~~~
n7k#  config t
n7k(config)#  virtual-service oac
n7k(config-virt-serv)#  activate

Note: Activating virtual-service 'oac', this might take a few minutes.
Use 'show virtual-service list' for progress.
  %$ VDC-1 %$ %VMAN-2-ACTIVATION_STATE: Successfully activated virtual service 'oac'

n7k# show virtual-service list
oac                     Activated          oac.1.0.0.ova
~~~

#### *Step 3. Set Up the OAC Network*

The OAC is an independent CentOS container that does not inherit settings from NX-OS.

* Use `virtual-service connect` to enter the OAC environment. *The OAC default userid / password is `root / oac`. You are required to change the password on initial login.*

* *Optional:* Use `chvrf` to specify a vrf namespace; e.g. `chvrf management`

~~~
n7k#  virtual-service connect name oac console
Connecting to virtual-service.  Exit using ^c^c^c

localhost login: root
Password: oac
You are required to change your password immediately (root enforced)
Changing password for root.
[root@localhost ~]#
[root@localhost ~]#  chvrf management
~~~

#### *Optional: Set up hostname*

This step is only needed if `certname` will not be specified in `puppet.conf`.

~~~bash
[root@guestshell guestshell]#  hostname n3k

[root@guestshell guestshell]#  echo 'n3k' > /etc/hostname
~~~

#### *Optional: Add DNS configuration*

~~~bash
[root@n7k ~]#  cat >> /etc/resolv.conf << EOF
nameserver 10.0.0.202
domain mycompany.com
EOF
~~~

See [References](#references) for OAC documentation.

## <a name="agent-config">Puppet Agent Installation, Configuration, and Usage</a>

This section is common to `bash-shell`, `guestshell` and the `open agent container`.

#### *Step 1. Select and Install the Puppet Agent RPM*

* Optional: Define proxy server variables to allow network access to `yum.puppetlabs.com`:

~~~bash
export http_proxy=http://proxy.yourdomain.com:<port>
export https_proxy=https://proxy.yourdomain.com:<port>
~~~
<br>

* Import the Puppet GPG keys

~~~
rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-reductive
rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet
~~~
<br>

* Select the appropriate Puppet RPM for your agent environment

Environment | RPM |
:--|:--|
`bash-shell` | <http://http://yum.puppetlabs.com/puppet5/puppet5-release-cisco-wrlinux-5.noarch.rpm> |
`guestshell` | <http://http://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm> |
`open agent`<br>`container (OAC)` | [http://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm](http://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm) (End Of Life)|

**OAC NOTE** The OAC rpm is now end of life (EOL) but later versions of the rpm cannot be hosted in the OAC due to a ruby version incompatibility.  To continue using an OAC workflow the module version must be `1.10.0` or ealier along with the now EOL rpm.

<br>

* Install the RPM (`$PUPPET_RPM` is the URL from the preceding table)

~~~bash
yum install $PUPPET_RPM
yum install puppet
~~~

* Update the PATH variable

~~~bash
export PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/puppet/lib:$PATH
~~~

<br>
#### *Step 2. Configure* `/etc/puppetlabs/puppet/puppet.conf`

Add your Puppet Server name to the configuration file.
*Optional:* Use `certname` to specify the agent node's ID. This is only needed if `hostname` has not been set.

~~~bash
[main]
  server   = mypuppetmaster.mycompany.com
  certname = this_node.mycompany.com
~~~
<br>

#### *Step 3. The `cisco_node_utils` Gem*

The [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils) ruby gem is a required component of the `ciscopuppet` module. This gem contains platform APIs for interfacing between Cisco CLI and Puppet agent resources. The gem can be automatically installed by Puppet agent by simply using the [`ciscopuppet::install`](https://github.com/cisco/cisco-network-puppet-module/blob/master/examples/demo_all_cisco.pp#L19) helper class, or it can be installed manually.

##### Automatic Gem Install Using `ciscopuppet::install`

* The `ciscopuppet::install` class is defined in the `install.pp` file in the `examples` subdirectory. Copy this file into the `manifests` directory as shown:

~~~bash
cd /etc/puppetlabs/code/environments/production/modules/ciscopuppet/
cp examples/install.pp  manifests/
~~~

* Next, update `site.pp` to use the install class

**Example**

~~~puppet
node 'default' {
  include ciscopuppet::install
}
~~~

The preceding configuration will cause the next `puppet agent` run to automatically download the current `cisco_node_utils` gem from <https://rubygems.org/gems/cisco_node_utils> and install it on the node.

##### Optional Parameters for `ciscopuppet::install`

  * Override the default rubygems repository to use a custom repository
  * Provide a proxy server

**Example**

~~~puppet
node default
  class {'ciscopuppet::install':
    repo  => 'http://gemserver.domain.com:8808',
    proxy => 'http://proxy.domain.com:8080',
  }
end
~~~

##### Gem Persistence

Once installed, the GEM will remain persistent across system reloads within the Guestshell or OAC environments; however, the bash-shell environment does not share this persistent behavior, in which case the `ciscopuppet::install` helper class automatically downloads and re-installs the gem after each system reload.

* The gem can also be manually installed on the agent node

~~~
gem install cisco_node_utils
~~~
<br>

#### *Step 4. Run Puppet Agent*

Executing the `puppet agent` command (with no arguments) will start the puppet agent process with the default runinterval of 30 minutes. Use the `-t` option to run puppet agent in test mode, which runs the agent a single time and stops.

~~~bash
puppet agent -t
~~~
<br>

## <a name="ha">Optional Setup: Guestshell on High Availability (HA) Platforms</a>

This section discusses `guestshell` usage on HA platforms. This section does not apply to the bash-shell environment, open agent container (OAC) environment or to single-sup platforms.

The `guestshell` container does not automatically sync filesystem changes from the active processor to the standby processor. This means that Puppet installation files and related file changes performed in the earlier steps will not be present on the standby until they are manually synced with the following NX-OS exec command:

~~~
guestshell sync
~~~
<br>

## <a name="persistence">Optional Setup: Puppet Agent Persistence</a>

This section discusses Puppet agent persistence after system restarts.

#### Service Management

It may be desirable to set up automatic restart of the Puppet agent in the event of a system reset. The bash and guestshell environments use different methods to achieve this.

* [Service Management in bash-shell using init.d](#svc-mgmt-bs)
* [Service Management in guestshell using systemd](#svc-mgmt-gs)
* The open agent container (OAC) does not officially support agent persistence.
<br>

#### <a name="svc-mgmt-bs">Service Management in bash-shell using init.d</a>

The `bash-shell` environment uses **init.d** for service management. The Puppet agent provides a generic init.d script when installed, but a slight modification as shown below is needed for nodes that run Puppet in the management (or other vrf) namespace:

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
<br>

#### <a name="svc-mgmt-gs">Service Management in guestshell using systemd</a>

The `guestshell` environment uses **systemd** for service management. The Puppet agent provides a generic systemd script when installed, but a slight modification as shown below is needed for nodes that run puppet in the management (or other vrf) namespace:

~~~diff
--- /usr/lib/systemd/system/puppet.service.old
+++ /usr/lib/systemd/system/puppet.service
@@ -7,7 +7,7 @@
 EnvironmentFile=-/etc/sysconfig/puppetagent
 EnvironmentFile=-/etc/sysconfig/puppet
 EnvironmentFile=-/etc/default/puppet
-ExecStart=/opt/puppetlabs/puppet/bin/puppet agent $PUPPET_EXTRA_OPTS --no-daemonize
+ExecStart=/bin/nsenter --net=/var/run/netns/management -- /opt/puppetlabs/puppet/bin/puppet agent $PUPPET_EXTRA_OPTS --no-daemonize
 KillMode=process

 [Install]
~~~

Next, enable your Puppet systemd service (the `enable` command adds it to systemd for autostarting the next time you boot) and optionally start it now:

~~~bash
systemctl enable my_puppet
systemctl start my_puppet
~~~

## <a name="references">References</a>

Reference | Description
:--|:--|
[Automated Puppet Agent Installation](README-beaker-agent-install.md) | (**DEPRECATED**) Using Beaker tools to install & configure Puppet Agent
[Cisco Nexus Puppet Modules](../README.md) | Types, Providers, Utilities
[Guestshell][GS_9K] | Guestshell Container Programmability Guide
[N5k, N6k Open Agent Container (OAC)][OAC_5K_DOC] | N5k, N6k Programmability Guide
[N7k Open Agent Container (OAC)][OAC_7K_DOC] | N7k Programmability Guide
[Puppet Agent Configuration Reference][PUP_CR] | `puppet.conf` settings

[GS_9K]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html

[OAC_5K_DOC]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus5000/sw/programmability/guide/b_Cisco_Nexus_5K6K_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_5K6K_Series_NX-OS_Programmability_Guide_chapter_01001.html

[OAC_5K_OVA]: https://software.cisco.com/download/release.html?i=!y&mdfid=284360574&softwareid=282088130&release=7.3%280%29N1%281%29&os=

[OAC_7K_DOC]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus7000/sw/programmability/guide/b_Cisco_Nexus_7000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_7000_Series_NX-OS_Programmability_Guide_chapter_01001.html

[OAC_7K_OVA]: https://software.cisco.com/download/release.html?i=!y&mdfid=283748960&softwareid=282088129&release=7.3%280%29D1%281%29&os=

[PUP_CR]: https://docs.puppetlabs.com/references/latest/configuration.html

## <a name="VIRT_9K">How to get a virtual Nexus N9k</a>
A virtual Nexus N9k may be helpful for development and testing. To obtain a virtual N9k, first register for a [cisco.com](http://cisco.com) userid at <https://tools.cisco.com/IDREG/guestRegistration>, then download the software from [CCO](https://software.cisco.com/download/release.html?mdfid=286312239&softwareid=282088129&release=7.0(3)I5(2)&relind=AVAILABLE&rellifecycle=&reltype=latest).

## License

~~~
Copyright (c) 2014-2019 Cisco and/or its affiliates.

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

