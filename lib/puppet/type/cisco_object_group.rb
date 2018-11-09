#
# Puppet resource type for cisco_object_group
#
# June 2018
#
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_object_group) do
  # ---------------------------------------------------------------
  # @doc entry to describe the resource and usage
  # ---------------------------------------------------------------
  @doc = "Manages configuration of an object_group instance

  ~~~puppet
  cisco_object_group {'<string>':
    ..attributes..
  }
  ~~~

  `<string>` is the name of the object_group instance.

  Example:

  ~~~puppet
    cisco_object_group { 'ipv4 port MyObjGrp1' :
      ensure          => present,
    }
  ~~~

  ~~~puppet
    cisco_object_group { 'ipv6 address MyObjGrp2' :
      ensure          => present,
    }
  ~~~
  "

  apply_to_all
  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse the title to populate the attributes in these patterns.
  # These attributes may be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(\S+)\s+(\S+)\s+(\S+)$/,
        [
          [:afi, identity],
          [:type, identity],
          [:grp_name, identity],
        ],
      ]
    ]
  end

  newparam(:afi, namevar: true) do
    desc 'The Address-Family Indentifier (ipv4|ipv6).'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:type, namevar: true) do
    desc 'Type of the object_group instance.'
    newvalues(:address, :port)
  end

  newparam(:grp_name, namevar: true) do
    desc 'Name of the object_group instance. Valid values are string.'
  end

  # Overwrites the name method which by default returns only self[:name].
  def name
    "#{self[:afi]} #{self[:type]} #{self[:grp_name]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end
end
