# Manages the Cisco Hsrp Global configuration resource.
#
# June 2018
#
# Copyright (c) 2016-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_hsrp_global) do
  @doc = "
    Manages the Cisco Hsrp Global configuration resource.
    cisco_hsrp_global {'default':
      ..attributes..
    }
    'default' is only acceptable name for this global config object.

    Example:
    cisco_hsrp_global { 'default':
      bfd_all_intf           => true,
      extended_hold          => 200,
    }
  "

  apply_to_all

  ###################
  # Resource Naming #
  ###################

  newparam(:name, namevar: :true) do
    desc 'ID of the hsrp global config. Valid values are default.'

    validate do |inst_name|
      fail "only acceptable name is 'default'" if inst_name != 'default'
    end
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:bfd_all_intf) do
    desc 'Enables BFD for all HSRP sessions on all interfaces'

    newvalues(:true, :false, :default)
  end # property bfd_all_intf

  newproperty(:extended_hold) do
    desc "Configures extended hold on global timers. Valid values
          are integer, keyword 'default'"

    munge do |value|
      value = value.to_s
      value = :default if value == 'default'
      value
    end
  end # property extended_hold
end # Puppet::Type.newtype
