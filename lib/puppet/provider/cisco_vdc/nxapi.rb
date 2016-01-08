#
# The NXAPI provider for cisco_vdc
#
# January 2016, Chris Van Heuveln
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

Puppet::Type.type(:cisco_vdc).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  # NOTE: For maintainability please keep this list in alphabetical order.
  VDC_NON_BOOL_PROPS = [
    :limit_resource_module_type
  ]
  VDC_BOOL_PROPS = []

  VDC_ALL_PROPS = VDC_NON_BOOL_PROPS + VDC_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            VDC_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            VDC_BOOL_PROPS)
  def initialize(value={})
    super(value)
    @nu = Cisco::Vdc.vdcs[@property_hash[:name]] unless @property_hash[:name].nil?
    @property_flush = {}
  end

  def self.properties_get(name, nu_obj)
    current_state = {
      name:   name,
      ensure: :present,
    }
    # Call node_utils getter for every property
    VDC_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    VDC_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      current_state[prop] = val.nil? ? nil : val.to_s.to_sym
    end
    new(current_state)
  end

  def self.instances
    all_vdcs = []
    Cisco::Vdc.vdcs.each do |name, nu_obj|
      all_vdcs << properties_get(name, nu_obj)
    end
    all_vdcs
  end

  def self.prefetch(resources)
    all_vdcs = instances
    resources.keys.each do |name|
      provider = all_vdcs.find do |vdc|
        # The manifest may specify the actual vdc name or just 'default'
        vdc.name == name ||
        (name == 'default' && vdc.name == Cisco::Vdc.default_vdc_name)
      end
      resources[name].provider = provider unless provider.nil?
    end
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def properties_set(new_vdc=false)
    VDC_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      if new_vdc
        # Set @property_flush for the current object
        send("#{prop}=", @resource[prop])
      end
      next if @property_flush[prop].nil?
      # Call the AutoGen setters for the @nu node_utils object.
      @nu.send("#{prop}=", @property_flush[prop]) if
        @nu.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      if @nu.nil?
        new_vdc = true
        @nu = Cisco::Vdc.new(@resource[:name])
      end
      properties_set(new_vdc)
    end
  end
end
