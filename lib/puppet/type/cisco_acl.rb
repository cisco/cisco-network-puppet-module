#
# Puppet resource type for cisco_acl
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

Puppet::Type.newtype(:cisco_acl) do
  # ---------------------------------------------------------------
  # @doc entry to describe the resource and usage
  # ---------------------------------------------------------------
  @doc = "Manages configuration of an acl instance

  ~~~puppet
  cisco_acl {'<string>':
    ..attributes..
  }
  ~~~

  `<string>` is the name of the acl instance.

  Example:

  ~~~puppet
    cisco_acl { 'ipv4 my_acl' :
      ensure          => present,
      stats_per_entry => false,
      fragments       => 'permit'
    }
  ~~~

  Example Title Patterns

  ~~~puppet
    cisco_acl { 'my_acl' :
      ensure          => present,
      afi             => 'ipv4',
    }
  ~~~

  ~~~puppet
    cisco_acl { 'ipv4' :
      ensure          => present,
      acl_name        => 'my_acl'
    }
  ~~~

  ~~~puppet
    cisco_acl { 'ipv4 my_acl' :
      ensure          => present,
    }
  ~~~
  "

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
        /^(ipv4|ipv6)$/,
        [
          [:afi, identity]
        ],
      ],
      [
        /^(\S+)\s+(\S+)$/,
        [
          [:afi, identity],
          [:acl_name, identity],
        ],
      ],
      [
        /^(\S+)$/,
        [
          [:acl_name, identity]
        ],
      ],
    ]
  end

  newparam(:afi, namevar: true) do
    desc 'The Address-Family Indentifier (ipv4|ipv6).'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:acl_name, namevar: true) do
    desc 'Name of the acl instance. Valid values are string.'
  end

  # Overwrites the name method which by default returns only self[:name].
  def name
    "#{self[:afi]} #{self[:acl_name]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  # ---------------------------------------------------------------
  # Definition of properties.
  # ---------------------------------------------------------------

  newproperty(:stats_per_entry) do
    desc 'Enable per-entry statistics for the acl.'
    newvalues(:true, :false)
  end

  newproperty(:fragments) do
    desc 'fragments permit-all/deny-all state for the acl.'

    newvalues(:permit, :deny, :default)
    munge do |value|
      "#{value}-all" unless /default/.match(value)
    end
  end
end
