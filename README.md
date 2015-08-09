# ciscopuppet
----
### _EARLY FIELD TRIAL:_ This is a Puppet agent EFT for use with Cisco NX-OS release 7.0(3)I2(1). Please see the [Limitations](#limitations) section for more information.
----

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ciscopuppet](#beginning-with-ciscopuppet)
4. [Usage](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This ciscopuppet module enables Puppet to config Cisco Nexus Switches that 
support NXAPI through types and NXAPI based providers.

## Module Description

This module enables users to manage Cisco Nexus switches using Puppet.

This module uses Cisco NXAPI to manage various Cisco NX-OS functions on certain Cisco Nexus Switches models such as N9k series and N31xx series. These functions include,
but are not limited to, tacacs server and host, snmp server and users, and OSPF. 

## Setup

### Beginning with ciscopuppet

Before the module can be run properly on the agent, enable pluginsync in the puppet.conf file on the agent.

You must also install the following gems on the agent: net_http_unix, cisco_nxapi,
and cisco_node_utils. Since these have dependencies on each other, when you 
install cisco_node_utils, the other two gems will be automatically installed. You can include the package provider in the manifest to automate installing these gems as shown in the following example.

~~~Puppet
package { 'cisco_node_utils' :
  provider => 'gem',
  ensure => present,
}
~~~~

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

## Reference

### Public Types

* [`cisco_command_config`](#type-cisco_command_config)
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
* [`cisco_vtp`](#type-cisco_vtp)

### Type: cisco_command_config

Allows execution of configuration commands.

#### Parameters

##### `command`

Configuration command(s) to be applied to the network element. Valid values 
are string.

This provider allows raw configurations to be managed by Puppet. It serves as a stopgap until specialized types are created. It has the following limitations:

* The input message buffer is limited to 500KB. Large configurations are often easier to debug if broken up into multiple smaller resource blocks.
* Order is important. Some dependent commands may fail if their associated `feature` configuration is not enabled first. Use Puppet's `before`, `after`, or `require` keywords to establish dependencies between blocks.
* Indentation counts! It implies sub-mode configuration. Use the switch's running-config as a guide and do not indent configurations that are not normally indented. Do not use tabs to indent.
* Inline comments must be prefixed by '!' or '#'.
* Negating a submode will also remove configuratons under that submode, without having to specify every submode config statement: `no router ospf RED` removes all configuration under router ospf RED.
* Syntax does not auto-complete: use `Ethernet1/1`, not `Eth1/1`.
* If a CLI command is rejected during configuration, the resource will abort at that point and will not issue any remaining CLI. For this reason, we recommend limiting the scope of each instance of this resource.

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

##### `switchport_autostate_exclude`
Exclude this port for the SVI link calculation. Valid values are 'true', 'false', and 'default'.

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

##### SVI interface config attributes

###### `svi_autostate`
Enable/Disable autostate on the SVI interface. Valid values are 'true', 
'false', and 'default'.

###### `svi_management`
Enable/Disable management on the SVI interface. Valid values are 'true', 'false', and 'default'.

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

### Type: cisco_ospf
Manages configuration of an ospf instance.

#### Parameters

##### `ensure`
Determine if the config should be present or not. Valid values are 'present', 
and 'absent'.

##### `ospf`
Name of the ospf router. Valid value is a string.

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

This module can only be supported from NX-OS software release 7.0(3)I2(1) 
on Cisco Nexus switch N95xx, N93xx, N30xx and N31xx platforms. Please ensure 
that the switch is running a supported version of NX-OS software.

On the supported platforms, it can work with both the native NX-OS 
Puppet agent or with the CentOS Puppet agent installed into the Guestshell. 
It does not (yet) address other Cisco operating systems such as IOS, IOS-XE, 
or IOS XR.

## Development

1. Fork the repository on Github.
2. Create a named feature branch (like add_component_x).
3. Write your change.
4. Write tests for your change (if applicable).
5. Run the tests, ensuring they all pass.
6. Submit a Pull Request using Github.

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