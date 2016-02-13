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
      next unless i.send(:switchport_mode) == :trunk
      array_vlans = convert_allowed_vlan_to_array(i.send(:switchport_trunk_allowed_vlan))
      interface = {
        interface:     interface_name,
        name:          interface_name,
        untagged_vlan: i.send(:switchport_trunk_native_vlan),
        tagged_vlans:  array_vlans,
        mode:          i.send(:switchport_mode),
        encapsulation: :dot1q,
        ensure:        :present,
      }
      interfaces << new(interface)
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
        @interface = Cisco::Interface.new(@resource[:name])
      end
      @interface.switchport_mode = :trunk
      @interface.switchport_trunk_native_vlan = @resource[:untagged_vlan] if @resource[:untagged_vlan]
      @interface.switchport_trunk_allowed_vlan = convert_array_to_allowed_vlan(@resource[:tagged_vlans]) if @resource[:tagged_vlans]
    end
  end

  # this converts from a cisco compatible comma separated range to an array of vlan_ids
  # better to give an examples of how this works:
  # 2-4,6-8 becomes [2,3,4,6,7,8]
  def self.convert_allowed_vlan_to_array(allowed_vlan)
    return_val = []
    array_strings = allowed_vlan.split(',')
    array_strings.each do |value|
      # is a range ?
      if value.include? '-'
        range = value.split('-')
        return_val.push(*(range.first..range.last).to_a)
      else
        return_val.push(value.to_i)
      end
    end
    return_val
  end

  # this converts from an array of vlan_ids to a cisco compatible comma separated range
  # better to give an examples, of how this works:
  # [2,3,4,6,7,8] becomes 2-4,6-8
  def convert_array_to_allowed_vlan(input)
    return_val = ''
    # take an array of vlan ids, and create an array  of ruby ranges
    ranges = input.sort.uniq.inject([]) do |spans, n|
      if spans.empty? || spans.last.last != n - 1
        spans + [n..n]
      else
        spans[0..-2] + [spans.last.first..n]
      end
    end
    # loop over ranges and create a string of cisco ranges
    ranges.each do |iter|
      if iter.size == 1
        return_val = return_val + iter.first.to_s + ','
      else
        return_val = return_val + iter.first.to_s + '-' + iter.last.to_s + ','
      end
    end
    return_val = return_val.chomp(',')
  end
end
