# Manages a Cisco VRF.
#
# July 2015
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_vrf) do
  @doc = "Manages a Cisco VRF.
  ~~~puppet
  cisco_vrf {'<vrf>':
    ..attributes..
  }
  ~~~

  <vrf> is the complete name of the VRF.

  Example:
  ~~~puppet
    cisco_vrf {'red':
     ensure                       => present,
     shutdown                     => false,
     description                  => 'vrf red',
    }
  ~~~
  "

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = lambda { |x| x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ]
    ]
    return patterns
  end

  newparam(:name, :namevar => :true) do
    desc "Name of the VRF. Valid value is a string of non-whitespace 
          characters. It is not case-sensitive"
    munge { |value|
      value.downcase.strip
    }
  end # param name

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:description) do
    desc "Description of the VRF. Valid value is string."
  end # property description

  newproperty(:shutdown) do
    desc "Shutdown state of the VRF."
    newvalues(:true, :false)
  end # property shutdown

end # Puppet::Type.newtype

