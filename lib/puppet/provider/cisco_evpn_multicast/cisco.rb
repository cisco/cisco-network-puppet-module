# February, 2018
#
# Copyright (c) 2018-2019 Cisco and/or its affiliates.
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

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_evpn_multicast).provide(:cisco) do
  desc 'The Cisco provider for cisco evpn multicast'

  confine feature: :cisco_node_utils

  mk_resource_methods

  def initialize(value={})
    super(value)
    @nu = Cisco::EvpnMulticast.new
    @property_flush = {}
  end # initialize

  def self.properties_get(nu_obj)
    current_state = {
      name:          'default',
      ensure:        :present,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    inst = []
    evpn_multicast = Cisco::EvpnMulticast.new
    inst << properties_get(evpn_multicast)
    inst
  end # self.instances

  def self.prefetch(resources)
    resources.values.first.provider = instances.first unless instances.first.nil?
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
        @nu = Cisco::EvpnMulticast.new
    end
  end
end # Puppet::Type
