# Manifest to demo cisco_encapsulation provider
#
# Copyright (c) 2016 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class ciscopuppet::cisco::demo_encapsulation {
  cisco_encapsulation {"PepsiCo" :
    ensure          => present,
    dot1q_map       => ['101-150,151, 201-250', '9000, 5102-5150,6000,7000-7050'],
  }
}
