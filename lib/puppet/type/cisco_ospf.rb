# Manages configuration for an ospf instance
#
# March 2014
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

Puppet::Type.newtype(:cisco_ospf) do
  @doc = "Manages configuration of an ospf instance

  cisco_ospf {\"<ospf>\":
    ..attributes..
  }

  <ospf> is the name of the ospf router instance.

  Example:
    cisco_ospf {\"green\" :
      ensure => present,
    }"

  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches the ospf name.
    patterns << [
      /^(\S+)$/,
      [
        [:ospf, identity]
      ],
    ]
    patterns
  end

  newparam(:ospf, namevar: true) do
    desc 'Name of the ospf router. Valid values are string.'
  end
end
