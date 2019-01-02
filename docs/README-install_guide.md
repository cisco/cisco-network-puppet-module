# Puppet Module Install & Setup: Cisco Nexus

#### Table of Contents

1. [Overview](#overview)
1. [Pre-install tasks](#pre-install)
    * [Puppet Agent mode](#agent-mode)
    * [Puppet Agentless mode](#agentless-mode)
    * [Common gem dependencies](#gem-dependencies)
1. [Transitioning to Agentless](#transitioning)
1. [Building from source](#building-manually)

---

<a name="overview"></a>
## Overview

This document describes the installation and setup of the Puppet Cisco module for the management of Cisco Nexus switches. These instructions focus on manual setup.

<a name="pre-install"></a>
## Pre-install tasks

This Puppet module supports two modes of operation, a Puppet agent mode, and a Puppet Agentless mode. The setup varies slightly for each mode, since the Puppet agent mode has a Puppet agent installed directly on to the device and communicates directly to the Puppet Master, whereas the Puppet Agentless mode will communicate with the device typically through a [Proxy Agent](https://puppet.com/docs/puppet/5.5/puppet_device.html#concept-562).

On each puppetserver or PE master that needs to serve catalogs for NX-OS devices will require the [puppetlabs-ciscopuppet](https://forge.puppet.com/puppetlabs/ciscopuppet) and the following Puppet modules:

* [puppetlabs-netdev_stdlib](https://forge.puppet.com/puppetlabs/netdev_stdlib) (v0.18.0 or later)
* [puppetlabs-resource_api](https://forge.puppet.com/puppetlabs/resource_api)

For more information on Puppet module installation see [Puppet Labs: Installing Modules](https://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)

The Resource API Ruby gem will also need to be installed on any puppetserver or PE master that needs to serve catalogs for an NX-OS device.

```bash
puppetserver gem install puppet-resource_api
puppetserver reload
```

<a name="agent-mode"></a>
#### Puppet Agent mode

The Puppet Agent mode is supported through the [2018.1 LTS Puppet Enterprice version](https://puppet.com/misc/puppet-enterprise-lifecycle) and provides the benefits of having access to [Puppet core types](https://puppet.com/docs/puppet/5.5/cheatsheet_core_types.html) for management of the underlying OS on the NX-OS device.

The Puppet Agent requires installation and setup on each device. Agent setup can be performed as a manual process or it may be automated. For more information please see the [README-agent-install.md](https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-agent-install.md) document for detailed instructions on agent installation and configuration on Cisco Nexus devices.

<a name="agentless-mode"></a>
#### Puppet Agentless mode

Using the module in the Puppet Agentless mode will harness the [`puppet device` command](https://puppet.com/docs/puppet/5.5/puppet_device.html), where it will communicate remotely with the device using the [configuration details provided](https://puppet.com/docs/puppet/5.5/puppet_device.html#concept-363).

This mode however has the limitations of being unable to manage the [Puppet core types](https://puppet.com/docs/puppet/5.5/cheatsheet_core_types.html) on the device, such as `file`, `package` etc.

<a name="gem-dependencies"></a>
#### Common gem dependencies

The following Ruby gems will need to be installed on the Puppet Agent which will be managing the device:

* [cisco_node_utils](https://rubygems.org/gems/cisco_node_utils)
* [puppet-resource_api](https://rubygems.org/gems/puppet-resource_api)

```
/opt/puppetlabs/puppet/bin/gem install <gem>
```

<a name="transitioning"></a>
## Transitioning to latest module version

If the existing version of the `ciscopuppet` module (Version 1.10.0 or earlier) with the agent-only based mode has been in use, if there are plans to continue using the agent then the [puppet-resource_api](https://rubygems.org/gems/puppet-resource_api) will need to be installed on to the devices' agent. 

If there are plans to move from using the agent on the device and swapping to using `puppet device` then following [Puppet Agentless mode](#agentless-mode) will be enough and disabling the agent when satisfied with the transition.

*Please note:* For existing catalogs containing [netdev_stdlib types](https://forge.puppet.com/puppetlabs/netdev_stdlib/readme) then there will be stricter type enforcement on the properties, i.e. for `Integer` as a type, `'7'` will not be treated as `7`.

<a name="building-manually"></a>
## Building from source

The [Puppet Development Kit](https://puppet.com/docs/pdk/1.x/pdk.html) is a recommended tool if planning on [building the module from source](https://puppet.com/docs/pdk/1.x/pdk_building_module_packages.html#concept-9267).

## License

~~~
Copyright (c) 2014-2018 Cisco and/or its affiliates.

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

