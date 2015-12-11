#
# Puppet resource type for acl
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

Puppet::Type.newtype(:cisco_acl) do
  # ---------------------------------------------------------------
  # STEP 1. Create a @doc entry to describe the resource and usage
  # ---------------------------------------------------------------
  @doc = "Manages configuration of a acl instance

  ```
  cisco_acl {'<string>':
    ..attributes..
  }
  ```

  `<string>` is the name of the acl instance.

  Example:

  ```
    cisco_acl { 'ipv4 foo' :
      ensure => present,
      stats_per_entry => false,
      fragments => 'permit'
    }

  ```
  "

  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse the title to populate the attributes in these patterns.
  # These attributes may be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches the resource name.
    patterns << [
      /^(\S+)\s+(\S+)$/,
      [
        [:afi, identity],
        [:acl_name, identity]
      ],
    ]
    patterns
  end

  newparam(:afi) do
    desc 'Whether it ACL is ipv4 ACL or ipv6 ACL'
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
  # STEP 3. Define any properties.
  # ---------------------------------------------------------------

  newproperty(:stats_per_entry) do
    desc 'per-entry statistics enabled stats for the acl.'
    newvalues(:true, :false)
  end

  newproperty(:fragments) do
    desc 'fragments permit-all/deny-all state for the acl.'

    munge do |value|
      value = :default if value == 'default'
      value
    end

    #newvalues(:permit, :deny, :default)
  end
end
