# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- Added CONTRIBUTING.md
- Added README-creating-types-providers.md and associated templates.
- Added SUPPORT.md
- Added Beaker test cases for cisco_command_config, file, package, and service providers.

### Fixed
- 'puppet resource cisco_vtp' now works properly.
- cisco_interface, cisco_ospf_vrf, and cisco_vlan now properly handle destroy/recreate scenarios.
- Added missing methods in cisco_ospf_vrf provider.
- Style cleanup of many Beaker test scripts.
- Fixed title pattern error in 'puppet resource cisco_snmp_group'.
- Avoid inadvertently suppressing relevant exceptions.
- Added dotted-decimal munging for area in cisco_interface_ospf

## [0.9.0] - 2015-07-24
### Added
- Initial release of puppetlabs-ciscopuppet module, supporting Cisco NX-OS software release 7.0(3)I2(1) on Cisco Nexus switch platforms: N95xx, N93xx, N30xx and N31xx.
- Please note: 0.9.0 is an EFT pre-release for a limited audience with access to NX-OS 7.0(3)I2(1). Additional code changes may occur in 0.9.x prior to the final 1.0.0 release.

