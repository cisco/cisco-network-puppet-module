# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_pim_rp_address).provide(:cisco) do
  desc 'The Cisco provider for cisco_pim_rp_address.'

  confine feature: :cisco_node_utils

  mk_resource_methods

  PIM_RP_ADDRESS_ALL_PROPS = [
  ]

  # Dynamic method generation for getters & setters
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@pim_rps',
                                            PIM_RP_ADDRESS_ALL_PROPS)

  def initialize(value={})
    super(value)
    afi = @property_hash[:afi]
    vrf = @property_hash[:vrf]
    rp_addr = @property_hash[:rp_addr]
    @pim_rps = Cisco::PimRpAddress.rp_addresses[afi][vrf][rp_addr] unless afi.nil? && vrf.nil? && rp_addr.nil?
    @property_flush = {}
  end

  def self.properties_get(afi, vrf, rp_addr, inst)
    current_state = {
      name:    "#{afi} #{vrf} #{rp_addr}",
      afi:     afi,
      vrf:     vrf,
      rp_addr: rp_addr,
      ensure:  :present,
    }
    # Call node_utils getter for each property
    PIM_RP_ADDRESS_ALL_PROPS.each do |prop|
      current_state[prop] = inst.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    pim_rp_address_instances = []
    Cisco::PimRpAddress.rp_addresses.each do |afi, vrfs|
      vrfs.each do |vrf, rp_addrs|
        rp_addrs.each do |rp_addr, pim_rp_address_inst|
          pim_rp_address_instances << properties_get(afi, vrf, rp_addr, pim_rp_address_inst)
        end
      end
    end
    pim_rp_address_instances
  end # self.instances

  def self.prefetch(resources)
    pim_rp_address_instances = instances
    resources.keys.each do |name|
      provider = pim_rp_address_instances.find do |pim_rp_addr|
        pim_rp_addr.afi.to_s == resources[name][:afi].to_s &&
        pim_rp_addr.vrf == resources[name][:vrf] &&
        pim_rp_addr.rp_addr == resources[name][:rp_addr]
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

  def properties_set(new_pim_rp_addr_instance=false)
    PIM_RP_ADDRESS_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_pim_rp_addr_instance
      next if @property_flush[prop].nil?
      @pim_rps.send("#{prop}=", @property_flush[prop]) if
        @pim_rps.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @pim_rps.destroy
      @pim_rps = nil
    else
      if @pim_rps.nil?
        # create new
        new_pim_rp_addr_instance = true
        @pim_rps = Cisco::PimRpAddress.new(@resource[:afi], @resource[:vrf], @resource[:rp_addr])
      end
      properties_set(new_pim_rp_addr_instance)
    end
  end
end
