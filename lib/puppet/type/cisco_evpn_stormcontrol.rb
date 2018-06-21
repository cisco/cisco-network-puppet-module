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

Puppet::Type.newtype(:cisco_evpn_stormcontrol) do
  @doc = %(Manages a Cisco Evpn stormcontrol level.

  cisco_evpn_stormcontrol {'<packet_type>':
    ..attributes..
  }

  <packet_type> is the type of packet like broadcast, unicast or multicast.

  Example:
    cisco_evpn_stormcontrol {'broadcast':
      ensure      => present,
      level       => '50',
    }
  )

  ##############
  # Parameters #
  ##############
  newparam(:packet_type, namevar: true) do
    desc "The packet type to apply stormcontol on. Valid values are 'unicast',
          'multicast' or 'broadcast'"
    validate do |packet_type|
      packet_type_list = %w(unicast broadcast multicast)
      fail 'only unicast, broadcast and multicast packets support
            stormcontrol' unless packet_type_list.include?(packet_type)
    end
  end

  ##############
  # Attributes #
  ##############

  apply_to_all
  ensurable

  newproperty(:level) do
    desc 'Stormcontrol level. Valid values are Integer.'

    munge do |value|
      begin
        value = Integer(value)
      rescue
        raise 'level must be an Integer.'
      end # rescue
      value
    end
  end # property level

  # VALIDATIONS
  validate do
    if self[:ensure] == :present
      fail('`level` is a required property when trying to configure
            stormcontrol.') if self[:level].nil?
    end
  end
end # Puppet::Type.newtype
