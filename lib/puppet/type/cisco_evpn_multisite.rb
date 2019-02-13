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

Puppet::Type.newtype(:cisco_evpn_multisite) do
  @doc = %(Manages a Cisco Evpn Multisite.

  cisco_evpn_multisite {'<multisite>':
    ..attributes..
  }

  <multisite> is the Evpn Multisite Site-Id.

  Example:
    cisco_evpn_multisite {'100':
      ensure              => present,
      delay_restore       => '500',
    }
  )

  ##############
  # Parameters #
  ##############
  newparam(:multisite, namevar: true) do
    desc 'The Evpn Multisite id. Valid values are integer.'

    validate do |value|
      begin
        Integer(value)
      rescue
        raise 'multisite id must be an integer.'
      end
      value
    end
  end

  ##############
  # Attributes #
  ##############

  apply_to_all
  ensurable

  newproperty(:delay_restore) do
    desc 'Delay restore time in seconds. Valid values are Integer or default.'

    munge do |value|
      begin
        value = Integer(value) unless value == 'default'
      rescue
        raise 'delay_restore must be an Integer.'
      end # rescue
      value = :default if value == 'default'
      value
    end
  end # property delay_restore
end # Puppet::Type.newtype
