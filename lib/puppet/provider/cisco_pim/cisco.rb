#
# The NXAPI provider for cisco_pim.
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_pim).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_pim.'

  confine feature: :cisco_node_utils

  mk_resource_methods

  PIM_NON_BOOL_PROPS = [
    :ssm_range
  ]

  PIM_BOOL_PROPS = [
  ]

  PIM_ALL_PROPS = PIM_NON_BOOL_PROPS + PIM_BOOL_PROPS

  # Dynamic method generation for getters & setters
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@pim',
                                            PIM_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@pim',
                                            PIM_BOOL_PROPS)

  def initialize(value={})
    super(value)
    afi = @property_hash[:afi]
    vrf = @property_hash[:vrf]
    @pim = Cisco::Pim.pims[afi][vrf] unless afi.nil? && vrf.nil?
    @property_flush = {}
  end

  def self.properties_get(afi, vrf, inst)
    current_state = {
      name:   "#{afi} #{vrf}",
      afi:    afi,
      vrf:    vrf,
      ensure: :present,
    }
    # Call node_utils getter for each property
    PIM_ALL_PROPS.each do |prop|
      current_state[prop] = inst.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    return [] unless Cisco::Pim.feature_enabled
    pim_instances = []
    Cisco::Pim.pims.each do |afi, vrfs|
      vrfs.each do |vrf, pim_inst|
        pim_instances << properties_get(afi, vrf, pim_inst)
      end
    end
    pim_instances
  end # self.instances

  def self.prefetch(resources)
    pim_instances = instances
    resources.keys.each do |name|
      provider = pim_instances.find do |pim|
        pim.afi.to_s == resources[name][:afi].to_s &&
        pim.vrf == resources[name][:vrf]
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

  def properties_set(new_pim_instance=false)
    PIM_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_pim_instance
      next if @property_flush[prop].nil?
      @pim.send("#{prop}=", @property_flush[prop]) if
        @pim.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @pim.destroy
      @pim = nil
    else
      if @pim.nil?
        # create new
        new_pim_instance = true
        @pim = Cisco::Pim.new(@resource[:afi], @resource[:vrf])
      end
      properties_set(new_pim_instance)
    end
  end
end
