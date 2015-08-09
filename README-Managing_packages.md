# Managing Packages with the Cisco <u>package</u> Provider

#### Table of Contents

1. [Overview](#overview)
2. [Syntax](#syntax)
3. [Examples](examples)
9. [References](#references)
10. [Limitations](#limitations)
11. [Known Issues](#issues)

## <a name="overview">Overview</a>

This document describes the Cisco **package** provider for puppet, which serves as a common package provider for both Cisco NX-OS RPM packages and 3rd Party RPM packages.

The Cisco **package** provider is a sub-class of Puppet's **yum_package**. It utilizes the yum provider for 3rd Party RPM management but uses custom install & uninstall methods to support NXAPI-based CLI installs for Cisco RPMs that target the NX-OS host environment.

* **3rd Party RPM**
  * These RPMs target one of the Cisco NX-OS 3rd Party environments:
    * `bash-shell` : The WRL linux environment underlying NX-OS
    * `guestshell` : A secure linux container running CentOS
  * The Cisco **package** provider uses yum for 3rd Party RPMs
  * May also be managed directly with **yum_package** or **rpm_package**

* **Cisco RPM**
  * These RPMS target the Cisco NX-OS host environment

## <a name="Syntax">Syntax</a>

```
package { 'name':
  ensure                => String,
  package_settings      => String, Array
  source                => String,
  provider              => String,
}
```
where:

* `package` tells the puppet agent to manage a package

* `name` is the name of the package

* `ensure` Optional. Valid settings are `absent` or `present`. Default is `present`

* `package_settings` Required for Cisco RPM installs. This is necessary to indicate that the given RPM should be installed to the host environment. Currently the only valid setting for this attribute is `{'target' => 'host'}`. This attribute is not used for 3rd Party installs.

* `source` Optional. Path to local file or URI for remote RPMs.

* `provider` Optional. Set to 'nxapi' if installling a cisco package.


## <a name="Examples">Examples</a>

* **Cisco RPMs**

```
package { 'n9000_sample':
  source           => "http://myrepo.my_company.com/n9000_sample-1.0.0-7.0.3.x86_64.rpm",
  package_settings => {'target' => 'host'}
  provider         => 'nxapi',
}
```
```
package { 'n9000_sample':
  ensure           => absent,
  package_settings => {'target' => 'host'},
  provider         => 'nxapi',
}
```
```
# Local RPM file
package { 'n9000_sample':
  source           => '/bootflash/n9000_sample-1.0.0-7.0.3.x86_64.rpm',
  package_settings => {'target' => 'host'}
}
```

* **3rd Party RPMs**

```
# Install directly to bash-shell or guestshell environments
package { 'package_A':
  ensure => present
}
```
```
package { 'package_B':
  ensure => absent
}
```

## <a name="references">References</a>

[Puppet package resource types](https://docs.puppetlabs.com/references/latest/type.html#package) - Generic and specific package management resources

[Cisco Nexus Puppet Modules](README.md) - Types, Providers, Utilities

[Cisco Nexus Programmability Guide](http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html) - Guestshell Documentation

## <a name="limitations">Limitations</a>

## <a name="issues">Known Issues</a>

