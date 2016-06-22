# June, 2016
#
# Copyright (c) 2016 Cisco and/or its affiliates.
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end
Puppet::Type.type(:cisco_ospf_area).provide(:cisco) do
  desc 'The Cisco OSPF area provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  OSPF_AREA_NON_BOOL_PROPS = [
    :authentication,
    :default_cost,
    :filter_list_in,
    :filter_list_out,
    :nssa_route_map,
    :nssa_translate_type7,
  ]
  OSPF_AREA_BOOL_PROPS = [
    :nssa, # :nssa should process before other nssa properties
    :nssa_default_originate,
    :nssa_no_redistribution,
    :nssa_no_summary,
    :stub,
    :stub_no_summary,
  ]
  OSPF_AREA_ARRAY_NESTED_PROPS = [
    :range
  ]

  OSPF_AREA_ALL_PROPS = OSPF_AREA_BOOL_PROPS + OSPF_AREA_NON_BOOL_PROPS +
                        OSPF_AREA_ARRAY_NESTED_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            OSPF_AREA_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            OSPF_AREA_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_nested, self, '@nu',
                                            OSPF_AREA_ARRAY_NESTED_PROPS)

  def initialize(value={})
    super(value)
    ospf = @property_hash[:ospf]
    vrf = @property_hash[:vrf]
    area = @property_hash[:area]
    @nu = Cisco::RouterOspfArea.areas[ospf][vrf][area] unless
      ospf.nil? || vrf.nil? || area.nil?
    @property_flush = {}
  end

  def self.properties_get(ospf, vrf, area, nu_obj)
    debug "Checking ospf instance, #{ospf} #{vrf} #{area}"
    current_state = {
      name:   "#{ospf} #{vrf} #{area}",
      ospf:   ospf,
      vrf:    vrf,
      area:   area,
      ensure: :present,
    }
    # Call node_utils getter for each property
    (OSPF_AREA_NON_BOOL_PROPS + OSPF_AREA_ARRAY_NESTED_PROPS).each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    OSPF_AREA_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    area_instances = []
    Cisco::RouterOspfArea.areas.each do |ospf, vrfs|
      vrfs.each do |vrf, areas|
        areas.each do |area, nu_obj|
          area_instances << properties_get(ospf, vrf, area, nu_obj)
        end
      end
    end
    area_instances
  end # self.instances

  def self.prefetch(resources)
    area_instances = instances
    resources.keys.each do |id|
      provider = area_instances.find do |ai|
        ai.ospf.to_s == resources[id][:ospf].to_s &&
        ai.vrf.to_s == resources[id][:vrf].to_s &&
        ai.area.to_s == resources[id][:area].to_s
      end
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def instance_name
    name
  end

  def properties_set(new_area=false)
    OSPF_AREA_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_area
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    nssa_set
  end

  def nssa_set
    attrs = {}
    vars = [
      :nssa,
      :nssa_route_map,
      :nssa_default_originate,
      :nssa_no_redistribution,
      :nssa_no_summary,
    ]
    if vars.any? { |p| @property_flush.key?(p) }
      # At least one var has changed, get all vals from manifest
      vars.each do |p|
        val = @resource[p]
        if val == :default
          val = @nu.send("default_#{p}")
        else
          val = PuppetX::Cisco::Utils.bool_sym_to_s(val)
        end
        next if val == false || val.to_s.empty?
        attrs[p] = val
      end
    end
    @nu.nssa_set(attrs)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      new_area = false
      if @nu.nil?
        new_area = true
        @nu = Cisco::RouterOspfArea.new(@resource[:ospf], @resource[:vrf],
                                        @resource[:area])
      end
      properties_set(new_area)
    end
  end
end
