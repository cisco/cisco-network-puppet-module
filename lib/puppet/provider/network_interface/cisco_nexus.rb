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
# Implementation for the network_interface type using the Resource API.
class Puppet::Provider::NetworkInterface::CiscoNexus
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, interfaces=nil)
    require 'cisco_node_utils'
    current_state = []
    @interfaces = Cisco::Interface.interfaces

    if interfaces.nil? || interfaces.empty?
      @interfaces.each do |interface_name, interface|
        current_state << get_current_state(interface_name, interface)
      end
    else
      interfaces.each do |interface|
        individual_interface = @interfaces[interface]
        next if individual_interface.nil?
        current_state << get_current_state(interface, individual_interface)
      end
    end
    current_state
  end

  def get_current_state(name, interface)
    {
      name:        name,
      description: interface.description,
      mtu:         interface.mtu,
      speed:       convert_speed_to_type(interface.speed),
      duplex:      interface.duplex,
      enable:      !interface.shutdown,
    }
  end

  def set(context, changes)
    changes.each do |name, change|
      update(context, name, change[:should]) if change[:should] != change[:is]
    end
  end

  def update(_context, name, should)
    @interfaces = Cisco::Interface.interfaces
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
