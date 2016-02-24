# ciscopuppet

##### Documentation Workflow Map

This workflow map aids *users*, *developers* and *maintainers* of the ciscopuppet project in selecting the appropriate document(s) for their task.

* User Guides
  * [README-agent-install.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/docs/README-agent-install.md) : Agent Installation and Configuration Guide
  * [README-beaker-agent-install.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/docs/README-beaker-agent-install.md) : Automated Agent Installation and Configuration
  * [README-package-provider.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/docs/README-package-provider.md) : Cisco Nexus Package Management using the Package Provider
  * [README-example-manifest.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/examples/README.md) : Example Demo Manifest User Guide
  * The remainder of this document is aimed at end users
* Developer Guides
  * [CONTRIBUTING.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/CONTRIBUTING.md) : Contribution guidelines
  * [README-develop-types-providers.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/docs/README-develop-types-providers.md) : Developing new ciscopuppet Types and Providers
  * [README-develop-beaker-scripts.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/docs/README-develop-beaker-scripts.md) : Developing new beaker test scripts for ciscopuppet
* Maintainers Guides
  * [README-maintainers.md](https://github.com/cisco/cisco-network-puppet-module/blob/develop/docs/README-maintainers.md) : Guidelines for core maintainers of the ciscopuppet project
  * All developer guides apply to maintainers as well

Please see [Learning Resources](#learning-resources) for additional references.

--
#### Table of Contents

1. [Overview](#overview)
1. [Module Description](#module-description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Platform Support](#platform-support)
   * [Provider Support Across Platforms](#provider-support-across-platforms)
1. [Resource Reference](#resource-reference)
   * [Resource Type Catalog (by Technology)](#resource-by-tech)
   * [Resource Type Catalog (by Name)](#resource-by-name)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Learning Resources](#learning-resources)



## Overview

The ciscopuppet module allows a network administrator to manage Cisco Network Elements using Puppet. This module bundles a set of Puppet Types, providers, Beaker Tests, Sample Manifests and Installation Tools for effective network management.  The  resources and capabilities provided by this Puppet Module will grow with contributions from Cisco, Puppet Labs and the open source community.

The Cisco Network Elements and Operating Systems managed by this Puppet Module are continuously expanding. Please refer to the [Limitations](#limitations) section for details on currently supported hardware and software.
The Limitations section also provides details on compatible Puppet Agent and Puppet Master versions.

This GitHub repository contains the latest version of the ciscopuppet module source code. Supported versions of the ciscopuppet module are available at Puppet Forge. Please refer to [SUPPORT.md](SUPPORT.md) for additional details.

Contributions to this Puppet Module are welcome. Guidelines on contributions to the module are captured in [CONTRIBUTING.md](CONTRIBUTING.md)

## Module Description

This module enables management of supported Cisco Network Elements using Puppet. This module enhances the Puppet DSL by introducing new Puppet Types and Providers capable of managing network elements.

The set of supported network element platforms is continuously expanding. Please refer to the [Limitations](#limitations) section for a list of currently supported platforms.

## Setup

#### Puppet Master

The `ciscopuppet` module is installed on the Puppet Master server. Please see [Puppet Labs: Installing Modules](https://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html) for general information on Puppet module installation.

#### Puppet Agent
The Puppet Agent requires installation and setup on each device. Agent setup can be performed as a manual process or it may be automated. For more information please see the [README-agent-install.md](docs/README-agent-install.md) document for detailed instructions on agent installation and configuration on Cisco Nexus devices.

##### Artifacts

As noted in the agent installation guide, these are the current RPM versions for use with ciscopuppet:
* `bash-shell`: Use [http://yum.puppetlabs.com/puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm](http://yum.puppetlabs.com/puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm)
* `guestshell`: Use [http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm](http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm)
* `open agent container (OAC)`: Use [http://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm](http://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm)

##### Gems

The ciscopuppet module has dependencies on a few ruby gems. After installing the Puppet Agent software you will then need to install the following gems on the agent device:

* [`net_http_unix`](https://rubygems.org/gems/net_http_unix)
* [`cisco_nxapi`](https://rubygems.org/gems/cisco_nxapi)
* [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils)

These gems have dependencies on each other so installing `cisco_node_utils` by itself will automatically install `net_http_unix` and `cisco_nxapi`.

Example:

~~~bash
[root@guestshell]#  gem install cisco_node_utils

[root@guestshell]#  gem list | egrep 'cisco|net_http'
cisco_node_utils (1.2.0)
cisco_nxapi (1.0.1)
net_http_unix (0.2.1)
~~~

*Please note: The `ciscopuppet` module requires a compatible `cisco_node_utils` gem. This is not an issue with release versions; however, when using a pre-release module it may be necessary to manually build a compatible gem. Please see the `cisco_node_utils` developer's guide for more information on building a `cisco_node_utils` gem:  [README-develop-node-utils-APIs.md](https://github.com/cisco/cisco-network-node-utils/blob/develop/docs/README-develop-node-utils-APIs.md#step-5-build-and-install-the-gem)*

##### Gem Persistence (bash-shell only)

Please note that in the Nexus `bash-shell` environment these gems are currently not persistent across system reload. This persistence issue can be mitigated by simply defining a manifest entry for installing the `cisco_node_utils` gem via the package provider.

Example:

~~~Puppet
package { 'cisco_node_utils' :
  provider => 'gem',
  ensure => present,
}
~~~
*This persistence issue does not affect the `guestshell` or `open agent container (OAC)` environments. Gems are persistent across reload in these environments.*

## Usage

The following example shows how to use ciscopuppet to configure ospf on a
Cisco Nexus switch.

Three types are needed to add OSPF support on an interface: cisco_ospf,
cisco_ospf_vrf, and cisco_interface_ospf.

First, to configure cisco_ospf to enable ospf on the device, add the
following type in the manifest:

~~~puppet
cisco_ospf {"Sample":
   ensure => present,
}
~~~

Then put the ospf router under a VRF, and add the corresponding OSPF configuration.
If the configuration is global, use 'default' as the VRF name.

~~~puppet
cisco_ospf_vrf {"Sample default":
   ensure => 'present',
   default_metric => '5',
   auto_cost => '46000',
}
~~~

Finally apply the ospf into an interface:

~~~puppet
cisco_interface_ospf {"Ethernet1/2 Sample":
   ensure => present,
   area => 200,
   cost => "200",
}
~~~

## Platform Support

### <a name="provider-platform-support">Provider Support Across Platforms</a>

The following table indicates which providers are supported on each platform. As platforms are added to the support list they may indicate `Unsupported` for some providers that have not completed the test validation process at the time of this release. Some providers will show caveats for a platform if there are limitations on usage, such as with unsupported properties or hardware limitations.

##### Cisco Providers

| ✅ = Supported <br> ❌ = Unsupported | N9k | N30xx | N31xx | N56xx | N6k | N7k | Caveats |
|:---|:---:|:-----:|:-----:|:-----:|:---:|:---:|:---:|
| [cisco_aaa_authentication_login](#type-cisco_aaa_authentication_login) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_aaa_authorization_cfg_svc](#type-cisco_aaa_authorization_cfg_svc) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_aaa_authorization_login_exec_svc](#type-cisco_aaa_authorization_login_exec_svc) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_aaa_group_tacacs](#type-cisco_aaa_group_tacacs) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_acl](#type-cisco_acl) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_ace](#type-cisco_ace) | ✅ | ✅ | ✅ | ❌* | ❌* | ❌* | * [caveats](#cisco_ace-caveats) |
| [cisco_command_config](#type-cisco_command_config) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_bgp](#type-cisco_bgp) | ✅ | ✅ | ✅ | ✅* | ✅* | ✅* | * [caveats](#cisco_bgp-caveats) |
| [cisco_bgp_af](#type-cisco_bgp_af) | ✅* | ✅* | ✅ | ✅ | ✅*  | ✅ | * [caveats](#cisco_bgp_af-caveats) |
| [cisco_bgp_neighbor](#type-cisco_bgp_neighbor) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_bgp_neighbor_af](#type-cisco_bgp_neighbor_af) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_interface](#type-cisco_interface) | ✅ | ✅ | ✅ | ✅* | ✅* | ✅ | * [caveats](#cisco_interface-caveats) |
| [cisco_interface_channel_group](#type-cisco_interface_channel_group) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_interface_ospf](#type-cisco_interface_ospf) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_portchannel_global](#type-cisco_portchannel_global) | ❌* | ✅* | ✅* | ❌* | ❌* | ❌* | * [caveats](#cisco_portchannel_global-caveats) |
| [cisco_interface_service_vni](#type-cisco_interface_service_vni) | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | 
| [cisco_ospf](#type-cisco_ospf) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_ospf_vrf](#type-cisco_ospf_vrf) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ✅ = Supported <br> ❌ = Unsupported  | N9k | N30xx | N31xx | N56xx | N6k | N7k | Caveats |
| [cisco_overlay_global](#type-cisco_overlay_global) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌  |
| [cisco_pim](#type-cisco_pim) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_pim_rp_address](#type-cisco_pim_rp_address) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_pim_group_list](#type-cisco_pim_group_list) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_portchannel_global](#type-cisco_portchannel_global) | ❌* | ✅* | ✅* | ❌* | ❌* | ❌ | * [caveats](#cisco_portchannel_global-caveats) |
| [cisco_snmp_community](#type-cisco_snmp_community) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_snmp_group](#type-cisco_snmp_group) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_snmp_server](#type-cisco_snmp_server) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_snmp_user](#type-cisco_snmp_user) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_tacacs_server](#type-cisco_tacacs_server) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_tacacs_server_host](#type-cisco_tacacs_server_host) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_vdc](#type-cisco_vdc) | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| [cisco_vlan](#type-cisco_vlan) | ✅* | ✅* | ✅* | ✅ | ✅ | ✅ | * [caveats](#cisco_vlan-caveats) |
| [cisco_vpc_domain](#type-cisco_vpc_domain) | ✅* | ✅* | ✅* | ✅* | ✅* | ✅* | * [caveats](#cisco_vlan-caveats) |
| [cisco_vrf](#type-cisco_vrf) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_vrf_af](#type-cisco_vrf_af) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_vtp](#type-cisco_vtp) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [cisco_vxlan_vtep](#type-cisco_vxlan_vtep) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| [cisco_vxlan_vtep_vni](#type-cisco_vxlan_vtep_vni) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

##### NetDev Providers

| ✅ = Supported <br> ❌ = Unsupported  | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|:---|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| [domain_name](#type-domain_name) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [name_server](#type-name_server) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [network_dns](#type-network_dns) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [network_interface](#type-network_interface) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [network_snmp](#type-network_snmp) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [network_trunk](#type-network_trunk) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [ntp_config](#type-ntp_config) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [ntp_server](#type-ntp_server) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [network_snmp](#type-network_snmp) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [radius](#type-radius) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [radius_global](#type-radius_global) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [radius_server](#type-radius_server) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [search_domain](#type-search_domain) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [snmp_community](#type-snmp_community) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [snmp_notification](#type-snmp_notification) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [snmp_notification_receiver](#type-snmp_notification_receiver) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [snmp_user](#type-snmp_user) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [syslog_server](#type-syslog_server) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [syslog_setting](#type-syslog_setting) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [tacacs](#type-tacacs) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [tacacs_global](#type-tacacs_global) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [tacacs_server_group](#type-tacacs_server_group) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| [tacacs_server](#type-tacacs_server) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |


## <a name ="resource-reference">Resource Reference<a>

The following resources include cisco types and providers along with cisco provider support for netdev stdlib types.  Installing the `ciscopuppet` module will install both the `ciscopuppet` and `netdev_stdlib` modules.

### <a name="resource-by-tech">Resource Type Catalog (by Technology)<a>

* Miscellaneous Types
  * [`cisco_command_config`](#type-cisco_command_config)
  * [`cisco_vdc`](#type-cisco_vdc)

* AAA Types
  * [`cisco_aaa_authentication_login`](#type-cisco_aaa_authentication_login)
  * [`cisco_aaa_authorization_login_cfg_svc`](#type-cisco_aaa_authorization_login_cfg_svc)
  * [`cisco_aaa_authorization_login_exec_svc`](#type-cisco_aaa_authorization_login_exec_svc)
  * [`cisco_aaa_group_tacacs`](#type-cisco_aaa_group_tacacs)

* ACL Types
  * [`cisco_ace`](#type-cisco_ace)
  * [`cisco_acl`](#type-cisco_acl)

* BGP Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_vrf_af`](#type-cisco_vrf_af)
  * [`cisco_bgp`](#type-cisco_bgp)
  * [`cisco_bgp_af`](#type-cisco_bgp_af)
  * [`cisco_bgp_neighbor`](#type-cisco_bgp_neighbor)
  * [`cisco_bgp_neighbor_af`](#type-cisco_bgp_neighbor_af)

* Domain Types
  * [`domain_name (netdev_stdlib)`](#type-domain_name)
  * [`name_server (netdev_stdlib)`](#type-name_server)
  * [`network_dns (netdev_stdlib)`](#type-network_dns)
  * [`search_domain (netdev_stdlib)`](#type-search_domain)

* Interface Types
  * [`cisco_interface`](#type-cisco_interface)
  * [`cisco_interface_channel_group`](#type-cisco_interface_channel_group)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)
  * [`cisco_interface_portchannel`](#type-cisco_interface_portchannel)
  * [`cisco_interface_service_vni`](#type-cisco_interface_service_vni)
  * [`network_interface (netdev_stdlib)`](#type-network_interface)

* Multicast Types
  * [`cisco_pim`](#type-cisco_pim)
  * [`cisco_pim_grouplist`](#type-cisco_pim_grouplist)
  * [`cisco_pim_rp_address`](#type-cisco_pim_rp_address)

* NTP Types
  * [`ntp_config (netdev_stdlib)`](#type-ntp_config)
  * [`ntp_server (netdev_stdlib)`](#type-ntp_server)

* OSPF Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_ospf`](#type-cisco_ospf)
  * [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)

* Portchannel Types
  * [`cisco_interface_channel_group`](#type-cisco_interface_channel_group)
  * [`cisco_interface_portchannel`](#type-cisco_interface_portchannel)
  * [`cisco_portchannel_global`](#type-cisco_portchannel_global)
  * [`port_channel (netdev_stdlib)`](#type-port_channel)

* RADIUS Types
  * [`radius (netdev_stdlib)`](#type-radius)
  * [`radius_global (netdev_stdlib)`](#type-radius_global)
  * [`radius_server (netdev_stdlib)`](#type-radius_server)

* SNMP Types
  * [`cisco_snmp_community`](#type-cisco_snmp_community)
  * [`cisco_snmp_group`](#type-cisco_snmp_group)
  * [`cisco_snmp_server`](#type-cisco_snmp_server)
  * [`cisco_snmp_user`](#type-cisco_snmp_user)
  * [`network_snmp (netdev_stdlib)`](#type-network_snmp)
  * [`snmp_community (netdev_stdlib)`](#type-snmp_community)
  * [`snmp_notification (netdev_stdlib)`](#type-snmp_notification)
  * [`snmp_notification_receiver (netdev_stdlib)`](#type-snmp_notification_receiver)
  * [`snmp_user (netdev_stdlib)`](#type-snmp_user)

* SYSLOG Types
  * [`syslog_server (netdev_stdlib)`](#type-syslog_server)
  * [`syslog_setting (netdev_stdlib)`](#type-syslog_setting)

* TACACS Types
  * [`cisco_tacacs_server`](#type-cisco_tacacs_server)
  * [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)
  * [`tacacs (netdev_stdlib)`](#type-tacacs)
  * [`tacacs_global (netdev_stdlib)`](#type-tacacs_global)
  * [`tacacs_server (netdev_stdlib)`](#type-tacacs_server)
  * [`tacacs_server_group (netdev_stdlib)`](#type-tacacs_server_group)

* VLAN Types
  * [`cisco_vlan`](#type-cisco_vlan)
  * [`cisco_vtp`](#type-cisco_vtp)
  * [`network_trunk (netdev_stdlib)`](#type-network_trunk)

* VPC Types
  * [`cisco_vpc_domain`](#type-cisco_vpc_domain)
  
* VRF Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_vrf_af`](#type-cisco_vrf_af)

* VNI Types
   * [`cisco_interface_service_vni`](#type-cisco_interface_service_vni)
   * [`cisco_vni`](#type-cisco_vni)

* VXLAN Types
  * [`cisco_overlay_global`](#type-cisco_overlay_global)
  * [`cisco_vxlan_vtep`](#type-cisco_vxlan_vtep)
  * [`cisco_vxlan_vtep_vni`](#type-cisco_vxlan_vtep_vni)

--
### <a name="resource-by-name">Cisco Resource Type Catalog (by Name)<a>

* [`cisco_command_config`](#type-cisco_command_config)
* [`cisco_aaa_authentication_login`](#type-cisco_aaa_authentication_login)
* [`cisco_aaa_authorization_login_cfg_svc`](#type-cisco_aaa_authorization_login_cfg_svc)
* [`cisco_aaa_authorization_login_exec_svc`](#type-cisco_aaa_authorization_login_exec_svc)
* [`cisco_aaa_group_tacacs`](#type-cisco_aaa_group_tacacs)
* [`cisco_acl`](#type-cisco_acl)
* [`cisco_ace`](#type-cisco_ace)
* [`cisco_bgp`](#type-cisco_bgp)
* [`cisco_bgp_af`](#type-cisco_bgp_af)
* [`cisco_bgp_neighbor`](#type-cisco_bgp_neighbor)
* [`cisco_bgp_neighbor_af`](#type-cisco_bgp_neighbor_af)
* [`cisco_interface`](#type-cisco_interface)
* [`cisco_interface_channel_group`](#type-cisco_interface_channel_group)
* [`cisco_interface_ospf`](#type-cisco_interface_ospf)
* [`cisco_interface_portchannel`](#type-cisco_interface_portchannel)
* [`cisco_interface_service_vni`](#type-cisco_interface_service_vni)
* [`cisco_ospf`](#type-cisco_ospf)
* [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
* [`cisco_overlay_global`](#type-cisco_overlay_global)
* [`cisco_pim`](#type-cisco_pim)
* [`cisco_pim_grouplist`](#type-cisco_pim_grouplist)
* [`cisco_pim_rp_address`](#type-cisco_pim_rp_address)
* [`cisco_portchannel_global`](#type-cisco_portchannel_global)
* [`cisco_snmp_community`](#type-cisco_snmp_community)
* [`cisco_snmp_group`](#type-cisco_snmp_group)
* [`cisco_snmp_server`](#type-cisco_snmp_server)
* [`cisco_snmp_user`](#type-cisco_snmp_user)
* [`cisco_tacacs_server`](#type-cisco_tacacs_server)
* [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)
* [`cisco_vdc`](#type-cisco_vdc)
* [`cisco_vlan`](#type-cisco_vlan)
* [`cisco_vpc_domain`](#type-cisco_vpc_domain)
* [`cisco_vni`](#type-cisco_vni)
* [`cisco_vrf`](#type-cisco_vrf)
* [`cisco_vrf_af`](#type-cisco_vrf_af)
* [`cisco_vtp`](#type-cisco_vtp)
* [`cisco_vxlan_vtep`](#type-cisco_vxlan_vtep)
* [`cisco_vxlan_vtep_vni`](#type-cisco_vxlan_vtep_vni)

### <a name="resource-by-name-netdev">NetDev StdLib Resource Type Catalog (by Name)<a>

* [`domain_name`](#type-domain_name)
* [`name_server`](#type-name_server)
* [`network_dns`](#type-network_dns)
* [`network_interface`](#type-network_interface)
* [`network_trunk`](#type-network_trunk)
* [`network_snmp`](#type-network_snmp)
* [`ntp_config`](#type-ntp_config)
* [`ntp_server`](#type-ntp_server)
* [`port_channel`](#type-port_channel)
* [`radius`](#type-radius)
* [`radius_global`](#type-radius_global)
* [`radius_server`](#type-radius_server)
* [`search_domain`](#type-search_domain)
* [`snmp_community`](#type-snmp_community)
* [`snmp_notification`](#type-snmp_notification)
* [`snmp_notification_receiver`](#type-snmp_notification_receiver)
* [`snmp_user`](#type-snmp_user)
* [`syslog_server`](#type-syslog_server)
* [`syslog_setting`](#type-syslog_setting)
* [`tacacs`](#type-tacacs)
* [`tacacs_global`](#type-tacacs_global)
* [`tacacs_server_group`](#type-tacacs_server_group)
* [`tacacs_server`](#type-tacacs_server)

--
### Cisco Resource Type Details

The following resources are listed alphabetically.

--
### Type: cisco_command_config

Allows execution of configuration commands.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `command`

Configuration command(s) to be applied to the network element. Valid values
are string.

This provider allows raw configurations to be managed by Puppet. It serves as a stopgap until specialized types are created. It has the following limitations:

* The input message buffer is limited to 500KB. Large configurations are often easier to debug if broken up into multiple smaller resource blocks.
* The cisco_command_config configuration block must use the same syntax as displayed by the `show running-config` command on the switch. In some cases, configuration commands that omit optional keywords when entered may actually appear with a different syntax when displayed by `show running-config`; for example, some access-list entries may be configured without a sequence number but yet an implicit sequence number is created regardless. This then creates an idempotency problem because there is a mismatch between `show running-config` and the manifest. The solution in this case is for the manifest to include explicit sequence numbers for the affected access-list entries.
* Order is important. Some dependent commands may fail if their associated `feature` configuration is not enabled first. Use Puppet's `before`, `after`, or `require` keywords to establish dependencies between blocks.
* Indentation counts! It implies sub-mode configuration. Use the switch's running-config as a guide and do not indent configurations that are not normally indented. Do not use tabs to indent.
* Inline comments must be prefixed by '!' or '#'.
* Negating a submode will also remove configuratons under that submode, without having to specify every submode config statement: `no router ospf RED` removes all configuration under router ospf RED.
* Syntax does not auto-complete: use `Ethernet1/1`, not `Eth1/1`.
* If a CLI command is rejected during configuration, the resource will abort at that point and will not issue any remaining CLI. For this reason, we recommend limiting the scope of each instance of this resource.

--
### Type: cisco_aaa_authentication_login

Manages AAA Authentication Login configuration.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
The name of the AAA Authentication Login instance. Must be 'default'

##### `ascii_authentication`
Enable/disable ascii_authentication for AAA Authentication Login. Valid values are true, false, keyword 'default'

##### `chap`
Enable/disable chap for AAA Authentication Login.

##### `error_display`
Enable/disable error_display for AAA Authentication Login.

##### `mschap`
Enable/disable mschap for AAA Authentication Login.

##### `mschapv2`
Enable/disable mschapv2 for AAA Authentication Login.

--
### Type: cisco_aaa_authorization_login_cfg_svc

Manages configuration for Authorization Login Config Service.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `name`
Name of the config login service. Valid values are 'console' or 'default'.

##### `groups`
Tacacs+ groups configured for this service. Valid values are an array of strings, keyword 'default'.

##### `method`
Authentication methods on this device. Valid values are 'local', 'unselected', 'default'.

--
### Type: cisco_aaa_authorization_login_exec_svc

Manages configuration for Authorization Login Exec Service.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `name`
Name of the exec login service. Valid values are 'console' or 'default'.

##### `groups`
Tacacs+ groups configured for this service. Valid values are an array of strings, keyword 'default'.

##### `method`
Authentication methods on this device. Valid values are 'local', 'unselected', 'default'.

--
### Type: cisco_aaa_group_tacacs

Manages configuration for a TACACS+ server group.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `group`
Name of the aaa group TACACS instance. Valid values are string.

##### `deadtime`
Deadtime interval for this TACACS+ server group. Valid values are integer, in minutes, keyword 'default'

##### `server_hosts`
An array of TACACS+ server hosts associated with this TACACS+ server group. Valid values are an array, or the keyword 'default'.

##### `source_interface`
Source interface for TACACS+ servers in this TACACS+ server group Valid values are string, keyword 'default'.

##### `vrf_name`
Specifies the virtual routing and forwarding instance (VRF) to use to contact this TACACS server group. Valid values are string, the keyword 'default'.

--
### Type: cisco_acl

Manages configuration of a Access Control List (ACL) instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `afi`
Address Family Identifier (AFI). Required. Valid values are ipv4 and ipv6.

##### `acl_name`
Name of the acl instance. Valid values are string.

##### `stats_per_entry`
Enable/disable Statistics Per Entry for ACL. Valid values are true, false, keyword 'default'.

##### `fragments`
Permit or deny Fragments for ACL. Valid values are 'permit-all' and 'deny-all'

--
### Type: cisco_ace

Manages configuration of an Access Control List (ACL) Access Control Entry (ACE) instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N30xx    | 7.0(3)I2(1)        | 1.2.0                  |
| N31xx    | 7.0(3)I2(1)        | 1.2.0                  |
| N56xx    | unsupported        | unsupported            |
| N6k      | unsupported        | unsupported            |
| N7k      | unsupported        | unsupported            |
| IOS XR   | unsupported        | unsupported            |

#### <a name="cisco_ace-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `http_method` | Not supported on N56xx, N6k, N7k |
| `packet_length` | Not supported on N56xx, N6k |
| `redirect` | Not supported on N56xx, N6k, N7k |
| `time_range` | Not supported on N56xx, N6k |
| `ttl` | Not supported on N56xx, N6k, N7k |
| `tcp_option_length` | Not supported on N56xx, N6k, N7k |

#### Example Usage

```puppet
cisco_ace { 'ipv4 my_acl 42':
  ensure              => 'present',
  remark              => 'East Branch',
  action              => 'permit',
  proto               => 'tcp',
  src_addr            => '10.0.0.0/8',
  src_port            => 'eq 40',
  dst_addr            => 'any',
  dst_port            => 'neq 80',

  dscp                => 'af11',
  established         => 'true',
  http_method         => 'post',
  log                 => 'true',
  packet_length       => 'range 512 1024'
  precedence          => 'flash',
  redirect            => 'Ethernet1/2,Port-Channel42',
  tcp_flags           => 'ack psh',
  tcp_option_length   => '36',
  time_range          => 'my_time_range',
  ttl                 => '128',
```

#### Parameters

| Example Parameter Usage
|:--
| `cisco_ace { '<afi> <acl_name> <seqno>':`
| `cisco_ace { 'ipv4 my_acl 42':`

##### `afi`
Address Family Identifier (AFI). Required. Valid values are ipv4 and ipv6.

##### `acl_name`
Access Control List (ACL) name. Required. Valid values are type String.

##### `seqno`
Access Control Entry (ACE) Sequence Number. Required. Valid values are type Integer.

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

#### Properties

##### `action`
The action to perform with this ACE. Valid values are keywords `permit` or `deny`.

| Example
|:--
| `action => 'permit'`

##### `dscp`
Allows matching by Differentiated Services Code Point (DSCP) value. Valid values are type String, which must be one of the following forms:

* A numeric dscp value
* One of the dscp keyword names
  * `af11` `af12` `af13` `af21` `af22` `af23` `af31` `af32` `af33` `af41` `af42` `af43`
  * `cs1` `cs2` `cs3` `cs4` `cs5` `cs6` `cs7`
  * `ef`
  * `default`

| Example
|:--
| `dscp => 'af11'`

##### `dst_addr`
The Destination Address to match against. This property shares the same syntax as `src_addr`. Valid values are type String, which must be one of the following forms:

* An IPv4/IPv6 address or subnet
* The keyword `host` and a host address
* The keyword `addrgroup` and its object group name
* The keyword `any`

| Examples
|:--
| `dst_addr => '10.0.0.0/8'`
| `dst_addr => 'host 10.0.0.1'`
| `dst_addr => '128:1::/64'`
| `dst_addr => 'addrgroup my_addrgroup'`
| `dst_addr => 'any'`

See [`src_addr`](#src_addr).

##### `dst_port`
The TCP or UDP Destination Port to match against. This property shares the same syntax as `src_port`. Valid values are type String, which must be one of the following forms:

* A comparison operator (`eq`, `neq`, `lt`, `gt`) and value
* The keyword `range` and a range value
* The keyword `portgroup` and its object group name

| Examples
|:--
| `dst_port => 'neq 40'`
| `dst_port => 'range 68 69'`
| `dst_port => 'portgroup my_portgroup'`

See [`src_port`](#src_port).

##### `established`
Allows matching against TCP Established connections. Valid values are true or false.

| Example
|:--
| `established => true`

##### `http_method`
Allows matching based on http-method. Valid values are String, which must be one of the following forms:

* A numeric http-method value
* One of the http-method keyword names
  * `connect` `delete` `get` `head` `post` `put` `trace`

| Examples
|:--
| `http_method => 'post'`

##### `log`
Enables logging for the ACE. Valid values are true or false.

| Examples
|:--
| `'log' => true`

##### `packet_length`
Allows matching based on Layer 3 Packet Length. Valid values are type String, which must be one of the following forms:

* A comparison operator (`eq`, `neq`, `lt`, `gt`) and value
* The keyword `range` and range values

| Examples
|:--
| `packet_length => 'gt 512'`
| `packet_length => 'range 512 1024'`

##### `precedence`
Allows matching by precedence value. Valid values are String, which must be one of the following forms:

* A numeric precedence value
* One of the precedence keyword names
  * `critical` `flash` `flash-override` `immediate` `internet` `network` `priority` `routine`

| Example
|:--
| `precedence => 'flash'`

##### `proto`
The protocol to match against. Valid values are String or Integer. Examples are: `tcp`, `udp`, `ip`, `6`.

| Example
|:--
| `proto => 'tcp'`

##### `redirect`
Allows for redirecting traffic to one or more interfaces. This property is only useful with VLAN ACL (VACL) applications. Valid values are a String containing a list of interface names.

| Examples
|:--
| `redirect => 'Ethernet1/1'`
| `redirect => 'Ethernet1/2,Port-Channel42'`

##### `remark`
This is a Remark description for the ACL or ACE. Valid values are string.

| Example
|:--
| `remark => 'East Branch'`

##### `src_addr`
The Source Address to match against. Valid values are type String, which must be one of the following forms:

* An IPv4/IPv6 address or subnet
* The keyword `host` and a host address
* The keyword `addrgroup` and its object group name
* The keyword `any`

| Examples
|:--
| `src_addr => '10.0.0.0/8'`
| `src_addr => 'host 10.0.0.1'`
| `src_addr => '128:1::/64'`
| `src_addr => 'addrgroup my_addrgroup'`
| `src_addr => 'any'`

See [`dst_addr`](#dst_addr).

##### `src_port`
The TCP or UDP Source Port to match against. Valid values are type String, which must be one of the following forms:

* A comparison operator (`eq`, `neq`, `lt`, `gt`) and value
* The keyword `range` and range values
* The keyword `portgroup` and its object group name

| Examples
|:--
| `src_port => 'neq 40'`
| `src_port => 'range 68 69'`
| `src_port => 'portgroup my_portgroup'`

See [`dst_port`](#dst_port).

##### `tcp_flags`
The TCP flags or control bits. Valid values are a String of some or all of flags: `urg`, `ack`, `psh`, `rst`, `syn`, or `fin`.

| Example
|:--
| `tcp_flags => 'ack psh'`

##### `tcp_option_length`
Allows matching on TCP options length. Valid values are type Integer or String, which must be a multiple of 4 in the range 0-40.

| Examples
|:--
| `tcp_option_length => '0'`
| `tcp_option_length => '36'`

##### `time_range`
Allows matching by Time Range. Valid values are String, which references a `time-range` name.

| Example
|:--
| `time_range => 'my_time_range'`


##### `ttl`
Allows matching based on Time-To-Live (TTL) value. Valid values are type Integer or String.

| Example
|:--
| `ttl => '128'`

--
### Type: cisco_bgp

Manages configuration of a BGP instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### <a name="cisco_bgp-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `disable_policy_batching_ipv4` <br> `disable_policy_batching_ipv4` <br> `neighbor_down_fib_accelerate` <br> `reconnect_interval` | Not supported on N56xx, N6k, N7k |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `asn`
BGP autonomous system number.  Valid values are String, Integer in ASPLAIN or ASDOT notation.

##### `vrf`
Name of the resource instance. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

<a name='bgp_rd'></a>
##### `route_distinguisher`
VPN Route Distinguisher (RD). The RD is combined with the IPv4 or IPv6 prefix learned by the PE router to create a globally unique address. Valid values are a String in one of the route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN); the keyword 'auto', or the keyword 'default'.

*Please note:* The `route_distinguisher` property is typically configured within the VRF context configuration on most platforms (including NXOS) but it is tightly coupled to bgp and therefore configured within the BGP configuration on some platforms (XR for example). For this reason the `route_distinguisher` property has support (with limitations) in both `cisco_vrf` and `cisco_bgp` providers:

* `cisco_bgp`: The property is fully supported on both NXOS and XR.
* `cisco_vrf`: The property is only supported on NXOS. See: [cisco_vrf: route_distinguisher](#vrf_rd)

*IMPORTANT: Choose only one provider to configure the `route_distinguisher` property on a given device. Using both providers simultaneously on the same device may have unpredictable results.*

##### `router_id`
Router Identifier (ID) of the BGP router VRF instance. Valid values are string, and keyword 'default'.

##### `cluster_id`
Route Reflector Cluster-ID. Valid values are String, keyword 'default'.

##### `confederation_id`
Routing domain confederation AS. Valid values are String, keyword 'default'.

##### `confederation_peers`
AS confederation parameters. Valid values are String, keyword 'default'.

##### `disable_policy_batching` 
Enable/Disable the batching evaluation of prefix advertisements to all peers. Valid values are 'true', 'false', and 'default'.

##### `disable_policy_batching_ipv4`
Enable/Disable the batching evaluation of prefix advertisements to all peers with prefix list. Valid values are String, keyword 'default'.  

##### `disable_policy_batching_ipv6`
Enable/Disable the batching evaluation of prefix advertisements to all peers with prefix list. Valid values are String, keyword 'default'.  

##### `enforce_first_as`
Enable/Disable enforces the neighbor autonomous system to be the first AS number listed in the AS path attribute for eBGP. Valid values are 'true', 'false', and 'default'.

##### `event_history_cli`
Enable/Disable cli event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'.

##### `event_history_detail`
Enable/Disable detail event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'.

##### `event_history_events`
Enable/Disable event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'.

##### `event_history_periodic`
Enable/Disable periodic event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'.

##### `fast_external_fallover`
Enable/Disable immediately reset the session if the link to a directly connected BGP peer goes down. Valid values are 'true', 'false', and 'default'.

##### `flush_routes`
Enable/Disable flush routes in RIB upon controlled restart. Valid values are 'true', 'false', and 'default'.

##### `isolate`
Enable/Disable isolate this router from BGP perspective. Valid values are 'true', 'false', and 'default'.

##### `maxas_limit`
Specify Maximum number of AS numbers allowed in the AS-path attribute. Valid values are integers between 1 and 512, or keyword 'default' to disable this property.

##### `neighbor_down_fib_accelerate`
Enable/Disable handle BGP neighbor down event, due to various reasons. Valid values are 'true', 'false', and 'default'.

##### `shutdown`
Administratively shutdown the BGP protocol. Valid values are 'true', 'false', and 'default'.

##### `supress_fib_pending`
Enable/Disable advertise only routes programmed in hardware to peers. Valid values are 'true', 'false', and 'default'

##### `log_neighbor_changes`
Enable/Disable message logging for neighbor up/down event. Valid values are 'true', 'false', and 'default'

##### `bestpath_always_compare_med`
Enable/Disable MED comparison on paths from different autonomous systems. Valid values are 'true', 'false', and 'default'.

##### `bestpath_aspath_multipath_relax`
Enable/Disable load sharing across the providers with different (but equal-length) AS paths. Valid values are 'true', 'false', and 'default'

##### `bestpath_compare_routerid`
Enable/Disable comparison of router IDs for identical eBGP paths. Valid values are 'true', 'false', and 'default'

##### `bestpath_cost_community_ignore`
Enable/Disable Ignores the cost community for BGP best-path calculations. Valid values are 'true', 'false', and 'default'

##### `bestpath_med_confed`
Enable/Disable enforcement of bestpath to do a MED comparison only between paths originated within a confederation. Valid values are 'true', 'false', and 'default'

##### `bestpath_med_missing_as_worst`
Enable/Disable assigns the value of infinity to received routes that do not carry the MED attribute, making these routes the least desirable. Valid values are 'true', 'false', and 'default'.

##### `bestpath_med_non_deterministic`
Enable/Disable deterministic selection of the best MED path from among the paths from the same autonomous system. Valid values are 'true', 'false', and 'default'

##### `timer_bestpath_limit`
Specify timeout for the first best path after a restart, in seconds. Valid values are Integer, keyword 'default'.

##### `timer_bestpath_limit_always`
Enable/Disable update-delay-always option. Valid values are 'true', 'false', and 'default'

##### `graceful_restart`
Enable/Disable graceful restart. Valid values are 'true', 'false', and 'default'

##### `graceful_restart_helper`
Enable/Disable graceful restart helper mode. Valid values are 'true', 'false', and 'default'

##### `graceful_restart_timers_restart`
Set maximum time for a restart sent to the BGP peer. Valid values are Integer, keyword 'default'.

##### `graceful_restart_timers_stalepath_time`
Set maximum time that BGP keeps the stale routes from the restarting BGP peer. Valid values are Integer, keyword 'default'.

##### `timer_bgp_keepalive`
Set bgp keepalive timer. Valid values are Integer, keyword 'default'.

##### `timer_bgp_hold`
Set bgp hold timer. Valid values are Integer, keyword 'default'.

--
### Type: cisco_bgp_af

Manages configuration of a BGP Address-family instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### <a name="cisco_bgp_af-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `advertise_l2vpn_evpn ` | Not supported on N30xx, N31xx, N6k |

#### Parameters

###### `ensure`
Determine whether the interface config should be present or not. Valid values
 are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in ASPLAIN or ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `afi`
Address Family Identifier (AFI). Required. Valid values are `ipv4` and `ipv6`.

##### `safi`
Sub Address Family Identifier (SAFI). Required. Valid values are `unicast` and `multicast`.

##### `additional_paths_install`
install a backup path into the forwarding table and provide prefix 'independent convergence (PIC) in case of a PE-CE link failure. Valid values are true, false, or 'default'

##### `additional_paths_receive`
Enables the receive capability of additional paths for all of the neighbors under this address family for which the capability has not been disabled.  Valid values are true, false, or 'default'

##### `additional_paths_selection`
Configures the capability of selecting additional paths for a prefix. Valid values are a string defining the name of the route-map.

##### `additional_paths_send`
Enables the send capability of additional paths for all of the neighbors under this address family for which the capability has not been disabled. Valid values are true, false, or 'default'

##### `advertise_l2vpn_evpn`
advertise evpn routes. Valid values are true and false.

##### `client_to_client`
Configure client-to-client route reflection. Valid values are true and false.

##### `dampen_igp_metric`
Specify dampen value for IGP metric-related changes, in seconds. Valid values are Integer, keyword 'default'.

##### `dampening_state`
Enable/disable route-flap dampening. Valid values are true, false or 'default'

##### `dampening_half_time`
Specify decay half-life in minutes for route-flap dampening. Valid values are Integer, keyword 'default'.

##### `dampening_max_suppress_time`
Specify max suppress time for route-flap dampening stable route. Valid values are Integer, keyword 'default'.

##### `dampening_reuse_time`
Specify route reuse time for route-flap dampening. Valid values are Integer, keyword 'default'.

##### `dampening_routemap`
Specify route-map for route-flap dampening. Valid values are a string defining the name of the route-map.

##### `dampening_suppress_time`
Specify route suppress time for route-flap dampening. Valid values are Integer, keyword 'default'.

##### Dampening Properties
Note: dampening_routemap is mutually exclusive with dampening_half_time, reuse_time, suppress_time and max_suppress_time.

##### `default_information_originate`
`default-information originate`. Valid values are true and false.

##### `default_metric`
Sets default metrics for routes redistributed into BGP. Valid values are Integer or keyword 'default'.

##### `distance_ebgp`
Sets the administrative distance for eBGP routes. Valid values are Integer or keyword 'default'.

##### `distance_ibgp`
Sets the administrative distance for iBGP routes. Valid values are Integer or keyword 'default'.

##### `distance_local`
Sets the administrative distance for local BGP routes. Valid values are Integer or keyword 'default'.

##### `inject_map`
An array of route-map names which will specify prefixes to inject. Each array entry must first specify the inject-map name, secondly an exist-map name, and optionally the `copy-attributes` keyword which indicates that attributes should be copied from the aggregate.

For example, the following array will create three separate inject-maps for `lax_inject_map`, `nyc_inject_map` (with copy-attributes), and `fsd_exist_map`:

```ruby
[
 ['lax_inject_map', 'lax_exist_map'],
 ['nyc_inject_map', 'nyc_exist_map', 'copy-attributes'],
 ['fsd_inject_map', 'fsd_exist_map']
]
```

##### `maximum_paths`
Configures the maximum number of equal-cost paths for load sharing. Valid value is an integer in the range 1-64. Default value is 1.

##### `maximum_paths_ibgp`
Configures the maximum number of ibgp equal-cost paths for load sharing. Valid value is an integer in the range 1-64. Default value is 1.

##### `networks`
Networks to configure. Valid value is a list of network prefixes to advertise.  The list must be in the form of an array.  Each entry in the array must include a prefix address and an optional route-map.

Example: IPv4 Networks Array

```ruby
[
 ['10.0.0.0/16', 'routemap_LA'],
 ['192.168.1.1', 'Chicago'],
 ['192.168.2.0/24],
 ['192.168.3.0/24', 'routemap_NYC']
]
```

Example: IPv6 Networks Array

```ruby
[
 ['10::0/64', 'routemap_LA'],
 ['192:168::1', 'Chicago'],
 ['192:168::/32]
]
```

##### `next_hop_route_map`
Configure route map for valid nexthops. Valid values are a string defining the name of the route-map.

##### `redistribute`
A list of redistribute directives. Multiple redistribute entries are allowed. The list must be in the form of a nested array: the first entry of each array defines the source-protocol to redistribute from; the second entry defines a route-map/route-policy name. A route-map/route-policy is highly advised but may be optional on some platforms, in which case it may be omitted from the array list.

Example: Platform requiring route-maps

```ruby
redistribute => [['direct',  'rm_direct'],
                 ['lisp',    'rm_lisp'],
                 ['static',  'rm_static'],
                 ['eigrp 1', 'rm_eigrp'],
                 ['isis 2',  'rm_isis'],
                 ['ospf 3',  'rm_ospf'],
                 ['rip 4',   'rm_rip']]
```
Example: Platform with optional route-maps

```ruby
redistribute => [['direct'],
                 ['lisp',    'rm_lisp'],
                 ['static'],
                 ['eigrp 1', 'rm_eigrp'],
                 ['isis 2',  'rm_isis'],
                 ['ospf 3',  'rm_ospf'],
                 ['rip 4']]
```

##### `suppress_inactive`
Advertises only active routes to peersy. Valid values are true, false, or 'default'.

##### `table_map`
Apply table-map to filter routes downloaded into URIB. Valid values are a string.

##### `table_map_filter`
Filters routes rejected by the route map and does not download them to the RIB. Valid values are true, false, or 'default'.

--
### Type: cisco_bgp_neighbor

Manages configuration of a BGP Neighbor.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

###### `ensure`
Determine whether the neighbor config should be present or not. Valid values are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in  ASPLAIN or ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `neighbor`
Neighbor Identifier. Required. Valid values are string. Neighbors may use IPv4 or IPv6 notation, with or without prefix length.

##### `description`
Description of the neighbor. Valid value is string.

##### `connected_check`
Configure whether or not to check for directly connected peer. Valid values are true and false.

##### `capability_negotiation`
Configure whether or not to negotiate capability with this neighbor. Valid  values are true and false.

##### `dynamic_capability`
Configure whether or not to enable dynamic capability. Valid values are true and false.

##### `ebgp_multihop`
Specify multihop TTL for a remote peer. Valid values are integers between 2  and 255, or keyword 'default' to disable this property.

##### `local_as`
Specify the local-as number for the eBGP neighbor. Valid values are String or Integer in ASPLAIN or ASDOT notation, or 'default', which means not to configure it.

##### `log_neighbor_changes`
Specify whether or not to enable log messages for neighbor up/down event. Valid values are 'enable', to enable it, 'disable' to disable it, or 'inherit' to use the configuration in the cisco_bgp type.

##### `low_memory_exempt`
Specify whether or not to shut down this neighbor under memory pressure. Valid values are 'true' to exempt the neighbor from being shutdown, 'false' to shut it down, or 'default' to perform the default shutdown behavior"

##### `maximum_peers`
Specify Maximum number of peers for this neighbor prefix. Valid values are between 1 and 1000, or 'default', which does not impose the limit. This  attribute can only be configured if neighbor is in 'ip/prefix' format.

##### `password`
Specify the password for neighbor. Valid value is string.

##### `password_type`
Specify the encryption type the password will use. Valid values are 'cleartext', '3des' or 'cisco_type_7' encryption, and 'default',which defaults to 'cleartext'.

##### `remote_as`
Specify Autonomous System Number of the neighbor. Valid values are String or Integer in ASPLAIN or ASDOT notation, or 'default', which means not to configure it.

##### `remove_private_as`
Specify the config to remove private AS number from outbound updates. Valid  values are 'enable' to enable this config, 'disable' to disable this config, 'all' to remove all private AS number, or 'replace-as', to replace the private AS number.

##### `shutdown`
Configure to administratively shutdown this neighbor. Valid values are true and false.

##### `suppress_4_byte_as`
Configure to suppress 4-byte AS Capability. Valid values are 'true', 'false', and 'default', which sets to the default 'false' value.

##### `timers_keepalive`
Specify keepalive timer value. Valid values are integers between 0 and 3600 in terms of seconds, or 'default', which is 60.

##### `timers_holdtime`
Specify holdtime timer value. Valid values are integers between 0 and 3600 in terms of seconds, or 'default', which is 180.

##### `transport_passive_only`
Configure whether or not to only allow passive connection setup. Valid values are 'true', 'false', and 'default', which defaults to 'false'. This attribute can only be configured when the neighbor is in 'ip' address format without prefix length.

##### `update_source`
Specify source interface of BGP session and updates. Valid value is a string of the interface name.

--
### Type: cisco_bgp_neighbor_af

Manages configuration of a BGP Neighbor Address-family instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

###### `ensure`
Determine whether the neighbor address family config should be present or not.
Valid values are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in ASPLAIN or
ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `neighbor`
Neighbor Identifier. Required. Valid values are string. Neighbors may use IPv4 or IPv6 notation, with or without a subnet mask.

##### `afi`
Neighbor Address Family Identifier (AFI). Required. Valid values are string. Valid neighbor AFIs are `ipv4` and `ipv6`. Note that some AFI/SAFI address-families may not be supported with some neighbors; e.g. an ipv6 neighbor may not support an ipv4 multicast address-family.

##### `safi`
Neighbor Sub Address Family Identifier (SAFI). Required. Valid values are string. Valid neighbor SAFIs are `unicast` and `multicast`. Note that some AFI/SAFI address-families may not be supported with some neighbors; e.g. an ipv6 neighbor may not support an ipv4 multicast address-family.

##### `advertise_map_exist`
Conditional route advertisement. This property requires two route maps: an advertise-map and an exist-map. Valid values are an array specifying both the advertise-map name and the exist-map name, or simply 'default'; e.g. `['my_advertise_map', 'my_exist_map']`. This command is mutually exclusive with the advertise_map_non_exist property.

##### `advertise_map_non_exist`
Conditional route advertisement. This property requires two route maps: an advertise-map and a non-exist-map. Valid values are an array specifying both the advertise-map name and the non-exist-map name, or simply 'default'; e.g. `['my_advertise_map', 'my_non_exist_map']`. This command is mutually exclusive with the advertise_map_exist property.

##### `allowas_in`
`allowas-in`. Valid values are true, false, or an integer value, which enables the command with a specific max-occurrences value. Related: `allowas_in_max`.

##### `allowas_in_max`
Optional max-occurrences value for `allowas_in`. Valid values are an integer value or 'default'. Can be used independently or in conjunction with `allowas_in`.

##### `as_override`
`as-override`. Valid values are true, false, or 'default'.

##### `additional_paths_receive`
`capability additional-paths receive`. Valid values are `enable` for basic command enablement; `disable` for disabling the command at the neighbor_af level (it adds the `disable` keyword to the basic command); and `inherit` to remove the command at this level (the command value is inherited from a higher BGP layer).

##### `additional_paths_send`
`capability additional-paths send`. Valid values are `enable` for basic command enablement; `disable` for disabling the command at the neighbor_af level (it adds the `disable` keyword to the basic command); and `inherit` to remove the command at this level (the command value is inherited from a higher BGP layer).

##### `default_originate`
`default-originate`. Valid values are True, False, or 'default'. Related: `default_originate_route_map`.

##### `default_originate_route_map`
Optional route-map for the `default_originate` property. Can be used independently or in conjunction with `default_originate`. Valid values are a string defining a route-map name, or 'default'.

##### `filter_list_in`
Valid values are a string defining a filter-list name, or 'default'.

##### `filter_list_out`
Valid values are a string defining a filter-list name, or 'default'.

##### `max_prefix_limit`
`maximum-prefix` limit value. Valid values are an integer value or 'default'. Related: `max_prefix_threshold`, `max_prefix_interval`, and `max_prefix_warning`.

##### `max_prefix_interval`
Optional restart interval. Valid values are an integer value or 'default'. Requires `max_prefix_limit`.

##### `max_prefix_threshold`
Optional threshold percentage at which to generate a warning. Valid values are an integer value or 'default'. Requires `max_prefix_limit`.

##### `max_prefix_warning`
Optional warning-only keyword. Valid values are True, False, or 'default'. Requires `max_prefix_limit`.

##### `next_hop_self`
`next-hop-self`. Valid values are True, False, or 'default'.

##### `next_hop_third_party`
`next-hop-third-party`. Valid values are True, False, or 'default'.

##### `prefix_list_in`
Valid values are a string defining a prefix-list name, or 'default'.

##### `prefix_list_out`
Valid values are a string defining a prefix-list name, or 'default'.

##### `route_map_in`
Valid values are a string defining a route-map name, or 'default'.

##### `route_map_out`
Valid values are a string defining a route-map name, or 'default'.

##### `route_reflector_client`
`route-reflector-client`. Valid values are True, False, or 'default'.

##### `send_community`
`send-community` attribute. Valid values are 'none', 'both', 'extended', 'standard', or 'default'.

##### `soft_reconfiguration_in`
`soft-reconfiguration inbound`. Valid values are `enable` for basic command enablement; `always` to add the `always` keyword to the basic command; and `inherit` to remove the command at this level (the command value is inherited from a higher BGP layer).

##### `soo`
Site-of-origin. Valid values are a string defining a VPN extcommunity or 'default'.

##### `suppress_inactive`
`suppress-inactive` Valid values are True, False, or 'default'.

##### `unsuppress_map`
`unsuppress-map`. Valid values are a string defining a route-map name or 'default'.

##### `weight`
`weight` value. Valid values are an integer value or 'default'.

--
### Type: cisco_interface

Manages a Cisco Network Interface. Any resource dependency should be run before the interface resource.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### <a name="cisco_interface-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| svi_autostate | Not supported on N56xx, N6k |
| vlan_mapping | Not supported on N9k, N3k, N56xx, N6k |

#### Parameters

##### Basic interface config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values
are 'present' and 'absent'.

###### `interface`
Name of the interface on the network element. Valid value is a string.

###### `description`
Description of the interface. Valid values are a string or the keyword 'default'.

###### `duplex`
Duplex of the interface. Valid values are 'full', and 'auto'.

###### `speed`
Speed of the interface. Valid values are 100, 1000, 10000, 40000, 1000000, and 'auto'.

###### `shutdown`
Shutdown state of the interface. Valid values are 'true', 'false', and
'default'.

###### `switchport_mode`
Switchport mode of the interface. To make an interface Layer 3, set
`switchport_mode` to 'disabled'. Valid values are 'disabled', 'access', 'tunnel', 'fex_fabric', 'trunk', and 'default'.

###### `ipv4_acl_in`
Apply ipv4 access list on the interface in ingress direction. Access-list should be present on the network device 
prior this configuration. Valid values are string, keyword 'default'.

###### `ipv4_acl_out`
Apply ipv4 access list on the interface in egress direction. Access-list should be present on the network device 
prior this configuration. Valid values are string, keyword 'default'.

###### `ipv6_acl_in`
Apply ipv6 access list on the interface in ingress direction. Access-list should be present on the network device 
prior this configuration. Valid values are string, keyword 'default'.

###### `ipv6_acl_out`
Apply ipv6 access list on the interface in egress direction. Access-list should be present on the network device 
prior this configuration. Valid values are string, keyword 'default'.

##### L2 interface config attributes

###### `access_vlan`
The VLAN ID assigned to the interface. Valid values are an integer or the keyword
'default'.

##### `encapsulation_dot1q`
Enable IEEE 802.1Q encapsulation of traffic on a specified subinterface.
Valid values are integer, keyword 'default'.

##### `mtu`
Maximum Trasnmission Unit size for frames received and sent on the specified
interface. Valid value is an integer.

##### `switchport_autostate_exclude`
Exclude this port for the SVI link calculation. Valid values are 'true', 'false', and 'default'.

##### `switchport_trunk_allowed_vlan`
The allowed VLANs for the specified Ethernet interface. Valid values are
string, keyword 'default'.

##### `switchport_trunk_native_vlan`
The Native VLAN assigned to the switch port. Valid values are integer, keyword 'default'.

###### `switchport_vtp`
Enable or disable VTP on the interface. Valid values are 'true', 'false',
and 'default'.

###### `negotiate_auto`
Enable/Disable negotiate auto on the interface. Valid values are 'true',
'false', and 'default'.

##### L3 interface config attributes

###### `ipv4_pim_sparse_mode`
Enables or disables ipv4 pim sparse mode on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_proxy_arp`
Enables or disables proxy arp on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_redirects`
Enables or disables sending of IP redirect messages. Valid values are 'true', 'false', and 'default'.

###### `ipv4_address`
IP address of the interface. Valid values are a string of ipv4 address or the
keyword 'default'.

###### `ipv4_netmask_length`
Network mask length of the IP address on the interface. Valid values are
integer and keyword 'default'.

###### `ipv4_address_secondary`
Secondary IP address of the interface. Valid values are a string of ipv4 address or the keyword 'default'.

###### `ipv4_netmask_length_secondary`
Network mask length of the secondary IP address on the interface. Valid values are integer and keyword 'default'.

###### `ipv4_arp_timeout`
Address Resolution Protocol (ARP) timeout value. Valid values are integer and keyword 'default'. Currently only supported on vlan interfaces.

###### `vlan_mapping`
This property is a nested array of [original_vlan, translated_vlan] pairs. Valid values are an array specifying the mapped vlans or keyword 'default'; e.g.:

```
vlan_mapping => [[20, 21], [30, 31]]
```

###### `vlan_mapping_enable`
Allows disablement of vlan_mapping on a given interface. Valid values are 'true', 'false', and 'default'.

###### `vpc_id`
Configure the vPC ID on this interface to make it a vPC link. The peer switch should configure a corresponding interface with the same vPC ID in order for the downstream device to add these links as part of the same port-channel. The vpc_id can generally be configured only on interfaces which are themselves port-channels (usually a single member port-channel). However, on the Nexus 7000 series a physical port can be configured as a vPC link. Valid values are integers in the range 1..4096. By default, interface is not configured with any vpc_id.

###### `vpc_peer_link`
Configure this port-channel interface to be a vPC peer-link. A vPC peer-link is essential to the working of the vPC complex, not only for establishing the peer connectivity for control message exchange, but also for providing redundancy when vPC links fail. Valid values are 'true' or 'false'. Default value: false.

###### `vrf`
VRF member of the interface.  Valid values are a string or the keyword 'default'.

##### SVI interface config attributes

###### `fabric_forwarding_anycast_gateway`
Associate SVI with anycast gateway under VLAN configuration mode. The `cisco_overlay_global` `anycast_gateway_mac` must be set before setting this property.
Valid values are 'true', 'false', and 'default'.

###### `svi_autostate`
Enable/Disable autostate on the SVI interface. Valid values are 'true',
'false', and 'default'.

###### `svi_management`
Enable/Disable management on the SVI interface. Valid values are 'true', 'false', and 'default'.

--
### Type: cisco_interface_channel_group

Manages a Cisco Network Interface Channel-group

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### Basic interface channel-group config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values are 'present' and 'absent'.

###### `interface`
Name of the interface where the service resides. Valid value is a string.

###### `channel_group`
channel_group is an aggregation of multiple physical interfaces that creates a logical interface. Valid values are 1 to 4096 and 'default'.

Note: On some platforms a normal side-effect of adding the channel-group property is that an independent port-channel interface will be created; however, removing the channel-group configuration by itself will not also remove the port-channel interface. Therefore, the port-channel interface itself may be explicitly removed by using the `cisco_interface` provider with `ensure => absent`.

###### `description`
Description of the interface. Valid values are a string or the keyword 'default'.

###### `shutdown`
Shutdown state of the interface. Valid values are 'true', 'false', and 'default'.

--
### Type: cisco_interface_service_vni

Manages a Cisco Network Interface Service VNI.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | unsupported | unsupported | unsupported | unsupported | unsupported | 1.2.0 |

#### Parameters

##### Basic interface service vni config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values are 'present' and 'absent'.

###### `interface`
Name of the interface where the service resides. Valid value is a string.

###### `sid`
The Service ID number. Valid value is an Integer.

###### `encapsulation_profile_vni`
The VNI Encapsulation Profile Name. Valid values are String or the keyword 'default'

###### `shutdown`
Shutdown state of the interface service vni. Valid values are 'true', 'false', or 'default'.

--
### Type: cisco_interface_ospf
Manages configuration of an OSPF interface instance.

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are
'present' and 'absent'.

##### `interface`
Name of this cisco_interface resource. Valid value is a string.

##### `ospf`
Name of the cisco_ospf resource. Valid value is a string.

##### `cost`
The cost associated with this cisco_interface_ospf instance. Valid value is an integer.

##### `hello_interval`
The hello_interval associated with this cisco_interface_ospf instance. Time
between sending successive hello packets. Valid values are an integer or the
keyword 'default'.

##### `dead_interval`
The dead_interval associated with the cisco_interface_ospf instance.
Time interval an ospf neighbor waits for a hello packet before tearing down
adjacencies. Valid values are an integer or the keyword 'default'.

##### `passive_interface`
Passive interface associated with the cisco_interface_ospf instance. Setting
to true will prevent this interface from receiving HELLO packets.
Valid values are 'true' and 'false'.

##### `message_digest`
Enables or disables the usage of message digest authentication.
Valid values are 'true' and 'false'.

##### `message_digest_key_id`
md5 authentication key-id associated with thecisco_interface_ospf instance.
If this is present in the manifest, message_digest_encryption_type,
message_digest_algorithm_type and message_digest_password are mandatory.
Valid value is an integer.

##### `message_digest_algorithm_type`
Algorithm used for authentication among neighboring routers within an area.
Valid values are 'md5' and keyword 'default'.

##### `message_digest_encryption_type`
Specifies the scheme used for encrypting message_digest_password.
Valid values are 'cleartext', '3des' or 'cisco_type_7' encryption, and
'default', which defaults to 'cleartext'.

##### `message_digest_password`
Specifies the message_digest password. Valid value is a string.

##### `area`
*Required*. Ospf area associated with this cisco_interface_ospf instance. Valid values are a string, formatted as an IP address (i.e. "0.0.0.0") or as an integer.

--
### Type: cisco_interface_portchannel

Manages configuration of a portchannel interface instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### <a name="cisco_interface_portchannel-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `port_hash_distribution ` <br> `port_load_defer ` | Not supported on N56xx, N6k |

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `lacp_graceful_convergence`
port-channel lacp graceful convergence. Valid values are true, false or 'default'.

##### `lacp_max_bundle`
port-channel max-bundle. Valid values are Integer, keyword 'default'.

##### `lacp_min_links`
port-channel min-links. Valid values are Integer, keyword 'default'.

##### `lacp_suspend_individual`
lacp port-channel state. Valid values are true and false or 'default'.

##### `port_hash_distribution`
port-channel per port hash-distribution. Valid values are 'adaptive', 'fixed' or the keyword 'default'. This property is not supported on (Nexus 5|6k)

##### `port_load_defer`
port-channel per port load-defer. Valid values are true, false or 'default'. This property is not supported on (Nexus 5|6k)

--
### Type: cisco_ospf

Manages configuration of an ospf instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determine if the config should be present or not. Valid values are 'present',
and 'absent'.

##### `ospf`
Name of the ospf router. Valid value is a string.

--
### Type: cisco_ospf_vrf

Manages a VRF for an OSPF router.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `vrf`
Name of the resource instance. Valid value is a string. The name 'default' is
a valid VRF representing the global ospf.

##### `ospf`
Name of the ospf instance. Valid value is a string.

##### `router_id`
Router Identifier (ID) of the OSPF router VRF instance. Valid values are a string or the keyword 'default'.

##### `default_metric`
Specify the default Metric value. Valid values are an  integer or the keyword
'default'.

##### `log_adjacency`
Controls the level of log messages generated whenever a neighbor changes state.
Valid values are 'log', 'detail', 'none', and 'default'.

##### `timer_throttle_lsa_start`
Specify the start interval for rate-limiting Link-State Advertisement (LSA)
generation. Valid values are an integer, in milliseconds, or the keyword 'default'.

##### `timer_throttle_lsa_hold`
Specifies the hold interval for rate-limiting Link-State Advertisement (LSA)
generation. Valid values are an integer, in milliseconds, or the keyword 'default'.

##### `timer_throttle_lsa_max`
Specifies the max interval for rate-limiting Link-State Advertisement (LSA)
generation.
Valid values are an integer, in milliseconds, or the keyword 'default'.

##### `timer_throttle_spf_start`
Specify initial Shortest Path First (SPF) schedule delay.
Valid values are an integer, in milliseconds, or the keyword 'default'.

##### `timer_throttle_spf_hold`
Specify minimum hold time between Shortest Path First (SPF) calculations.
Valid values are an integer, in milliseconds, or the keyword 'default'.

##### `timer_throttle_spf_max`
Specify the maximum wait time between Shortest Path First (SPF) calculations.
Valid values are an integer, in milliseconds, or the keyword 'default'.

##### `auto_cost`
Specifies the reference bandwidth used to assign OSPF cost.
Valid values are an integer, in Mbps, or the keyword 'default'.

--
### Type: cisco_overlay_global
Handles the detection of duplicate IP or MAC addresses based on the number of moves in a given time-interval (seconds).
Also configures anycast gateway MAC of the switch.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | unsupported | unsupported | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
Instance of cisco_overlay_global, only allow the value 'default'

##### `anycast_gateway_mac`
Anycast gateway mac of the switch

##### `dup_host_ip_addr_detection_host_moves`
The number of host moves allowed in n seconds. The range is 1 to 1000 moves; default is 5 moves.

##### `dup_host_ip_addr_detection_timeout`
The duplicate detection timeout in seconds for the number of host moves. The range is 2 to 36000 seconds; default is 180 seconds.

##### `dup_host_mac_detection_host_moves`
The number of host moves allowed in n seconds. The range is 1 to 1000 moves; default is 5 moves.

##### `dup_host_mac_detection_timeout`
The duplicate detection timeout in seconds for the number of host moves. The range is 2 to 36000 seconds; default is 180 seconds.

--
### Type: cisco_pim
Manages configuration of an Protocol Independent Multicast (PIM) instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `afi`
Address Family Identifier (AFI). Required. Valid value is ipv4.

##### `vrf`
Name of the resource instance. Required. Valid values are string. The name 'default' is a valid VRF representing the global vrf.

##### `ssm_range`
Configure group ranges for Source Specific Multicast (SSM). Valid values are multicast addresses or the keyword ‘none’.

--
### Type: cisco_pim_grouplist
Manages configuration of an Protocol Independent Multicast (PIM) static route processor (RP) address for a multicast group range.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `afi`
Address Family Identifier (AFI). Required. Valid values are ipv4 and ipv6.

##### `vrf`
Name of the resource instance. Required. Valid values are string. The name 'default' is a valid VRF representing the global vrf.

##### `rp_addr`
IP address of a router which is the route processor (RP) for a group range.. Required. Valid values are unicast addresses.

##### `group`
Specifies a group range for a static route processor (RP) address. Required. Valid values are multicast addresses.

--
### Type: cisco_pim_rp_address
Manages configuration of an Protocol Independent Multicast (PIM) static route processor (RP) address instance.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `afi`
Address Family Identifier (AFI). Required. Valid values are ipv4 and ipv6.

##### `vrf`
Name of the resource instance. Required. Valid values are string. The name 'default' is a valid VRF representing the global vrf.

##### `rp_addr`
Configures a Protocol Independent Multicast (PIM) static route processor (RP) address. Required. Valid values are unicast addresses.

--
### Type: cisco_portchannel_global
Manages configuration of a portchannel global parameters

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | unsupported | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### <a name="cisco_portchannel_global-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `asymmetric` <br> `hash_distribution` <br> `load_defer` | Supported only on N7k |
| `concatenation` <br> `resilient` | Supported only on N9k, N30xx, N31xx |
| `hash_poly` <br> `rotate` | Supported only on N56xx, N6k |
| `symmetry ` | Supported only on N9k |

#### Parameters

##### `asymmetric`
port-channel asymmetric hash. Valid values are true, false or 'default'. This property is supported only on (Nexus 7k)

##### `bundle_hash`
port-channel bundle hash. Valid values are 'ip', 'ip-l4port', 'ip-l4port-vlan', 'ip-vlan', 'l4port', 'mac', 'port', 'ip-only', 'port-only', 'ip-gre' or 'default'. 'port', 'ip-only', 'port-only', 'ip-gre' are not supported on (Nexus 7k). 'ip-l4port', 'ip-l4port-vlan', 'ip-vlan', 'l4port', 'ip-gre' are not supported on (Nexus 5|6k). 'port', 'ip-only', 'port-only' are not supported on (Nexus 3|9k)

##### `bundle_select`
port-channel bundle select. Valid values are 'src', 'dst', 'src-dst' or 'default'.

##### `concatenation`
port-channel concatenation enable or disable. Valid values are true, false or 'default'. This property is supported only on (Nexus 3|9k)

##### `hash_distribution`
port-channel hash-distribution. Valid values are 'adaptive', 'fixed' or the keyword 'default'. This property is supported only on (Nexus 7k)

##### `hash_poly`
port-channel hash-polynomial. Valid values are 'CRC10a', 'CRC10b', 'CRC10c', 'CRC10d'. This property is supported only on (Nexus 5|6k).

##### `load_defer`
port-channel load-defer time interval. Valid values are integer or 'default'. This property is supported only on (Nexus 7k)

##### `resilient`
port-channel resilient mode. Valid values are true, false or 'default'. This property is supported only on (Nexus 3|9k)

##### `rotate`
port-channel hash input offset. Valid values are integer or 'default'. This property is not supported on (Nexus 5|6k)

##### `symmetry`
port-channel symmetry hash. Valid values are true, false or 'default'. This property is supported only on (Nexus 3|9k)

--
### Type: cisco_snmp_community
Manages an SNMP community on a Cisco SNMP server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determine whether the config should be present or not on the device. Valid
values are 'present' and 'absent'.

##### `community`
Name of the SNMP community. Valid value is a string.

##### `group`
Group that the SNMP community belongs to. Valid values are a string or the
keyword 'default'.

##### `acl`
Assigns an Access Control List (ACL) to an SNMP community to filter SNMP
requests. Valid values are a string or the keyword 'default'.

--
### Type: cisco_snmp_group

Manages a Cisco SNMP Group on a Cisco SNMP Server.

The term 'group' is a standard SNMP term, but in NXOS role it serves the purpose
of group; thus this provider utility does not create snmp groups and only reports group (role) existence.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determines whether the config should be present on the device or not. Valid
values are 'present', and 'absent'.

##### `group`
Name of the snmp group. Valid value is a string.

--
### Type: cisco_snmp_server
Manages a Cisco SNMP Server. There can only be one instance of the
cisco_snmp_server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `name`
The name of the SNMP Server instance. Only 'default' is accepted as a valid
name.

##### `location`
SNMP location (sysLocation). Valid values are a string or the keyword 'default'.

##### `contact`
SNMP system contact (sysContact). Valid values are a string or the keyword
'default'.

##### `aaa_user_cache_timeout`
Configures how long the AAA synchronized user configuration stays in the local
cache. Valid values are an integer or the keyword 'default'.

##### `packet_size`
Size of SNMP packet. Valid values are an integer, in bytes, or the keyword 'default'.

##### `global_enforce_priv`
Enable/disable SNMP message encryption for all users. Valid values are 'true',
'false', and 'default'.

##### `protocol`
Enable/disable SNMP protocol. Valid values are 'true', 'false', and 'default'.

##### `tcp_session_auth`
Enable/disable a one time authentication for SNMP over TCP session.
Valid values are 'true', 'false', and 'default'.

--
### Type: cisco_snmp_user

Manages an SNMP user on an cisco SNMP server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid
values are 'present', and 'absent'.

##### `user`
Name of the SNMP user. Valid value is a string.

##### `engine_id`
Engine ID of the SNMP user. Valid values are empty string or 5 to 32 octets
seprated by colon.

##### `groups`
Groups that the SNMP user belongs to. Valid value is a string.

##### `auth_protocol`
Authentication protocol for the SNMP user. Valid values are 'md5', 'sha',
and 'none'.

##### `auth_password`
Authentication password for the SNMP user. Valid value is string.

##### `priv_protocol`
Privacy protocol for the SNMP user. Valid values are 'aes128', 'des', and
'none'.

##### `priv_password`
Privacy password for SNMP user. Valid value is a string.

##### `localized_key`
Specifies whether the passwords specified in manifest are in localized key
format (in case of true) or cleartext (in case of false). Valid values are 'true', and 'false'.

--
### Type: cisco_tacacs_server

Manages a Cisco TACACS+ Server global configuration. There can only be one
instance of the cisco_tacacs_server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `name`
Instance of the tacacs_server, only allows the value 'default'.

##### `timeout`
Global timeout interval for TACACS+ servers.  Valid value is an integer,
in seconds, or the keyword 'default'.

##### `directed_request`
Allows users to specify a TACACS+ server to send the authentication request
when logging in. Valid values are 'true', and 'false'.

##### `deadtime`
Specifies the global deadtime interval for TACACS+ servers. Valid values are
Integer, in minutes, and keyword 'default'.

##### `encryption_type`
Specifies the global preshared key type for TACACS+ servers.
Valid values are 'clear', 'encrypted', 'none', and 'default'.

##### `encryption_password`
Specifies the global TACACS+ servers preshared key password. Valid values are
string, and keyword 'default'.

##### `source_interface`
Global source interface for all TACACS+ server groups configured on the device.
Valid values are string, and keyword 'default'.

--
### Type: cisco_tacacs_server_host

Configures Cisco TACACS+ server hosts.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid
values are 'present' and 'absent'.

##### `host`
Name of the tacacs_server_host instance. Valid value is a string.

##### `port`
Server port for the host. Valid values are an integer or the keyword 'default'.

##### `timeout`
Timeout interval for the host. Valid values are an integer, in seconds, or the
keyword 'default'.

##### `encryption_type`
Specifies a preshared key for the host. Valid values are 'clear', 'encrypted',
'none', and keyword 'default'.

##### `encryption_password`
"Specifies the preshared key password for the host. Valid value is a string.

--
### Type: cisco_vdc

Manages a Cisco VDC (Virtual Device Context).

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | unsupported | unsupported | unsupported | unsupported | unsupported | 1.2.0 |

#### Parameters

##### `name`
Name of the VDC. Valid value is a String or optional keyword 'default' when referencing the default VDC.
*The current implementation restricts changes to the default VDC*.

##### `ensure`
Determines whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `limit_resource_module_type`
This command restricts the allowed module-types in a given VDC. Valid values are String or keyword 'default'.

--
### Type: cisco_vlan

Manages a Cisco VLAN.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | 1.2.0 | 1.2.0 | 1.2.0 |

#### <a name="cisco_vlan-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `mode` | Not supported on N9k, N30xx, N31xx |

#### Parameters

##### `vlan`
ID of the Virtual LAN. Valid value is an integer.

##### `ensure`
Determines whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `mapped_vni`
The Virtual Network Identifier (VNI) id that is mapped to the VLAN. Valid values are integer and keyword 'default'.

##### `vlan_name`
The name of the VLAN. Valid values are a string or the keyword 'default'.

##### `state`
State of the VLAN. Valid values are 'active', 'suspend', and keyword 'default'.

##### `shutdown`
Whether or not the vlan is shutdown. Valid values are 'true', 'false' and
keyword 'default'.

--
### Type: cisco_vpc_domain
Manages the virtual Port Channel (vPC) domain configuration of a Cisco device.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### <a name="cisco_vpc_domain-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `auto_recovery` | Not supported on N56xx, N6k |
| `layer3_peer_routing` | Not supported on N9k, N30xx, N31xx, N56xx |
| `peer_gateway_exclude_vlan` | Not supported on N9k, N30xx, N31xx |
| `port_channel_limit` | Not supported on N9k, N56xx, N6k |
| `self_isolation` | Not supported on N9k, N56xx, N6k |
| `shutdown` | Not supported on N9k, N30xx, N31xx |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `domain`
vPC domain ID. Valid values are integer in the range 1-1000. There is no default value, this is a 'name' parameter.

##### `auto_recovery`
Auto Recovery enable or disable if peer is non-operational. Valid values are true, false or default. This parameter is available only on Nexus 7000 series. Default value: true.

##### `auto_recovery_reload_delay`
Delay (in secs) before peer is assumed dead before attempting to recover vPCs. Valid values are integers in the range 240..3600. Default value: 240.

##### `delay_restore`
Delay (in secs) after peer link is restored to bring up vPCs. Valid values are integers in the range 1..3600. Default vlaue: 30.

##### `delay_restore_interface_vlan`
Delay (in secs) after peer link is restored to bring up Interface VLANs or Interface BDs. Valid values are integers in the
range 1..3600. Default value: 10.

##### `dual_active_exclude_interface_vlan_bridge_domain`
Interface VLANs or BDs to exclude from suspension when dual-active. Valid value is a string of integer ranges from 1..4095. There is no default value.

##### `graceful_consistency_check`
Graceful conistency check . Valid values are true, false or default. Default value: true.

##### `layer3_peer_routing`
Enable or Disable Layer3 peer routing. Valid values are true/false or default. Default value: false.

##### `peer_keepalive_dest`
Destination IPV4 address of the peer where Peer Keep-alives are terminated. Valid values are IPV4 unicast address. There is no default value.

##### `peer_keepalive_hold_timeout`
Peer keep-alive hold timeout in secs. Valid Values are integers in the range 3..10. Default value: 3.

##### `peer_keepalive_interval`
Peer keep-alive interval in millisecs. Valid Values are integers in the range 400..10000. Default value: 1000.

##### `peer_keepalive_interval_timeout`
Peer keep-alive interval timeout. Valid Values are integers in the range 3..20. Default value: 5.

##### `peer_keepalive_precedence`
Peer keep-alive precedence. Valid Values are integers in the range 0..7. Default value: 6.

##### `peer_keepalive_src`
Source IPV4 address of this switch where Peer Keep-alives are Sourced. Valid values are IPV4 unicast address. There is no default value.

##### `peer_keepalive_udp_port`
Peer keep-alive udp port used for hellos. Valid Values are integers in the range 1024..65000. Default value: 3200.

##### `peer_keepalive_vrf`
Peer keep-alive VRF. Valid Values are string. There is no default value.

##### `peer_gateway`
Enable or Disable Layer3 forwarding for packets with peer gateway-mac. Valid values are true/false or default. Default: false.

##### `peer_gateway_exclude_vlan`
Interface vlans to exclude from peer gateway functionality. Valid value is a string of integer ranges from 1..4095. This parameter is available only in Nexus 5000, Nexus 6000 and Nexus 7000 series. There is no default value.

##### `role_priority`
Priority to be used during vPC role selection of primary vs secondary. Valid values are integers in the range 1..65535. Default value: 32667.

##### `self_isolation`
Enable or Disable self-isolation function for vPC. Valid values are true, false or default. This parameter is available only in Nexus 7000 series. Default value: false.

##### `shutdown`
Whether or not the vPC domain is shutdown. This property is not avialable on Nexus 9000 and Nexus 3000 series. Default value: false.

##### `system_mac`
vPC system mac. Valid values are in mac addresses format. There is no default value.

##### `system_priority`
vPC system priority. Valid values are integers in the range 1..65535. Default value: 32667.

--
### Type: cisco_vrf

Manages Cisco Virtual Routing and Forwarding (VRF) configuration of a Cisco
device.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid
values are 'present' and 'absent'. Default value is 'present'.

##### `name`
Name of the VRF. Valid value is a string of non-whitespace characters. It is
not case-sensitive and overrides the title of the type.

##### `description`
Description of the VRF. Valid value is string.

<a name='vrf_rd'></a>
##### `route_distinguisher`
VPN Route Distinguisher (RD). The RD is combined with the IPv4 or IPv6 prefix learned by the PE router to create a globally unique address. Valid values are a String in one of the route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN); the keyword 'auto', or the keyword 'default'.

*Please note:* The `route_distinguisher` property is typically configured within the VRF context configuration on most platforms (including NXOS) but it is tightly coupled to bgp and therefore configured within the BGP configuration on some platforms (XR for example). For this reason the `route_distinguisher` property has support (with limitations) in both `cisco_vrf` and `cisco_bgp` providers:

* `cisco_bgp`: The property is fully supported on both NXOS and XR. See: [cisco_bgp: route_distinguisher](#bgp_rd)
* `cisco_vrf`: The property is only supported on NXOS.

*IMPORTANT: Choose only one provider to configure the `route_distinguisher` property on a given device. Using both providers simultaneously on the same device may have unpredictable results.*

##### `shutdown`
Shutdown state of the VRF. Valid values are 'true', 'false', and 'default'.

##### `vni`
Specify virtual network identifier. Valid values are Integer or keyword 'default'.

--
### Type: cisco_vrf_af

Manages Cisco Virtual Routing and Forwarding (VRF) Address-Family configuration.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid
values are 'present' and 'absent'. Default value is 'present'.

##### `name`
Name of the VRF. Required. Valid value is a string of non-whitespace characters. It is
not case-sensitive and overrides the title of the type.

##### `afi`
Address-Family Identifier (AFI). Required. Valid values are 'ipv4' or 'ipv6'.

##### `safi`
Sub Address-Family Identifier (SAFI). Required. Valid values are `unicast` or `multicast`.
*`multicast` is not supported on some platforms.*

##### `route target both auto`
Enable/Disable the route-target 'auto' setting for both import and export target communities. Valid values are true, false, or 'default'.

##### `route target both auto evpn`
(EVPN only) Enable/Disable the EVPN route-target 'auto' setting for both import and export target communities. Valid values are true, false, or 'default'.

##### `route_target_import`
Sets the route-target import extended communities. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

route_target Examples:

~~~puppet
route_target_import => ['1.2.3.4:5', '33:55']
route_target_export => '4:4 66:66'
route_target_export_evpn => '5:5'
~~~

##### `route_target_import_evpn`
(EVPN only) Sets the route-target import extended communities for EVPN. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

##### `route_target_export`
Sets the route-target export extended communities. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

##### `route_target_export_evpn`
(EVPN only) Sets the route-target export extended communities for EVPN. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

--
### Type: cisco_vtp

Manages the VTP (VLAN Trunking Protocol) configuration of a Cisco device.
There can only be one instance of the cisco_vtp.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.0.1 | 1.0.1 | 1.0.1 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid
values are 'present' and 'absent'.

##### `name`
Instance of vtp, only allow the value 'default'

##### `domain`
*Required.* VTP administrative domain. Valid value is a string.

##### `version`
Version for the VTP domain. Valid values are an integer or the keyword 'default'.

##### `file_name`
VTP file name. Valid values are a string or the keyword 'default'.

##### `password`
Password for the VTP domain. Valid values are a string or the keyword 'default'.

--
### Type: cisco_vxlan_vtep
Creates a VXLAN Network Virtualization Endpoint (NVE) overlay interface that terminates VXLAN tunnels.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | unsupported | unsupported | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `description`
Description of the NVE interface.  Valid values are string, or keyword 'default'.

##### `host_reachability`
Specify mechanism for host reachability advertisement. Valid values are 'evpn', 'flood' or keyword 'default'.

##### `shutdown`
Administratively shutdown the NVE interface. Valid values are true, false or keyword 'default'.

##### `source_interface`
Specify the loopback interface whose IP address should be used for the NVE interface. Valid values are string or keyword 'default'.

--
### Type: cisco_vxlan_vtep_vni
Creates a Virtual Network Identifier member (VNI) for an NVE overlay interface.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | unsupported | unsupported | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `interface`
Name of the nve interface on the network element. Valid values are string.

##### `vni`
ID of the Virtual Network Identifier. Valid values are integer.

##### `assoc_vrf`
This attribute is used to identify and separate processing VNIs that are associated with a VRF and used for routing. The VRF and VNI specified with this command must match the configuration of the VNI under the VRF. Valid values are true or false.

##### `ingress_replication`
Specifies mechanism for host reachability advertisement. Valid values are 'bgp', 'static', or 'default'.

##### `multicast_group`
The multicast group (range) of the VNI. Valid values are string and keyword 'default'.

##### `peer_list`
Set the ingress-replication static peer list. Valid values are an Array, a space-separated String of ip addresses, or the keyword 'default'.

##### `suppress_arp`
Suppress arp under layer 2 VNI. Valid values are true, false, or 'default'.

--
### NetDev StdLib Resource Type Details

The following resources are listed alphabetically.

--

### Type: domain_name

Configure the domain name of the device

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Domain name of the device. Valid value is a string.

--
### Type: name_server

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Hostname or address of the DNS server.  Valid value is a string.

--
### Type: network_dns

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Name, generally "settings", not used to manage the resource.  Valid value is a string.

##### `domain`
Default domain name to append to the device hostname.  Valid value is a string.

##### `search`
Array of DNS suffixes to search for FQDN entries.  Valid value is an array of strings.

##### `servers`
Array of DNS servers to use for name resolution.  Valid value is an array of strings.

--
### Type: `network_interface`

Manages a puppet netdev_stdlib Network Interface. Any resource dependency should be run before the interface resource.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

###### `name`
Name of the interface on the network element. Valid value is a string.

###### `description`
Description of the interface. Valid values are a string or the keyword 'default'.

###### `duplex`
Duplex of the interface. Valid values are 'full', and 'auto'.

###### `speed`
Speed of the interface. Valid values are 100m, 1g, 10g, 40g, 100g, and 'auto'.

##### `mtu`
Maximum Trasnmission Unit size for frames received and sent on the specified
interface. Valid value is an integer.

--
### Type: network_snmp

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
Name of the Puppet resource, not used to manage the device.  Valid value is a string.

##### `enable`
Enable or disable SNMP functionality.  Valid values are 'true' or 'false'.

##### `contact`
Contact name for this device.  Valid value is a string.

##### `location`
Location of this device.  Valid value is a string.

--
### Type: `network_trunk`

Manages a puppet netdev_stdlib Network Trunk. It should be noted that while the NetDev stdlib has certain specified accepted parameters these may not be applicable to different network devices. For example, certain Cisco devices only use dot1q encapsulation, and therefore other values will cause errors.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

###### `name`
The switch interface name. Valid value is a string.

###### `encapsulation`
The vlan-tagging encapsulation protocol, usually dot1q. Valid values are 'dot1q', 'isl', 'negotiate' and 'none'. Cisco devices use dot1q encapsulation.

###### `mode`
The L2 interface mode, enables or disables trunking. Valid values are 'access', 'trunk', 'dynamic_auto', and 'dynamic_desirable'. The mode on a Cisco device will always be 'trunk'.

###### `untagged_vlan`
VLAN used for untagged VLAN traffic. a.k.a Native VLAN. Values must be in range of 1 to 4095.

###### `tagged_vlans`
Array of VLAN names used for tagged packets. Values must be in range of 1 to 4095.

###### `pruned_vlans`
Array of VLAN ID numbers used for VLAN pruning. Values must be in range of 1 to 4095. Cisco do not implement the concept of pruned vlans.

--
### Type: ntp_config

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
Resource name, not used to configure the device.  Valid value is a string.

##### `source_interface`
Source interface for the NTP server.  Valid value is a string.

--
### Type: ntp_server

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Hostname or IPv4/IPv6 address of the NTP server.  Valid value is a string.

--
### Type: port_channel

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `id`
Channel group ID. eg 100. Valid value is an integer.

##### `interfaces`
Array of Physical Interfaces that are part of the port channel. An array of valid interface names.

##### `minimum_links`
Number of active links required for port channel to be up. Valid value is an integer.

##### `name`
Name of the port channel. eg port-channel100. Valid value is a string.

--
### Type: radius

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
Resource name, not used to manage the device.  Valid value is a string.

##### `enable`
Enable or disable radius functionality.  Valid values are 'true' or 'false'.

--
### Type: radius_global

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
Resource identifier, not used to manage the device.  Valid value is a string.

##### `timeout`
Number of seconds before the timeout period ends.  Valid value is an integer.

##### `retransmit_count`
Number of times to retransmit.  Valid value is an integer.

##### `key`
Encryption key (plaintext or in hash form depending on key_format).  Valid value is a string.

##### `key_format`
Encryption key format [0-7].  Valid value is an integer.

--
### Type: radius_server

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
IPv4/IPv6 address of the radius server.  Valid value is a string.

##### `auth_port`
Port number to use for authentication.  Valid value is an integer.

##### `acct_port`
Port number to use for accounting.  Valid value is an integer.

##### `timeout`
Number of seconds before the timeout period ends.  Valid value is an integer.

##### `retransmit_count`
Number of times to retransmit.  Valid value is an integer.

##### `accouting_only`
Enable this server for accounting only.  Valid values are 'true' or 'false'.

##### `authentication_only`
Enable this server for authentication only.  Valid values are 'true' or 'false'.

##### `key`
Encryption key (plaintext or in hash form depending on key_format).  Valid value is a string.

##### `key_format`
Encryption key format [0-7].  Valid value is an integer.

--
### Type: search_domain

Configure the search domain of the device. Note that this type is functionally equivalent to the netdev_stdlib domain_name type.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Search domain of the device. Valid value is a string.

-
### Type: snmp_community

Manages an SNMP community on a Cisco SNMP server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determine whether the config should be present or not on the device. Valid
values are 'present' and 'absent'.

##### `group`
Group that the SNMP community belongs to. Valid values are a string or the
keyword 'default'.

##### `acl`
Assigns an Access Control List (ACL) to an SNMP community to filter SNMP
requests. Valid values are a string or the keyword 'default'.

--
### Type: snmp_notification

Manages an SNMP notification on a Cisco SNMP server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `enable`
Determine whether the trap should be on or off. Valid
values are true and false.

--
### Type: snmp_notification_receiver

Manages an SNMP user on an cisco SNMP server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid
values are 'present', and 'absent'.

##### `name`
IP address of the SNMP user. Valid value is a string.

##### `port`
SNMP UDP port number

##### `username`
Username to use for SNMPv3 privacy and authentication.  This is the community string for SNMPv1 and v2.

##### `version`
SNMP version [v1|v2|v3]

##### `type`
The type of receiver [traps|informs].

##### `security`
SNMPv3 security mode [auto|noauth|priv].

##### `vrf`
Interface to send SNMP data from, e.g. "management"

##### `source_interface`
Source interface to send SNMP data from, e.g. "ethernet 2/1".

--
### Type: snmp_user

Manages an SNMP user on an cisco SNMP server.

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid
values are 'present', and 'absent'.

##### `name`
Name of the SNMP user. Valid value is a string.

##### `engine_id`
Engine ID of the SNMP user. Valid values are empty string or 5 to 32 octets
seprated by colon.

##### `roles`
Groups that the SNMP user belongs to. Valid value is a string.

##### `auth`
Authentication protocol for the SNMP user. Valid values are 'md5' and 'sha'.

##### `password`
Authentication password for the SNMP user. Valid value is string.

##### `privacy`
Privacy protocol for the SNMP user. Valid values are 'aes128' and 'des'.

##### `private_key`
Privacy password for SNMP user. Valid value is a string.

##### `localized_key`
Specifies whether the passwords specified in manifest are in localized key
format (in case of true) or cleartext (in case of false). Valid values are 'true', and 'false'.

--
### Type: syslog_server

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Hostname or IPv4/IPv6 address of the Syslog server.  Valid value is a string.

##### `serverity_level`
Syslog severity level to log.  Valid value is an integer.

##### `vrf`
Interface to send syslog data from, e.g. "management".  Valid value is a string.

--
### Type: syslog_setting

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.1.0 | 1.1.0 | 1.1.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `name`
Hostname or address of the Syslog server.  Valid value is a string.

##### `time_stamp_units`
The unit of measurement for log time values.  Valid values are 'seconds' and 'milliseconds'.

--
### Type: tacacs

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `enable`
Enable or disable radius functionality [true|false]

--
### Type: tacacs_global

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `enable`
Enable or disable radius functionality [true|false]

##### `key`
Encryption key (plaintext or in hash form depending on key_format)

##### `key_format`
Encryption key format [0-7]

##### `timeout`
Number of seconds before the timeout period ends

--
### Type: tacacs_server

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `key`
Encryption key (plaintext or in hash form depending on key_format)

##### `key_format`
Encryption key format [0-7]

##### `name`
Hostname or IPv4/IPv6 address of the Syslog server.  Valid value is a string.

##### `port`
The port of the tacacs server.

##### `timeout`
Number of seconds before the timeout period ends

--
### Type: tacacs_server_group

| Minimum Requirements | N9k | N30xx | N31xx | N56xx | N6k | N7k |
|----------------------|:---:|:-----:|:-----:|:-----:|:---:|:---:|
| OS Image | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.0(3)I2(1) | 7.3(0)N1(1) | 7.3(0)N1(1) | 7.3(0)D1(1) |
| Puppet Module | 1.2.0 | 1.2.0 | 1.2.0 | unsupported | unsupported | unsupported |

#### Parameters

##### `servers`
Array of servers associated with this group.

## Limitations

Minimum Requirements:
* Cisco NX-OS Puppet implementation requires open source Puppet version 4.0 or Puppet Enterprise 2015.2
* Supported Platforms:
  * Cisco Nexus 95xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 93xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 31xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 30xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 56xx, OS Version 7.3(0)N1(1), Environments: Open Agent Container (OAC)
  * Cisco Nexus 60xx, OS Version 7.3(0)N1(1), Environments: Open Agent Container (OAC)
  * Cisco Nexus 7xxx, OS Version 7.3(0)D1(1), Environments: Open Agent Container (OAC)

## Learning Resources

* Puppet
  * [https://learn.puppetlabs.com/](https://learn.puppetlabs.com/)
  * [https://en.wikipedia.org/wiki/Puppet_(software)](https://en.wikipedia.org/wiki/Puppet_(software))
* Markdown (for editing documentation)
  * [https://help.github.com/articles/markdown-basics/](https://help.github.com/articles/markdown-basics/)
* Ruby
  * [https://en.wikipedia.org/wiki/Ruby_(programming_language)](https://en.wikipedia.org/wiki/Ruby_(programming_language))
  * [https://www.codecademy.com/tracks/ruby](https://www.codecademy.com/tracks/ruby)
  * [https://rubymonk.com/](https://rubymonk.com/)
  * [https://www.codeschool.com/paths/ruby](https://www.codeschool.com/paths/ruby)
* Ruby Gems
  * [http://guides.rubygems.org/](http://guides.rubygems.org/)
  * [https://en.wikipedia.org/wiki/RubyGems](https://en.wikipedia.org/wiki/RubyGems)
* YAML
  * [https://en.wikipedia.org/wiki/YAML](https://en.wikipedia.org/wiki/YAML)
  * [http://www.yaml.org/start.html](http://www.yaml.org/start.html)
* Yum
  * [https://en.wikipedia.org/wiki/Yellowdog_Updater,_Modified](https://en.wikipedia.org/wiki/Yellowdog_Updater,_Modified)
  * [https://www.centos.org/docs/5/html/yum/](https://www.centos.org/docs/5/html/yum/)
  * [http://www.linuxcommand.org/man_pages](http://www.linuxcommand.org/man_pages/yum8.html)

## License

~~~text
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
