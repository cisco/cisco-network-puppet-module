# Installing the `cisco_node_utils` gem for Puppet

#### Table of Contents

1. [Overview](#overview)
1. [Gem Installation](#gem-installation)
1. [Gem Configuration](#gem-configuration)
1. [Gem Persistence](#gem-persistence)

## Overview

The ciscopuppet module has dependencies on the [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils) ruby gem. After [installing the Puppet Agent software](README-agent-install.md) you will then need to install the gem on the agent device.

## Gem Installation

Installing `cisco_node_utils` by itself will automatically install the dependencies that are relevant to the target platform.

Example:

~~~bash
[root@guestshell]# /opt/puppetlabs/puppet/bin/gem install cisco_node_utils
...
[root@guestshell]# /opt/puppetlabs/puppet/bin/gem list | egrep 'cisco|net_http'
cisco_node_utils (1.2.0)
net_http_unix (0.2.1)
~~~

*Please note: The `ciscopuppet` module requires a compatible `cisco_node_utils` gem. This is not an issue with release versions; however, when using a pre-release module it may be necessary to manually build a compatible gem. Please see the `cisco_node_utils` developer's guide for more information on building a `cisco_node_utils` gem:  [README-develop-node-utils-APIs.md](https://github.com/cisco/cisco-network-node-utils/blob/develop/docs/README-develop-node-utils-APIs.md#step-5-build-and-install-the-gem)*

## Gem Persistence

*This section currently applies to the NX-OS `bash-shell` environment only.*

Please note that in the Nexus `bash-shell` environment these gems are currently not persistent across system reload. This persistence issue can be mitigated by simply defining a manifest entry for installing the `cisco_node_utils` gem via the package provider.

Example:

~~~Puppet
package { 'cisco_node_utils' :
  provider => 'gem',
  ensure => present,
}
~~~

*This persistence issue does not affect the `guestshell` or `open agent container (OAC)` environments. Gems are persistent across reload in these environments.*

