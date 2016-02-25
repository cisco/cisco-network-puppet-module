# The NXAPI provider for network_vlan
#
# October, 2015
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

Puppet::Type.type(:network_vlan).provide(:nxapi, parent: Puppet::Type.type(:cisco_vlan).provider(:nxapi)) do
  @doc = 'cisco VLAN'

  mk_resource_methods

  def self.instances
    vlans = []
    Cisco::Vlan.vlans.each do |vlan_id, v|
      vlan = {
        name:      vlan_id,
        ensure:    :present,
        vlan_name: v.send(:vlan_name),
        shutdown:  v.send(:shutdown),
      }
      vlans << new(vlan)
    end
    vlans
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vlan.destroy
      @vlan = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty?
        # create a new vlan
        @vlan = Cisco::Vlan.new(@resource[:id])
        @property_hash[:ensure] = :present
      end
      # modify vlan properties
      if @resource[:shutdown]
        shutdown = false
        shutdown = true if @resource[:shutdown] == :true
        @vlan.shutdown = shutdown if @vlan.shutdown != shutdown
      end
      @vlan.vlan_name = @resource[:vlan_name] if @resource[:vlan_name] && @vlan.vlan_name != @resource[:vlan_name]
    end
  end
end
