# Manifest to demo cisco_interface provider
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

class ciscopuppet::demo_portchannel_global {

  $asymmetric = platform_get() ? {
    'n7k'  => false,
    default => undef
  }

  $concatenation = platform_get() ? {
    'n3k'  => true,
    'n9k'  => true,
    default => undef
  }

  $hash_distribution = platform_get() ? {
    'n7k'  => 'adaptive',
    default => undef
  }

  $hash_poly = platform_get() ? {
    'n5k'  => 'CRC10c',
    'n6k'  => 'CRC10c',
    default => undef
  }

  $load_defer = platform_get() ? {
    'n7k'  => 100,
    default => undef
  }

  $resilient = platform_get() ? {
    'n3k'  => false,
    'n9k'  => false,
    default => undef
  }

  $rotate = platform_get() ? {
    'n3k'  => '4',
    'n7k'  => '4',
    'n9k'  => '4',
    default => undef
  }

  $symmetry = platform_get() ? {
    'n3k'  => false,
    'n9k'  => false,
    default => undef
  }

  cisco_portchannel_global { 'default':
    asymmetric        => $asymmetric,
    bundle_hash       => 'ip',
    bundle_select     => 'src-dst',
    concatenation     => $concatenation,
    hash_distribution => $hash_distribution,
    hash_poly         => $hash_poly,
    load_defer        => $load_defer,
    resilient         => $resilient,
    rotate            => $rotate,
    symmetry          => $symmetry,
  }
}
