require 'puppet/resource_api/simple_provider'
require 'cisco_node_utils'

# Implementation for the port_channel type using the Resource API.
class Puppet::Provider::PortChannel::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context)
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
        minimum_links: p.send(:lacp_min_links),
        id:            id_number,
        ensure:        'present',
      }
      if !interfaces_in_port.empty?
        portchannel[:interfaces] = interfaces_in_port
      end
      portchannels << portchannel
    end
    portchannels
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
