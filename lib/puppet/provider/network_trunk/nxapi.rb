# The NXAPI provider for network_trunk
#
# November, 2015
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

Puppet::Type.type(:network_trunk).provide(:nxapi, parent: Puppet::Type.type(:cisco_interface).provider(:nxapi)) do
  @doc = 'network TRUNK'

  mk_resource_methods

  def self.instances
    interfaces = []
    Cisco::Interface.interfaces.each do |interface_name, i|
      if i.send(:switchport_mode) == :trunk
        interface = {
          interface:      interface_name,
          name:           interface_name,
          untagged_vlan:  i.send(:switchport_trunk_native_vlan),
          ensure:         :present,
        }
        interfaces << new(interface)
      end
    end
    interfaces
  end

  def flush
    if @property_flush[:ensure] == :absent
      @interface.destroy
      @interface = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty?
        @interface = Cisco::Interface.new(@resource[:interface])
      end
      @interface.switchport_mode = :trunk
      @interface.switchport_trunk_native_vlan = @resource[:untagged_vlan] if @resource[:untagged_vlan]
    end
  end

end
