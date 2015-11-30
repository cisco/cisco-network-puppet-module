#
# Puppet resource type for X__RESOURCE_NAME__X
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

Puppet::Type.newtype(:cisco_X__RESOURCE_NAME__X) do
  # ---------------------------------------------------------------
  # STEP 1. Create a @doc entry to describe the resource and usage
  # ---------------------------------------------------------------
  @doc = "Manages configuration of a X__RESOURCE_NAME__X instance

  ```
  cisco_X__RESOURCE_NAME__X {'<string>':
    ..attributes..
  }
  ```

  `<string>` is the name of the X__RESOURCE_NAME__X instance.

  Example:

  ```
    cisco_X__RESOURCE_NAME__X { 'green' :
      ensure => present,
      # ---------------------------------------------------------------
      # STEP 2. Include an example of each property this resource will
      #         support, e.g.   shutdown => true
      # ---------------------------------------------------------------
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
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  newparam(:name, namevar: true) do
    desc 'Name of the X__RESOURCE_NAME__X instance. Valid values are string.'
  end

  # ---------------------------------------------------------------
  # STEP 3. Define any properties. Examples are shown.
  # ---------------------------------------------------------------

  # -------------------------
  # EXAMPLE. INTEGER PROPERTY
  # -------------------------
  newproperty(:X__PROPERTY_INT__X) do
    desc " xxxxxxxxx.  Valid values are integer, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'X__PROPERTY_INT__X must be a valid integer, or default.'
      end
      value
    end
  end

  # -------------------------
  # EXAMPLE. BOOLEAN PROPERTY
  # -------------------------
  newproperty(:X__PROPERTY_BOOL__X) do
    desc 'X__PROPERTY_BOOL__X state of the interface.'

    newvalues(:true, :false, :default)
  end
end
