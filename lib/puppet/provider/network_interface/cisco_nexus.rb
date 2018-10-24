# Implementation for the network_interface type using the Resource API.
class Puppet::Provider::NetworkInterface::CiscoNexus
  def get(_context)
    require 'cisco_node_utils'
    current_state = []
    @interfaces ||= Cisco::Interface.interfaces
    @interfaces.each do |interface_name, interface|
      current_state << {
        name:        interface_name,
        description: interface.description,
        mtu:         interface.mtu,
        speed:       convert_speed_to_type(interface.speed),
        duplex:      interface.duplex,
        enable:      !interface.shutdown,
      }
    end
    current_state
  end

  def set(context, changes)
    changes.each do |name, change|
      update(context, name, change[:should]) if change[:should] != change[:is]
    end
  end

  def update(_context, name, should)
    @interfaces ||= Cisco::Interface.interfaces
    interface = @interfaces[name]

    interface.shutdown = !should[:enable] if should.key? :enable
    interface.mtu = should[:mtu] if should.key? :mtu
    interface.description = should[:description] if should.key? :description
    interface.speed = convert_type_to_speed(should[:speed]) if should.key? :speed
    interface.duplex = should[:duplex] if should.key? :duplex
  end

  def convert_type_to_speed(type)
    case type.to_s
    when '100m' then 100
    when '1g' then 1000
    when '10g' then 10_000
    when '40g' then 40_000
    when '100g' then 100_000
    else type
    end
  end

  def convert_speed_to_type(speed)
    case speed.to_s
    when '100' then '100m'
    when '1000' then '1g'
    when '10000' then '10g'
    when '40000' then '40g'
    when '100000' then '100g'
    else speed
    end
  end
end
