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
Puppet::Type.type(:cisco_itd_service).provide(:cisco) do
  desc 'The Cisco provider for cisco_itd_service.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  ITDSERVICE_NON_BOOL_PROPS = [
    :access_list,
    :device_group,
    :exclude_access_list,
    :load_bal_buckets,
    :load_bal_mask_pos,
    :load_bal_method_bundle_hash,
    :load_bal_method_bundle_select,
    :load_bal_method_end_port,
    :load_bal_method_proto,
    :load_bal_method_start_port,
    :peer_local,
  ]
  ITDSERVICE_BOOL_PROPS = [
    :fail_action,
    :load_bal_enable,
    :nat_destination,
  ]
  # shutdown property is treated separately due to the ordering.
  # When shutdown goes from true to false, it needs to be set
  # after all the other properties are set. For all other cases,
  # shutdown needs to be set first before any other
  # properties are set. Basically, no properties cannot be
  # changed while the service is active.
  ITDSERVICE_SHUT_PROP = [
    :shutdown
  ]
  ITDSERVICE_ARRAY_FLAT_PROPS = [
    :ingress_interface,
    :peer_vdc,
    :virtual_ip,
  ]
  ITDSERVICE_ALL_PROPS = ITDSERVICE_NON_BOOL_PROPS +
                         ITDSERVICE_ARRAY_FLAT_PROPS + ITDSERVICE_BOOL_PROPS
  ITDSERVICE_ALL_BOOL_PROPS = ITDSERVICE_BOOL_PROPS + ITDSERVICE_SHUT_PROP

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            ITDSERVICE_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            ITDSERVICE_ARRAY_FLAT_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            ITDSERVICE_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            ITDSERVICE_SHUT_PROP)

  def initialize(value={})
    super(value)
    @nu = Cisco::ItdService.itds[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(itd_service_name, nu_obj)
    debug "Checking instance, #{itd_service_name}."
    current_state = {
      service_name: itd_service_name,
      name:         itd_service_name,
      ensure:       :present,
    }
    # Call node_utils getter for each property
    ITDSERVICE_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    ITDSERVICE_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    ITDSERVICE_ALL_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    # nested array properties
    current_state[:ingress_interface] = nu_obj.ingress_interface
    current_state[:peer_vdc] = nu_obj.peer_vdc
    current_state[:virtual_ip] = nu_obj.virtual_ip
    new(current_state)
  end # self.properties_get

  def self.instances
    itds = []
    Cisco::ItdService.itds.each do |itd_service_name, nu_obj|
      itds << properties_get(itd_service_name, nu_obj)
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
    service_name
  end

  def service_shutdown?
    cur_shut = @property_hash[:shutdown]
    next_shut = @resource[:shutdown]
    !(cur_shut == :false && (next_shut.nil? || next_shut == :true))
  end

  def all_prop_set(new_itd)
    ITDSERVICE_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_itd
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    load_balance_set
  end

  def shut_prop_set(new_itd)
    ITDSERVICE_SHUT_PROP.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_itd
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
  end

  def properties_set(new_itd=false)
    if new_itd || service_shutdown?
      all_prop_set(new_itd)
      shut_prop_set(new_itd)
    else
      shut_prop_set(new_itd)
      all_prop_set(new_itd)
    end
  end

  def ingress_interface=(should_list)
    should_list = @nu.default_ingress_interface if should_list[0] == :default
    @property_flush[:ingress_interface] = should_list
  end

  def peer_vdc=(should_list)
    should_list = @nu.default_peer_vdc if should_list[0] == :default
    @property_flush[:peer_vdc] = should_list
  end

  def virtual_ip=(should_list)
    should_list = @nu.default_virtual_ip if should_list[0] == :default
    @property_flush[:virtual_ip] = should_list
  end

  def load_balance_set
    attrs = {}
    vars = [
      :load_bal_buckets,
      :load_bal_mask_pos,
      :load_bal_method_bundle_hash,
      :load_bal_method_bundle_select,
      :load_bal_method_end_port,
      :load_bal_method_proto,
      :load_bal_method_start_port,
      :load_bal_enable,
    ]
    return unless vars.any? { |p| @property_flush.key?(p) }
    # At least one var has changed, get all vals from manifest
    vars.each do |p|
      if @resource[p] == :default
        attrs[p] = @nu.send("default_#{p}")
      else
        attrs[p] = @resource[p]
        attrs[p] = PuppetX::Cisco::Utils.bool_sym_to_s(attrs[p])
      end
    end
    @nu.load_balance_set(attrs)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_itd = true
        @nu = Cisco::ItdService.new(@resource[:service_name])
      end
      properties_set(new_itd)
    end
  end
end
