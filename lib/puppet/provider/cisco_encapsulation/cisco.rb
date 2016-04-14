# The NXAPI provider for cisco encapsulation.
#
# March, 2016
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

Puppet::Type.type(:cisco_encapsulation).provide(:cisco) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  ENCAP_ARRAY_FLAT_PROPS = [:dot1q_map]
  ENCAP_ALL_PROPS = ENCAP_ARRAY_FLAT_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            ENCAP_ARRAY_FLAT_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::Encapsulation.encaps[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(encap, nu_obj)
    debug "Checking instance, encap #{encap}"
    current_state = {
      encap:  encap,
      name:   encap,
      ensure: :present,
    }

    # Call node_utils getter for each property
    ENCAP_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    encaps = []
    Cisco::Encapsulation.encaps.each do |encap, nu_obj|
      encaps << properties_get(encap, nu_obj)
    end
    encaps
  end

  def self.prefetch(resources)
    encaps = instances

    resources.keys.each do |id|
      provider = encaps.find { |encap| encap.instance_name == id }
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
    encap
  end

  def properties_set(new_encap=false)
    ENCAP_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_encap
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_encap = true
        @nu = Cisco::Encapsulation.new(@resource[:encap])
      end
      properties_set(new_encap)
    end
  end
end   # Puppet::Type
