# Manifest to demo tcollector monitoring application 
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

class ciscopuppet::cisco::demo_tcollector {
  package { 'tcollector':
    ensure => present,
  }
  file { '/etc/sysconfig/tcollector' :
    ensure  => file,
    content => template('ciscopuppet/tcollector.conf.erb'),
    owner   => 'root',
    group   => root,
    mode    => 'ug+rwx',
  }
  service { 'tcollector':
    ensure => running,
  }
}
