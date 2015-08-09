# Manifest to demo cisco patching capabilities
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class ciscopuppet::demo_patching {
  $repo = 'http://example.domain.com/repo'
  yumrepo { 'reponame' :
    name     => 'reponame',
    baseurl  => $repo,
    enabled  => 1,
    gpgcheck => 0,
  }

  # Handle differences between Native and Guestshell#

  case $::osfamily  {
    # TODO: 'RedHat' is no longer a value returned in the GS
    # by facter.  This needs to be updated to another value
    # once we identify one.
    'RedHat': {    # GuestShell
    $rpmMibSource = $repo

    # GS/Centos: systemd services
    $svcDemoTarget = '/usr/lib/systemd/system/demo-one.service'
    $svcDemoSource = 'puppet:///modules/ciscopuppet/demo-one.service'
    }

    'wrLinux':  {    # Native
    $rpmMibSource = $repo

    # Native/WRL: init.d services
      $svcDemoTarget = '/etc/init.d/demo-one'
      $svcDemoSource = 'puppet:///modules/ciscopuppet/demo-one.initd'
    }
    default:  { fail("## UNRECOGNIZED OSFAMILY: ${::osfamily}")
    }
  }

  #Use Case 1: install cisco package

  $rpmMib = "${rpmMibSource}/n9000_sample-1.0.0-7.0.3.x86_64.rpm"
  $settings = {'target' => 'host'}
  package { 'n9000_sample':
    ensure           => present,
    provider         => 'nxapi',
    source           => $rpmMib,
    package_settings => $settings,
  }

  #Use Case 2: install third party package:

  $rpmDemo = "${repo}/demo-one-1.0-1.x86_64.rpm"
  package { 'demo-one':
    ensure => present,
    source => $rpmDemo,
  }

  #Use Case 3: install and start a service locally

  file { $svcDemoTarget :
    ensure => file,
    source => $svcDemoSource,
    owner  => 'root',
    group  => root,
    mode   => 'ug+rwx',
  }

  service { 'demo-one':
    ensure => running,
  }
}
