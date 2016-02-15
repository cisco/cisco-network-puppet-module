# The NXAPI provider for network_interface
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

Puppet::Type.type(:port_channel).provide(:nxapi, parent: Puppet::Type.type(:cisco_interface_portchannel).provider(:nxapi)) do
  @doc = 'port channel'

  mk_resource_methods

  def self.instances
    interfaces = []
    Cisco::InterfaceChannelGroup.interfaces.each do |interface_name, i|
      interface = {
        interface:     interface_name,
        channel_group: i.send(:channel_group),
      }
      interfaces.push(interface) if i.send(:channel_group)
    end
    portchannels = []
    Cisco::InterfacePortChannel.interfaces.each do |port_channel, p|
      id_number = port_channel[/\d+/].to_i
      interfaces_in_port = []

      interfaces.each do |interface|
        if interface[:channel_group] == id_number
          interfaces_in_port.push(interface[:interface])
        end
      end
      portchannel = {
        name:          port_channel,
        interface:     port_channel,
        minimum_links: p.send(:lacp_min_links),
        id:            id_number,
        interfaces:    interfaces_in_port,
        ensure:        :present,
      }
      portchannels << new(portchannel)
    end
    portchannels
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty?
        @nu = Cisco::InterfacePortChannel.new(@resource[:name])
      end
      @nu.lacp_min_links = @resource[:minimum_links] if @resource[:minimum_links]
      # loop through interfaces
      if @resource[:interfaces]
        @resource[:interfaces].each do |i|
          bla = Cisco::InterfaceChannelGroup.interfaces[i]
          bla.channel_group = @resource[:id] if @resource[:id]
        end
      end
    end
  end
end
