# Manifest to demo cisco_encapsulation provider
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

class ciscopuppet::cisco::demo_encapsulation {
  if platform_get() =~ /n7k/ {
    cisco_encapsulation {"test_encap" :
      ensure          => present,
      dot1q_map       => ['101-102,151, 201-202', '5101-5104,5202'],
    }
  } else {
     notify{'SKIP: This platform does not support cisco_encapsulation': }
  }
}
