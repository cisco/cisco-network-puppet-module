# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased
### Added
- New documentation for developing beaker testcases: README-develop-beaker-scripts.md
- Extended cisco_interface with the following attributes:
  - encapsulation dot1q
  - mtu
  - switchport trunk allowed VLANs
  - switchport trunk native VLAN
- Rubocop enabled and passes (@robert-w-gries)

### Removed
- Obsolete documents: README-beaker-testcase-execution.md, README-beaker-testcase-writing.md

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
[1.0.2]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.1...v1.0.0
[0.9.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.0...v0.9.1
