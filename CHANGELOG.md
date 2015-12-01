# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### New feature support
#### NetDev Resources.
- search_domain provider.

### Added
- Extended cisco_bgp with the following attributes:
  - route_distinguisher
- Extended cisco_bgp_af with the following attributes:
  - route_target_both_auto, route_target_both_auto_evpn
  - route_target_import, route_target_import_evpn
  - route_target_export, route_target_export_evpn
- Extended cisco_vrf with `vni`

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
- syslog_server provider.
- syslog_setting provider.
- snmp_user provider.

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

[unreleased]: https://github.com/cisco/cisco-network-puppet-module/compare/master...develop
[1.1.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.1...v1.0.0
[0.9.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.0...v0.9.1
