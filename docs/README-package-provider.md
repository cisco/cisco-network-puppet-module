# Managing Packages with the Cisco <u>package</u> Provider

#### Table of Contents

1. [Overview](#overview)
2. [Syntax](#syntax)
3. [Examples](#examples)
4. [References](#references)

## <a name="overview">Overview</a>

This document describes the Cisco **package** provider for Puppet, which serves as a common package provider for Cisco NX-OS and IO-XR RPM packages and third-party RPM packages.

The Cisco **package** provider is a sub-class of Puppet's **yum_package**. It uses the yum provider for third-party RPM management but uses custom install and uninstall methods to support NXAPI-based CLI installation on NX-OS that target the NX-OS host environment for Cisco RPMs and sdr_instcmd based installation on IOS-XR for Cisco RPMs.

* **Third-Party RPM**
  *  Third party RPMs target 
    * one of the Cisco NX-OS third party environments:
      * `bash-shell`: The WRL Linux environment underlying NX-OS.
      * `guestshell`: A secure Linux container running CentOS.
    or
    * IOS-XR.
  * The Cisco **package** provider uses yum for third-party RPMs.
  * May also be managed directly with **yum_package** or **rpm_package**.

* **Cisco RPM**
  * These RPMS target the Cisco NX-OS host environment or IOS-XR.


## <a name="Syntax">Syntax</a>

~~~
package { 'name':
  ensure                => String,
  package_settings      => String, Array
  source                => String,
  provider              => String,
}
~~~

where:

* `package`: Tells the Puppet agent to manage a package.

* `name`: The name of the package.

* `ensure`: Optional. Valid settings are `absent` or `present`. Default is `present`.

* `package_settings`: Required for Cisco RPM installs. This is necessary to indicate that the given RPM should be installed to the host environment. The only valid setting for this attribute is `{'target' => 'host'}`. This attribute is not used for third-party installs.

* `source`: Optional. Path to local file or URI for remote RPMs.

* `provider`: Optional. Set to 'cisco' if installling a Cisco package.


## <a name="examples">Examples</a>

* **Cisco RPMs**

~~~
# NX-OS RPM file
package { 'n9000_sample':
  source           => "http://myrepo.my_company.com/n9000_sample-1.0.0-7.0.3.x86_64.rpm",
  package_settings => {'target' => 'host'}
  provider         => 'cisco',
}
~~~

~~~
# NX-OS RPM file
package { 'n9000_sample':
  ensure           => absent,
  package_settings => {'target' => 'host'},
  provider         => 'cisco',
}
~~~

~~~
# Local NX-OS RPM file
package { 'n9000_sample':
  source           => '/bootflash/n9000_sample-1.0.0-7.0.3.x86_64.rpm',
  package_settings => {'target' => 'host'}
}
~~~

~~~
# IOS-XR Local RPM file
  package { 'xrv9k-ospf-1.0.0.0-r61107I':
    ensure           => 'present',
    name             => 'xrv9k-ospf-1.0.0.0-r61107I.x86_64.rpm-XR-DEV-16.03.24C',
    provider         => 'cisco',
    source           => '/disk0:/xrv9k-ospf-1.0.0.0-r61107I.x86_64.rpm-XR-DEV-16.03.24C',
    platform         => 'x86_64',
    package_settings => {},
  }
~~~

* **Third-Party RPMs**

~~~
# Install directly to bash-shell or guestshell environments
package { 'package_A':
  ensure => present
}
~~~
~~~
package { 'package_B':
  ensure => absent
}
~~~

## <a name="references">References</a>

[Puppet package resource types](https://docs.puppetlabs.com/references/latest/type.html#package) - Generic and specific package management resources.

[Cisco Nexus Puppet Modules](../README.md) - Types, Providers, Utilities

[Cisco Nexus Programmability Guide](http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html) - Guestshell Documentation
