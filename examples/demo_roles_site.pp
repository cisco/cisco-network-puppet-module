# Sample site.pp file for role based manifest.
#
# This manifest is designed to show the hierarchical manner in which
# puppet manifests can be constructed.
#
# This manifest can be used to assign roles to various switches in
# your network but is only intended as an example.  Use this as a
# guideline when building a manifest hierarchy for your network.
#
# Roles: (E) = Edge, (I) = Internal
#  
#            +------------+
#            | Role: (E)  |
#            +------------+
#             |          |
#             |          |
#   +------------+   +------------+
#   | Role: (I)  |   | Role: (I)  |
#   +------------+   +------------+
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

node 'n9k-edge-switch' {
  include ciscopuppet::demo_role::edge_switch
}

node 'n9k-internal-switch' {
  include ciscopuppet::demo_role::internal_switch
}

node 'n3k-internal-switch' {
  include ciscopuppet::demo_role::internal_switch
}

