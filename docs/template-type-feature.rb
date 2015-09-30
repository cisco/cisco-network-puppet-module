#
# Puppet resource type for feature X__RESOURCE_NAME__X
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
  @doc = "Manages configuration of feature X__RESOURCE_NAME__X

  ```
  cisco_X__RESOURCE_NAME__X {'<title>':
    ..attributes..
  }
  ```

  Example:
  ```
    cisco_X__RESOURCE_NAME__X {'xxxxx' :
      ensure => present,
    }
  ```
  "

  ensurable

  newparam(:name, namevar: true) do
    desc 'Resource title. Valid values are string.'
  end

  # There are no additional properties for this command.
end
