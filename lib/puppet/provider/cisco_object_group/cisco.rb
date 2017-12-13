# Copyright (c) 2017 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_object_group).provide(:cisco) do
  desc 'The Cisco provider for cisco_object_group.'

  confine feature: :cisco_node_utils

  mk_resource_methods

  def initialize(value={})
    super(value)
    afi = @property_hash[:afi]
    type = @property_hash[:type]
    grp_name = @property_hash[:grp_name]
    @nu = Cisco::ObjectGroup.object_groups[afi][type][grp_name] unless afi.nil?
    @property_flush = {}
  end

  def self.properties_get(afi, type, grp_name, _inst)
    current_state = {
      name:     "#{afi} #{type} #{grp_name}",
      afi:      afi,
      type:     type,
      grp_name: grp_name,
      ensure:   :present,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    instance_array = []
    Cisco::ObjectGroup.object_groups.each do |afi, types|
      types.each do |type, grp_names|
        grp_names.each do |grp_name, inst|
          begin
            instance_array << properties_get(afi, type, grp_name, inst)
          end
        end
      end
    end
    instance_array
  end # self.instances

  def self.prefetch(resources)
    instance_array = instances
    resources.keys.each do |name|
      provider = instance_array.find do |objgrp|
        objgrp.afi.to_s == resources[name][:afi].to_s &&
        objgrp.type.to_s == resources[name][:type].to_s &&
        objgrp.grp_name.to_s == resources[name][:grp_name].to_s
      end
      resources[name].provider = provider unless provider.nil?
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

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      if @nu.nil?
        # create new
        @nu = Cisco::ObjectGroup.new(@resource[:afi], @resource[:type], @resource[:grp_name])
      end
    end
  end
end
