# Manifest to demo cisco patch rpm 
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

class ciscopuppet::cisco::demo_cisco_patch_rpm {

  # Sample rpm is only compatible with FCS release version 7.0(3)I2(1) image.
  $ciscoPatchName = 'n9000_sample-1.0.0-7.0.3.x86_64.rpm'
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
  package { 'n9000_sample':
    ensure           => present,
    provider         => 'nxapi',
    source           => $ciscoPatchFile,
    package_settings => $settings,
  }
}
