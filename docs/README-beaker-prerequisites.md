# Prerequisites for running Beaker

This document describes prerequisite setup to be done before running [Beaker](https://github.com/puppetlabs/beaker/blob/master/README.md) against a NX-OS or IOS XR agent node, whether as an [installer](README-beaker-agent-install.md) or as a [test runner](README-develop-beaker-scripts.md)

## Platform and Software Support

Beaker Release 2.38.1 and later

## Install Beaker

[Install Beaker](https://github.com/puppetlabs/beaker/wiki/Beaker-Installation) on your designated beaker server.

### Configure NX-OS

You must enable ssh to allow the Beaker workstation to access the Puppet agent during testing.

#### Enable SSH: bash-shell

For `bash-shell`, ssh access is enabled by configuring `feature ssh` and userids are created with the `username` configuration. The example below create a 'devops' userid with the role and shelltype settings needed for beaker.

**Example:**

~~~bash
configure terminal
  feature ssh
  username devops password devopspassword role network-admin
  username devops shelltype bash
end
~~~

#### Enable SSH: open agent container (OAC)

Open a console session to the `OAC` using the `virtual-service connect` command:

`virtual-service connect name oac console`

~~~bash
# First become root:
sudo su -

# Restart sshd
[root@localhost ~]# /etc/init.d/sshd restart
Stopping sshd:                                             [  OK  ]
Starting sshd:                                             [  OK  ]
~~~

Note that this daemon listens on port 2222 rather than the SSH default port of 22. You will configure `hosts.cfg` to specify this port for Beaker's use [below](#beaker-config), but if you want to manually SSH to the node, you will need to specify the port number as well:

~~~bash
ssh root@<oac-mgmt-ip> -p 2222
~~~

### Configure IOS XR

#### Start SSHd for TPNNS

IOS XR provides an SSH server daemon that runs within the [third-party network namespace (TPNNS)](http://www.cisco.com/c/en/us/td/docs/iosxr/AppHosting/AH_Config_Guide/AH_User_Guide_chapter_00.html#concept_B8195E8C04EF4900BF51B2F3832F52AE), which is where Beaker needs to run the Puppet agent. Start this daemon from the IOS XR bash shell:

~~~bash
run bash
service sshd_tpnns start
chkconfig --add sshd_tpnns
~~~

Note that this daemon listens on port 57722 rather than the SSH default port of 22. You will configure `hosts.cfg` to specify this port for Beaker's use, but if you want to manually SSH to the node, you will need to specify the port number as well:

~~~bash
ssh devops@192.168.122.222 -p 57722
~~~

#### Configure a user for passwordless sudo

`sshd_tpnns` doesn't allow login as root, but the Puppet agent needs to run with root permissions. Beaker needs to be able to log in as a user that can transparently invoke `sudo` without a password prompt. There are several ways you can edit the `/etc/sudoers` file (using `visudo` from the Bash prompt) to permit this:

Enable passwordless sudo for all users in group `sudo` (which includes all configured IOS XR users in IOS XR group `root-lr`, including the root-system user created at boot time):

~~~diff
 #includedir /etc/sudoers.d
-%sudo ALL=(ALL) ALL
+%sudo ALL=(ALL) NOPASSWD: ALL
~~~

Or, enable passwordless sudo only for a specific user, such as 'devops':

~~~diff
 #includedir /etc/sudoers.d
 %sudo ALL=(ALL) ALL
+devops ALL=(ALL) NOPASSWD: ALL
~~~

