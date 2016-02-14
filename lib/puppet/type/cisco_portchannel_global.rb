# Manages the Cisco PortChannel Global configuration resource.
#
# Dec 2015
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_portchannel_global) do
  @doc = "
    Manages the Cisco PortChannel Global configuration resource.
    cisco_portchannel_global {'default':
      ..attributes..
    }
    'default' is only acceptable name for this global config object.
    Example:
    cisco_portchannel_global { 'default':
      asymmetric                     => 'true',
      bundle_hash                    => 'ip',
      bundle_select                  => 'dst',
      concatenation                  => 'false',
      hash_distribution              => 'adaptive',
      hash_poly                      => 'CRC10a',
      load_defer                     => '1000',
      resilient                      => 'true',
      rotate                         => '10',
      symmetry                       => 'true',
    }
  "
  ###################
  # Resource Naming #
  ###################

  newparam(:name, namevar: :true) do
    desc 'ID of the portchannel global config. Valid values are default.'

    validate do |inst_name|
      fail "only acceptable name is 'default'" if inst_name != 'default'
    end
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:asymmetric) do
    desc 'Asymmetric hash.'

    newvalues(:true, :false, :default)
  end # property asymmetric

  newproperty(:bundle_hash) do
    desc 'Bundle hash'

    newvalues(:default, :ip, :'ip-l4port', :'ip-l4port-vlan',
              :'ip-vlan', :l4port, :mac, :port, :'ip-only', :'port-only',
              :'ip-gre')
  end # property bundle_hash

  newproperty(:bundle_select) do
    desc 'Bundle select'

    newvalues(:default, :src, :dst, :'src-dst')
  end # property bundle_select

  newproperty(:concatenation) do
    desc 'Enable/disable concatenation'

    newvalues(:true, :false, :default)
  end # property concatenation

  newproperty(:hash_distribution) do
    desc 'port-channel hash-distribution.'

    newvalues(:adaptive, :fixed, :default)
  end # property hash_distribution

  newproperty(:hash_poly) do
    desc 'port-channel hash-polynomial.'

    newvalues(:CRC10a, :CRC10b, :CRC10c, :CRC10d, :default)
  end # property hash_poly

  newproperty(:load_defer) do
    desc 'Load defer time interval'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'load_defer must be a valid integer, or default.'
      end
      value
    end
  end # property load_defer

  newproperty(:resilient) do
    desc 'Resilient mode.'

    newvalues(:true, :false, :default)
  end # property resilient

  newproperty(:rotate) do
    desc 'Offset the hash-input'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'rotate must be a valid integer, or default.'
      end
      value
    end
  end # property rotate

  newproperty(:symmetry) do
    desc 'Symmetric load balancing'

    newvalues(:true, :false, :default)
  end # property symmetry
end # Puppet::Type.newtype
