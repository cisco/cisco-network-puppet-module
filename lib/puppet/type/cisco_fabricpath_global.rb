# Manages the Cisco Fabricpath Global configuration resource.
#
# April 2013
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

Puppet::Type.newtype(:cisco_fabricpath_global) do
  @doc = %q(
    Manages the Cisco Fabricpath Global configuration resource.

    cisco_fabricpath_global {"default":
      ..attributes..
    }

    "default" is only acceptable name for this global config object.

    Example:
    cisco_fabricpath_global { "default":
      ensure                         => 'present',
      aggregate_multicast_routes     => false,
      allocate_delay                 => 10,
      graceful_merge                 => enable,
      linkup_delay                   => 10,
      linkup_delay_enable            => true,
      linkup_delay_always            => false,
      loadbalance_multicast_rotate   => 4,
      loadbalance_multicast_has_vlan => true,
      loadbalance_unicast_layer      => "mixed",
      loadbalance_unicast_has_vlan   => true,
      loadbalance_unicast_rotate     => 10,
      mode                           => "normal",
      switch_id                      => 25,
      transition_delay               => 10,
      ttl_unicast                    => 32,
      ttl_multicast                  => 32,
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
      /^(\S+)$/,
      [
        [:name, identity],
      ],
    ]
    patterns
  end

  newparam(:name, namevar: true) do
    desc 'ID of the fabricpath global config. Valid values are default.'

    validate do |inst_name|
      fail "only acceptable name is 'default'" if inst_name != 'default'
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:aggregate_multicast_routes) do
    desc 'Aggregate Multicast Routes on same tree in the topology.
          Valid values are true/false'
    newvalues(:true, :false, :default)
  end

  newproperty(:allocate_delay) do
    desc 'Fabricpath Timers Allocate Delay. Valid values are Integer from
          1..1200 seconds or default'
    validate do |value|
      if value != 'default'
        fail('allocate_delay should be a value in the range 1..1200') unless
          value.to_i.between?(1, 1200)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property allocate_delay

  newproperty(:graceful_merge) do
    desc 'Graceful merge for conflicting switch-id or FTAG allocation.
          Valid values are enable/disable'
    newvalues(:enable, :disable, :default)
  end

  newproperty(:linkup_delay) do
    desc 'Fabricpath Timers Link-up Delay. Valid values are Integer from
          1..1200 seconds or string default'
    validate do |value|
      if value != 'default'
        fail('linkup should be a value in the range 1..1200') unless
          value.to_i.between?(1, 1200)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property linkup_delay

  newproperty(:loadbalance_multicast_has_vlan) do
    desc 'Multicast Loadbalance flow parameters includes vlan or not.
          Valid values are true or false'
    newvalues(:true, :false, :default)
  end # property

  newproperty(:loadbalance_multicast_rotate) do
    desc 'Multicast Loadbalance flow parameters: rotate amount in bytes .
          Valid values are Integer in range 0..15'
    validate do |value|
      if value != 'default'
        fail('rotate amount should be a value in the range 0..15') unless
          value.to_i.between?(0, 15)
      end
    end
    munge { |value| value == 'default' ? :default : value }
  end # loadbalance_multicast_rotate

  newproperty(:loadbalance_unicast_has_vlan) do
    desc 'Unicast Loadbalance flow parameters includes vlan or not.
          Valid values are true or false'
    newvalues(:true, :false, :default)
  end # property

  newproperty(:loadbalance_unicast_layer) do
    desc 'Unicast Loadbalance flow parameters layer.
          Valid values string'
    newvalues('default',
              'layer2',
              'layer3',
              'layer4',
              'mixed')
    munge { |value| value == 'default' ? :default : value }
  end # property

  newproperty(:loadbalance_unicast_rotate) do
    desc 'Multicast Loadbalance flow parameters: rotate amount in bytes .
          Valid values are Integer in range 0..15'
    validate do |value|
      if value != 'default'
        fail('rotate amount should be a value in the range 0..15') unless
          value.between?(0, 15)
      end
    end
    munge { |value| value == 'default' ? :default : value }
  end # loadbalance_unicast_rotate

  newproperty(:linkup_delay_always) do
    desc 'Fabricpath Timers Link-up delay always. Valid values are true/false'
    newvalues(:true, :false, :default)
  end

  newproperty(:linkup_delay_enable) do
    desc 'Fabricpath Timers Link-up delay enable. Valid values are true/false'
    newvalues(:true, :false, :default)
  end

  newproperty(:mode) do
    desc 'Mode of operation w.r.t to segmentation.
          Valid values are normal/transit'
    newvalues(:normal, :transit, :default)
  end

  newproperty(:switch_id) do
    desc 'The fabricpath switch_id. Valid values are Integer from 1..4094'

    validate do |value|
      fail('Switch ID should be a value in the range 1..4094') unless
        value.to_i.between?(1, 4094)
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property name

  newproperty(:transition_delay) do
    desc 'Fabricpath Timers Transition Delay. Valid values are Integer from
          1..1200 seconds or default'
    validate do |value|
      if value != 'default'
        fail('allocate_delay should be a value in the range 1..1200') unless
          value.to_i.between?(1, 1200)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property transition_delay

  newproperty(:ttl_multicast) do
    desc 'Fabricpath Multicast TTL value. Valid values are Integer from 1..64
          or string default'
    validate do |value|
      if value != 'default'
        fail('TTL should be a value in the range 1..64') unless
          value.to_i.between?(1, 64)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property ttl_multicast

  newproperty(:ttl_unicast) do
    desc 'Fabricpath Unicast TTL value. Valid values are Integer from 1..64
          or default'
    validate do |value|
      if value != 'default'
        fail('TTL should be a value in the range 1..64') unless
          value.to_i.between?(1, 64)
      end
    end
    munge { |value| value == 'default' ? :default : value.to_i }
  end # property ttl_unicast
end # Puppet::Type.newtype
