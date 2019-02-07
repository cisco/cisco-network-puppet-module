# Manifest to demo cisco_upgrade
#
# Copyright (c) 2017 Cisco and/or its affiliates.
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

class ciscopuppet::cisco::demo_upgrade {

  # To use this manifest, make sure the gem and bin file are in the files directory under your
  # puppet module on the puppet master.

  # puppetmaster:files:2009> cd /etc/puppetlabs/code/environments/production/modules/ciscopuppet/files/
  # puppetmaster:files:2010> ls -lh
  # total 1.3G
  # -rw-r--r-- 1 root root 431K Mar  2 14:19 cisco_node_utils-1.6.0.gem
  # -rwxr-xr-- 1 root root 530M Mar  2 15:46 nxos.7.0.3.I2.5.bin
  # -rwxr-xr-- 1 root root 723M Mar  2 15:25 nxos.7.0.3.I5.1.bin
  # puppetmaster:files:2011>

  node 'certname' {
    $gem = 'cisco_node_utils-1.6.0.gem'
    $uri = 'bootflash'
    $image = 'nxos.7.0.3.I2.5.bin'

    # If you are behind proxy, please set the proxy variable.
    # $proxy = 'http://<proxy>.<domain>:<port>'
    $proxy = ''

    if $proxy == '' {
      $opts = {}
    }
    else {
      $opts = { '--http-proxy' => $proxy }
    }

    # If installing cisco_node_utils from local source
    #  file { "/${uri}/${gem}" :
    #   ensure => file,
    #   source => "puppet:///modules/ciscopuppet/${gem}",
    #   owner  => 'root',
    #   group  => 'root',
    #   mode   => 'ug+rwx',
    # }

    package { 'cisco_node_utils' :
      ensure          => present,
      provider        => 'gem',
      # source        => "/${uri}/${gem}",
      install_options => $opts,
    }

    file { "/${uri}/${image}" :
      ensure => file,
      source => "puppet:///modules/ciscopuppet/${image}",
      owner  => 'root',
      group  => 'root',
      mode   => 'ug+rwx',
    }

    cisco_upgrade { 'image' :
      package           => "${uri}:///${image}",
      force_upgrade     => false,
      delete_boot_image => false,
    }
  }
}
