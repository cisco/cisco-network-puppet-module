# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.3] - 2016-02-24
### Added
- Download link for Nexus 5000 and Nexus 6000 Open Agent Container (OAC).
- OAC programmability guide links.
- Complete cisco_ace documentation.

## [1.2.2] - 2016-02-14

### Fixed
- Fixed Cisco NetDev port\_channel provider to use the correct cisco\_node\_utils object.
- Fixed beaker test setup and cleanup issues.
- Fixed incomplete documentation references for the open agent container (OAC)

## 1.2.1
This version was never released.

## [1.2.0] - 2016-02-12

### New feature support
#### Cisco Resources
- `cisco_aaa_authentication_login` type and provider.
- `cisco_aaa_authorization_login_cfg_svc` type and provider.
- `cisco_aaa_authorization_login_exec_svc` type and provider.
- `cisco_aaa_group_tacacs` type and provider.
- `cisco_ace` type and provider
- `cisco_acl` type and provider
- `cisco_evpn_vni` type and provider.
- `cisco_interface_channel_group` type and provider
- `cisco_interface_portchannel` type and provider
- `cisco_interface_service_vni` type and provider
- `cisco_overlay_global` type and provider.
- `cisco_pim` type and provider
- `cisco_pim_rp_address` type and provider
- `cisco_pim_grouplist` type and provider
- `cisco_portchannel_global` type and provider
- `cisco_vdc` type and provider.
- `cisco_vni` type and provider.
- `cisco_vrf_af` type and provider.
- `cisco_vxlan_vtep` type and provider.

#### NetDev Resources
- `network_trunk` provider.
- `port_channel` provider.
- `search_domain` provider.
- `snmp_notification` provider.

### Added
- Extended `cisco_bgp` with the following attributes:
  - `disable_policy_batching`, `disable_policy_batching_ipv4`, `disable_policy_batching_ipv6`
  - `fast_external_fallover`
  - `flush_routes`
  - `isolate`
  - `neighbor_down_fib_accelerate`
  - `route_distinguisher`
  - `event_history_cli`
  - `event_history_detail`
  - `event_history_events`
  - `event_history_periodic`
- Extended `cisco_bgp_af` with the following attributes:
  - `default_metric`
  - `distance_ebgp`, `distance_ibgp`, `distance_local`
  - `inject_map`
  - `table_map`, `table_map_filter`
  - `suppress_inactive`
- Extended `cisco_interface` with the following attributes:
  - `fabric_forwarding_anycast_gateway` 
  - `ipv4_address_secondary`, `ipv4_netmask_length_secondary`
  - `ipv4_arp_timeout`
  - `ipv4_pim_sparse_mode`
  - `vlan_mapping`, `vlan_mapping_enable`
  - `ipv4_acl_in`, `ipv4_acl_out`, `ipv6_acl_in`, `ipv6_acl_out`
- Extended `cisco_vrf` with the following attributes:
  - `route_distinguisher`
  - `vni`

### Removed

## [1.1.0] - 2015-11-02

### New feature support
#### Cisco Resources.
- cisco_bgp type and provider.
- cisco_bgp_af type and provider.
- cisco_bgp_neighbor type and provider.
- cisco_bgp_neighbor_af type and provider.
- cisco_vrf type and provider.

#### NetDev Resources.
- domain_name provider.
- name_server provider.
- network_dns provider.
- network_snmp provider.
- ntp_config provider.
- ntp_server provider.
- radius provider.
- radius global provider.
- snmp_notification_receiver provider.
- snmp_user provider.
- syslog_server provider.
- syslog_setting provider.

### Added
- New documentation for developing beaker testcases: README-develop-beaker-scripts.md
- Extended cisco_interface with the following attributes:
  - encapsulation dot1q
  - mtu
  - speed
  - duplex
  - switchport trunk allowed VLANs
  - switchport trunk native VLAN
- Added support for network_interface from puppets netdev_stdlib
- Rubocop enabled and passes (@robert-w-gries)
- Gemfile now requires puppet version 4.0 or higher
- Gemfile.lock added to gitignore

### Removed
- Obsolete documents: README-beaker-testcase-execution.md, README-beaker-testcase-writing.md
- Travis no longer tests ruby version 1.9.3

## [1.0.2] - 2015-09-28
### Fixed
- Updated documentation links to reflect that the repo and agent RPM packages have had their platform renamed from 'nxos' to 'cisco-wrlinux'.

## [1.0.1] - 2015-09-18
### Fixed
- Fixed broken documentation links

## [1.0.0] - 2015-08-28
### Added
- New facts `cisco_node_utils` and `cisco_nxapi` report the installed version of these gems.
- Providers requiring the `cisco_node_utils` feature will generate a warning message if an obsolete gem version is installed.
- Added README-maintainers.md

### Fixed
- Metadata URLs now point to new public GitHub repository.
- Moved misc READMEs into /docs
- NXAPI providers are marked as defaultfor 'nexus' operating system.
- Fixed beaker test for package and interface ospf
- Fixed sample install.pp

## [0.9.1] - 2015-08-13
### Added
- Added CONTRIBUTING.md
- Added README-creating-types-providers.md and associated templates.
- Added SUPPORT.md
- Added Beaker test cases for cisco_command_config, file, package, and service providers.
- Added VRF attribute to cisco_interface provider.

### Fixed
- 'puppet resource cisco_vtp' now works properly.
- cisco_interface, cisco_ospf_vrf, and cisco_vlan now properly handle destroy/recreate scenarios.
- Added missing methods in cisco_ospf_vrf provider.
- Style cleanup of many Beaker test scripts.
- Fixed title pattern error in 'puppet resource cisco_snmp_group'.
- Avoid inadvertently suppressing relevant exceptions.
- Added dotted-decimal munging for area in cisco_interface_ospf
- Modified template placeholder names to meet lint reqs

## 0.9.0 - 2015-07-24
### Added
- Initial release of puppetlabs-ciscopuppet module, supporting Cisco NX-OS software release 7.0(3)I2(1) on Cisco Nexus switch platforms: N95xx, N93xx, N30xx and N31xx.
- Please note: 0.9.0 is an EFT pre-release for a limited audience with access to NX-OS 7.0(3)I2(1). Additional code changes may occur in 0.9.x prior to the final 1.0.0 release.

[1.2.3]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.2.0...v1.2.2
[1.2.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.1...v1.0.0
[0.9.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.0...v0.9.1
