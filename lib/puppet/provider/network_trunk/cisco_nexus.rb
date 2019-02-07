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

# Implementation for the network_trunk type using the Resource API.
class Puppet::Provider::NetworkTrunk::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    require 'cisco_node_utils'

    resources.each do |resource|
      resource[:tagged_vlans] = resource[:tagged_vlans].sort_by(&:to_i) if resource[:tagged_vlans]
    end
    resources
  end

  def get(_context, interface_names=nil)
    require 'cisco_node_utils'

    current_states = []
    @interfaces = Cisco::Interface.interfaces
    if interface_names.nil? || interface_names.empty?
      @interfaces.each do |interface_name, instance|
        get_interface(interface_name, instance, current_states)
      end
    else
      interface_names.each do |interface_name|
        get_interface(interface_name, @interfaces[interface_name], current_states)
      end
    end
    current_states
  end

  def get_interface(name, interface, current_states)
    return if interface.nil?
    return unless interface.send(:switchport_mode) == :trunk
    array_vlans = convert_allowed_vlan_to_array(interface.send(:switchport_trunk_allowed_vlan))
    current_states << {
      name:          name,
      untagged_vlan: interface.send(:switchport_trunk_native_vlan),
      tagged_vlans:  array_vlans.sort_by(&:to_i),
      mode:          'trunk',
      ensure:        'present',
    }
  end

  def update(context, name, should)
    validate_should(should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    @interfaces = Cisco::Interface.interfaces
    @interfaces[name].switchport_mode = should[:mode].to_sym if should[:mode]
    @interfaces[name].switchport_trunk_native_vlan = should[:untagged_vlan] if should[:untagged_vlan]
    @interfaces[name].switchport_trunk_allowed_vlan = convert_array_to_allowed_vlan(should[:tagged_vlans]) if should[:tagged_vlans]
  end

  alias create update

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @interfaces = Cisco::Interface.interfaces
    @interfaces[name].destroy
  end

  # based on running commands against a NX-OS 9k device only
  # 'access' and 'trunk' are supported switchport modes, and
  # controlling of encapsulation does not seem possible, and
  # there is no reference as to what pruned VLANS are with
  # no indication on how to set/control them
  def validate_should(should)
    raise Puppet::ResourceError, "The mode `#{should[:mode]}` is not supported" if should[:mode] && !['access', 'trunk'].include?(should[:mode])
    raise Puppet::ResourceError, 'VLAN-Tagging encapsulation is not supported on this device' if should[:encapsulation]
    raise Puppet::ResourceError, 'VLAN pruning is not supported on this device' if should[:pruned_vlans]
  end

  # this converts from a cisco compatible comma separated range to an array of vlan_ids
  # better to give an examples of how this works:
  # 2-4,6-8 becomes [2,3,4,6,7,8]
  def convert_allowed_vlan_to_array(allowed_vlan)
    return_val = []
    array_strings = allowed_vlan.split(',')
    array_strings.each do |value|
      # is a range ?
      if value.include? '-'
        range = value.split('-')
        return_val.push(*(range.first..range.last).to_a)
      else
        return_val.push(value)
      end
    end
    return_val.sort_by(&:to_i)
  end

  # this converts from an array of vlan_ids to a cisco compatible comma separated range
  # better to give an examples, of how this works:
  # [2,3,4,6,7,8] becomes 2-4,6-8
  def convert_array_to_allowed_vlan(input)
    # setting switchport_trunk_allowed_vlan to nil sets it to default range of 1-4094
    return nil if input.empty?
    return_val = ''
    # take an array of vlan ids, and create an array  of ruby ranges
    ranges = input.map(&:to_i).sort.uniq.reduce([]) do |spans, n|
      if spans.empty? || spans.last.last != n.to_i - 1
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
