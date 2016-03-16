# Installing the `cisco_node_utils` gem for Puppet

#### Table of Contents

1. [Overview](#overview)
1. [Gem Installation](#gem-installation)
1. [Gem Configuration](#gem-configuration)
1. [Gem Persistence](#gem-persistence)

## Overview

The ciscopuppet module has dependencies on the [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils) ruby gem. After [installing the Puppet Agent software](README-agent-install.md) you will then need to install the gem on the agent device.

## Gem Installation

This gem has various dependencies which differ between IOS XR and Nexus; installing `cisco_node_utils` by itself will automatically install the dependencies that are relevant to the target platform.

Nexus example:

~~~bash
[root@guestshell]# /opt/puppetlabs/puppet/bin/gem install cisco_node_utils
...
[root@guestshell]# /opt/puppetlabs/puppet/bin/gem list | egrep 'cisco|net_http'
cisco_node_utils (1.2.0)
net_http_unix (0.2.1)
~~~

IOS XR example:

~~~bash
bash-4.3# /opt/puppetlabs/puppet/bin/gem install cisco_node_utils
...
bash-4.3# /opt/puppetlabs/puppet/bin/gem list 'cisco|grpc|google'
cisco_node_utils (1.2.0)
google-protobuf (3.0.0.alpha.5.0.3 x86_64-linux)
googleauth (0.5.1)
grpc (0.13.0 x86_64-linux)
~~~

*Please note: The `ciscopuppet` module requires a compatible `cisco_node_utils` gem. This is not an issue with release versions; however, when using a pre-release module it may be necessary to manually build a compatible gem. Please see the `cisco_node_utils` developer's guide for more information on building a `cisco_node_utils` gem:  [README-develop-node-utils-APIs.md](https://github.com/cisco/cisco-network-node-utils/blob/develop/docs/README-develop-node-utils-APIs.md#step-5-build-and-install-the-gem)*

## Gem Configuration

*This section currently applies to IOS XR only.*

For IOS XR, in order to use most functionality of `cisco_node_utils`, you will also need to create an appropriate [configuration file](https://github.com/cisco/cisco-network-node-utils#configuration). Since Puppet normally runs as root, we recommend creating the system-wide configuration file and marking it as readable only by root:

~~~bash
# customize these as appropriate
export GRPC_PORT=57400
export IOS_XR_USER='adminusername'
export IOS_XR_PASS='admin_password!'
cat >> /etc/cisco_node_utils.yaml << EOF
default:
  port: $GRPC_PORT
  username: "$IOS_XR_USER"
  password: "$IOS_XR_PASS"
EOF
sudo chown root /etc/cisco_node_utils.yaml
sudo chmod 0600 /etc/cisco_node_utils.yaml
~~~

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

