# October, 2015
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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
begin
  require 'puppet_x/cisco/autogen'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:network_interface).provide(:cisco) do
  @doc = 'network INTERFACE'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: [:nexus, :ios_xr]

  mk_resource_methods

  UNSUPPORTED_PROPS_IOS_XR = [:speed, :duplex]

  def initialize(value={})
    super(value)
    @interface = Cisco::Interface.interfaces[@property_hash[:name]]
    @property_flush = {}
  end

  def self.instances
    interfaces = []
    Cisco::Interface.interfaces.each do |interface_name, i|
      speed = convert_speed_to_type(i.send(:speed))
      interface = {
        interface:   interface_name,
        name:        interface_name,
        description: i.send(:description),
        mtu:         i.send(:mtu),
        speed:       speed,
        duplex:      i.send(:duplex),
        ensure:      :present,
      }
      interfaces << new(interface)
    end
    interfaces
  end

  def self.prefetch(resources)
    interfaces = instances

    resources.keys.each do |id|
      provider = interfaces.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def instance_name
    interface
  end

  def validate
    return unless Facter.value('operatingsystem').eql?('ios_xr')

    invalid = []
    UNSUPPORTED_PROPS_IOS_XR.each do |prop|
      invalid << prop if @resource[prop]
    end

    fail ArgumentError, "This provider does not support the following properties on this platform: #{invalid}" unless invalid.empty?
  end

  def flush
    validate

    if @property_flush[:ensure] == :absent
      @interface.destroy
      @interface = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty? || @interface.nil?
        @interface = Cisco::Interface.new(@resource[:name])
      end
      @interface.mtu = @resource[:mtu] if @resource[:mtu]
      @interface.description = @resource[:description] if @resource[:description]
      speed = convert_type_to_speed(@resource[:speed])
      @interface.speed = speed if @resource[:speed]
      @interface.duplex = @resource[:duplex] if @resource[:duplex]
    end
  end

  def convert_type_to_speed(type)
    case type.to_s
    when '100m' then 100
    when '1g' then 1000
    when '10g' then 10_000
    when '40g' then 40_000
    when '100g' then 1_000_000
    else type
    end
  end

  def self.convert_speed_to_type(speed)
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
