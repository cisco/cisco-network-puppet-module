# ciscopuppet

##### Documentation Workflow Map

This workflow map aids *users*, *developers* and *maintainers* of the ciscopuppet project in selecting the appropriate document(s) for their task.

* User Guides
  * [README-agent-install.md](docs/README-agent-install.md) : Agent Installation and Configuration Guide
  * [README-beaker-agent-install.md](docs/README-beaker-agent-install.md) : Automated Agent Installation and Configuration
  * [README-package-provider.md](docs/README-package-provider.md) : Cisco Nexus Package Management using the Package Provider
  * [README-example-manifest.md](examples/README.md) : Example Demo Manifest User Guide
  * The remainder of this document is aimed at end users
* Developer Guides
  * [CONTRIBUTING.md](CONTRIBUTING.md) : Contribution guidelines
  * [README-develop-types-providers.md](docs/README-develop-types-providers.md) : Developing new ciscopuppet Types and Providers
  * [README-develop-beaker-scripts.md](docs/README-develop-beaker-scripts.md) : Developing new beaker test scripts for ciscopuppet
* Maintainers Guides
  * [README-maintainers.md](docs/README-maintainers.md) : Guidelines for core maintainers of the ciscopuppet project
  * All developer guides apply to maintainers as well

Please see [Learning Resources](#learning-resources) for additional references.

--
#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Resource Reference](#resource-reference)
   * [Resource Type Catalog (by Technology)](#resource-by-tech)
   * [Resource Type Catalog (by Name)](#resource-by-name)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Learning Resources](#learning-resources)



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
cisco_node_utils (1.0.0)
cisco_nxapi (1.0.0)
net_http_unix (0.2.1)
~~~

##### Gem Persistence (bash-shell only)

Please note that in the Nexus `bash-shell` environment these gems are currently not persistent across system reload. This persistence issue can be mitigated by simply defining a manifest entry for installing the `cisco_node_utils` gem via the package provider.

Example:

~~~Puppet
package { 'cisco_node_utils' :
  provider => 'gem',
  ensure => present,
}
~~~
*This persistence issue does not affect the `guestshell` environment. Gems are persistent across reload in the `guestshell`.*

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

## Resource Reference

### <a name="resource-by-tech">Resource Type Catalog (by Technology)<a>

* Miscellaneous Types
  * [`cisco_command_config`](#type-cisco_command_config)

* BGP Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_bgp`](#type-cisco_bgp)
  * [`cisco_bgp_af`](#type-cisco_bgp_af)
  * [`cisco_bgp_neighbor`](#type-cisco_bgp_neighbor)
  * [`cisco_bgp_neighbor_af`](#type-cisco_bgp_neighbor_af)

* Interface Types
  * [`cisco_interface`](#type-cisco_interface)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)

* OSPF Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_ospf`](#type-cisco_ospf)
  * [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)

* SNMP Types
  * [`cisco_snmp_community`](#type-cisco_snmp_community)
  * [`cisco_snmp_group`](#type-cisco_snmp_group)
  * [`cisco_snmp_server`](#type-cisco_snmp_server)
  * [`cisco_snmp_user`](#type-cisco_snmp_user)

* TACACS Types
  * [`cisco_tacacs_server`](#type-cisco_tacacs_server)
  * [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)

* VLAN Types
  * [`cisco_vlan`](#type-cisco_vlan)
  * [`cisco_vtp`](#type-cisco_vtp)

* VRF Type
  * [`cisco_vrf`](#type-cisco_vrf)

--
### <a name="resource-by-name">Resource Type Catalog (by Name)<a>

* [`cisco_command_config`](#type-cisco_command_config)
* [`cisco_bgp`](#type-cisco_bgp)
* [`cisco_bgp_af`](#type-cisco_bgp_af)
* [`cisco_bgp_neighbor`](#type-cisco_bgp_neighbor)
* [`cisco_bgp_neighbor_af`](#type-cisco_bgp_neighbor_af)
* [`cisco_interface`](#type-cisco_interface)
* [`cisco_interface_ospf`](#type-cisco_interface_ospf)
* [`cisco_ospf`](#type-cisco_ospf)
* [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
* [`cisco_snmp_community`](#type-cisco_snmp_community)
* [`cisco_snmp_group`](#type-cisco_snmp_group)
* [`cisco_snmp_server`](#type-cisco_snmp_server)
* [`cisco_snmp_user`](#type-cisco_snmp_user)
* [`cisco_tacacs_server`](#type-cisco_tacacs_server)
* [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)
* [`cisco_vlan`](#type-cisco_vlan)
* [`cisco_vrf`](#type-cisco_vrf)
* [`cisco_vtp`](#type-cisco_vtp)

--
### Resource Type Details

The following resources are listed alphabetically.

--
### Type: cisco_command_config

Allows execution of configuration commands.

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
### Type: cisco_bgp

Manages configuration of a BGP instance.

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid
values are 'present' and 'absent'.

##### `asn`
BGP autonomous system number.  Valid values are String, Integer in ASPLAIN or
ASDOT notation.

##### `vrf`
Name of the resource instance. Valid values are string. The name 'default' is
a valid VRF representing the global bgp.

##### `router_id`
Router Identifier (ID) of the BGP router VRF instance.
Valid values are string, and keyword 'default'.

##### `cluster_id`
Route Reflector Cluster-ID. Valid values are String, keyword 'default'.

##### `confederation_id`
Routing domain confederation AS. Valid values are String, keyword 'default'.

##### `confederation_peers`
AS confederation parameters. Valid values are String, keyword 'default'.

##### `enforce_first_as`
Enable/Disable enforces the neighbor autonomous system to be the first AS number 
listed in the AS path attribute for eBGP.Valid values are 'present' and 'absent'.

##### `shutdown`
Administratively shutdown the BGP protocol. Valid values are 'true', 'false',
and 'default'.

##### `supress_fib_pending`
Enable/Disable advertise only routes that are programmed in hardware to peers.
Valid values are 'true', 'false', and 'default'

##### `log_neighbor_changes`
Enable/Disable message logging for neighbor up/down event.
Valid values are 'true', 'false', and 'default'

##### `bestpath_always_compare_med`
Enable/Disable MED comparison on paths from different autonomous systems.
Valid values are 'true', 'false', and 'default'.

##### `bestpath_aspath_multipath_relax`
Enable/Disable load sharing across the providers with different
(but equal-length) AS paths. Valid values are 'true', 'false', and 'default'

##### `bestpath_compare_routerid`
Enable/Disable comparison of router IDs for identical eBGP paths.
Valid values are 'true', 'false', and 'default'

##### `bestpath_cost_community_ignore`
Enable/Disable Ignores the cost community for BGP best-path calculations.
Valid values are 'true', 'false', and 'default'

##### `bestpath_med_confed`
Enable/Disable enforcement of bestpath to do a MED comparison only between
paths originated within a confederation. Valid values are 'true', 'false',
and 'default'

##### `bestpath_med_non_deterministic`
Enable/Disable deterministic selection of the best MED path from among
the paths from the same autonomous system. Valid values are 'true', 'false',
and 'default'

##### `timer_bestpath_limit`
Specify timeout for the first best path after a restart, in seconds.
Valid values are Integer, keyword 'default'.

##### `timer_bestpath_limit_always`
Enable/Disable update-delay-always option. Valid values are 'true', 'false',
and 'default'

##### `graceful_restart`
Enable/Disable graceful restart. Valid values are 'true', 'false', and 'default'

##### `graceful_restart_helper`
Enable/Disable graceful restart helper mode. Valid values are 'true', 'false',
and 'default'

##### `graceful_restart_timers_restart`
Set maximum time for a restart sent to the BGP peer. Valid values are Integer,
keyword 'default'.

##### `graceful_restart_timers_stalepath_time`
Set maximum time that BGP keeps the stale routes from the restarting BGP peer.
Valid values are Integer, keyword 'default'.

##### `timer_bgp_keepalive`
Set bgp keepalive timer. Valid values are Integer, keyword 'default'.

##### `timer_bgp_hold`
Set bgp hold timer. Valid values are Integer, keyword 'default'.

--
### Type: cisco_bgp_af

Manages configuration of a BGP Address-family instance.

#### Parameters

###### `ensure`
Determine whether the interface config should be present or not. Valid values
 are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in ASPLAIN or
ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `afi`
Address Family Identifier (AFI). Required. Valid values are `ipv4` and `ipv6`.

##### `safi`
Sub Address Family Identifier (SAFI). Required. Valid values are `unicast` and `multicast`.

##### `client_to_client`
`client-to-client reflection`. Valid values are true and false.

##### `default_information_originate`
`default-information originate`. Valid values are true and false.

##### `next_hop_route_map`
`nexthop route-map`. Valid values are a string defining a route-map.

--
### Type: cisco_bgp_neighbor

Manages configuration of a BGP Neighbor.

#### Parameters

###### `ensure`
Determine whether the neighbor config should be present or not. Valid values 
are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in 
ASPLAIN or ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid
VRF representing the global bgp.

##### `neighbor`
Neighbor Identifier. Required. Valid values are string. Neighbors may use
IPv4 or IPv6 notation, with or without prefix length.

##### `description`
Description of the neighbor. Valid value is string.

##### `connected_check`
Configure whether or not to check for directly connected peer. Valid values are 
true and false.

##### `capability_negotiation`
Configure whether or not to negotiate capability with this neighbor. Valid 
values are true and false.

##### `dynamic_capability`
Configure whether or not to enable dynamic capability. Valid values are true
and false.

##### `ebgp_multihop`
Specify multihop TTL for a remote peer. Valid values are integers between 2 
and 255, or keyword 'default' to disable this property.

##### `local_as`
Specify the local-as number for the eBGP neighbor. Valid values are String or
Integer in ASPLAIN or ASDOT notation, or 'default', which means not to 
configure it.

##### `log_neighbor_changes`
Specify wether or not to enable log messages for neighbor up/down event. Valid 
values are 'enable', to enable it, 'disable' to disable it, or 'inherit' to use
the configuration in the cisco_bgp type.

##### `low_memory_exempt`
Specify whether or not to shut down this neighbor under memory pressue. Valid
values are 'true' to exempt the neighbor from being shutdown, 'false' to shut it 
down, or 'default' to perform the default shutdown behavior"

##### `maximum_peers`
Specify Maximum number of peers for this neighbor prefix. Valid values are 
between 1 and 1000, or 'default', which does not impose the limit. This 
attribute can only be configured if neighbor is in 'ip/prefix' format.

##### `password`
Specify the password for neighbor. Valid value is string.

##### `password_type`
Specify the encryption type the password will use. Valid values are 
'cleartext', '3des' or 'cisco_type_7' encryption, and 'default', which
defaults to 'cleartext'.

##### `remote_as`
Specify Autonomous System Number of the neighbor. Valid values are String or 
Integer in ASPLAIN or ASDOT notation, or 'default', which means not to
configure it. 

##### `remove_private_as`
Specify the config to remove private AS number from outbound updates. Valid 
values are 'enable' to enable this config, 'disable' to disable this config,
'all' to remove all private AS number, or 'replace-as', to replace the 
private AS number.

##### `shutdown`
Configure to administratively shutdown this neighbor. Valid values are true
and false.

##### `suppress_4_byte_as`
Configure to suppress 4-byte AS Capability. Valid values are 'true', 'false',
and 'default', which sets to the default 'false' value.

##### `timers_keepalive`
Specify keepalive timer value. Valid values are integers between 0 and 3600
in terms of seconds, or 'default', which is 60.

##### `timers_holdtime`
Specify holdtime timer value. Valid values are integers between 0 and 3600 in
terms of seconds, or 'default', which is 180.

##### `transport_passive_only`
Configure whether or not to only allow passive connection setup. Valid values
are 'true', 'false', and 'default', which defaults to 'false'. This attribute
can only be configured when the neighbor is in 'ip' address format without
prefix length.

##### `update_source`
Specify source interface of BGP session and updates. Valid value is a string
of the interface name.

--
### Type: cisco_bgp_neighbor_af

Manages configuration of a BGP Neighbor Address-family instance.

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

#### Parameters

##### Basic interface config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values
are 'present' and 'absent'.

###### `interface`
Name of the interface on the network element. Valid value is a string.

###### `description`
Description of the interface. Valid values are a string or the keyword 'default'.

###### `shutdown`
Shutdown state of the interface. Valid values are 'true', 'false', and
'default'.

###### `switchport_mode`
Switchport mode of the interface. To make an interface Layer 3, set
`switchport_mode` to 'disabled'. Valid values are 'disabled', 'access', 'tunnel', 'fex_fabric', 'trunk', and 'default'.

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

###### `vrf`
VRF member of the interface.  Valid values are a string or the keyword 'default'.

##### SVI interface config attributes

###### `svi_autostate`
Enable/Disable autostate on the SVI interface. Valid values are 'true',
'false', and 'default'.

###### `svi_management`
Enable/Disable management on the SVI interface. Valid values are 'true', 'false', and 'default'.

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
### Type: cisco_ospf
Manages configuration of an ospf instance.

#### Parameters

##### `ensure`
Determine if the config should be present or not. Valid values are 'present',
and 'absent'.

##### `ospf`
Name of the ospf router. Valid value is a string.

--
### Type: cisco_ospf_vrf

Manages a VRF for an OSPF router.

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid
values are 'present' and 'absent'.

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
### Type: cisco_snmp_community
Manages an SNMP community on a Cisco SNMP server.

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
### Type: cisco_vlan

Manages a Cisco VLAN.

#### Parameters

##### `vlan`
ID of the Virtual LAN. Valid value is an integer.

##### `ensure`
Determined wether the config should be present or not. Valid values are
'present' and 'absent'.

##### `vlan_name`
The name of the VLAN. Valid values are a string or the keyword 'default'.

##### `state`
State of the VLAN. Valid values are 'active', 'suspend', and keyword 'default'.

##### `shutdown`
Whether or not the vlan is shutdown. Valid values are 'true', 'false' and
keyword 'default'.

--
### Type: cisco_vrf

Manages Cisco Virtual Routing and Forwarding (VRF) configuration of a Cisco
device.

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid
values are 'present' and 'absent'. Default value is 'present'.

##### `name`
Name of the VRF. Valid value is a string of non-whitespace characters. It is
not case-sensitive and overrides the title of the type.

##### `description`
Description of the VRF. Valid value is string.

##### `shutdown`
Shutdown state of the VRF. Valid values are 'true' and 'false'.

--
### Type: cisco_vtp

Manages the VTP (VLAN Trunking Protocol) configuration of a Cisco device.
There can only be one instance of the cisco_vtp.

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

## Limitations

Minimum Requirements:
* Cisco NX-OS Puppet implementation requires open source Puppet version 4.0 or Puppet Enterprise 2015.2
* Supported Platforms:
  * Cisco Nexus 95xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 93xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 31xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 30xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell

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
