# Manages a Cisco Hsrp Interface.
#
# October 2016
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

Puppet::Type.newtype(:cisco_interface_hsrp) do
  @doc = %q(
    "Manages a Cisco Hsrp Interface.

     cisco_interface_hsrp {\"<interface>\":
       ..attributes..
     }

     <interface> is the complete name of the interface.

     Example:
     cisco_interface_hsrp {"port-channel100":
       ensure        => 'present',
       bfd           => true,
       delay_minimum => 222,
       delay_reload  => 10,
       mac_refresh   => 555,
       use_bia       => 'use_bia',
       version       => 2,
     }
  )

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
      /^(\S+)/,
      [
        [:interface, identity]
      ],
    ]
    patterns
  end

  newparam(:interface, namevar: :true) do
    desc 'Name of the interface on the network element. Valid values are string.'

    munge(&:downcase)
  end # param name

  #######################################
  # Attributes #
  #######################################

  ensurable

  newproperty(:bfd) do
    desc 'Enable BFD on this interface.'

    newvalues(:true, :false, :default)
  end # property bfd

  newproperty(:delay_minimum) do
    desc "Hsrp intialization minimim delay in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property delay_minimum

  newproperty(:delay_reload) do
    desc "Hsrp intialization delay after reload in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property delay_reload

  newproperty(:mac_refresh) do
    desc "Hsrp mac refresh time in sec. Valid values are
          integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property mac_refresh

  newproperty(:use_bia) do
    desc 'Use interface burned in address'

    newvalues(:use_bia, :use_bia_intf, :default)
  end # property use_bia

  newproperty(:version) do
    desc "Hsrp version. Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property version
end
