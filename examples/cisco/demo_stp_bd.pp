# Manifest to demo cisco_interface provider
#
# Copyright (c) 2016 Cisco and/or its affiliates.
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

class ciscopuppet::cisco::demo_stp_bd {

  $bd_designated_priority = platform_get() ? {
    'n7k' => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    default => undef
  }

  $bd_forward_time = platform_get() ? {
    'n7k' => [['2-42', '26'], ['83-92,1000-2300', '20']],
    default => undef
  }

  $bd_hello_time = platform_get() ? {
    'n7k' => [['2-42', '6'], ['83-92,1000-2300', '9']],
    default => undef
  }

  $bd_max_age = platform_get() ? {
    'n7k' => [['2-42', '26'], ['83-92,1000-2300', '21']],
    default => undef
  }

  $bd_priority = platform_get() ? {
    'n7k' => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    default => undef
  }

  $bd_root_priority = platform_get() ? {
    'n7k' => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
    default => undef
  }

  $sys_bd_cmd = platform_get() ? {
    'n7k'  => 'system bridge-domain all',
    default => undef
  }

  cisco_command_config { 'system-bd-all':
    command => $sys_bd_cmd,
  }

  cisco_stp_global { 'default':
    bd_designated_priority => $bd_designated_priority,
    bd_forward_time        => $bd_forward_time,
    bd_hello_time          => $bd_hello_time,
    bd_max_age             => $bd_max_age,
    bd_priority            => $bd_priority,
    bd_root_priority       => $bd_root_priority,
  }
}
