# Manages a Cisco Network Interface Service VNI
#
# January 2016
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

Puppet::Type.newtype(:cisco_interface_service_vni) do
  @doc = "Manages a Cisco Network Interface Service VNI.

  cisco_interface_service_vni_vni {'<interface> <service_id>':
    ..attributes..
  }

  <interface> is the complete name of the interface.
  <service_id> is the VNI service instance ID

  Example:
    cisco_interface_service_vni {'ethernet1/1 214':
     shutdown                     => false,
     encapsulation_profile_vni    => 'vni_500_5000',
    }

    cisco_interface_service_vni {'ethernet1/9 4022':
     shutdown                     => false,
     encapsulation_profile_vni    => 'vni_700_7000',
    }
  "

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)\s+(\S+)/,
      [
        [:interface, identity],
        [:sid, identity],
      ],
    ]
    patterns
  end

  ensurable

  # Overwrites the name method which by default returns only self[:name]
  def name
    "#{self[:interface]} #{self[:sid]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of the interface. Valid values are type String.'
    munge(&:downcase)
  end # param name

  newparam(:sid, namevar: :true) do
    desc 'The service ID number. Valid values are type Integer.'
    munge(&:downcase)
  end # param sid

  #######################################
  #                Attributes           #
  #######################################

  newproperty(:encapsulation_profile_vni) do
    desc 'The VNI Encapsulation Profile Name. Valid values are String or'\
         "keyword 'default'"
    munge { |value| value == 'default' ? :default : value }
  end # encapsulation_profile_vni

  newproperty(:shutdown) do
    desc 'Shutdown state of the interface service.'

    newvalues(:true, :false, :default)
  end # property shutdown
end # Puppet::Type.newtype
