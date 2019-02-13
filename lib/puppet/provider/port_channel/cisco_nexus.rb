# Copyright (c) 2018 Cisco and/or its affiliates.
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
require 'puppet/resource_api/simple_provider'

# Implementation for the port_channel type using the Resource API.
class Puppet::Provider::PortChannel::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, channels=nil)
    require 'cisco_node_utils'

    interfaces = []
    @interfaces = Cisco::InterfaceChannelGroup.interfaces
    @interfaces.each do |interface_name, i|
      interface = {
        interface:     interface_name,
        channel_group: i.send(:channel_group),
      }
      interfaces.push(interface) if i.send(:channel_group)
    end

    portchannels = []
    @channels =  Cisco::InterfacePortChannel.interfaces
    if channels.nil? || channels.empty?
      @channels.each do |port_channel, port|
        portchannels << get_current_state(port_channel, port, interfaces)
      end
    else
      channels.each do |channel|
        individual_channel = @channels[channel]
        next if individual_channel.nil?
        portchannels << get_current_state(channel, individual_channel, interfaces)
      end
    end
    portchannels
  end

  def get_current_state(name, instance, interfaces)
    id_number = name[/\d+/].to_i
    interfaces_in_port = []

    interfaces.each do |interface|
      if interface[:channel_group] == id_number
        interfaces_in_port.push(interface[:interface])
      end
    end

    channel = {
      name:          name,
      minimum_links: instance.send(:lacp_min_links),
      id:            id_number,
      ensure:        'present',
    }
    unless interfaces_in_port.empty?
      channel[:interfaces] = interfaces_in_port
    end

    channel
  end

  def create_update(name, should, create_bool)
    port_channel = Cisco::InterfacePortChannel.new(name, create_bool)
    if should[:minimum_links]
      port_channel.lacp_min_links = should[:minimum_links]
    end
    return unless should[:interfaces]
    should[:interfaces].each do |i|
      interface = Cisco::InterfaceChannelGroup.interfaces[i]
      interface.channel_group_mode_set(should[:id]) if should[:id]
    end
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    create_update(name, should, true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    create_update(name, should, false)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    port_channel = Cisco::InterfacePortChannel.new(name, false)
    port_channel.destroy
  end
end
