# Example Manifest Usage

#### Table of Contents

1. [Overview](#overview)
2. [Initial Setup](#setup)
3. [Run Basic Demo](#basic-demo)
4. [Run Role Based Demo](#role-based-demo)
5. [Run BGP IPv4/IPv6 Demo](#bgp-demo)
6. [License Information](#license-information)

## <a name="overview">Overview</a>

This document describes how to use the example demo manifest files contained within the `examples` directory.  There are several different demo's to choose from.

* `demo_site.pp`
  * Provides basic sample manifests to demo all cisco providers.
* `demo_roles_site.pp`
  * Provides a role based hierarchical set of sample manifests that can be used to demonstrate configuration of switches with different roles in a network.
* `demo_bgp_[ipv4|ipv6]_site.pp`
  * Provides sample manifests to configure bgp using the `cisco_command_config` provider.

**Note:** Before following the steps in this guide make sure the puppet agent is [installed and configured.](../docs/README-agent-install.md)

## <a name="setup">Initial Setup</a>

### (Optional:) Uninstall Older Version of the `puppetlabs-ciscopuppet` Module.

If your puppet master has an older version of the `puppetlabs-ciscopuppet` module installed go ahead and uninstall it now.

#### List Current Module

```bash
puppetmaster# puppet module list
/etc/puppetlabs/code/environments/production/modules
|
+-- puppetlabs-ciscopuppet (v1.1.0)
/etc/puppetlabs/code/modules (no modules installed)
/opt/puppetlabs/puppet/modules (no modules installed)
```

#### Remove Current Module

```bash
puppetmaster:# puppet module uninstall puppetlabs-ciscopuppet
Notice: Preparing to uninstall 'puppetlabs-ciscopuppet' ...
Removed 'puppetlabs-ciscopuppet' (v1.1.0) from /etc/puppetlabs/code/environments/production/modules
```

### Build and Install `puppetlabs-ciscopuppet` Module.

The recommended workflow is to clone the `cisco-ciscopuppet.git` repository on your puppet master.  This allows for easy build and installation of the `puppetlabs-ciscopuppet` module.

#### Clone the `cisco-network-puppet-module.git` repo on your puppet master

```bash
puppetmaster:# git clone https://github.com/cisco/cisco-network-puppet-module.git
```

#### Build the `puppetlabs-ciscopuppet` module on your puppet master

Issue the following command one layer **above** the `cisco-network-puppet-module` directory on your puppet master.

```bash
puppetmaster:# puppet module build cisco-network-puppet-module/
Notice: Building /githubpuppet/cisco-network-puppet-module for release
Module built: /githubpuppet/cisco-network-puppet-module/pkg/puppetlabs-ciscopuppet-1.2.0.tar.gz
```

#### Install the `puppetlabs-ciscopuppet` module on your puppet master

```bash
puppetmaster:# cd cisco-ciscopuppet/pkg/
puppetmaster:# puppet module install ./puppetlabs-ciscopuppet-[version].tar.gz
Notice: Preparing to install into /etc/puppetlabs/code/environments/production/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/code/environments/production/modules
|
+-- puppetlabs-ciscopuppet (v1.2.0)
+-- puppetlabs-netdev_stdlib (v0.11.1)
```

**Note:** Optionally, restart your puppet server following the install.


#### Copy all demo files under the `modules/ciscopuppet/examples/` directory to the `modules/ciscopuppet/manifests` directory

```bash
puppetmaster:# cd /etc/puppetlabs/code/environments/production/modules/ciscopuppet/examples
puppetmaster:# cp -r * /etc/puppetlabs/code/environments/production/modules/ciscopuppet/manifests/
```

## <a name="basic-demo">Run Basic Demo</a>

The basic demo covers all existing cisco providers using a flat hierarchy.  The `demo_site_cisco.pp` and `demo_site_netdev.pp` files are the sample `site.pp` files for this demo.  For a current list of all cisco providers included in this demo visit the `demo_all_cisco.pp` and `demo_all_netdev.pp` files.

### Copy `demo_site_cisco.pp` and `demo_site_netdev` files to `production/manifests` directory

```bash
puppetmaster:# cd /etc/puppetlabs/code/environments/production/modules/ciscopuppet/examples
puppetmaster:# cp ./demo_site_cisco.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
```

### Modify the `site.pp` file to use your agent node name

```puppet
node 'your_node_name' {  <---------------- Modify
  include ciscopuppet::demo_all_cisco
}
```
### Apply the demo `site.pp` manifest using the `puppet agent -t` command on the agent

```bash
root@n9k#puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for n9k.domain.com
Warning: Found multiple default providers for package: yum, puppet_gem, pip3; using yum
Info: Applying configuration version '1438692679'
Notice: /Stage[main]/Ciscopuppet::Install/Package[net_http_unix]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Install/Package[cisco_nxapi]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Install/Package[cisco_node_utils]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_command_config/Cisco_command_config[feature_bgp]/command: command changed '' to 'feature bgp
'
Notice: /Stage[main]/Ciscopuppet::Demo_command_config/Cisco_command_config[router_bgp_42]/command: command changed '' to 'router bgp 42
router-id 192.168.1.42
address-family ipv4 unicast
network 10.0.0.0/8
redistribute static route-map bgp-statics
'
Notice: /Stage[main]/Ciscopuppet::Demo_interface/Cisco_interface[Vlan22]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_ospf/Cisco_ospf[Sample]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_ospf/Cisco_interface_ospf[Ethernet1/1 Sample]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_ospf/Cisco_ospf_vrf[dark_blue default]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_ospf/Cisco_ospf_vrf[dark_blue vrf1]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_tacacs_server/Cisco_tacacs_server[default]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_tacacs_server_host/Cisco_tacacs_server_host[tachost]/ensure: created
Notice: /Stage[main]/Ciscopuppet::Demo_vtp/Cisco_vtp[default]/ensure: created
Notice: Applied catalog in 51.70 seconds
root@n9k#
```

## <a name="role-based-demo">Run Role Based Demo</a>

The role based demo covers resources that can be applied to switches that perform different roles in the network.  The `demo_roles_site.pp` file is the sample `site.pp` file for this demo.

### Copy `demo_roles_site.pp` file to `production/manifests` directory

```bash
puppetmaster:# cd /etc/puppetlabs/code/environments/production/modules/ciscopuppet/examples
puppetmaster:# cp ./demo_roles_site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
```

#### Modify the `site.pp` file to use your agent node names

```puppet
node 'your_n9k-edge-switch' {   <---------------- Modify
  include ciscopuppet::demo_role::edge_switch
}

node 'your_n9k-internal-switch' {   <---------------- Modify
  include ciscopuppet::demo_role::internal_switch
}

node 'your_n3k-internal-switch' {   <---------------- Modify
  include demo_role::internal_switch
}
```
#### Apply the demo `site.pp` manifest using the `puppet agent -t` command on the agent

## <a name="bgp-demo">Run BGP IPv4/IPv6 Demo</a>

The BGP [IPv4|IPv6] demo uses the `cisco_command_config` provider to apply sample bgp configuraton.  The `demo_bgp_[ipv4|ipv6]_site.pp` file is the sample `site.pp` file for this demo.

### Copy `demo_bgp_[ipv4|ipv6]_site.pp` file to `production/manifests` directory

```bash
puppetmaster:# cd /etc/puppetlabs/code/environments/production/modules/ciscopuppet/examples
puppetmaster:# cp ./demo_bgp_[ipv4|ipv6]_site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
```

#### Modify the `site.pp` file to use your agent node name

```puppet
node 'cisco_[bgpv4|bgpv6]_device_name' {  <------ Modify
  include ciscopuppet::demo_bgp_[ipv4|ipv6]
}
```
#### Apply the demo `site.pp` manifest using the `puppet agent -t` command on the agent


## <a name="license-information">License Information</a>

```
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
```
