# Puppet Module Install & Setup: Cisco Nexus

#### Table of Contents

1. [Overview](#overview)
1. [Pre-install tasks](#pre-install)
    * [Puppet agent mode](#agent-mode)
    * [Puppet agentless mode](#agentless-mode)
    * [Common gem dependencies](#gem-dependencies)
1. [Transitioning to agentless](#transitioning)
1. [Building from source](#building-manually)

---

<a name="overview"></a>
## Overview

This document describes how to install and manually setup the Puppet Cisco module for the managing Cisco Nexus switches.

<a name="pre-install"></a>
## Pre-install tasks

This Puppet module supports two modes of operation: an agent mode and an agentless mode. The setup varies slightly for each mode — the agent mode has a Puppet agent installed directly on to the device and communicates directly with the Puppet master, whereas the agentless mode communicates with the device typically through a [Proxy Agent](https://puppet.com/docs/puppet/latest/puppet_device.html#concept-562).

Each puppetserver or PE master that serve catalogs for NX-OS devices require [puppetlabs-ciscopuppet](https://forge.puppet.com/puppetlabs/ciscopuppet) and the following two modules:

* [puppetlabs-netdev_stdlib](https://forge.puppet.com/puppetlabs/netdev_stdlib) (v0.18.0 or later)
* [puppetlabs-resource_api](https://forge.puppet.com/puppetlabs/resource_api)

You will also need to install the Resource API Ruby gem:

```bash
puppetserver gem install puppet-resource_api
puppetserver reload
```

For more information on installing Puppet modules, [Installing and managing modules](https://puppet.com/docs/puppet/latest/modules_installing.html)

<a name="agent-mode"></a>
#### Puppet agent mode

The agent mode is supported by the [2018.1 LTS Puppet Enterprice version](https://puppet.com/misc/puppet-enterprise-lifecycle) and provides access to [Puppet core types](https://puppet.com/docs/puppet/5.5/cheatsheet_core_types.html) for managing the underlying OS on the NX-OS device.

Install and setup the Puppet agent on each device — you can do this manually or as an automated process. For instructions on how to install agents and configure Cisco Nexus devices, see [README-agent-install.md](https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-agent-install.md).

<a name="agentless-mode"></a>
#### Puppet agentless mode

Using the module in the agentless mode will harness the [`puppet device` command](https://puppet.com/docs/puppet/5.5/puppet_device.html) and communicate remotely with the device using the [configuration details provided](https://puppet.com/docs/puppet/latest/puppet_device.html#concept-363).

Note that this mode is unable to manage the [Puppet core types](https://puppet.com/docs/puppet/5.5/cheatsheet_core_types.html) on the device, such as `file`, `package` etc.

<a name="gem-dependencies"></a>
#### Common gem dependencies

The following Ruby gems need to be installed on the Puppet agent which will be managing the device:

* [cisco_node_utils](https://rubygems.org/gems/cisco_node_utils)
* [puppet-resource_api](https://rubygems.org/gems/puppet-resource_api)

```
/opt/puppetlabs/puppet/bin/gem install <gem>
```

<a name="transitioning"></a>
## Transitioning to latest module version

If you are using the existing version of the `ciscopuppet` module (Version 1.10.0 or earlier) with the agent-only based mode has been in use and you plan to continue using the agent, install the [puppet-resource_api](https://rubygems.org/gems/puppet-resource_api) on to the devices' agent. 

If you plan to swap using the agent on the device to using `puppet device`, use the [agentless mode](#agentless-mode) and disable the agent when the transition in complete.

*Please note:* For existing catalogs containing [netdev_stdlib types](https://forge.puppet.com/puppetlabs/netdev_stdlib/readme) there will be stricter type enforcement on the properties, for example, for `Integer` as a type, `'7'` will not be treated as `7`.

<a name="building-manually"></a>
## Building from source

[Puppet Development Kit](https://puppet.com/docs/pdk/1.x/pdk.html) is the recommended tool if you're planning to [build the module from source](https://puppet.com/docs/pdk/1.x/pdk_building_module_packages.html#concept-9267).

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

