# ciscopuppet

#### Table of Contents

1. [Module Description](#module-description)
1. [Setup](#setup)
1. [Example Manifests](#example-manifests)
1. [Resource Reference](#resource-reference)
   * [Resource Type Catalog (by Technology)](#resource-by-tech)
   * [Resource Type Catalog (by Name)](#resource-by-name)
   * [Resource Platform Support Matrix](#resource-platform-support-matrix)
1. [Documentation Guide](#documentation-guide)

## <a href='module-description'>Module Description</a>

The ciscopuppet module allows a network administrator to manage Cisco Network Elements using Puppet. This module bundles a set of Puppet Types, Providers, Beaker Tests, Sample Manifests and Installation Tools for effective network management.  The  resources and capabilities provided by this Puppet Module will grow with contributions from Cisco, Puppet Labs and the open source community.

The Cisco Network Elements and Operating Systems managed by this Puppet Module are continuously expanding. See [Resource Platform Support Matrix](#resource-platform-support-matrix) for a list of currently supported hardware and software.

This GitHub repository contains the latest version of the ciscopuppet module source code. Supported versions of the ciscopuppet module are available at Puppet Forge. Please refer to [SUPPORT.md][MAINT-2] for additional details.

##### Dependencies

The `ciscopuppet` module has a dependency on the [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils) ruby gem. See the **Setup** section that follows for more information on `cisco_node_utils`.

##### Contributing

Contributions to the `ciscopuppet` module are welcome. See [CONTRIBUTING.md][DEV-1] for guidelines.

## <a href='setup'>Setup</a>

#### Puppet Master

The `ciscopuppet` module must be installed on the Puppet Master server.

```bash
puppet module install puppetlabs-ciscopuppet
```

For more information on Puppet module installation see [Puppet Labs: Installing Modules](https://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)

##### The `puppetlabs-netdev_stdlib` module

PuppetLabs provides NetDev resource support for Cisco Nexus devices with their [`puppetlabs-netdev-stdlib`](https://forge.puppet.com/puppetlabs/netdev_stdlib) module. Installing the `ciscopuppet` module automatically installs both the `ciscopuppet` and `netdev_stdlib` modules.

#### Puppet Agent

The Puppet Agent requires installation and setup on each device. Agent setup can be performed as a manual process or it may be automated. For more information please see the [README-agent-install.md][USER-1] document for detailed instructions on agent installation and configuration on Cisco Nexus devices.

##### The `cisco_node_utils` Ruby Gem

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
node 'default' {
  class {'ciscopuppet::install':
    repo  => 'http://gemserver.domain.com:8808',
    proxy => 'http://proxy.domain.com:8080',
  }
}
~~~

##### Gem Persistence

Once installed, the GEM will remain persistent across system reloads within the Guestshell or OAC environments; however, the bash-shell environment does not share this persistent behavior, in which case the `ciscopuppet::install` helper class automatically downloads and re-installs the gem after each system reload.

See [General Documentation](#general-documentation) for information on Guestshell and OAC.

## <a href='example-manifests'>Example Manifests</a>

This module has dependencies on the [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils) ruby gem. After installing the Puppet Agent software, use Puppet's built-in [`Package`](https://github.com/cisco/cisco-network-puppet-module/blob/master/examples/install.pp#L17) provider to install the gem.

A helper class [`ciscopuppet::install`](https://github.com/cisco/cisco-network-puppet-module/blob/master/examples/demo_all_cisco.pp#L19) is provided in the examples subdirectory of this module.  Simply add an `include ciscopuppet::install` statement at the beginning of the manifest to install the latest `cisco_node_utils` gem from rubygems.org. Including the aforementioned class with [`additional parameters`](https://github.com/cisco/cisco-network-puppet-module/blob/master/examples/demo_all_cisco.pp#L24) overrides the default rubygems.org repository with a custom repository.

For Puppet Agents running within the GuestShell or OAC environment, the installed GEM remains persistent across system reloads, however, agents running in the NX-OS bash-shell environment will automatically download and reinstall the GEM after a system reload.

##### OSPF Example Manifest

The following example demonstrates how to define a manifest that uses `ciscopuppet` to configure OSPF on a Cisco Nexus switch. Three resource types are used to define an OSPF instance, basic OSPF router settings, and OSPF interface settings:

* [`cisco_ospf`](https://github.com/cisco/cisco-network-puppet-module/tree/master#type-cisco_ospf)
* [`cisco_ospf_vrf`](https://github.com/cisco/cisco-network-puppet-module/tree/master#type-cisco_ospf_vrf)
* [`cisco_interface_ospf`](https://github.com/cisco/cisco-network-puppet-module/tree/master#type-cisco_interface_ospf)

The first manifest type should define the router instance using `cisco_ospf`. The title '`Sample`' becomes the router instance name.

~~~puppet
cisco_ospf {"Sample":
   ensure => present,
}
~~~

The next type to define is `cisco_ospf_vrf`. The title includes the OSPF router instance name and the VRF name. Note that a non-VRF configuration uses 'default' as the VRF name.

~~~puppet
cisco_ospf_vrf {"Sample default":
   ensure => 'present',
   default_metric => '5',
   auto_cost => '46000',
}
~~~

Finally, define the OSPF interface settings. The title here includes the Interface name and the OSPF router instance name.

~~~puppet
cisco_interface_ospf {"Ethernet1/2 Sample":
   ensure => present,
   area => 200,
   cost => "200",
}
~~~

## <a name ="resource-reference">Resource Reference<a>

The following resources include cisco types and providers along with cisco provider support for netdev stdlib types.  Installing the `ciscopuppet` module will install both the `ciscopuppet` and `netdev_stdlib` modules.

### <a name="resource-by-tech">Resource Type Catalog (by Technology)<a>

* Miscellaneous Types
  * [`cisco_command_config`](#type-cisco_command_config)
  * [`cisco_vdc`](#type-cisco_vdc)
  * [`cisco_upgrade`](#type-cisco_upgrade)

* AAA Types
  * [`cisco_aaa_authentication_login`](#type-cisco_aaa_authentication_login)
  * [`cisco_aaa_authorization_login_cfg_svc`](#type-cisco_aaa_authorization_login_cfg_svc)
  * [`cisco_aaa_authorization_login_exec_svc`](#type-cisco_aaa_authorization_login_exec_svc)
  * [`cisco_aaa_group_tacacs`](#type-cisco_aaa_group_tacacs)

* ACL Types
  * [`cisco_ace`](#type-cisco_ace)
  * [`cisco_acl`](#type-cisco_acl)

* BFD Types
  * [`cisco_bfd_global`](#type-cisco_bfd_global)

* BGP Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_vrf_af`](#type-cisco_vrf_af)
  * [`cisco_bgp`](#type-cisco_bgp)
  * [`cisco_bgp_af`](#type-cisco_bgp_af)
  * [`cisco_bgp_af_aa`](#type-cisco_bgp_af_aa)
  * [`cisco_bgp_neighbor`](#type-cisco_bgp_neighbor)
  * [`cisco_bgp_neighbor_af`](#type-cisco_bgp_neighbor_af)

* Bridge_Domain Types
  * [`cisco_bridge_domain`](#type-cisco_bridge_domain)
  * [`cisco_bridge_domain_vni`](#type-cisco_bridge_domain_vni)

* DHCP Types
  * [`cisco_dhcp_relay_global`](#type-cisco_dhcp_relay_global)

* Domain Types
  * [`domain_name (netdev_stdlib)`](#type-domain_name)
  * [`name_server (netdev_stdlib)`](#type-name_server)
  * [`network_dns (netdev_stdlib)`](#type-network_dns)
  * [`search_domain (netdev_stdlib)`](#type-search_domain)

* Fabricpath Types
  * [`cisco_fabricpath_global`](#type-cisco_fabricpath_global)
  * [`cisco_fabricpath_topology`](#type-cisco_fabricpath_topology)

* HSRP Types
  * [`cisco_hsrp_global`](#type-cisco_hsrp_global)
  * [`cisco_interface_hsrp_group`](#type-cisco_interface_hsrp_group)

* Interface Types
  * [`cisco_interface`](#type-cisco_interface)
  * [`cisco_interface_channel_group`](#type-cisco_interface_channel_group)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)
  * [`cisco_interface_portchannel`](#type-cisco_interface_portchannel)
  * [`cisco_interface_service_vni`](#type-cisco_interface_service_vni)
  * [`network_interface (netdev_stdlib)`](#type-network_interface)

* ITD (Intelligent Traffic Director) Types
  * [`cisco_itd_device_group`](#type-cisco_itd_device_group)
  * [`cisco_itd_device_group_node`](#type-cisco_itd_device_group_node)
  * [`cisco_itd_service`](#type-cisco_itd_service)

* Multicast Types
  * [`cisco_pim`](#type-cisco_pim)
  * [`cisco_pim_grouplist`](#type-cisco_pim_grouplist)
  * [`cisco_pim_rp_address`](#type-cisco_pim_rp_address)

* NTP Types
  * [`ntp_auth_key (netdev_stdlib)`](#type-ntp_auth_key)
  * [`ntp_config (netdev_stdlib)`](#type-ntp_config)
  * [`ntp_server (netdev_stdlib)`](#type-ntp_server)

* OSPF Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_ospf`](#type-cisco_ospf)
  * [`cisco_ospf_area`](#type-cisco_ospf_area)
  * [`cisco_ospf_area_vlink`](#type-cisco_ospf_area_vlink)
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
  * [`radius_server_group (netdev_stdlib)`](#type-radius_server_group)

* RouteMap Types
  * [`cisco_route_map`](#type-cisco_route_map)

* STP Types
  * [`cisco_stp_global`](#type-cisco_stp_global)

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
  * [`network_vlan (netdev_stdlib)`](#type-network_vlan)

* VPC Types
  * [`cisco_vpc_domain`](#type-cisco_vpc_domain)

* VRF Types
  * [`cisco_vrf`](#type-cisco_vrf)
  * [`cisco_vrf_af`](#type-cisco_vrf_af)

* VNI Types
   * [`cisco_interface_service_vni`](#type-cisco_interface_service_vni)
   * [`cisco_vni`](#type-cisco_vni)
   * [`cisco_encapsulation`](#type-cisco_encapsulation)

* VXLAN Types
  * [`cisco_evpn_vni`](#type-cisco_evpn_vni)
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
* [`cisco_bfd_global`](#type-cisco_bfd_global)
* [`cisco_bgp`](#type-cisco_bgp)
* [`cisco_bgp_af`](#type-cisco_bgp_af)
* [`cisco_bgp_af_aa`](#type-cisco_bgp_af_aa)
* [`cisco_bgp_neighbor`](#type-cisco_bgp_neighbor)
* [`cisco_bgp_neighbor_af`](#type-cisco_bgp_neighbor_af)
* [`cisco_bridge_domain`](#type-cisco_bridge_domain)
* [`cisco_bridge_domain_vni`](#type-cisco_bridge_domain_vni)
* [`cisco_dhcp_relay_global`](#type-cisco_dhcp_relay_global)
* [`cisco_encapsulation`](#type-cisco_encapsulation)
* [`cisco_evpn_vni`](#type-cisco_evpn_vni)
* [`cisco_fabricpath_global`](#type-cisco_fabricpath_global)
* [`cisco_fabricpath_topology`](#type-cisco_fabricpath_topology)
* [`cisco_hsrp_global`](#type-cisco_hsrp_global)
* [`cisco_interface`](#type-cisco_interface)
* [`cisco_interface_channel_group`](#type-cisco_interface_channel_group)
* [`cisco_interface_hsrp_group`](#type-cisco_interface_hsrp_group)
* [`cisco_interface_ospf`](#type-cisco_interface_ospf)
* [`cisco_interface_portchannel`](#type-cisco_interface_portchannel)
* [`cisco_interface_service_vni`](#type-cisco_interface_service_vni)
* [`cisco_itd_device_group`](#type-cisco_itd_device_group)
* [`cisco_itd_device_group_node`](#type-cisco_itd_device_group_node)
* [`cisco_itd_service`](#type-cisco_itd_service)
* [`cisco_ospf`](#type-cisco_ospf)
* [`cisco_ospf_area`](#type-cisco_ospf_area)
* [`cisco_ospf_area_vlink`](#type-cisco_ospf_area_vlink)
* [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
* [`cisco_overlay_global`](#type-cisco_overlay_global)
* [`cisco_pim`](#type-cisco_pim)
* [`cisco_pim_grouplist`](#type-cisco_pim_grouplist)
* [`cisco_pim_rp_address`](#type-cisco_pim_rp_address)
* [`cisco_portchannel_global`](#type-cisco_portchannel_global)
* [`cisco_route_map`](#type-cisco_route_map)
* [`cisco_stp_global`](#type-cisco_stp_global)
* [`cisco_snmp_community`](#type-cisco_snmp_community)
* [`cisco_snmp_group`](#type-cisco_snmp_group)
* [`cisco_snmp_server`](#type-cisco_snmp_server)
* [`cisco_snmp_user`](#type-cisco_snmp_user)
* [`cisco_tacacs_server`](#type-cisco_tacacs_server)
* [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)
* [`cisco_upgrade`](#type-cisco_upgrade)
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
* [`network_snmp`](#type-network_snmp)
* [`network_trunk`](#type-network_trunk)
* [`network_vlan`](#type-network_vlan)
* [`ntp_auth_key`](#type-ntp_auth_key)
* [`ntp_config`](#type-ntp_config)
* [`ntp_server`](#type-ntp_server)
* [`port_channel`](#type-port_channel)
* [`radius`](#type-radius)
* [`radius_global`](#type-radius_global)
* [`radius_server_group`](#type-radius_server_group)
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

### <a href='resource-platform-support-matrix'>Resource Platform Support Matrix</a>

The Nexus family of switches support various hardware and software features depending on the model and version. The following table will guide you through the provider support matrix.

**Platform Models**

Platform | Description | Environments
:--|:--|:--
**N9k**   | Support includes all N9xxx models  | bash-shell, guestshell
**N3k**   | Support includes N30xx and N31xx models only.<br>The N35xx model is not supported.   | bash-shell, guestshell
**N5k**   | Support includes N56xx models only.<br>The N50xx and N55xx models are not supported at this time. | Open Agent Container (OAC)
**N6k**   | Support includes all N6xxx models  | Open Agent Container (OAC)
**N7k**   | Support includes all N7xxx models  | Open Agent Container (OAC)
**N9k-F** | Support includes all N95xx models running os version 7.0(3)Fx(x) | bash-shell, guestshell



**Matrix Legend**

Symbol | Meaning | Description
:--|:--|:--
✅ | Supported      | The provider has been validated to work on the platform.<br>An asterisk '*' indicates that some provider properties may have software or hardware limitations, caveats, or other noted behaviors.<br>Click on the associated caveat link for more information.
➖ | Not Applicable | The provider is not supported on the platform because of hardware or software limitations.

**Support Matrix**

| ✅ = Supported <br> ➖ = Not Applicable | N9k | N3k | N5k | N6k | N7k | N9k-F | Caveats |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| [cisco_aaa_<br>authentication_login](#type-cisco_aaa_authentication_login)                 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_aaa_<br>authorization_login_cfg_svc](#type-cisco_aaa_authorization_login_cfg_svc)   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_aaa_<br>authorization_login_exec_svc](#type-cisco_aaa_authorization_login_exec_svc) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| [cisco_aaa_group_tacacs](#type-cisco_aaa_group_tacacs)     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_acl](#type-cisco_acl)                               | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_ace](#type-cisco_ace)                               | ✅  | ✅  | ✅* | ✅* | ✅* | ✅ | \*[caveats](#cisco_ace-caveats) |
| [cisco_bfd_global](#type-cisco_bfd_global)                 | ✅* | ✅* | ✅* | ✅* | ✅* | ✅* | \*[caveats](#cisco_bfd_global-caveats) |
| [cisco_command_config](#type-cisco_command_config)         | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_bgp](#type-cisco_bgp)                               | ✅  | ✅  | ✅* | ✅* | ✅* | ✅ | \*[caveats](#cisco_bgp-caveats) |
| [cisco_bgp_af](#type-cisco_bgp_af)                         | ✅* | ✅* | ✅  | ✅* | ✅  | ✅ | \*[caveats](#cisco_bgp_af-caveats) |
| [cisco_bgp_af_aa](#type-cisco_bgp_af_aa)                   | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_bgp_neighbor](#type-cisco_bgp_neighbor)             | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_bgp_neighbor_af](#type-cisco_bgp_neighbor_af)       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_bridge_domain](#type-cisco_bridge_domain)           | ➖ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_bridge_domain_vni](#type-cisco_bridge_domain_vni)   | ➖ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_dhcp_relay_global](#type-cisco_dhcp_relay_global)   | ✅* | ✅* | ✅* | ✅* | ✅* | ✅* | \*[caveats](#cisco_dhcp_relay_global-caveats)
| [cisco_encapsulation](#type-cisco_encapsulation)           | ➖ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_evpn_vni](#type-cisco_evpn_vni)                     | ✅ | ➖ | ✅ | ✅ | ✅ | ✅ | \*[caveats](#cisco_evpn_vni-caveats) |
| [cisco_fabricpath_global](#type-cisco_fabricpath_global)     | ➖ | ➖ | ✅ | ✅ | ✅* | ➖ | \*[caveats](#cisco_fabricpath_global-caveats) |
| [cisco_fabricpath_topology](#type-cisco_fabricpath_topology) | ➖ | ➖ | ✅ | ✅ | ✅  | ➖ |
| [cisco_hsrp_global](#type-cisco_hsrp_global)                         | ✅  | ✅* | ✅  | ✅  | ✅  | ✅  | \*[caveats](#cisco_hsrp_global-caveats) |
| [cisco_interface](#type-cisco_interface)                             | ✅* | ✅* | ✅* | ✅* | ✅* | ✅* | \*[caveats](#cisco_interface-caveats) |
| [cisco_interface_channel_group](#type-cisco_interface_channel_group) | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ | \*[caveats](#cisco_interface_channel_group-caveats) |
| [cisco_interface_hsrp_group](#type-cisco_interface_hsrp_group)       | ✅  | ✅ | ➖ | ➖ | ✅* | ✅ | \*[caveats](#cisco_interface_hsrp_group-caveats) |
| [cisco_interface_ospf](#type-cisco_interface_ospf)                   | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_interface_portchannel](#type-cisco_interface_portchannel)     | ✅* | ✅* | ✅* | ✅* | ✅* | ✅ | \*[caveats](#cisco_interface_portchannel-caveats) |
| [cisco_interface_service_vni](#type-cisco_interface_service_vni) | ➖ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_itd_device_group](#type-cisco_itd_device_group)           | ✅ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_itd_device_group_node](#type-cisco_itd_device_group_node) | ✅ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_itd_service](#type-cisco_itd_service)                     | ✅ | ➖ | ➖ | ➖ | ✅ | ➖ | \*[caveats](#cisco_itd_service-caveats) |
| [cisco_ospf](#type-cisco_ospf)                             | ✅  | ✅  | ✅ | ✅  | ✅ | ✅ |
| [cisco_ospf_vrf](#type-cisco_ospf_vrf)                     | ✅  | ✅  | ✅ | ✅  | ✅ | ✅ |
| ✅ = Supported <br> ➖ = Not Applicable | N9k | N3k | N5k | N6k | N7k | N9k-F | Caveats |
| [cisco_overlay_global](#type-cisco_overlay_global)         | ✅  | ✅* | ✅  | ✅  | ✅  | ✅ | \*[caveats](#cisco_overlay_global-caveats) |
| [cisco_pim](#type-cisco_pim)                               | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ | \*[caveats](#cisco_pim-caveats) |
| [cisco_pim_rp_address](#type-cisco_pim_rp_address)         | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_pim_grouplist](#type-cisco_pim_grouplist)           | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_portchannel_global](#type-cisco_portchannel_global) | ✅* | ✅* | ✅* | ✅* | ✅* | ✅* | \*[caveats](#cisco_portchannel_global-caveats) |
| [cisco_route_map](#type-cisco_route_map)                   | ✅* | ✅* | ✅* | ✅* | ✅* | ✅* | \*[caveats](#cisco_route_map-caveats) |
| [cisco_stp_global](#type-cisco_stp_global)                 | ✅* | ✅* | ✅* | ✅* | ✅ | ✅ | \*[caveats](#cisco_stp_global-caveats) |
| [cisco_snmp_community](#type-cisco_snmp_community)         | ✅  | ✅  | ✅  | ✅  | ✅ | ✅ |
| [cisco_snmp_group](#type-cisco_snmp_group)                 | ✅  | ✅  | ✅  | ✅  | ✅ | ✅ |
| [cisco_snmp_server](#type-cisco_snmp_server)               | ✅  | ✅  | ✅  | ✅  | ✅ | ✅ |
| [cisco_snmp_user](#type-cisco_snmp_user)                   | ✅  | ✅  | ✅  | ✅  | ✅ | ✅ |
| [cisco_tacacs_server](#type-cisco_tacacs_server)           | ✅  | ✅  | ✅  | ✅  | ✅ | ✅ |
| [cisco_tacacs_server_host](#type-cisco_tacacs_server_host) | ✅  | ✅  | ✅  | ✅  | ✅ | ✅ |
| [cisco_upgrade](type-cisco_upgrade)                        | ✅* | ✅* | ➖ | ➖ | ➖ | ✅* | \*[caveats](#cisco_upgrade-caveats) |
| [cisco_vdc](#type-cisco_vdc)                               | ➖ | ➖ | ➖ | ➖ | ✅ | ➖ |
| [cisco_vlan](#type-cisco_vlan)                             | ✅* | ✅* | ✅  | ✅  | ✅ | ✅ | \*[caveats](#cisco_vlan-caveats) |
| [cisco_vpc_domain](#type-cisco_vpc_domain)                 | ✅* | ✅* | ✅* | ✅* | ✅* | ➖ | \*[caveats](#cisco_vpc_domain-caveats) |
| [cisco_vrf](#type-cisco_vrf)                               | ✅  | ✅* | ✅  | ✅  | ✅ | ✅ | \*[caveats](#cisco_vrf-caveats) |
| [cisco_vrf_af](#type-cisco_vrf_af)                         | ✅  | ✅* | ✅* | ✅* | ✅* | ✅ | \*[caveats](#cisco_vrf_af-caveats) |
| [cisco_vtp](#type-cisco_vtp)                               | ✅  | ✅  | ✅  | ✅  | ✅  | ✅ |
| [cisco_vxlan_vtep](#type-cisco_vxlan_vtep)                 | ✅  | ➖ | ✅  | ✅  | ✅* | ✅ | \*[caveats](#cisco_vxlan_vtep-caveats) |
| [cisco_vxlan_vtep_vni](#type-cisco_vxlan_vtep_vni)         | ✅  | ➖ | ✅  | ✅  | ✅  | ✅ | \*[caveats](#cisco_vxlan_vtep_vni-caveats) |

##### NetDev Providers

| ✅ = Supported <br> ➖ = Not Applicable | N9k | N3k | N5k | N6k | N7k | N9k-F | Caveats |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| [domain_name](#type-domain_name)                           | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [name_server](#type-name_server)                           | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [network_dns](#type-network_dns)                           | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [network_interface](#type-network_interface)               | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [network_snmp](#type-network_snmp)                         | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [network_trunk](#type-network_trunk)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [network_vlan](#type-network_vlan)                         | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [ntp_auth_key](#type-ntp_auth_key)                         | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [ntp_config](#type-ntp_config)                             | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  | \*[caveats](#ntp_config-caveats)
| [ntp_server](#type-ntp_server)                             | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  | \*[caveats](#ntp_server-caveats)
| [port_channel](#type-port_channel)                         | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [radius](#type-radius)                                     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [radius_global](#type-radius_global)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [radius_server_group](#type-tacacs_server_group)           | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [radius_server](#type-radius_server)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [search_domain](#type-search_domain)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [snmp_community](#type-snmp_community)                     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [snmp_notification](#type-snmp_notification)               | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [snmp_notification_receiver](#type-snmp_notification_receiver) | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [snmp_user](#type-snmp_user)                               | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [syslog_server](#type-syslog_server)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [syslog_setting](#type-syslog_setting)                     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [tacacs](#type-tacacs)                                     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [tacacs_global](#type-tacacs_global)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [tacacs_server](#type-tacacs_server)                       | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |
| [tacacs_server_group](#type-tacacs_server_group)           | ✅  | ✅  | ✅  | ✅  | ✅  | ✅  |

--
### Cisco Resource Type Details

The following resources are listed alphabetically.

--
### Type: cisco_command_config

Allows execution of configuration commands.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |

#### <a name="cisco_acl-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `fragments` | Not supported on N5k, N6k |

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
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |

#### <a name="cisco_ace-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `http_method`        | ipv4 only <br> Not supported on N5k, N6k, N7k |
| `packet_length`      | Not supported on N5k, N6k |
| `precedence`         | ipv4 only |
| `redirect`           | ipv4 only <br> Not supported on N5k, N6k, N7k |
| `time_range`         | Not supported on N5k, N6k |
| `ttl`                | Not supported on N5k, N6k, N7k |
| `tcp_option_length`  | ipv4 only <br> Not supported on N5k, N6k, N7k |

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
  log                 => 'true',
  packet_length       => 'range 512 1024'
  precedence          => 'flash',
  redirect            => 'Ethernet1/2,Port-Channel42',
  tcp_flags           => 'ack psh',
  time_range          => 'my_time_range',
  ttl                 => '128',
}

cisco_ace { 'ipv6 my_v6_acl 42':
  ensure              => 'present',
  remark              => 'East Branch',
  action              => 'permit',
  proto               => 'tcp',
  src_addr            => '1:1::1/128',
  dst_addr            => 'any',
}
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
(ipv4 only) Allows matching based on http-method. Valid values are String, which must be one of the following forms:

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
(ipv4 only) Allows matching by precedence value. Valid values are String, which must be one of the following forms:

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
(ipv4 only) Allows for redirecting traffic to one or more interfaces. This property is only useful with VLAN ACL (VACL) applications. Valid values are a String containing a list of interface names.

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
(ipv4 only) Allows matching on TCP options length. Valid values are type Integer or String, which must be a multiple of 4 in the range 0-40.

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
### Type: cisco_bfd_global

Manages configuration of a BFD (Bidirectional Forwarding Detection) instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.4.0                  |
| N3k      | 7.0(3)I2(1)        | 1.4.0                  |
| N5k      | 7.3(0)N1(1)        | 1.4.0                  |
| N6k      | 7.3(0)N1(1)        | 1.4.0                  |
| N7k      | 7.3(0)D1(1)        | 1.4.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_bfd_global-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `echo_rx_interval`      | Not supported on N5k, N6k        |
| `fabricpath_interval`   | Not supported on N3k, N9k-F, N9k |
| `fabricpath_slow_timer` | Not supported on N3k, N9k-F, N9k |
| `fabricpath_vlan`       | Not supported on N3k, N9k-F, N9k |
| `interval`              | Supported on N3k, N5k, N6k, N7k <br> Supported in OS Version 7.0(3)F2(1) and later on N9k-F <br> Supported in OS Version 7.0(3)I6(1) and later on N9k |
| `ipv4_echo_rx_interval` | Not supported on N5k, N6k        |
| `ipv4_interval`         | Not supported on N5k, N6k        |
| `ipv4_slow_timer`       | Not supported on N5k, N6k        |
| `ipv6_echo_rx_interval` | Not supported on N5k, N6k        |
| `ipv6_interval`         | Not supported on N5k, N6k        |
| `ipv6_slow_timer`       | Not supported on N5k, N6k        |
| `startup_timer`         | Not supported on N5k, N6k, N7k   |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `echo_interface`
Loopback interface used for echo frames.  Valid values are String, and 'default'.

##### `echo_rx_interval`
Echo receive interval in milliseconds.  Valid values are integer, and 'default'.

##### `fabricpath_interval`
BFD fabricpath interval.  Valid values are an array of [fabricpath_interval, fabricpath_min_rx, fabricpath_multiplier] or 'default'.

Example: `fabricpath_interval => [100, 120, 4]`

##### `fabricpath_slow_timer`
BFD fabricpath slow rate timer in milliseconds.  Valid values are integer, and 'default'.

##### `fabricpath_vlan`
BFD fabricpath control vlan.  Valid values are integer, and 'default'.

##### `interval`
BFD interval.  Valid values are an array of [interval, min_rx, multiplier] or 'default'.

Example: `interval => [100, 120, 4]`

##### `ipv4_echo_rx_interval`
IPv4 session echo receive interval in milliseconds.  Valid values are integer, and 'default'.

##### `ipv4_interval`
BFD IPv4 session interval.  Valid values are an array of [ipv4_interval, ipv4_min_rx, ipv4_multiplier] or 'default'.

Example: `ipv4_interval => [100, 120, 4]`

##### `ipv4_slow_timer`
BFD IPv4 session slow rate timer in milliseconds.  Valid values are integer, and 'default'.

##### `ipv6_echo_rx_interval`
IPv6 session echo receive interval in milliseconds.  Valid values are integer, and 'default'.

##### `ipv6_interval`
BFD IPv6 session interval.  Valid values are an array of [ipv6_interval, ipv6_min_rx, ipv6_multiplier] or 'default'.

Example: `ipv6_interval => [100, 120, 4]`

##### `ipv6_slow_timer`
BFD IPv6 session slow rate timer in milliseconds.  Valid values are integer, and 'default'.

##### `slow_timer`
BFD slow rate timer in milliseconds.  Valid values are integer, and 'default'.

##### `startup_timer`
BFD delayed startup timer in seconds.  Valid values are integer, and 'default'.

--
### Type: cisco_bgp

Manages configuration of a BGP instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |

#### <a name="cisco_bgp-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `disable_policy_batching_ipv4` | Not supported on N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |
| `disable_policy_batching_ipv6` | Not supported on N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |
| `event_history_errors        ` | supported on N3|9k on 7.0(3)I5(1) and later images |
| `event_history_events        ` | default value is 'large' for N3|9k on 7.0(3)I5(1) and later images |
| `event_history_objstore      ` | supported on N3|9k on 7.0(3)I5(1) and later images |
| `event_history_periodic      ` | default value is 'false' for N3|9k on 7.0(3)I5(1) and later images |
| `neighbor_down_fib_accelerate` | Not supported on N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |
| `reconnect_interval`           | Not supported on N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |
| `suppress_fib_pending`         | Idempotence supported only on 7.0(3)I5(1) and later images N3|9k |

#### Parameters

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `asn`
BGP autonomous system number.  Valid values are String, Integer in ASPLAIN or ASDOT notation.

##### `vrf`
Name of the resource instance. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

#### Properties

##### `bestpath_always_compare_med`
Enable/Disable MED comparison on paths from different autonomous systems. Valid values are 'true', 'false', and 'default'.

##### `bestpath_aspath_multipath_relax`
Enable/Disable load sharing across the providers with different (but equal-length) AS paths. Valid values are 'true', 'false', and 'default'

##### `bestpath_compare_routerid`
Enable/Disable comparison of router IDs for identical eBGP paths. Valid values are 'true', 'false', and 'default'

##### `bestpath_cost_community_ignore`
Enable/Disable Ignores the cost community for BGP best-path calculations. Valid values are 'true', 'false', and 'default'

##### `bestpath_med_confed`
Enable/Disable enforcement of bestpath to do a MED comparison only between paths originated within a confederation. Valid values are 'true', 'false', and 'default'.

##### `bestpath_med_missing_as_worst`
Enable/Disable assigns the value of infinity to received routes that do not carry the MED attribute, making these routes the least desirable. Valid values are 'true', 'false', and 'default'.

##### `bestpath_med_non_deterministic`
Enable/Disable deterministic selection of the best MED path from among the paths from the same autonomous system. Valid values are 'true', 'false', and 'default'.

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
Enable/Disable enforces the neighbor autonomous system to be the first AS number listed in the AS path attribute for eBGP. Valid values are 'true', 'false', and 'default'. On NX-OS, this property is only supported in the global BGP context.

##### `event_history_cli`
Enable/Disable/specify size of cli event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'. Size can also be specified in bytes.

##### `event_history_detail`
Enable/Disable/specify size of detail event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'. Size can also be specified in bytes.

##### `event_history_errors`
Enable/Disable/specify size of error history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'. Size can also be specified in bytes.

##### `event_history_events`
Enable/Disable/specify size of event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'. Size can also be specified in bytes.

##### `event_history_objstore`
Enable/Disable/specify size of objstore history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'. Size can also be specified in bytes.

##### `event_history_periodic`
Enable/Disable/specify size of periodic event history buffer. Valid values are 'true', 'false', 'size_small', 'size_medium', 'size_large', 'size_disable' and 'default'. Size can also be specified in bytes.

##### `fast_external_fallover`
Enable/Disable immediately reset the session if the link to a directly connected BGP peer goes down. Valid values are 'true', 'false', and 'default'. On NX-OS, this property is only supported in the global BGP context.

##### `flush_routes`
Enable/Disable flush routes in RIB upon controlled restart. Valid values are 'true', 'false', and 'default'. On NX-OS, this property is only supported in the global BGP context.

##### `graceful_restart`
Enable/Disable graceful restart. Valid values are 'true', 'false', and 'default'.

##### `graceful_restart_helper`
Enable/Disable graceful restart helper mode. Valid values are 'true', 'false', and 'default'.

##### `graceful_restart_timers_restart`
Set maximum time for a restart sent to the BGP peer. Valid values are Integer, keyword 'default'.

##### `graceful_restart_timers_stalepath_time`
Set maximum time that BGP keeps the stale routes from the restarting BGP peer. Valid values are Integer, keyword 'default'.

##### `isolate`
Enable/Disable isolate this router from BGP perspective. Valid values are 'true', 'false', and 'default'.

##### `log_neighbor_changes`
Enable/Disable message logging for neighbor up/down event. Valid values are 'true', 'false', and 'default'

##### `maxas_limit`
Specify Maximum number of AS numbers allowed in the AS-path attribute. Valid values are integers between 1 and 512, or keyword 'default' to disable this property.

##### `neighbor_down_fib_accelerate`
Enable/Disable handle BGP neighbor down event, due to various reasons. Valid values are 'true', 'false', and 'default'.

##### `nsr`
Enable/Disable Non-Stop Routing (NSR). Valid values are 'true', 'false', and 'default'. This property is not supported on Nexus.

##### `reconnect_interval`
The BGP reconnection interval for dropped sessions. Valid values are Integer or keyword 'default'.

<a name='bgp_rd'></a>
##### `route_distinguisher`
VPN Route Distinguisher (RD). The RD is combined with the IPv4 or IPv6 prefix learned by the PE router to create a globally unique address. Valid values are a String in one of the route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN); the keyword 'auto', or the keyword 'default'.

*Please note:* The `route_distinguisher` property is typically configured within the VRF context configuration on most platforms (including NXOS) but it is tightly coupled to bgp and therefore configured within the BGP configuration on some non-NXOS platforms. For this reason the `route_distinguisher` property has support (with limitations) in both `cisco_vrf` and `cisco_bgp` providers:

* `cisco_bgp`: The property is supported on NXOS and some non-NXOS platforms.
* `cisco_vrf`: The property is only supported on NXOS. See: [cisco_vrf: route_distinguisher](#vrf_rd)

*IMPORTANT: Choose only one provider to configure the `route_distinguisher` property on a given device. Using both providers simultaneously on the same device may have unpredictable results.*

##### `router_id`
Router Identifier (ID) of the BGP router VRF instance. Valid values are string, and keyword 'default'.

##### `shutdown`
Administratively shutdown the BGP protocol. Valid values are 'true', 'false', and 'default'.

##### `suppress_fib_pending`
Enable/Disable advertise only routes programmed in hardware to peers. Valid values are 'true', 'false', and 'default'.

##### `timer_bestpath_limit`
Specify timeout for the first best path after a restart, in seconds. Valid values are Integer, keyword 'default'.

##### `timer_bestpath_limit_always`
Enable/Disable update-delay-always option. Valid values are 'true', 'false', and 'default'.

##### `timer_bgp_hold`
Set bgp hold timer. Valid values are Integer, keyword 'default'.

##### `timer_bgp_keepalive`
Set bgp keepalive timer. Valid values are Integer, keyword 'default'.

--
### Type: cisco_bgp_af

Manages configuration of a BGP Address-family instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_bgp_af-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `additional_paths_install`  | Not supported on N3k, N9k-F, N9k                                                           |
| `advertise_l2vpn_evpn`      | Not supported on N3k, N6k                                                                  |
| address-family `l2vpn/evpn` | Module Minimum Version 1.3.2 <br> OS Minimum Version 7.0(3)I3(1) <br> Not supported on N3k |

#### Parameters

###### `ensure`
Determine whether the interface config should be present or not. Valid values
 are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in ASPLAIN or ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `afi`
Address Family Identifier (AFI). Required. Valid values are `ipv4`, `ipv6`, `vpnv4`, `vpnv6` and `l2vpn`.

##### `safi`
Sub Address Family Identifier (SAFI). Required. Valid values are `unicast`, `multicast` and `evpn`.

#### Properties

##### `additional_paths_install`
Install a backup path into the forwarding table and provide prefix 'independent convergence (PIC) in case of a PE-CE link failure. Valid values are true, false, or 'default'.

##### `additional_paths_receive`
Enables the receive capability of additional paths for all of the neighbors under this address family for which the capability has not been disabled.  Valid values are true, false, or 'default'

##### `additional_paths_selection`
Configures the capability of selecting additional paths for a prefix. Valid values are a string defining the name of the [route-map](#cisco-os-differences).

##### `additional_paths_send`
Enables the send capability of additional paths for all of the neighbors under this address family for which the capability has not been disabled. Valid values are true, false, or 'default'

##### `advertise_l2vpn_evpn`
Advertise evpn routes. Valid values are true and false.

##### `client_to_client`
Configure client-to-client route reflection. Valid values are true and false.

##### `dampen_igp_metric`
Specify dampen value for IGP metric-related changes, in seconds. Valid values are Integer, keyword 'default'.

##### `dampening_state`
Enable/disable route-flap dampening. Valid values are true, false or 'default'.

##### `dampening_half_time`
Specify decay half-life in minutes for route-flap dampening. Valid values are Integer, keyword 'default'.

##### `dampening_max_suppress_time`
Specify max suppress time for route-flap dampening stable route. Valid values are Integer, keyword 'default'.

##### `dampening_reuse_time`
Specify route reuse time for route-flap dampening. Valid values are Integer, keyword 'default'.

##### `dampening_routemap`
Specify [route-map](#cisco-os-differences) for route-flap dampening. Valid values are a string defining the name of the route-map.

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
Networks to configure. Valid value is a list of network prefixes to advertise.  The list must be in the form of an array.  Each entry in the array must include a prefix address and an optional [route-map](#cisco-os-differences).

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
Configure a [route-map](#cisco-os-differences) for valid nexthops. Valid values are a string defining the name of the route-map.

##### `redistribute`
A list of redistribute directives. Multiple redistribute entries are allowed. The list must be in the form of a nested array: the first entry of each array defines the source-protocol to redistribute from; the second entry defines a [route-map](#cisco-os-differences) name. A route-map is highly advised but may be optional on some platforms, in which case it may be omitted from the array list.

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
Advertises only active routes to peers. Valid values are true, false, or 'default'.

##### `table_map`
Apply table-map to filter routes downloaded into URIB. Valid values are a string.

##### `table_map_filter`
Filters routes rejected by the route-map and does not download them to the RIB. Valid values are true, false, or 'default'.

--
### Type: cisco_bgp_af_aa

Manages configuration of a BGP Address-family Aggregate-address instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(5)        | 1.7.0                  |
| N3k      | 7.0(3)I2(5)        | 1.7.0                  |
| N5k      | 7.3(0)N1(1)        | 1.7.0                  |
| N6k      | 7.3(0)N1(1)        | 1.7.0                  |
| N7k      | 7.3(0)D1(1)        | 1.7.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.7.0                  |

#### Parameters

###### `ensure`
Determine whether the BGP address family aggregate address should be present or not. Valid values
 are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in ASPLAIN or ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `afi`
Address Family Identifier (AFI). Required. Valid values are `ipv4`, `ipv6`, `vpnv4`, `vpnv6` and `l2vpn`.

##### `safi`
Sub Address Family Identifier (SAFI). Required. Valid values are `unicast`, `multicast` and `evpn`.

##### `aa`
Aggregate address mask in ipv4/ipv6 format. Required. Valid values are string. Examples: 1.1.1.1/32 or 2000:1/128.

#### Properties

##### `as_set`
Generates autonomous system set path information. Valid values are true, false or 'default'.

##### `advertise_map`
Name of the route map used to select the routes to create AS_SET origin communities. Valid values are string or 'default'.

##### `attribute_map`
Name of the route map used to set the attribute of the aggregate route. Valid values are string or 'default'.

##### `summary_only`
Filters all more-specific routes from updates.  Valid values are true, false or 'default'.

##### `suppress_map`
Name of the route map used to select the routes to be suppressed. Valid values are string or 'default'.

--
### Type: cisco_bgp_neighbor

Manages configuration of a BGP Neighbor.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_bgp_neighbor-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `log_neighbor_changes` | Not supported on N5k, N6k <br> Minimum puppet module version 1.7.0 for N7k <br> Supported in OS Version 8.1.1 and later on N7k |
| `bfd` | (ciscopuppet v1.4.0) BFD support added for all platforms |
| `bfd` on IPv6 | Not supported on N5k, N6k |

#### Parameters

###### `ensure`
Determine whether the neighbor config should be present or not. Valid values are 'present' and 'absent'.

##### `asn`
BGP autonomous system number. Required. Valid values are String, Integer in  ASPLAIN or ASDOT notation.

##### `vrf`
VRF name. Required. Valid values are string. The name 'default' is a valid VRF representing the global bgp.

##### `neighbor`
Neighbor Identifier. Required. Valid values are string. Neighbors may use IPv4 or IPv6 notation, with or without prefix length.

#### Properties

##### `description`
Description of the neighbor. Valid value is string.

##### `bfd`
Enable Bidirectional Forwarding Detection (BFD). Valid values are true, false and keyword 'default'.

##### `connected_check`
Configure whether or not to check for directly connected peer. Valid values are true and false.

##### `capability_negotiation`
Configure whether or not to negotiate capability with this neighbor. Valid values are true and false.

##### `dynamic_capability`
Configure whether or not to enable dynamic capability. Valid values are true and false.

##### `ebgp_multihop`
Specify multihop TTL for a remote peer. Valid values are integers between 2 and 255, or keyword 'default' to disable this property.

##### `local_as`
Specify the local-as number for the eBGP neighbor. Valid values are String or Integer in ASPLAIN or ASDOT notation, or 'default', which means not to configure it.

##### `log_neighbor_changes`
Specify whether or not to enable log messages for neighbor up/down event. Valid values are 'enable', to enable it, 'disable' to disable it, or 'inherit' to use the configuration in the cisco_bgp type.

##### `low_memory_exempt`
Specify whether or not to shut down this neighbor under memory pressure. Valid values are 'true' to exempt the neighbor from being shutdown, 'false' to shut it down, or 'default' to perform the default shutdown behavior.

##### `maximum_peers`
Specify Maximum number of peers for this neighbor prefix. Valid values are between 1 and 1000, or 'default', which does not impose the limit.

##### `password`
Specify the password for neighbor. Valid value is string.

##### `password_type`
Specify the encryption type the password will use. Valid values for Nexus are 'cleartext', '3des' or 'cisco_type_7' encryption, and 'default', which defaults to 'cleartext'.

##### `remote_as`
Specify Autonomous System Number of the neighbor. Valid values are String or Integer in ASPLAIN or ASDOT notation, or 'default', which means not to configure it.

##### `remove_private_as`
Specify the config to remove private AS number from outbound updates. Valid values are 'enable' to enable this config, 'disable' to disable this config, 'all' to remove all private AS number, or 'replace-as', to replace the private AS number.

##### `shutdown`
Configure to administratively shutdown this neighbor. Valid values are true and false.

##### `suppress_4_byte_as`
Configure to suppress 4-byte AS Capability. Valid values are 'true', 'false', and 'default', which sets to the default 'false' value.

##### `timers_keepalive`
Specify keepalive timer value. Valid values are integers between 0 and 3600 in terms of seconds, or 'default', which is 60.

##### `timers_holdtime`
Specify holdtime timer value. Valid values are integers between 0 and 3600 in terms of seconds, or 'default', which is 180.

##### `transport_passive_mode`
Specify whether BGP sessions can be established from incoming or outgoing TCP connection requests (or both).
Valid values for Nexus are 'passive_only', 'both', 'clear' and 'default', which defaults to 'clear'.  This property can only be configured when the neighbor is in 'ip' address format without prefix length. This property and the transport_passive_only property are mutually exclusive.

##### `transport_passive_only`
Specify whether or not to only allow passive connection setup. Valid values are 'true', 'false', and 'default', which defaults to 'false'. This property can only be configured when the neighbor is in 'ip' address format without prefix length. This property and the transport_passive_mode property are mutually exclusive.

##### `update_source`
Specify source interface of BGP session and updates. Valid value is a string of the interface name.

--
### Type: cisco_bgp_neighbor_af

Manages configuration of a BGP Neighbor Address-family instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_bgp_neighbor_af-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|

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
Neighbor Address Family Identifier (AFI). Required. Valid values are string. Valid neighbor AFIs are `ipv4`, `ipv6`, `vpnv4`, `vpnv6` and `l2vpn`. Note that some AFI/SAFI address-families may not be supported with some neighbors; e.g. an ipv6 neighbor may not support an ipv4 multicast address-family.

##### `safi`
Neighbor Sub Address Family Identifier (SAFI). Required. Valid values are string. Valid neighbor SAFIs are `unicast`, `multicast` and `evpn`. Note that some AFI/SAFI address-families may not be supported with some neighbors; e.g. an ipv6 neighbor may not support an ipv4 multicast address-family.

#### Properties

##### `additional_paths_receive`
`capability additional-paths receive`. Valid values are `enable` for basic command enablement; `disable` for disabling the command at the neighbor_af level (it adds the `disable` keyword to the basic command); and `inherit` to remove the command at this level (the command value is inherited from a higher BGP layer).

##### `additional_paths_send`
`capability additional-paths send`. Valid values are `enable` for basic command enablement; `disable` for disabling the command at the neighbor_af level (it adds the `disable` keyword to the basic command); and `inherit` to remove the command at this level (the command value is inherited from a higher BGP layer).

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

##### `default_originate`
`default-originate`. Valid values are True, False, or 'default'. Related: `default_originate_route_map`.

##### `default_originate_route_map`
Optional [route-map](#cisco-os-differences) for the `default_originate` property. Can be used independently or in conjunction with `default_originate`. Valid values are a string defining a route-map name, or 'default'.

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
Valid values are a string defining a [route-map](#cisco-os-differences) name, or 'default'.

##### `route_map_out`
Valid values are a string defining a [route-map](#cisco-os-differences) name, or 'default'.

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
### Type: cisco_bridge_domain
Manages a cisco Bridge-Domain

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `bd`
ID of the Bridge Domain. Valid values are integer.

##### `bd_name`
The bridge-domain name. Valid values are String or keyword 'default'.

##### `shutdown`
Specifies the shutdown state of the bridge-domain. Valid values are true, false, 'default'.

##### `fabric_control`
Specifies this bridge-domain as the fabric control bridge-domain. Only one bridge-domain or VLAN can be configured as fabric-control. Valid values are true, false.

--
### Type: cisco_bridge_domain_vni
Creates a Virtual Network Identifier member (VNI) mapping for cisco Bridge-Domain.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `bd`
The bridge-domain ID. Valid values are one or range of integers.

##### `member_vni`
The Virtual Network Identifier (VNI) id that is mapped to the VLAN. Valid values are one or range of integers

--
### Type: cisco_dhcp_relay_global

Manages configuration of a DHCP relay global configuration.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(2e)       | 1.4.0                  |
| N3k      | 7.0(3)I2(2e)       | 1.4.0                  |
| N5k      | 7.3(0)N1(1)        | 1.4.0                  |
| N6k      | 7.3(0)N1(1)        | 1.4.0                  |
| N7k      | 7.3(0)D1(1)        | 1.4.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_dhcp_relay_global-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `ipv4_information_option_trust`     | Not supported on N5k, N6k        |
| `ipv4_information_trust_all`        | Not supported on N5k, N6k        |
| `ipv4_src_addr_hsrp`                | Not supported on N3k, N9k, N9k-F |
| `ipv4_sub_option_circuit_id_custom` | Not supported on N7k, N9k-F(TBD) and supported on N3k and N9k running os version 7.0(3)I3.1 and later |
| `ipv4_sub_option_circuit_id_string` | Supported on N3k <br> Supported in OS Version 7.0(3)I6(1) and later on N9k |
| `ipv6_option_cisco`                 | Not supported on N5k, N6k      |

#### Parameters

##### `ipv4_information_option`
Enables inserting relay information in BOOTREQUEST. Valid values are true, false, 'default'.

##### `ipv4_information_option_trust`
Enables relay trust functionality on the system. Valid values are true, false, 'default'.

##### `ipv4_information_option_vpn`
Enables relay support across VRFs. Valid values are true, false, 'default'.

##### `ipv4_information_trust_all`
Enables relay trust on all the interfaces. Valid values are true, false, 'default'.

##### `ipv4_relay`
Enables DHCP relay agent. Valid values are true, false, 'default'.

##### `ipv4_smart_relay`
Enables DHCP smart relay. Valid values are true, false, 'default'.

##### `ipv4_src_addr_hsrp`
Enables Virtual IP instead of SVI address. Valid values are true, false, 'default'.

##### `ipv4_src_intf`
Source interface for the DHCPV4 relay. Valid values are string, keyword 'default'.

##### `ipv4_sub_option_circuit_id_custom`
Enables circuit id customized to include vlan id, slot and port info. Valid values are true, false, 'default'.

##### `ipv4_sub_option_circuit_id_string`
Specifies suboption format type string. Valid values are string, keyword 'default'.

##### `ipv4_sub_option_cisco`
Enables cisco propritery suboptions. Valid values are true, false, 'default'.

##### `ipv6_option_cisco`
Enables cisco propritery suboptions for DHCPV6. Valid values are true, false, 'default'.

##### `ipv6_option_vpn`
Enables DHCPv6 relay support across VRFs. Valid values are true, false, 'default'.

##### `ipv6_relay`
Enables DHCPv6 relay agent. Valid values are true, false, 'default'.

##### `ipv6_src_intf`
Source interface for the DHCPV6 relay. Valid values are string, keyword 'default'.

--
### Type: cisco_encapsulation
Manages a Global VNI Encapsulation profile

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `encap`
Profile name of the Encapsulation. Valid values are String only.

#### Properties

##### `dot1q_map`
The encapsulation profile dot1q vlan-to-vni mapping. Valid values are an array of [vlans, vnis] pairs.

--
### Type: cisco_evpn_vni

Manages Cisco Ethernet Virtual Private Network (EVPN) VXLAN Network Identifier (VNI) configurations of a Cisco device.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I3(1)        | 1.3.0                  |
| N3k      | not applicable     | not applicable         |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_evpn_vni-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `route_target_both` | Supported on most Nexus platforms but usage is *discouraged*. See `route_target_both` below. |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'. Default value is 'present'.

##### `vni`
The EVPN VXLAN Network Identifier. Valid values are Integer.

#### Properties

##### `route_distinguisher`

The VPN Route Distinguisher (RD). The RD is combined with the IPv4 or IPv6 prefix learned by the PE router to create a globally unique address. Valid values are a String in one of the route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN); the keyword 'auto', or the keyword 'default'.

##### `route_target_both`

Enables/Disables route-target settings for both import and export target communities using a single property. Valid values are an Array or space-separated String of extended communities, or the keywords 'auto' or 'default'."

*Caveat*: The `route_target_both` property is discouraged due to the inconsistent behavior of the property across Nexus platforms and image versions. The 'both' keyword has a transformative behavior on some platforms/versions in which it creates two cli configurations: one for import targets, a second for export targets, while the 'both' command itself may not appear at all. When the 'both' keyword does not appear in the configuration it causes an idempotency problem for puppet. For this reason it is recommended to use explicit 'route_target_export' and 'route_target_import' properties instead of `route_target_both`.

##### `route_target_import`

Sets the route-target 'import' extended communities. Valid values are an Array or space-separated String of extended communities, or the keywords 'auto' or 'default'.

route_target Examples:

route_target_import => ['1.2.3.4:5', '33:55']
route_target_export => '4:4 66:66'

##### `route_target_export`

Sets the route-target 'export' extended communities. Valid values are an Array or space-separated String of extended communities, or the keywords 'auto' or 'default'.

--
### Type: cisco_fabricpath_global
Manages Cisco fabricpath global parameters.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |

#### <a name="cisco_fabricpath_global-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `loadbalance_multicast_has_vlan` | Supported only on N7k |
| `loadbalance_multicast_rotate`   | Supported only on N7k |
| `ttl_multicast`                  | Supported only on N7k |
| `ttl_unicast`                    | Supported only on N7k |

#### Parameters

##### `name`
ID of the fabricpath global config. The only valid value is keyword 'default'.

##### `aggregate_multicast_routes`
Aggregate Multicast Routes on same tree in the topology. Valid values are true/false and keyword 'default'. Default value: false.

##### `allocate_delay`
Fabricpath Timers Allocate Delay in seconds. Valid values are integers from 1..1200 and keyword 'default'. Default value: 10.

##### `graceful_merge`
Graceful merge for conflicting switch-id or FTAG allocation. Valid values are enable/disable and keyword 'default'. Default value: true.

##### `linkup_delay`
Fabricpath Timers Link-up Delay in seconds. Valid values are integers from 1..1200 and keyword 'default'. Default value: 10.

##### `loadbalance_algorithm`
Fabricpath ECMP loadbalancing alogorithm. Valid values are 'destination', 'source', 'source-destination', 'symmetric' and the keyword 'default'. Default is symmetric for Nexus 7000 series and source-destination for others.

##### `loadbalance_multicast_has_vlan`
Multicast Loadbalance flow parameters - include vlan or not. Valid values are true or false and keyword 'default'. Default value: true.

##### `loadbalance_multicast_rotate`
Multicast Loadbalance flow parameters -  rotate amount in bytes. Valid values are integer in range 0..15 and keyword 'default'. Default value: 1.

##### `loadbalance_unicast_has_vlan`
Unicast Loadbalance flow parameters - include vlan or not. Valid values are true/false and keyword 'default'. Default value: 1.

##### `loadbalance_unicast_layer`
Unicast Loadbalance flow parameters - layer. Valid values are : layer2, layer3,
layer4, mixed, and keyword 'default'. Default value: mixed.

##### `loadbalance_unicast_rotate`
Unicast Loadbalance flow parameters - rotate amount in bytes. Valid values are Integers in range 0..15 and keyword 'default'. Default value: 1.

##### `linkup_delay_always`
Fabricpath Timers Link-up delay always. This configuration introduces a linkup delay always whether the link is administratively brought up or whether it is restored after events such as a module reload. Valid values are true/false. Default: true.

##### `linkup_delay_enable`
Fabricpath Timers Link-up delay enable. Valid values are true/false and keyword 'default'. Default value: true.

##### `mode`
Mode of operation of this switch w.r.t to segmentation. Valid values are normal/transit and keyword 'default'. Default: normal.

##### `switch_id`
The fabricpath switch_id. This parameter can be used to over-ride the automatically assigned switch-id for this switch. Valid values are integers from 1..4094.

##### `transition_delay`
Fabricpath Timers Transition Delay in seconds. Valid values are integers from 1..1200 and keyword 'default'. Default value: 10.

##### `ttl_multicast`
Fabricpath Multicast TTL value. Valid values are integers from 1..64 and keyword 'default'. Default value: 32.

##### `ttl_unicast`
Fabricpath Unicast TTL value. Valid values are integers from 1..64 and keyword 'default'. Default value: 32.

--
### Type: cisco_fabricpath_topology
Manages a Cisco fabricpath Topology

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `topo_id`
ID of the fabricpath topology. Valid values are integers in the range 1-63.
Value of 0 is reserved for default topology.

##### `member_vlans`
ID of the VLAN(s) tha are members of this topology. Valid values are integer/integer ranges.

##### `topo_name`
Descriptive name of the topology. Valid values are string

--
### Type: cisco_hsrp_global

Manages Cisco Hot Standby Router Protocol (HSRP) global parameters.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.5.0                  |
| N3k      | 7.0(3)I2(1)        | 1.5.0                  |
| N5k      | 7.3(0)N1(1)        | 1.5.0                  |
| N6k      | 7.3(0)N1(1)        | 1.5.0                  |
| N7k      | 7.3(0)D1(1)        | 1.5.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_hsrp_global-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `bfd_all_intf`                        | Not supported on N3k          |

#### Parameters

##### `bfd_all_intf`
Enables BFD for all HSRP sessions on all interfaces. Valid values are 'true', 'false', and
'default'.

##### `extended_hold`
Configures extended hold on global timers. Valid values are integer, keyword 'default'.

--
### Type: cisco_interface

Manages a Cisco Network Interface. Any resource dependency should be run before the interface resource.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_interface-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `ipv4_dhcp_relay_info_trust`          | Not supported on N5k,N6k        |
| `ipv4_dhcp_relay_src_addr_hsrp`       | Not supported on N3k,N9k-F,N9k  |
| `storm_control_broadcast`             | Not supported on N7k            |
| `storm_control_multicast`             | Not supported on N7k            |
| `pvlan_mapping`                       | Not supported on N9k-F          |
| `switchport_pvlan_host`               | Not supported on N9k-F          |
| `switchport_pvlan_host_association`   | Not supported on N9k-F          |
| `switchport_pvlan_mapping`            | Not supported on N9k-F          |
| `switchport_pvlan_mapping_trunk`      | Not supported on N3k,N9k-F      |
| `switchport_pvlan_promiscuous`        | Not supported on N9k-F          |
| `switchport_pvlan_trunk_allowed_vlan` | Not supported on N9k-F          |
| `switchport_pvlan_trunk_association`  | Not supported on N3k,N9k-F      |
| `switchport_pvlan_trunk_native_vlan`  | Not supported on N9k-F          |
| `switchport_pvlan_trunk_promiscuous`  | Not supported on N3k,N9k-F      |
| `switchport_pvlan_trunk_secondary`    | Not supported on N3k,N9k-F      |
| `svi_autostate`                       | Only supported on N3k,N7k,N9k   |
| `vlan_mapping`                        | Only supported on N7k           |
| `vlan_mapping_enable`                 | Only supported on N7k           |
| `hsrp_bfd`                            | Not supported on N5k,N6k <br> Minimum puppet module version 1.5.0 <br> Supported in OS Version 8.0 and later on N7k |
| `hsrp_delay_minimum`                  | Not supported on N5k,N6k <br> Minimum puppet module version 1.5.0 <br> Supported in OS Version 8.0 and later on N7k |
| `hsrp_delay_reload`                   | Not supported on N5k,N6k <br> Minimum puppet module version 1.5.0 <br> Supported in OS Version 8.0 and later on N7k |
| `hsrp_mac_refresh`                    | Not supported on N5k,N6k <br> Minimum puppet module version 1.5.0 <br> Supported in OS Version 8.0 and later on N7k |
| `hsrp_use_bia`                        | Not supported on N5k,N6k <br> Minimum puppet module version 1.5.0 <br> Supported in OS Version 8.0 and later on N7k |
| `hsrp_version`                        | Not supported on N5k,N6k <br> Minimum puppet module version 1.5.0 <br> Supported in OS Version 8.0 and later on N7k |
| `pim_bfd`                             | Minimum puppet module version 1.5.0 |
| `load_interval_counter_1_delay`       | Minimum puppet module version 1.6.0 |
| `load_interval_counter_2_delay`       | Minimum puppet module version 1.6.0 |
| `load_interval_counter_3_delay`       | Minimum puppet module version 1.6.0 |
| `purge_config`                        | Minimum puppet module version 1.7.0 |

#### Parameters

##### Basic interface config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values
are 'present' and 'absent'.

###### `interface`
Name of the interface on the network element. Valid value is a string.

#### Properties

###### `bfd_echo`
Enables bfd echo function for all address families. Valid values are 'true', 'false', and
'default'. This property is not applicable for loopback interfaces.

###### `description`
Description of the interface. Valid values are a string or the keyword 'default'.

###### `duplex`
Duplex of the interface. Valid values are 'full', and 'auto'.

###### `purge_config`
Puts the ethernet interface into default state. Valid value is 'true'. When this property is set to 'true', the manifest can have no other properties.

#### Example Usage

```puppet
cisco_interface { 'ethernet1/10':
    purge_config => true,
  }
```

###### `speed`
Speed of the interface. Valid values are 100, 1000, 10000, 40000, 1000000, and 'auto'.

###### `shutdown`
Shutdown state of the interface. Valid values are 'true', 'false', and
'default'.

###### `switchport_mode`
Switchport mode of the interface. Interfaces that support `switchport_mode` may default to layer 2 or layer 3 depending on platform, interface type, or the `system default switchport` setting. An interface may be explicitly set to Layer 3 by setting `switchport_mode` to 'disabled'. Valid values are 'disabled', 'access', 'tunnel', 'fex_fabric', 'trunk', 'fabricpath' and 'default'.

##### L2 interface config attributes

###### `access_vlan`
The VLAN ID assigned to the interface. Valid values are an integer or the keyword 'default'.

##### `encapsulation_dot1q`
Enable IEEE 802.1Q encapsulation of traffic on a specified subinterface.
Valid values are integer, keyword 'default'.

##### `mtu`
Maximum Trasnmission Unit size for frames received and sent on the specified
interface. Valid value is an integer.

##### `switchport_autostate_exclude`
Exclude this port for the SVI link calculation. Valid values are 'true', 'false', and 'default'.

##### `pvlan_mapping`
Maps secondary VLANs to the VLAN interface of a primary VLAN. Valid inputs are a String containing a range of secondary vlans or keyword 'default'.

Example: `pvlan_mapping => '3-4,6'`

##### `switchport_pvlan_host`
Configures a Layer 2 interface as a private VLAN host port. Valid values are 'true', 'false', and 'default'

##### `switchport_pvlan_host_association`
Associates the Layer 2 host port with the primary and secondary VLANs of a private VLAN. Valid inputs are: An array containing the primary and secondary vlans, or keyword 'default'.

Example: `switchport_pvlan_host_association => ['44', '144']`

##### `switchport_pvlan_mapping`
Associates the specified port with a primary VLAN and a selected list of secondary VLANs. Valid inputs are an array containing both the primary vlan and a range of secondary vlans, or keyword 'default'.

Example: `switchport_pvlan_mapping => ['44', '3-4,6']`

##### `switchport_pvlan_mapping_trunk`
Maps the promiscuous trunk port with the primary VLAN and a selected list of associated secondary VLANs. Valid inputs are: An array containing both the primary vlan and a range of secondary vlans, a nested array if there are multiple mappings, or keyword 'default'.

Examples:

```
 switchport_pvlan_mapping_trunk => [['44', '3-4,6'], ['99', '199']]

   -or-

 switchport_pvlan_mapping_trunk => ['44', '3-4,6']
```

##### `switchport_pvlan_trunk_allowed_vlan`
Sets the allowed VLANs for the private VLAN isolated trunk interface. Valid values are a String range of vlans or keyword 'default'.

Example: `switchport_pvlan_trunk_allowed_vlan => '3-4,6'`

##### `switchport_pvlan_trunk_association`
Associates the Layer 2 isolated trunk port with the primary and secondary VLANs of private VLANs. Valid inputs are: An array containing an association of primary and secondary vlans, a nested array if there are multiple associations, or the keyword 'default'.

Examples:

```
switchport_pvlan_trunk_association => [['44', '244'], ['45', '245']]

   -or-

switchport_pvlan_trunk_association => ['44', '244']
```

##### `switchport_pvlan_trunk_native_vlan`
Sets the native VLAN for the 802.1Q trunk. Valid values are Integer, String, or keyword 'default'.

##### `switchport_pvlan_promiscuous`
Configures a Layer 2 interface as a private VLAN promiscuous port. Valid values are 'true', 'false', and 'default'.

##### `switchport_pvlan_trunk_promiscuous`
Configures a Layer 2 interface as a private VLAN promiscuous trunk port. Valid values are 'true', 'false', and 'default'.

##### `switchport_pvlan_trunk_secondary`
Configures a Layer 2 interface as a private VLAN isolated trunk port. Valid values are 'true', 'false', and 'default'.

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

##### `storm_control_broadcast`
Allowed broadcast traffic level. Valid values are a string representing the broadcast level or keyword 'default'.

##### `storm_control_multicast`
Allowed multicast traffic level. Valid values are a string representing the multicast level or keyword 'default'.

##### `storm_control_unicast`
Allowed unicast traffic level. Valid values are a string representing the unicast level or keyword 'default'.

##### L3 interface config attributes

###### `ipv4_acl_in`
Applies an ipv4 access list on the interface in the ingress direction. An access-list should be present on the network device prior to this configuration. Valid values are string, keyword 'default'.

###### `ipv4_acl_out`
Applies an ipv4 access list on the interface in the egress direction. An access-list should be present on the network device prior to this configuration. Valid values are string, keyword 'default'.

###### `ipv4_pim_sparse_mode`
Enables or disables ipv4 pim sparse mode on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_proxy_arp`
Enables or disables proxy arp on the interface. Valid values are 'true', 'false', and 'default'.

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

###### `ipv4_forwarding`
IP forwarding state.  Valid values are string or keyword 'default'.

###### `ipv4_pim_sparse_mode`
Enables or disables ipv4 pim sparse mode on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_proxy_arp`
Enables or disables proxy arp on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_redirects`
Enables or disables sending of IP redirect messages. Valid values are 'true', 'false', and 'default'.

###### `ipv6_acl_in`
Applies an ipv6 access list on the interface in the ingress direction. An access-list should be present on the network device prior to this configuration. Valid values are string, keyword 'default'.

###### `ipv6_acl_out`
Applies an ipv6 access list on the interface in the egress direction. An access-list should be present on the network device prior to this configuration. Valid values are string, keyword 'default'.

###### `ipv4_dhcp_relay_addr`
This property is an array of dhcp relay addresses. Valid values are an array specifying the dhcp relay addresses or keyword 'default'; e.g.:

```
ipv4_dhcp_relay_addr => ['1.1.1.1', '2.2.2.2']
```
###### `ipv4_dhcp_relay_info_trust`
Enable/Disable relay trust on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_dhcp_relay_src_addr_hsrp`
Enable/Disable virtual IP instead of SVI address on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_dhcp_relay_src_intf`
Source interface for the DHCPV4 relay. Valid values are string, keyword 'default'.

###### `ipv4_dhcp_relay_info_trust`
Enable/Disable DHCP relay subnet-broadcast on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv4_dhcp_smart_relay`
Enable/Disable DHCP smart relay on the interface. Valid values are 'true', 'false', and 'default'.

###### `ipv6_dhcp_relay_addr`
This property is an array of ipv6 dhcp relay addresses. Valid values are an array specifying the ipv6 dhcp relay addresses or keyword 'default'; e.g.:

```
ipv6_dhcp_relay_addr => ['2000::11', '2001::22']
```
###### `ipv6_dhcp_relay_src_intf`
Source interface for the DHCPV6 relay. Valid values are string, keyword 'default'.

###### `pim_bfd`
Enables PIM BFD on the interface. Valid values are 'true', 'false', and 'default'.

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

##### STP config attributes

##### `stp_bpdufilter`
Enable/Disable BPDU (Bridge Protocol Data Unit) filter for this interface. Valid values are enable, disable or 'default'.

##### `stp_bpduguard`
Enable/Disable BPDU (Bridge Protocol Data Unit) guard for this interface. Valid values are enable, disable or 'default'.

##### `stp_cost`
Path cost. Valid values are integer, 'auto' or 'default'.

##### `stp_guard`
Guard mode. Valid values are loop, none, root or 'default'.

##### `stp_link_type`
Link type. Valid values are auto, shared, point-to-point or 'default'.

##### `stp_mst_cost`
Mst cost. Valid values are an array of [mst_range, cost] pairs or 'default'.

##### `stp_mst_port_priority`
Mst port priority. Valid values are an array of [mst_range, port_priority] pairs or 'default'.

##### `stp_port_priority`
Port priority. Valid values are integer or 'default'.

##### `stp_port_type`
Port type. Valid values are edge, network, normal, edge_trunk or 'default'.

##### `stp_vlan_cost`
Vlan path cost. Valid values are an array of [vlan_range, cost] pairs or 'default'.

##### `stp_vlan_port_priority`
Vlan port priority. Valid values are an array of [vlan_range, port_priority] pairs or 'default'.

##### SVI interface config attributes

###### `fabric_forwarding_anycast_gateway`
Associate SVI with anycast gateway under VLAN configuration mode. The `cisco_overlay_global` `anycast_gateway_mac` must be set before setting this property.
Valid values are 'true', 'false', and 'default'.

###### `svi_autostate`
Enable/Disable autostate on the SVI interface. Valid values are 'true',
'false', and 'default'.

###### `svi_management`
Enable/Disable management on the SVI interface. Valid values are 'true', 'false', and 'default'.

##### HSRP config attributes

##### `hsrp_bfd`
Enable HSRP BFD on this interface. Valid values are true, false or 'default'.

##### `hsrp_delay_minimum`
HSRP intialization minimim delay in seconds. Valid values are integer, keyword 'default'

##### `hsrp_delay_reload`
HSRP intialization delay after reload in seconds. Valid values are integer, keyword 'default'

##### `hsrp_mac_refresh`
HSRP mac refresh time in seconds. Valid values are integer, keyword 'default'

##### `hsrp_use_bia`
HSRP uses this interface's burned in address. Valid values are 'use_bia', 'use_bia_intf' or 'default'. 'use_bia' uses interface's burned in address. 'use_bia_intf' will increase the scope and applies this configuration to all groups on this interface.

##### `hsrp_version`
HSRP version for this interface. Valid values are integer, keyword 'default'.

##### load-interval config attributes

##### `load_interval_counter_1_delay`
Load interval delay for counter 1 in seconds. Valid values are integer, keyword 'default'

##### `load_interval_counter_2_delay`
Load interval delay for counter 2 in seconds. Valid values are integer, keyword 'default'

##### `load_interval_counter_3_delay`
Load interval delay for counter 3 in seconds. Valid values are integer, keyword 'default'

--
### Type: cisco_interface_channel_group

Manages a Cisco Network Interface Channel-group.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_interface_channel_group-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `channel_group_mode`          | Minimum puppet module version 1.7.0 |

#### Parameters

##### Basic interface channel-group config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values are 'present' and 'absent'.

###### `interface`
Name of the interface where the service resides. Valid value is a string.

###### `channel_group`
channel_group is an aggregation of multiple physical interfaces that creates a logical interface. Valid values are 1 to 4096 and 'default'.

Note: On some platforms a normal side-effect of adding the channel-group property is that an independent port-channel interface will be created; however, removing the channel-group configuration by itself will not also remove the port-channel interface. Therefore, the port-channel interface itself may be explicitly removed by using the `cisco_interface` provider with `ensure => absent`.

###### `channel_group_mode`
channel_group_mode is the port-channel mode of the interface. Valid values are 'active', 'passive', 'on', and 'default'.

###### `description`
Description of the interface. Valid values are a string or the keyword 'default'.

###### `shutdown`
Shutdown state of the interface. Valid values are 'true', 'false', and 'default'.

--
### Type: cisco_interface_hsrp_group

Manages a Cisco Network Interface HSRP group.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.5.0                  |
| N3k      | 7.0(3)I2(1)        | 1.5.0                  |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 8.0                | 1.5.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_interface_hsrp_group-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `all properties`              | Supported in OS Version 8.0 and later on N7k |

#### Parameters

##### Interface hsrp-group config attributes

###### `ensure`
Determine whether the interface hsrp group config should be present or not. Valid values are 'present' and 'absent'.

###### `authentication_auth_type`
Authentication type for the HSRP group. Valid values are 'cleartext', 'md5', keyword 'default'.

###### `authentication_compatibility`
Turn on compatibility mode for MD5 type-7 authentication. Valid values are 'true', 'false', keyword 'default'.

###### `authentication_enc_type`
Scheme used for encrypting authentication key string. Valid values are 'clear', 'encrypted', keyword 'default'.

###### `authentication_key_type`
Authentication key type. Valid values are 'key-chain', 'key-string', keyword 'default'.

###### `authentication_string`
Specifies password or key chain name or key string name. Valid values are string, keyword 'default'.

###### `authentication_timeout`
Specifies authentication timeout. Valid values are integer, keyword 'default'.

###### `ipv4_enable`
Enables HSRP ipv4. Valid values are 'true', 'false', keyword 'default'.

###### `ipv4_vip`
Sets HSRP IPv4 virtual IP addressing name. Valid values are string, keyword 'default'.

###### `ipv6_autoconfig`
Obtains ipv6 address using autoconfiguration. Valid values are 'true', 'false', keyword 'default'.

###### `ipv6_vip`
Enables HSRP IPv6 and sets an array of virtual IPv6 addresses. Valid values are array of ipv6 addresses, keyword 'default'.

###### `mac_addr`
Virtual mac address. Valid values are string specifying the mac address, keyword 'default'.

###### `group_name`
Redundancy name string. Valid values are string, keyword 'default'.

###### `preempt`
Overthrows lower priority Active routers. Valid values are 'true', 'false', keyword 'default'.

###### `preempt_delay_minimum`
Specifies amount of time to wait before pre-empting. Valid values are integer, keyword 'default'.

###### `preempt_delay_reload`
Specifies time to wait after reload. Valid values are integer, keyword 'default'.

###### `preempt_delay_sync`
Specifies time to wait for IP redundancy clients. Valid values are integer, keyword 'default'.

###### `priority`
Sets priority value for this interface hsrp group. Valid values are integer, keyword 'default'.

###### `priority_forward_thresh_lower`
Sets priority forwarding lower threshold value. Valid values are integer, keyword 'default'.

###### `priority_forward_thresh_upper`
Sets priority forwarding upper threshold value. Valid values are integer, keyword 'default'.

###### `timers_hello_msec`
Specify hello interval in milliseconds. Valid values are 'true', 'false', keyword 'default'.

###### `timers_hold_msec`
Specify hold interval in milliseconds. Valid values are 'true', 'false', keyword 'default'.

###### `timers_hello`
Sets hello interval. Valid values are integer, keyword 'default'.

###### `timers_hold`
Sets hold interval. Valid values are integer, keyword 'default'.

--
### Type: cisco_interface_service_vni

Manages a Cisco Network Interface Service VNI.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### Basic interface service vni config attributes

###### `ensure`
Determine whether the interface config should be present or not. Valid values are 'present' and 'absent'.

###### `interface`
Name of the interface where the service resides. Valid value is a string.

###### `sid`
The Service ID number. Valid value is an Integer.

#### Properties

###### `encapsulation_profile_vni`
The VNI Encapsulation Profile Name. Valid values are String or the keyword 'default'

###### `shutdown`
Shutdown state of the interface service vni. Valid values are 'true', 'false', or 'default'.

--
### Type: cisco_interface_ospf
Manages configuration of an OSPF interface instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are
'present' and 'absent'.

##### `interface`
Name of this cisco_interface resource. Valid value is a string.

##### `ospf`
Name of the cisco_ospf resource. Valid value is a string.

###### `bfd`
Enables bfd at interface level. This overrides the bfd variable set at the ospf router level. Valid values are 'true', 'false', or 'default'.

##### `cost`
The cost associated with this cisco_interface_ospf instance. Valid value is an integer or the keyword 'default'.

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
Valid values are 'true' and 'false' or the keyword 'default'.

##### `message_digest`
Enables or disables the usage of message digest authentication.
Valid values are 'true' and 'false' or the keyword 'default'.

##### `message_digest_key_id`
md5 authentication key-id associated with the cisco_interface_ospf instance.
If this is present in the manifest, message_digest_encryption_type,
message_digest_algorithm_type and message_digest_password are mandatory.
Valid value is an integer or the keyword 'default'.

##### `message_digest_algorithm_type`
Algorithm used for authentication among neighboring routers within an area.
Valid values are 'md5' and keyword 'default'.

##### `message_digest_encryption_type`
Specifies the scheme used for encrypting message_digest_password.
Valid values are 'cleartext', '3des' or 'cisco_type_7' encryption, and
'default', which defaults to 'cleartext'.

##### `message_digest_password`
Specifies the message_digest password. Valid value is a string or the keyword 'default'.

###### `mtu_ignore`
Disables OSPF MTU mismatch detection. Valid values are 'true', 'false', or 'default'.

##### `network_type`
Specifies the network type of this interface. Valid values are 'broadcast', 'p2p' or the keyword 'default'. 'broadcast' type is not applicable on loopback interfaces.

##### `priority`
The router priority associated with this cisco_interface_ospf instance. Valid values are an integer or the keyword 'default'.

###### `shutdown`
Shuts down ospf on this interface. Valid values are 'true', 'false', or 'default'.

##### `transmit_delay`
Packet transmission delay in seconds. Valid values are an integer or the keyword 'default'.

##### `area`
*Required*. Ospf area associated with this cisco_interface_ospf instance. Valid values are a string, formatted as an IP address (i.e. "0.0.0.0") or as an integer.

--
### Type: cisco_interface_portchannel

Manages configuration of a portchannel interface instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |

#### <a name="cisco_interface_portchannel-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `port_hash_distribution ` <br> `port_load_defer ` | Not supported on N5k, N6k |
| `lacp_suspend_individual` | **WARNING:** On N9k, the portchannel interface must be shutdown before the property can be set.  This provider automatically shuts the interface down if needed.<br> The interface is automatically restored to the original state after the property is set. |

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `bfd_per_link`
Enables BFD sessions on each port-channel link. Valid values are true, false or 'default'.

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
### Type: cisco_itd_device_group

Manages configuration of ITD (Intelligent Traffic Director) device group

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I3(1)        | 1.3.0                  |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `probe_control`
Enable control protocol for probe. Valid values are true, false or 'default'. This is applicable only when the probe type is 'tcp' or 'udp'

##### `probe_dns_host`
Host name or target address when the probe type is 'dns'. Valid values are String.

##### `probe_frequency`
Probe frequency in seconds. Valid values are Integer, keyword 'default'.

##### `probe_port`
Probe port number when the type is 'tcp' or 'udp'. Valid values are Integer.

##### `probe_retry_down`
Probe retry count when the node goes down. Valid values are Integer, keyword 'default'.

##### `probe_retry_up`
Probe retry count when the node comes back up. Valid values are Integer, keyword 'default'.

##### `probe_timeout`
Probe timeout in seconds. Valid values are Integer, keyword 'default'.

##### `probe_type`
Probe type. Valid values are 'icmp', 'dns', 'tcp', 'udp' or keyword 'default'.

--
### Type: cisco_itd_device_group_node

Manages configuration of ITD (Intelligent Traffic Director) device group node

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I3(1)        | 1.3.0                  |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `hot_standby`
Change mode of this node as hot-standby. Valid values are true, false or 'default'.

##### `node_type`
Type of the device group node. Valid values are ip and IPv6. It defaults to ip if not specified. IPv6 is not supported for N9k.

##### `probe_control`
Enable control protocol for probe. Valid values are true, false or 'default'. This is applicable only when the probe type is 'tcp' or 'udp'

##### `probe_dns_host`
Host name or target address when the probe type is 'dns'. Valid values are String.

##### `probe_frequency`
Probe frequency in seconds. Valid values are Integer, keyword 'default'.

##### `probe_port`
Probe port number when the type is 'tcp' or 'udp'. Valid values are Integer.

##### `probe_retry_down`
Probe retry count when the node goes down. Valid values are Integer, keyword 'default'.

##### `probe_retry_up`
Probe retry count when the node comes back up. Valid values are Integer, keyword 'default'.

##### `probe_timeout`
Probe timeout in seconds. Valid values are Integer, keyword 'default'.

##### `probe_type`
Probe type. Valid values are 'icmp', 'dns', 'tcp', 'udp' or keyword 'default'.

##### `weight`
Weight for traffic distribution. Valid values are Integer, keyword 'default'.

--
### Type: cisco_itd_service

Manages configuration of ITD (Intelligent Traffic Director) service.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I3(1)        | 1.3.0                  |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |

#### <a name="cisco_itd_service-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
|  | This provider requires the following commands to be applied as prerequisites using the [cisco_command_config](https://github.com/cisco/cisco-network-puppet-module/blob/master/README.md#type-cisco_command_config) provider.<br><br>&nbsp;&nbsp;cisco_command_config { 'prerequisites':<br>&nbsp;&nbsp;&nbsp;&nbsp;command => "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;feature pbr<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;feature sla sender<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;feature sla responder<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ip sla responder<br>&nbsp;&nbsp;&nbsp;&nbsp;"<br>&nbsp;&nbsp;}|
| `nat_destination` | Supported only on N7k |
| `peer_local`      | Supported only on N9k |
| `peer_vdc`        | Supported only on N7k |

#### Parameters

##### `ensure`
Determine whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `access_list`
ITD access-list name. Valid values are String or 'default'.

##### `device_group`
Device group name where this service belongs. Valid values are String or 'default'.

##### `exclude_access_list`
ITD exclude-access-list name. Valid values are String or 'default'.

##### `fail_action`
ITD failaction to reassign node. This enables traffic on failed nodes to be reassigned to the first available active node. Valid values are true, false or 'default'.

##### `ingress_interface`
Ingress interface. Valid values are an array of `[interface, next-hop]` pairs or 'default'.

##### `load_bal_enable`
Enable or disable load balance. Valid values are true, false or 'default'.

##### `load_bal_buckets`
Buckets for traffic distribution (in powers of 2). Valid values are Integer, or keyword 'default'.

##### `load_bal_mask_pos`
Loadbalance mask position. Valid values are Integer, keyword 'default'.

##### `load_bal_method_bundle_select`
Loadbalance bundle select. Valid values are 'src, 'dst' or keyword 'default'.

##### `load_bal_method_bundle_hash`
Loadbalance bundle hash. Valid values are 'ip, 'ip-l4port' or keyword 'default'.

##### `load_bal_method_proto`
Loadbalance protocol. This is valid only when the bundle hash is 'ip-l4port'. Valid values are 'tcp, 'udp' or keyword 'default'.

##### `load_bal_method_start_port`
Starting port in range (to match only packets in the range of port numbers). This is valid only when the bundle hash is 'ip-l4port'. Valid values are Integer, keyword 'default'.

##### `load_bal_method_end_port`
Ending port in range (to match only packets in the range of port numbers). This is valid only when the bundle hash is 'ip-l4port'. Valid values are Integer, keyword 'default'.

##### `nat_destination`
Destination NAT. Valid values are true, false or 'default'.

##### `peer_local`
Peer involved in sandwich mode. Valid values are String or 'default'.

##### `peer_vdc`
Peer involved in sandwich mode. Valid values are an array of `[vdc, service]` or 'default'.

##### `shutdown`
Whether or not the service is shutdown. Valid values are 'true', 'false' and
keyword 'default'.

##### `virtual_ip`
Virtual ip configuration. Valid values are an array of Strings or 'default'.

--
### Type: cisco_ospf

Manages configuration of an ospf instance.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `ensure`
Determine if the config should be present or not. Valid values are 'present',
and 'absent'.

##### `ospf`
Name of the ospf router. Valid value is a string.

--
### Type: cisco_ospf_area

Manages an area for an OSPF router.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.4.0                  |
| N3k      | 7.0(3)I2(1)        | 1.4.0                  |
| N5k      | 7.3(0)N1(1)        | 1.4.0                  |
| N6k      | 7.3(0)N1(1)        | 1.4.0                  |
| N7k      | 7.3(0)D1(1)        | 1.4.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Example Usage

```puppet
cisco_ospf_area { 'my_ospf_instance default 10':
  ensure          => 'present',
  range           => [['10.3.0.0/16', 'not_advertise', '23'],
                      ['10.3.3.0/24', '450']
                     ],
}

cisco_ospf_area { 'my_ospf_instance my_vrf 1.1.1.1':
  ensure          => 'present',
  authentication  => 'md5',
  default_cost    => 1000,
  filter_list_in  => 'fin',
  filter_list_out => 'fout',
  stub            => true,
}

cisco_ospf_area { 'my_ospf_instance my_vrf 1000':
  ensure                 => 'present',
  nssa                   => true,
  nssa_default_originate => true,
  nssa_no_redistribution => true,
  nssa_no_summary        => true,
  nssa_route_map         => 'rmap',
  nssa_translate_type7   => 'always',
}
```

#### Parameters

| Example Parameter Usage |
|:--|:--
|`cisco_ospf_area { '<ospf_process_id> <vrf> <area_id>':`
|`cisco_ospf_area { '1 my_vrf 10':`
|`cisco_ospf_area { 'my_ospf default 10.1.1.1':`

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `authentication`
Enables authentication for the area. Valid values are 'cleartext', 'md5' or 'default'.

##### `default_cost`
Default_cost for default summary Link-State Advertisement (LSA). Valid values are integer or keyword 'default'.

##### `filter_list_in`
This is a route-map for filtering networks sent to this area. Valid values are string or keyword 'default'.

##### `filter_list_out`
This is a route-map for filtering networks sent from this area. Valid values are string or keyword 'default'.

##### `nssa`
This property defines the area as NSSA (not so stubby area). Valid values are true, false or keyword 'default'. This property is mutually exclusive with `stub` and `stub_no_summary`.

##### `nssa_default_originate`
Generates an NSSA External (type 7) LSA for use as a default route to the external autonomous system. Valid values are true, false or keyword 'default'.

##### `nssa_no_redistribution`
Disable redistribution within the NSSA. Valid values are true, false or keyword 'default'.

##### `nssa_no_summary`
Disables summary LSA flooding within the NSSA. Valid values are true, false or keyword 'default'.

##### `nssa_route_map`
Controls distribution of the default route. This property can only be used when the `nssa_default_originate` property is set to true. Valid values are String (the route-map name) or keyword 'default'.

##### `nssa_translate_type7`
Translates NSSA external (type 7) LSAs to standard external (type 5) LSAs for use outside the NSSA. Valid values are one of the following keyword strings:

Keyword | Description
|:--|:--
|`always`             | Always translate
|`suppress_fa`        | Forwarding Address Suppression
|`always_suppress_fa` | Always translate & use Forwarding Address Suppression
|`never`              | Never translate
|`default`            | Translation is not configured

##### `range`
Summarizes routes at an area boundary. Optionally sets the area range status to DoNotAdvertise as well as setting per-summary cost values. Valid values are a nested array of [summary_address, 'not_advertise', cost], or keyword 'default'. The summary-address is mandatory.

Example: `range => [['10.3.0.0/16', 'not_advertise', '23'],
                    ['10.3.0.0/32', 'not_advertise'],
                    ['10.3.0.1/32'],
                    ['10.3.3.0/24', '450']]`

##### `stub`
Defines the area as a stub area. Valid values are true, false or keyword 'default'. This property is not necessary when the `stub_no_summary` property is set to true, which also defines the area as a stub area. This property is mutually exclusive with `nssa`.


##### `stub_no_summary`
Stub areas flood summary LSAs. This property disables summary flooding into the area. This property can be used in place of the `stub` property or in conjunction with it. Valid values are true, false or keyword 'default'. This property is mutually exclusive with `nssa`.

--
### Type: cisco_ospf_area_vlink

Manages an area virtual link for an OSPF router.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.4.0                  |
| N3k      | 7.0(3)I2(1)        | 1.4.0                  |
| N5k      | 7.3(0)N1(1)        | 1.4.0                  |
| N6k      | 7.3(0)N1(1)        | 1.4.0                  |
| N7k      | 7.3(0)D1(1)        | 1.4.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Example Usage

```puppet
cisco_ospf_area_vlink { 'my_ospf_instance default 10 1.1.1.1':
  ensure                             => 'present',
  auth_key_chain                     => 'keyChain',
  authentication                     => 'md5',
  authentication_key_encryption_type => cisco_type_7,
  authentication_key_password        => '98765432109876543210',
  dead_interval                      => 500,
  hello_interval                     => 2000,
  message_digest_algorithm_type      => 'md5',
  message_digest_encryption_type     => cisco_type_7,
  message_digest_key_id              => 123,
  message_digest_password            => '12345678901234567890',
  retransmit_interval                => 777,
  transmit_delay                     => 333,
}
```

#### Parameters

| Example Parameter Usage |
|:--|:--
|`cisco_ospf_area_vlink { '<ospf_process_id> <vrf> <area_id> <vlink_id>':`
|`cisco_ospf_area_vlink { '1 my_vrf 10 1.1.1.1':`
|`cisco_ospf_area_vlink { 'my_ospf default 10.1.1.1 2.2.2.2':`

##### `ensure`
Determines whether the config should be present or not on the device. Valid values are 'present' and 'absent'.

##### `auth_key_chain`
Authentication password key chain name. Valid values are string, or 'default'.

##### `authentication`
Enables authentication for the virtual link. Valid values are 'cleartext', 'md5', 'null', or 'default'.

##### `authentication_key_encryption_type`
Specifies the scheme used for encrypting authentication_key_password. Valid values are 'cleartext', '3des' or 'cisco_type_7' encryption, and 'default', which defaults to 'cleartext'.

##### `authentication_key_password`
Specifies the authentication_key password. Valid value is a string, or 'default'.

##### `dead_interval`
Time in seconds that a neighbor waits for a Hello packet before declaring the local router as dead and tearing down adjacencies. Valid values are integer, keyword 'default'.

##### `hello_interval`
Time in seconds between successive Hello packets. Valid values are integer, keyword 'default'.

##### `message_digest_algorithm_type`
Algorithm used for authentication among neighboring routers within an area virtual link. Valid values are 'md5' and keyword 'default'.

##### `message_digest_encryption_type`
Specifies the scheme used for encrypting message_digest_password. Valid values are 'cleartext', '3des' or 'cisco_type_7' encryption, and 'default', which defaults to 'cleartext'.

##### `message_digest_key_id`
md5 authentication key id. Valid values are integer.

##### `message_digest_password`
Specifies the message_digest password. Valid value is a string.

##### `retransmit_interval`
Estimated time in seconds between successive LSAs. Valid values are integer, keyword 'default'.

##### `transmit_delay`
Estimated time in seconds to transmit an LSA to a neighbor. Valid values are integer, keyword 'default'.

--
### Type: cisco_ospf_vrf

Manages a VRF for an OSPF router.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

##### `bfd`
Enables bfd on all the OSPF interfaces on this router. The individual interfaces can override this. Valid values are true, false or keyword 'default'

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I6(1)        | 1.7.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_overlay_global-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `anycast_gateway_mac `                   | Not supported on N3k        |
| `dup_host_ip_addr_detection_host_moves`  | Not supported on N3k        |
| `dup_host_ip_addr_detection_timeout`     | Not supported on N3k        |
| `dup_host_mac_detection_host_moves`      | Supported in OS Version 7.0(3)I6(1) and later on N3k |
| `dup_host_mac_detection_timeout`         | Supported in OS Version 7.0(3)I6(1) and later on N3k |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_pim-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `bfd`    | Minimum puppet module version 1.5.0 |

#### Parameters

##### `afi`
Address Family Identifier (AFI). Required. Valid value is ipv4.

##### `vrf`
Name of the resource instance. Required. Valid values are string. The name 'default' is a valid VRF representing the global vrf.

#### Properties

##### `bfd`
Enables BFD for all PIM interfaces in the current VRF. Valid values are true, false or 'default'.

##### `ssm_range`
Configure group ranges for Source Specific Multicast (SSM). Valid values are multicast addresses or the keyword ‘none’.

--
### Type: cisco_pim_grouplist
Manages configuration of an Protocol Independent Multicast (PIM) static route processor (RP) address for a multicast group range.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.3.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_portchannel_global-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `asymmetric` <br> `hash_distribution` <br> `load_defer`                  | Supported only on N7k |
| `bundle_hash` values: `port`, `ip-only`, `port-only`                     | Only supported on N3k, N5k, N6k |
| `bundle_hash` values: `ip-gre`                                           | Only supported on N3k, N9k |
| `bundle_hash` values: `ip-l4port`, `ip-l4port-vlan`, `ip-vlan`, `l4port` | Only supported on N7k, N9k |
| `concatenation`             | Supported only on N9k             |
| `hash_poly`                 | Supported only on N5k, N6k        |
| `resilient` <br> `symmetry` | Supported only on N3k, N9k        |
| `rotate`                    | Supported only on N7k, N9k-F, N9k |

#### Parameters

##### `asymmetric`
port-channel asymmetric hash. Valid values are true, false or 'default'.

##### `bundle_hash`
port-channel bundle hash. Valid values are 'ip', 'ip-l4port', 'ip-l4port-vlan', 'ip-vlan', 'l4port', 'mac', 'port', 'ip-only', 'port-only', 'ip-gre' or 'default'.

##### `bundle_select`
port-channel bundle select. Valid values are 'src', 'dst', 'src-dst' or 'default'.

##### `concatenation`
port-channel concatenation enable or disable. Valid values are true, false or 'default'.

##### `hash_distribution`
port-channel hash-distribution. Valid values are 'adaptive', 'fixed' or the keyword 'default'.

##### `hash_poly`
port-channel hash-polynomial. Valid values are 'CRC10a', 'CRC10b', 'CRC10c' or 'CRC10d'. Note: This property does not support the keyword 'default'.

##### `load_defer`
port-channel load-defer time interval. Valid values are integer or 'default'.

##### `resilient`
port-channel resilient mode. Valid values are true, false or 'default'.

##### `rotate`
port-channel hash input offset. Valid values are integer or 'default'.

##### `symmetry`
port-channel symmetry hash. Valid values are true, false or 'default'.

--
### Type: cisco_route_map

Manages a Cisco Route Map.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.6.0                  |
| N3k      | 7.0(3)I2(1)        | 1.6.0                  |
| N5k      | 7.3(0)N1(1)        | 1.6.0                  |
| N6k      | 7.3(0)N1(1)        | 1.6.0                  |
| N7k      | 7.3(0)D1(1)        | 1.6.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.6.0                  |

#### <a name="cisco_route_map-caveats">Caveats</a>

| Property | Caveat Description |
|:---------|:-------------|
| `match_evpn_route_type_1`                | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_2_all`            | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_2_mac_ip`         | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_2_mac_only`       | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_3`                | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_4`                | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_5`                | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_6`                | Not supported on N3k,N9k-F,N9k  |
| `match_evpn_route_type_all`              | Not supported on N3k,N9k-F,N9k  |
| `match_length`                           | Not supported on N3k,N9k-F,N9k  |
| `match_mac_list`                         | Not supported on N3k,N9k-F,N9k  |
| `match_metric`                           | Supported in OS Version 7.0(3)F2(1) and later on N9k-F |
| `match_ospf_area`                        | Not supported on N5k,N6k,N7k,N9k-F <br> Supported in OS version 7.0(3)I5.1 and later on N3k, N9k  |
| `match_vlan`                             | Not supported on N3k,N9k-F,N9k  |
| `set_extcommunity_4bytes_additive`       | Supported in OS Version 7.0(3)F2(1) and later on N9k-F |
| `set_extcommunity_4bytes_non_transitive` | Supported in OS Version 7.0(3)F2(1) and later on N9k-F |
| `set_extcommunity_4bytes_transitive`     | Supported in OS Version 7.0(3)F2(1) and later on N9k-F |
| `set_extcommunity_cost_igp`              | Not supported on N9k-F          |
| `set_extcommunity_cost_pre_bestpath`     | Not supported on N9k-F          |
| `set_extcommunity_rt_additive`           | Not supported on N9k-F          |
| `set_extcommunity_rt_asn`                | Not supported on N9k-F,N9k      |
| `set_forwarding_addr`                    | Not supported on N9k-F          |
| `set_ipv4_default_next_hop`              | Not supported on N5k,N6k,N9k-F,N9k  |
| `set_ipv4_default_next_hop_load_share`   | Not supported on N5k,N6k,N9k-F,N9k  |
| `set_ipv4_next_hop`                      | Not supported on N9k-F          |
| `set_ipv4_next_hop_load_share`           | Not supported on N5k,N6k <br> Supported in OS Version 7.0(3)I5.1 and later on N9k <br> Supported in OS Version 7.0(3)F2(1) and later on N9k-F |
| `set_ipv4_next_hop_redist`               | Supported on N5k,N6k,N7k,N9k-F <br> Supported in OS Version 7.0(3)I5.1 and later on N3k,N9k  |
| `set_ipv4_precedence`                    | Not supported on N9k-F          |
| `set_ipv4_prefix`                        | Not supported on N5k,N6k,N9k-F  |
| `set_ipv6_default_next_hop`              | Not supported on N5k,N6k,N9k-F,N9k  |
| `set_ipv6_default_next_hop_load_share`   | Not supported on N5k,N6k,N9k-F,N9k  |
| `set_ipv6_next_hop`                      | Not supported on N9k-F          |
| `set_ipv6_next_hop_load_share`           | Not supported on N5k,N6k <br> Supported in OS Version 7.0(3)I5.1 and later on N9k <br> Supported in OS Version 7.0(3)F2(1) and later on N9k-F |
| `set_ipv6_next_hop_redist`               | Supported on N5k,N6k,N7k,N9k-F <br> Supported in OS Version 7.0(3)I5.1 and later on N3k,N9k  |
| `set_ipv6_prefix`                        | Not supported on N5k,N6k,N9k-F  |
| `set_vrf`                                | Supported on N7k                |


| Example Parameter Usage |
|:--
|`match_as_number { '<AA4>,  <AA4>-<AA4>, ..':`
|`match_as_number { '['3', '22-34', '38', '101-110', '120']':`

##### Basic interface config attributes

###### `ensure`
Determine whether the route map config should be present or not. Valid values
are 'present' and 'absent'.


##### `description`
Description of the route-map. Valid values are string, or keyword 'default'

##### `match_as_number`
Match BGP peer AS number. Valid values are an array of ranges or keyword 'default'


##### `match_as_number_as_path_list`
Match BGP AS path list. Valid values are an array of list names or keyword 'default'

##### `match_community`
Match BGP community list. Valid values are an array of communities or keyword 'default'

##### `match_community_exact_match`
Enable exact matching of communities. Valid values 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_1`
Enable match BGP EVPN route type-1. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_2_all`
Enable match all BGP EVPN route in type-2. Valid values are 'true', false or keyword 'default'

##### `match_evpn_route_type_2_mac_ip`
Enable match mac-ip BGP EVPN route in type-2. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_2_mac_only`
Enable match mac-only BGP EVPN route in type-2. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_3`
Enable match BGP EVPN route type-3. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_4`
Enable match BGP EVPN route type-4. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_5`
Enable match BGP EVPN route type-5. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_6`
Enable match BGP EVPN route type-6. Valid values are 'true', 'false' or keyword 'default'

##### `match_evpn_route_type_all`
Enable match BGP EVPN route type 1-6. Valid values are 'true', 'false' or keyword 'default'

##### `match_ext_community`
Match BGP extended community list. Valid values are an array of extended communities or keyword 'default'

##### `match_ext_community_exact_match`
Enable exact matching of extended communities. Valid values are 'true', 'false' or keyword 'default'

##### `match_interface`
Match first hop interface of route. Valid values are array of interfaces or keyword 'default'

##### `match_ipv4_addr_access_list`
Match IPv4 access-list name. Valid values are String or keyword 'default'

##### `match_ipv4_addr_prefix_list`
Match entries of prefix-lists for IPv4. Valid values are array of prefixes or keyword 'default'

##### `match_ipv4_multicast_enable`
Enable match IPv4 multicast. This property should be set to 'true' before setting any IPv4 multicast properties. Valid values are are 'true', 'false' or keyword 'default'

##### `match_ipv4_multicast_group_addr`
Match IPv4 multicast group prefix. Valid values are string, or keyword 'default'

##### `match_ipv4_multicast_group_range_begin_addr`
Match IPv4 multicast group address begin range. Valid values are string, or keyword 'default'

##### `match_ipv4_multicast_group_range_end_addr`
Match IPv4 multicast group address end range. Valid values are string, or keyword 'default'

##### `match_ipv4_multicast_rp_addr`
Match IPv4 multicast rendezvous prefix. Valid values are string, or keyword 'default'

##### `match_ipv4_multicast_rp_type`
Match IPv4 multicast rendezvous point type. Valid values are 'ASM', 'Bidir' or keyword 'default'

##### `match_ipv4_multicast_src_addr`
Match IPv4 multicast source prefix. Valid values are string or keyword 'default'

##### `match_ipv4_next_hop_prefix_list`
Match entries of prefix-lists for next-hop address of route for IPv4. Valid values are an array of prefixes or keyword 'default'

##### `match_ipv4_route_src_prefix_list`
Match entries of prefix-lists for advertising source address of route for IPv4. Valid values are an array of prefixes or keyword 'default'

##### `match_ipv6_addr_access_list`
Match IPv6 access-list name. Valid values are string or keyword 'default'

##### `match_ipv6_addr_prefix_list`
Match entries of prefix-lists for IPv6. Valid values are array of prefixes or keyword 'default'

##### `match_ipv6_multicast_enable`
Enable match IPv6 multicast. This property should be set to 'true' before setting any IPv6 multicast properties. Valid values are 'true', 'false' or keyword 'default'

##### `match_ipv6_multicast_group_addr`
Match IPv6 multicast group prefix. Valid values are string, or keyword 'default'

##### `match_ipv6_multicast_group_range_begin_addr`
Match IPv6 multicast group address begin range. Valid values are string, or keyword 'default'

##### `match_ipv6_multicast_group_range_end_addr`
Match IPv6 multicast group address end range. Valid values are string, or keyword 'default'

##### `match_ipv6_multicast_rp_addr`
Match IPv6 multicast rendezvous prefix. Valid values are string, or keyword 'default'

##### `match_ipv6_multicast_rp_type`
Match IPv6 multicast rendezvous point type. Valid values are 'ASM', 'Bidir' or keyword 'default'

##### `match_ipv6_multicast_src_addr`
Match IPv6 multicast source prefix. Valid values are string or keyword 'default'

##### `match_ipv6_next_hop_prefix_list`
Match entries of prefix-lists for next-hop address of route for IPv6. Valid values are array of prefixes or keyword 'default'

##### `match_ipv6_route_src_prefix_list`
Match entries of prefix-lists for advertising source address of route for IPv6. Valid values are array of prefixes or keyword 'default'

##### `match_length`
Match packet length. Valid values are array of minimum and maximum lengths or keyword 'default'

##### `match_mac_list`
Match entries of mac-lists. Valid values are array of mac list names or keyword 'default'

##### `match_metric`
Match metric of route. Valid values are array of [metric, deviation] pairs or keyword 'default'

##### `match_ospf_area`
Match entries of ospf area IDs. Valid values are array of ids or keyword 'default'

##### `match_route_type_external`
Enable match external route type (BGP, EIGRP and OSPF type 1/2). Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_inter_area`
Enable match OSPF inter area type. Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_internal`
Enable match OSPF inter area type (OSPF intra/inter area). Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_intra_area`
Enable match OSPF intra area route. Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_level_1`
Enable match IS-IS level-1 route. Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_level_2`
Enable match IS-IS level-2 route. Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_local`
Enable match locally generated route. Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_nssa_external`
Enable match nssa-external route (OSPF type 1/2). Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_type_1`
Enable match OSPF external type 1 route. Valid values are 'true', 'false' or keyword 'default'

##### `match_route_type_type_2`
Enable match OSPF external type 2 route. Valid values are 'true', 'false' or keyword 'default'

##### `match_src_proto`
Match source protocol. Valid values are array of protocols or keyword 'default'

##### `match_tag`
Match tag of route. Valid values are array of tags or keyword 'default'

##### `match_vlan`
Match VLAN Id. Valid values are array of string of VLAN ranges or keyword 'default'

##### `set_as_path_prepend`
Prepend string for a BGP AS-path attribute. Valid values are array of AS numbers or keyword 'default'

##### `set_as_path_prepend_last_as`
Number of last-AS prepends. Valid values are integer or keyword 'default'

##### `set_as_path_tag`
Set the tag as an AS-path attribute. Valid values are 'true', 'false' or keyword 'default'

##### `set_comm_list`
Set BGP community list (for deletion). Valid values are String or keyword 'default'

##### `set_community_additive`
Add to existing BGP community. Valid values are 'true', 'false' or keyword 'default'

##### `set_community_asn`
Set community number. Valid values are array of AS numbers or keyword 'default'

##### `set_community_internet`
Set Internet community. Valid values are 'true', 'false' or keyword 'default'

##### `set_community_local_as`
Do not send outside local AS. Valid values are 'true', 'false' or keyword 'default'

##### `set_community_no_advtertise`
Do not advertise to any peer. Valid values are 'true', 'false' or keyword 'default'

##### `set_community_no_export`
Do not export to next AS. Valid values are 'true', 'false' or keyword 'default'

##### `set_community_none`
Set no community attribute. Valid values are 'true', 'false' or keyword 'default'

##### `set_dampening_half_life`
Set half-life time for the penalty of BGP route flap dampening. Valid values are integer or keyword 'default'

##### `set_dampening_max_duation`
Set maximum duration to suppress a stable route of BGP route flap dampening. Valid values are integer or keyword 'default'

##### `set_dampening_reuse`
Set penalty to start reusing a route of BGP route flap dampening. Valid values are integer or keyword 'default'

##### `set_dampening_suppress`
Set penalty to start suppressing a route of BGP route flap dampening. Valid values are integer or keyword 'default'

##### `set_distance_igp_ebgp`
Set administrative distance for IGP or EBGP routes. Valid values are integer or keyword 'default'

##### `set_distance_internal`
Set administrative distance for internal routes. Valid values are integer or keyword 'default'

##### `set_distance_local`
Set administrative distance for local routes. Valid values are integer or keyword 'default'

##### `set_extcomm_list`
Set BGP extended community list (for deletion). Valid values are string or keyword 'default'

##### `set_extcommunity_4bytes_additive`
Add to existing generic extcommunity. Valid values are 'true', 'false' or keyword 'default'

##### `set_extcommunity_4bytes_non_transitive`
Set non-transitive extended community. Valid values are array of communities, or keyword 'default'

##### `set_extcommunity_4bytes_none`
Set no extcommunity generic attribute. Valid values are 'true', 'false' or keyword 'default'

##### `set_extcommunity_4bytes_transitive`
Set transitive extended community. Valid values are array of communities, or keyword 'default'

##### `set_extcommunity_cost_igp`
Compare following IGP cost comparison. Valid values are array of [communityId, cost] pairs or keyword 'default'

##### `set_extcommunity_cost_pre_bestpath`
Compare before all other steps in bestpath calculation. Valid values are array of [communityId, cost] pairs or keyword 'default'

##### `set_extcommunity_rt_additive`
Set add to existing route target extcommunity. Valid values are 'true', 'false' or keyword 'default'

##### `set_extcommunity_rt_asn`
Set community number. Valid values are array of AS numbers or keyword 'default'

##### `set_forwarding_addr`
Set the forwarding address. Valid values are 'true', 'false' or keyword 'default'

##### `set_interface`
Set output interface. Valid values are 'Null0' or keyword 'default'

##### `set_ipv4_default_next_hop`
Set default next-hop IPv4 address. Valid values are array of next hops or keyword 'default'

##### `set_ipv4_default_next_hop_load_share`
Enable default IPv4 next-hop load-sharing. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv4_next_hop`
Set next-hop IPv4 address. Valid values are array of next hops or keyword 'default'

##### `set_ipv4_next_hop_load_share`
Enable IPv4 next-hop load-sharing. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv4_next_hop_peer_addr`
Enable IPv4 next-hop peer address. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv4_next_hop_redist`
Enable IPv4 next-hop unchanged address during redistribution. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv4_next_hop_unchanged`
Enable IPv4 next-hop unchanged address. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv4_precedence`
Set IPv4 precedence field. Valid values are 'critical', 'flash', 'flash-override', 'immediate', 'internet', 'network', 'priority', 'routine' or keyword 'default'

##### `set_ipv4_prefix`
Set IPv4 prefix-list. Valid values are string or keyword 'default'

##### `set_ipv6_default_next_hop`
Set default next-hop IPv6 address. Valid values are array of next hops or keyword 'default'

##### `set_ipv6_default_next_hop_load_share`
Enable default IPv6 next-hop load-sharing. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv6_next_hop`
Set next-hop IPv6 address. Valid values are array of next hops or keyword 'default'

##### `set_ipv6_next_hop_load_share`
Enable IPv6 next-hop load-sharing. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv6_next_hop_peer_addr`
Enable IPv6 next-hop peer address. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv6_next_hop_redist`
Enable IPv6 next-hop unchanged address during redistribution. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv6_next_hop_unchanged`
Enable IPv6 next-hop unchanged address. Valid values are 'true', 'false' or keyword 'default'

##### `set_ipv6_precedence`
Set IPv6 precedence field. Valid values are 'critical', 'flash', 'flash-override', 'immediate', 'internet', 'network', 'priority', 'routine' or keyword 'default'

##### `set_ipv6_prefix`
Set IPv6 prefix-list. Valid values are string or keyword 'default'

##### `set_level`
Set where to import route. Valid values are 'level-1', 'level-1-2', 'level-2' or keyword 'default'

##### `set_local_preference`
Set BGP local preference path attribute. Valid values are integer or keyword 'default'

##### `set_metric_additive`
Set add to metric. Valid values are 'true', 'false' or keyword 'default'

##### `set_metric_bandwidth`
Set metric value or Bandwidth in kbps. Valid values are integer or keyword 'default'

##### `set_metric_delay`
Set IGRP delay metric. Valid values are integer or keyword 'default'

##### `set_metric_effective_bandwidth`
Set IGRP Effective bandwidth metric. Valid values are integer or keyword 'default'

##### `set_metric_mtu`
Set IGRP MTU of the path. Valid values are integer or keyword 'default'

##### `set_metric_reliability`
Set IGRP reliability metric. Valid values are integer or keyword 'default'

##### `set_metric_type`
Set type of metric for destination routing protocol. Valid values are 'external, 'internal', 'type-1, 'type-2, or keyword 'default'

##### `set_nssa_only`
Set OSPF NSSA Areas. Valid values are 'true, 'false' or keyword 'default'

##### `set_origin`
Set BGP origin code. Valid values are 'egp, 'igp', 'incomplete', or keyword 'default'

##### `set_path_selection`
Set path selection criteria for BGP. Valid values are 'true, 'false' or keyword 'default'

##### `set_tag`
Set tag value for destination routing protocol. Valid values are integer or keyword 'default'

##### `set_vrf`
Set the VRF for next-hop resolution. Valid values are string or keyword 'default'

##### `set_weight`
Set BGP weight for routing table. Valid values are integer or keyword 'default'

--
### Type: cisco_stp_global
Manages spanning tree global parameters

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.3.0                  |
| N3k      | 7.0(3)I2(1)        | 1.3.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |

#### <a name="cisco_stp_global-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `bd_designated_priority` | Supported only on N7k |
| `bd_forward_time`        | Supported only on N7k |
| `bd_hello_time`          | Supported only on N7k |
| `bd_max_age`             | Supported only on N7k |
| `bd_priority`            | Supported only on N7k |
| `bd_root_priority`       | Supported only on N7k |
| `domain`                 | Supported only on N5k, N6k, N7k <br> Supported in OS Version 7.0(3)I6(1) and later on N3k, N9k |
| `fcoe`                   | Supported only on N9k |

#### Parameters

##### `bd_designated_priority`
Designated bridge priority. Valid values are an array of [bd_range, designated_priority] pairs or 'default'.

##### `bd_forward_time`
Forward delay. Valid values are an array of [bd_range, forward_time] pairs or 'default'.

##### `bd_hello_time`
Hello interval. Valid values are an array of [bd_range, hello_time] pairs or 'default'.

##### `bd_max_age`
Max age interval. Valid values are an array of [bd_range, max_age] pairs or 'default'.

##### `bd_priority`
Bridge priority. Valid values are an array of [bd_range, priority] pairs or 'default'.

##### `bd_root_priority`
Root bridge priority. Valid values are an array of [bd_range, root_priority] pairs or 'default'.

##### `bpdufilter`
Edge port (portfast) bpdu filter. Valid values are true, false or 'default'.

##### `bpduguard`
Edge port (portfast) bpdu guard. Valid values are true, false or 'default'.

##### `bridge_assurance`
Bridge Assurance on all network ports. Valid values are true, false or 'default'.

##### `domain`
Domain. Valid values are integer or 'default'.

##### `fcoe`
Spanning tree protocol for FCoE VLAN. Valid values are true, false or 'default'.

##### `loopguard`
Enable loopguard by default on all ports. Valid values are true, false or 'default'.

##### `mode`
Operating mode. Valid values are mst, rapid-pvst or 'default'.

##### `mst_designated_priority`
Designated priority for multiple spanning tree configuration. Valid values are an array of [mst_range, designated_priority] pairs or 'default'

##### `mst_hello_time`
Hello interval for multiple spanning tree configuration. Valid values are integer or 'default'.

##### `mst_inst_vlan_map`
Map vlans to an MST instance. Valid values are an array of [mst_instance, vlan_range] pairs or 'default'

##### `mst_max_age`
Max age interval for multiple spanning tree configuration. Valid values are integer or 'default'.

##### `mst_max_hops`
Max hops for multiple spanning tree configuration. Valid values are integer or 'default'

##### `mst_name`
Name for multiple spanning tree configuration. Valid values are String or 'default'

##### `mst_priority`
Priority for multiple spanning tree configuration. Valid values are an array of [mst_range, priority] pairs or 'default'

##### `mst_revision`
Configuration revision number for multiple spanning tree configuration. Valid values are String or 'default'

##### `mst_root_priority`
Root priority for multiple spanning tree configuration. Valid values are an array of [mst_range, root_priority] pairs or 'default'

##### `pathcost`
Pathcost option. Valid values are long, short or 'default'.

##### `vlan_designated_priority`
Designated priority for vlan. Valid values are an array of [vlan_range, designated_priority] pairs or 'default'

##### `vlan_forward_time`
Forward delay for vlan. Valid values are an array of [vlan_range, forward_time] pairs or 'default'

##### `vlan_hello_time`
Hello interval for vlan. Valid values are an array of [vlan_range, hello_time] pairs or 'default'

##### `vlan_max_age`
Max age interval for vlan. Valid values are an array of [vlan_range, max_age] pairs or 'default'

##### `vlan_priority`
Priority for vlan. Valid values are an array of [vlan_range, priority] pairs or 'default'

##### `vlan_root_priority`
Root priority for vlan. Valid values are an array of [vlan_range, root_priority] pairs or 'default'

--
### Type: cisco_snmp_community
Manages an SNMP community on a Cisco SNMP server.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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
### Type: cisco_upgrade

Manages the upgrade of a Cisco device.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(2e)       | 1.6.0                  |
| N3k      | 7.0(3)I2(2e)       | 1.6.0                  |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | not applicable     | not applicable         |
| N9k-F    | 7.0(3)F1(1)        | 1.6.0                  |

#### <a name="cisco_upgrade-caveats">Caveats</a>

The `cisco_upgrade` is only supported on *simplex* N3k, N9k and N9k-F devices. HA devices are currently not supported.

| Property | Caveat Description |
|:--------|:-------------|
| `package`    | Only images on `bootflash`, `tftp` and `usb` (if available) are supported. The puppet file provider can be used to copy the image file to `bootflash`. Refer to <a href="https://github.com/cisco/cisco-network-puppet-module/blob/develop/examples/cisco/demo_upgrade.pp">Demo Upgrade</a> for an example. |

#### Parameters

##### `name`
Name of cisco_upgrade instance. Valid values are string.
*Only 'image' is a valid name for the cisco_upgrade resource.*

##### `delete_boot_image`
Delete the booted image. Valid values are `true`, `false`.

##### `force_upgrade`
Force upgrade the device.Valid values are `true`, `false`.

#### Properties

##### `package`
Package to install on the device. Format `<uri>:<image>`. Valid values are strings.
*Example --> bootflash:nxos.7.0.3.I5.2.bin
         --> tftp://x.x.x.x/path/to/nxos.7.0.3.I5.2.bin*
*NOTE: Only images on `bootflash:`, `tftp:` and `usb` (if available) are supported.*

--
### Type: cisco_vdc

Manages a Cisco VDC (Virtual Device Context).

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | not applicable     | not applicable         |
| N3k      | not applicable     | not applicable         |
| N5k      | not applicable     | not applicable         |
| N6k      | not applicable     | not applicable         |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | not applicable     | not applicable         |

#### Parameters

##### `name`
Name of the VDC. Valid value is a String or optional keyword 'default' when referencing the default VDC.
*The current implementation restricts changes to the default VDC*.

##### `ensure`
Determines whether the config should be present or not. Valid values are 'present' and 'absent'.

#### Properties

##### `limit_resource_module_type`
This command restricts the allowed module-types in a given VDC. Valid values are String or keyword 'default'.

--
### Type: cisco_vlan

Manages a Cisco VLAN.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |

#### <a name="cisco_vlan-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `fabric_control`    | Only supported on N7k (support added in ciscopuppet 1.3.0) |
| `mode`              | Only supported on N5k,N6k,N7k |
| `pvlan_type`        | Not supported on N9k-F        |
| `pvlan_association` | Not supported on N9k-F        |

#### Parameters

##### `vlan`
ID of the Virtual LAN. Valid value is an integer.

##### `ensure`
Determines whether the config should be present or not. Valid values are 'present' and 'absent'.

##### `mapped_vni`
The Virtual Network Identifier (VNI) id that is mapped to the VLAN. Valid values are integer and keyword 'default'.

##### `mode`
Determines mode of the VLAN. Valid values are 'CE', 'fabricpath' and
keyword 'default'.

##### `vlan_name`
The name of the VLAN. Valid values are a string or the keyword 'default'.

##### `state`
State of the VLAN. Valid values are 'active', 'suspend', and keyword 'default'.

##### `shutdown`
Whether or not the vlan is shutdown. Valid values are 'true', 'false' and
keyword 'default'.

##### `pvlan_type`
The private vlan type. Valid values are: 'primary', 'isolated', 'community' or 'default'.

##### `pvlan_association`
Associates the secondary vlan(s) to the primary vlan. Valid values are an Array or String of vlan ranges, or keyword 'default'.

Examples:

```
pvlan_associate => ['2-5, 9']
  -or-
pvlan_associate => '2-5, 9'
```

##### `fabric_control`
Specifies this vlan as the fabric control vlan. Only one bridge-domain or VLAN can be configured as fabric-control. Valid values are true, false.

--
### Type: cisco_vpc_domain
Manages the virtual Port Channel (vPC) domain configuration of a Cisco device.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_vpc_domain-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `auto_recovery`                     | Only supported on N3k, N7k, N9k |
| `fabricpath_emulated_switch_id`     | Only supported on N7k           |
| `fabricpath_multicast_load_balance` | Only supported on N7k           |
| `layer3_peer_routing`               | Only supported on N5k, N6k, N7k <br> Supported in OS Version 7.0(3)I6(1) and later on N3k, N9k |
| `peer_gateway_exclude_vlan`         | Only supported on N5k, N6k, N7k |
| `port_channel_limit`                | Only supported on N7k           |
| `self_isolation`                    | Only supported on N7k           |
| `shutdown`                          | Only supported on N5k, N6k, N7k <br> Supported in OS Version 7.0(3)I6(1) and later on N3k, N9k |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `domain`
vPC domain ID. Valid values are integer in the range 1-1000. There is no default value, this is a 'name' parameter.

##### `auto_recovery`
Auto Recovery enable or disable if peer is non-operational. Valid values are true, false or default. This parameter is available only on Nexus 7000 series. Default value: true.

##### `auto_recovery_reload_delay`
Delay (in secs) before peer is assumed dead before attempting to recover vPCs. Valid values are Integer or keyword 'default'

##### `delay_restore`
Delay (in secs) after peer link is restored to bring up vPCs. Valid values are Integer or keyword 'default'.

##### `delay_restore_interface_vlan`
Delay (in secs) after peer link is restored to bring up Interface VLANs or Interface BDs. Valid values are Integer or keyword 'default'.

##### `dual_active_exclude_interface_vlan_bridge_domain`
Interface VLANs or BDs to exclude from suspension when dual-active. Valid values are Integer or keyword 'default'.

##### `fabricpath_emulated_switch_id`
Configure a fabricpath switch_Id to enable vPC+ mode. This is also known as the Emulated switch-id. Valid values are Integer or keyword 'default'. 

##### `fabricpath_multicast_load_balance`
In vPC+ mode, enable or disable the fabricpath multicast load balance. This loadbalances the Designated Forwarder selection for multicast traffic. Valid values are true, false or default

##### `graceful_consistency_check`
Graceful conistency check . Valid values are true, false or default. Default value: true.

##### `layer3_peer_routing`
Enable or Disable Layer3 peer routing. Valid values are true/false or default. Default value: false.

##### `peer_keepalive_dest`
Destination IPV4 address of the peer where Peer Keep-alives are terminated. Valid values are IPV4 unicast address. There is no default value.

##### `peer_keepalive_hold_timeout`
Peer keep-alive hold timeout in secs. Valid values are Integer or keyword 'default'.

##### `peer_keepalive_interval`
Peer keep-alive interval in millisecs. Valid values are Integer or keyword 'default'.

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

##### `port_channel_limit`
In vPC+ mode, enable or disable the port channel scale limit of
244 vPCs.  Valid values are true, false or default

##### `role_priority`
Priority to be used during vPC role selection of primary vs secondary. Valid values are integers in the range 1..65535. Default value: 32667.

##### `self_isolation`
Enable or Disable self-isolation function for vPC. Valid values are true, false or default. This parameter is available only in Nexus 7000 series. Default value: false.

##### `shutdown`
Whether or not the vPC domain is shutdown.  Default value: false.

##### `system_mac`
vPC system mac. Valid values are in mac addresses format. There is no default value.

##### `system_priority`
vPC system priority. Valid values are integers in the range 1..65535. Default value: 32667.

--
### Type: cisco_vrf

Manages Cisco Virtual Routing and Forwarding (VRF) configuration of a Cisco
device.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_vrf-caveats">Caveats</a>

| Property                     | Caveat Description               |
|------------------------------|----------------------------------|
| mhost_ipv4_default_interface | Not supported on Nexus           |
| mhost_ipv6_default_interface | Not supported on Nexus           |
| remote_route_filtering       | Not supported on Nexus           |
| route_distinguisher          | Only supported on N3k, N9k       |
| shutdown                     | Only supported on N3k, N9k       |
| vni                          | Only supported on N9k            |
| vpn_id                       | Not supported on Nexus           |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid
values are 'present' and 'absent'. Default value is 'present'.

##### `name`
Name of the VRF. Valid value is a string of non-whitespace characters. It is
not case-sensitive and overrides the title of the type.

#### Properties

##### `description`
Description of the VRF. Valid value is string.

##### `mhost_ipv4_default_interface`
Specify multicast ipv4 host default interface. Valid value will be a valid interface or the keyword 'default'.

##### `mhost_ipv6_default_interface`
Specify multicast ipv6 host default interface. Valid value will be a valid interface or the keyword 'default'.

##### `remote_route_filtering`
Enable/disable remote route filtering. Valid value will be true, false or the keyword 'default'.

<a name='vrf_rd'></a>
##### `route_distinguisher`
VPN Route Distinguisher (RD). The RD is combined with the IPv4 or IPv6 prefix learned by the PE router to create a globally unique address. Valid values are a String in one of the route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN); the keyword 'auto', or the keyword 'default'.

*Please note:* The `route_distinguisher` property is typically configured within the VRF context configuration on most platforms (including NXOS) but it is tightly coupled to bgp and therefore configured within the BGP configuration on some non-NXOS platforms. For this reason the `route_distinguisher` property has support (with limitations) in both `cisco_vrf` and `cisco_bgp` providers:

* `cisco_bgp`: The property is supported on both NXOS and some non-NXOS platforms. See: [cisco_bgp: route_distinguisher](#bgp_rd)
* `cisco_vrf`: The property is only supported on NXOS.

*IMPORTANT: Choose only one provider to configure the `route_distinguisher` property on a given device. Using both providers simultaneously on the same device may have unpredictable results.*

##### `shutdown`
Shutdown state of the VRF. Valid values are 'true', 'false', and 'default'.

##### `vni`
Specify virtual network identifier. Valid values are Integer or keyword 'default'.

##### `vpn_id`
Specify vpn_id. Valid values are <0-ffffff>:<0-ffffffff>  or keyword 'default'.

--
### Type: cisco_vrf_af

Manages Cisco Virtual Routing and Forwarding (VRF) Address-Family configuration.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.2.0                  |
| N6k      | 7.3(0)N1(1)        | 1.2.0                  |
| N7k      | 7.3(0)D1(1)        | 1.2.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_vrf_af-caveats">Caveats</a>

| Property                      | Caveat Description                   |
|-------------------------------|--------------------------------------|
| route_target_both_auto        | Not supported on N3k                 |
| route_target_both_auto_evpn   | Not supported on N3k                 |
| route_target_export_evpn      | Not supported on N3k                 |
| route_target_export_stitching | Not supported on Nexus               |
| route_target_import_evpn      | Not supported on N3k                 |
| route_target_import_stitching | Not supported on Nexus               |

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

#### Properties

##### `route policy export`
Set route-policy (route-map) export name. Valid value is string or keyword 'default'.

##### `route policy import`
Set route-policy (route-map) import name. Valid value is string or keyword 'default'.

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

##### `route_target_import_stitching`
(Stitching only) Sets the route-target import extended communities for stitching. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

##### `route_target_export`
Sets the route-target export extended communities. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

##### `route_target_export_evpn`
(EVPN only) Sets the route-target export extended communities for EVPN. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

##### `route_target_export_stitching`
(Stitching only) Sets the route-target export extended communities for stitching. Valid values are an Array or space-separated String of extended communities, or the keyword 'default'.

--
### Type: cisco_vtp

Manages the VTP (VLAN Trunking Protocol) configuration of a Cisco device.
There can only be one instance of the cisco_vtp.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.0.1                  |
| N3k      | 7.0(3)I2(1)        | 1.0.1                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | not applicable     | not applicable         |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_vxlan_vtep-caveats">Caveats</a>

| Property                        | Caveat Description                   |
|---------------------------------|--------------------------------------|
| source_interface_hold_down_time | Not supported on N3k, N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |

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

##### `source_interface_hold_down_time`
Suppresses advertisement of the NVE loopback address until the overlay has converged. Valid values are Integer or keyword 'default'.

--
### Type: cisco_vxlan_vtep_vni
Creates a Virtual Network Identifier member (VNI) for an NVE overlay interface.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | not applicable     | not applicable         |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="cisco_vxlan_vtep_vni-caveats">Caveats</a>

| Property                        | Caveat Description                   |
|---------------------------------|--------------------------------------|
| ingress_replication             | Not supported on N3k, N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |
| peer_list                       | Not supported on N3k, N5k, N6k <br> Supported in OS Version 8.1.1 and later on N7k |
| suppress_uuc                    | Not supported on N3k, N9k, N9k-F <br> Supported in OS Version 8.1.1 and later on N7k |

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

##### `suppress_uuc`
Suppress uuc under layer 2 VNI. Valid values are true, false, or 'default'.

--
### NetDev StdLib Resource Type Details

The following resources are listed alphabetically.

--

### Type: domain_name

Configure the domain name of the device

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Domain name of the device. Valid value is a string.

--
### Type: name_server

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Hostname or address of the DNS server.  Valid value is a string.

--
### Type: network_dns

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

###### `name`
Name of the interface on the network element. Valid value is a string.

#### Properties

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

###### `name`
The switch interface name. Valid value is a string.

#### Properties

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
### Type: network_vlan

Manages a puppet netdev_stdlib Network Vlan.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

###### `id`
ID of the Virtual LAN. Valid value is a string.

###### `shutdown`
Whether or not the vlan is shutdown. Valid values are 'true' or 'false'.

###### `vlan_name`
The name of the VLAN.  Valid value is a string.

--
### Type: ntp_auth_key

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.7.0                  |
| N3k      | 7.0(3)I2(1)        | 1.7.0                  |
| N5k      | 7.3(0)N1(1)        | 1.7.0                  |
| N6k      | 7.3(0)N1(1)        | 1.7.0                  |
| N7k      | 7.3(0)D1(1)        | 1.7.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.7.0                  |

#### Parameters

##### `algorithm`
Authentication scheme.  Valid value is 'md5'.

##### `key`
Authentication key number.  Valid value is a string.

##### `mode`
Authentication mode.  Valid values are '0' and '7'.

##### `password`
Authentication password.  Valid value is a string.

--
### Type: ntp_config

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="ntp_config-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `authenticate` | Module minimum version 1.7.0 |
| `trusted_key`  | Module minimum version 1.7.0 |

#### Parameters

##### `authenticate`
Enable authentication.  Valid values are 'true', 'false' and 'default'.

##### `name`
Resource name, not used to configure the device.  Valid value is a string.

##### `source_interface`
Source interface for the NTP server.  Valid value is a string.

##### `trusted_key`
Trusted key for the NTP server.  Valid value is integer.

--
### Type: ntp_server

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### <a name="ntp_server-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|
| `key`     | Module minimum version 1.7.0 |
| `maxpoll` | Module minimum version 1.7.0 |
| `minpoll` | Module minimum version 1.7.0 |
| `vrf`     | Module minimum version 1.7.0 |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `key`
Key id to be used while communicating to this NTP.  Valid value is an integer.

##### `maxpoll`
Maximum interval to poll NTP server.  Valid value is an integer.

##### `minpoll`
Minimum interval to poll NTP server.  Valid value is an integer.

##### `name`
Hostname or IPv4/IPv6 address of the NTP server.  Valid value is a string.

##### `vrf`
Name of the vrf.  Valid value is a string.

--
### Type: port_channel

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `name`
Resource name, not used to manage the device.  Valid value is a string.

##### `enable`
Enable or disable radius functionality.  Valid values are 'true' or 'false'.

--
### Type: radius_global

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |

#### <a name="radius_server-caveats">Caveats</a>

| Property | Caveat Description |
|:--------|:-------------|

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

##### `accounting_only`
Enable this server for accounting only.  Valid values are 'true' or 'false'.

##### `authentication_only`
Enable this server for authentication only.  Valid values are 'true' or 'false'.

##### `key`
Encryption key (plaintext or in hash form depending on key_format).  Valid value is a string.

##### `key_format`
Encryption key format [0-7].  Valid value is an integer.

--
### Type: radius_server_group

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `servers`
Array of servers associated with this group.

--
### Type: search_domain

Configure the search domain of the device. Note that this type is functionally equivalent to the netdev_stdlib domain_name type.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `ensure`
Determines whether or not the config should be present on the device. Valid values are 'present' and 'absent'.

##### `name`
Search domain of the device. Valid value is a string.

-
### Type: snmp_community

Manages an SNMP community on a Cisco SNMP server.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `enable`
Determine whether the trap should be on or off. Valid
values are true and false.

--
### Type: snmp_notification_receiver

Manages an SNMP notification receiver on an cisco SNMP server.

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.1.0                  |
| N3k      | 7.0(3)I2(1)        | 1.1.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `name`
Hostname or address of the Syslog server.  Valid value is a string.

##### `time_stamp_units`
The unit of measurement for log time values.  Valid values are 'seconds' and 'milliseconds'.

--
### Type: tacacs

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `enable`
Enable or disable radius functionality [true|false]

--
### Type: tacacs_global

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

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

| Platform | OS Minimum Version | Module Minimum Version |
|----------|:------------------:|:----------------------:|
| N9k      | 7.0(3)I2(1)        | 1.2.0                  |
| N3k      | 7.0(3)I2(1)        | 1.2.0                  |
| N5k      | 7.3(0)N1(1)        | 1.3.0                  |
| N6k      | 7.3(0)N1(1)        | 1.3.0                  |
| N7k      | 7.3(0)D1(1)        | 1.3.0                  |
| N9k-F    | 7.0(3)F1(1)        | 1.5.0                  |

#### Parameters

##### `servers`
Array of servers associated with this group.

## <a href='documentation-guide'>Documentation Guide</a>

The following table groups **ciscopuppet** documentation based on the intended audience.

Audience | ciscopuppet Documentation |
:--:|:--|
User       | [README.md][USER-0] : (This document)<br>[README-agent-install.md][USER-1] : Agent Installation and Configuration Guide<br>[README-beaker-agent-install.md][USER-2] : Automated Agent Installation and Configuration<br>[README-package-provider.md][USER-3] : Cisco Nexus Package Management<br>[README-example-manifest.md][USER-4] : Example Demo Manifest User Guide
Developer  | [CONTRIBUTING.md][DEV-1] : Contribution guidelines<br>[README-develop-types-providers.md][DEV-2] : Developing new ciscopuppet Types & Providers<br>[README-develop-beaker-scripts.md][DEV-3] : Developing new beaker test scripts for ciscopuppet
Maintainer | [README-maintainers.md][MAINT-1] : Guidelines for core maintainers of the ciscopuppet project<br>*(Developer guides apply to Maintainers as well)*

[USER-0]: https://github.com/cisco/cisco-network-puppet-module/blob/master/README.md
[USER-1]: https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-agent-install.md
[USER-2]: https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-beaker-agent-install.md
[USER-3]: https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-package-provider.md
[USER-4]: https://github.com/cisco/cisco-network-puppet-module/blob/master/examples/README.md

[DEV-1]: https://github.com/cisco/cisco-network-puppet-module/blob/master/CONTRIBUTING.md
[DEV-2]: https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-develop-types-providers.md
[DEV-3]: https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-develop-beaker-scripts.md

[MAINT-1]: https://github.com/cisco/cisco-network-puppet-module/blob/master/docs/README-maintainers.md
[MAINT-2]: https://github.com/cisco/cisco-network-puppet-module/blob/master/SUPPORT.md

##### General Documentation

Topic | Resources |
:---------|:--|
Puppet    | <https://learn.puppetlabs.com/><br><https://en.wikipedia.org/wiki/Puppet_(software)>
Guestshell | [N9k Programmability Guide][GS_9K]
Markdown<br>(*editor*) | <https://help.github.com/articles/markdown-basics/>
N5k,N6k OAC<br>(open agent container) | [N5k,N6k Programmability Guide][OAC_5K_DOC]
N7k OAC<br>(open agent container)     | [N7k Programmability Guide][OAC_7K_DOC]
Ruby      | <https://en.wikipedia.org/wiki/Ruby_(programming_language)><br><https://www.codecademy.com/tracks/ruby><br><https://rubymonk.com/><br><https://www.codeschool.com/paths/ruby>
Ruby Gems | <http://guides.rubygems.org/><br><https://en.wikipedia.org/wiki/RubyGems>
YAML      | <https://en.wikipedia.org/wiki/YAML><br><http://www.yaml.org/start.html>
Yum       | <https://en.wikipedia.org/wiki/Yellowdog_Updater,_Modified><br><https://www.centos.org/docs/5/html/yum/><br><http://www.linuxcommand.org/man_pages>

[GS_9K]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html

[OAC_5K_DOC]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus5000/sw/programmability/guide/b_Cisco_Nexus_5K6K_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_5K6K_Series_NX-OS_Programmability_Guide_chapter_01001.html

[OAC_7K_DOC]: http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus7000/sw/programmability/guide/b_Cisco_Nexus_7000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_7000_Series_NX-OS_Programmability_Guide_chapter_01001.html

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
