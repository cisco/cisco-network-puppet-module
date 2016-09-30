# Manifest to demo cisco patching capabilities
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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

# To apply this demo_patching manifest first you must setup your own local
# repository and replace the '<>' markers with your local repo information.

class ciscopuppet::cisco::demo_patching {

  # Handle differences between Native and Guestshell#

  case $::osfamily  {
    'RedHat': {    # GuestShell
      # GS/Centos: systemd services
      $svcDemoTarget = '/usr/lib/systemd/system/demo-one.service'
      $svcDemoSource = 'puppet:///modules/ciscopuppet/demo-one.service'
    }
    'cisco-wrlinux':  {    # Native
      # Native/WRL: init.d services
      $svcDemoTarget = '/etc/init.d/demo-one'
      $svcDemoSource = 'puppet:///modules/ciscopuppet/demo-one.initd'
    }
    default:  { fail("## UNRECOGNIZED OSFAMILY: ${::osfamily}")
    }
  }

  #Use Case 1: install cisco package

  # Sample rpm is only compatible with the following FCS release versions:
  # - 7.0(3)I2(1)
  # - 7.0(3)I3(1)
  $image_ver = $::os['release']['full'] 
  case $image_ver {
    '7.0(3)I2(1)': {
      $ciscoPatchName = 'n9000_sample-1.0.0-7.0.3.x86_64.rpm'
      $ciscoPackageName = 'n9000_sample'
    }
    '7.0(3)I3(1)': {
      $ciscoPatchName = 'CSCuxdublin-1.0.0-7.0.3.I3.1.lib32_n9000.rpm'
      $ciscoPackageName = 'CSCuxdublin'
    }
    '7.0(3)I4(1)': {
      $ciscoPatchName = 'nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.1.lib32_n9000.rpm'
      $ciscoPackageName = 'nxos.sample-n9k_EOR'
    }
    default:  { fail("\n## NO COMPATIBLE SAMPLE PATCH RPMs AVAILABLE FOR THIS IMAGE: ${image_ver}\n")
    }
  }
  $ciscoPatchSource = "puppet:///modules/ciscopuppet/${ciscoPatchName}"
  $ciscoPatchFile = "/bootflash/${ciscoPatchName}"

  file { $ciscoPatchFile :
    ensure => file,
    source => $ciscoPatchSource,
    owner  => 'root',
    group  => 'root',
    mode   => 'ug+rwx',
  }

  $settings = {'target' => 'host'}
  package { $ciscoPackageName :
    ensure           => present,
    provider         => 'cisco',
    source           => $ciscoPatchFile,
    package_settings => $settings,
  }

  #Use Case 2: install third party package and
  #  start the service:

  #To install third party packages uncomment the
  #following and replace the '<>' markers with
  #your information.

  # $repo = '<>'
  # yumrepo { '<>' :
  #   name     => '<>',
  #   baseurl  => $repo,
  #   enabled  => 1,
  #   gpgcheck => 0,
  # }
  #
  # $rpmDemo = "${repo}/<thirdParty.rpm>"
  # package { 'thirdParty':
  #   ensure => present,
  #   source => $rpmDemo,
  # }
  #
  # file { $svcDemoTarget :
  #   ensure => file,
  #   source => $svcDemoSource,
  #   owner  => 'root',
  #   group  => root,
  #   mode   => 'ug+rwx',
  # }
  #
  # service { 'thirdParty':
  #   ensure => running,
  #}
}
