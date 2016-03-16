#
# The Cisco provider for cisco_itd_device_group.
#
# March 2016
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
Puppet::Type.type(:cisco_itd_device_group).provide(:cisco) do
  desc 'The Cisco provider for cisco_itd_device_group.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  ITDDG_NON_BOOL_PROPS = [
    :probe_type,
    :probe_dns_host,
    :probe_frequency,
    :probe_port,
    :probe_retry_down,
    :probe_retry_up,
    :probe_timeout,
  ]
  ITDDG_BOOL_PROPS = [
    :probe_control
  ]
  ITDDG_ALL_PROPS = ITDDG_NON_BOOL_PROPS + ITDDG_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            ITDDG_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            ITDDG_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::ItdDeviceGroup.itds[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(itd_device_group_name, nu_obj)
    debug "Checking instance, #{itd_device_group_name}."
    current_state = {
      itddg:  itd_device_group_name,
      name:   itd_device_group_name,
      ensure: :present,
    }
    # Call node_utils getter for each property
    ITDDG_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end

    ITDDG_BOOL_PROPS.each do |prop|
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
    itds = []
    Cisco::ItdDeviceGroup.itds.each do |itd_device_group_name, nu_obj|
      itds << properties_get(itd_device_group_name, nu_obj)
    end
    itds
  end

  def self.prefetch(resources)
    itds = instances
    resources.keys.each do |name|
      provider = itds.find { |nu_obj| nu_obj.instance_name == name }
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

  def instance_name
    itddg
  end

  def properties_set(new_itd=false)
    ITDDG_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_itd
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    probe_set
  end

  # The following properties are setters and cannot be handled
  # by PuppetX::Cisco::AutoGen.mk_puppet_methods.
  def probe_set
    attrs = {}
    vars = [
      :probe_type,
      :probe_dns_host,
      :probe_frequency,
      :probe_port,
      :probe_retry_down,
      :probe_retry_up,
      :probe_timeout,
      :probe_control,
    ]
    if vars.any? { |p| @property_flush.key?(p) }
      # At least one var has changed, get all vals from manifest
      vars.each do |p|
        if @resource[p] == :default
          attrs[p] = @nu.send("default_#{p}")
        else
          attrs[p] = @resource[p]
          attrs[p] = PuppetX::Cisco::Utils.bool_sym_to_s(attrs[p])
        end
      end
    end
    return if attrs.empty?
    @nu.probe_set(attrs)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_itd = true
        @nu = Cisco::ItdDeviceGroup.new(@resource[:itddg])
      end
      properties_set(new_itd)
    end
  end
end
