# Prerequisites for running Beaker

This document describes prerequisite setup to be done before running [Beaker](https://github.com/puppetlabs/beaker/blob/master/README.md) against a NX-OS agent node, whether as an [installer](README-beaker-agent-install.md) or as a [test runner](README-develop-beaker-scripts.md)

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
