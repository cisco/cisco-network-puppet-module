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
    :vrf,
  ]
  ITDSERVICE_BOOL_PROPS = [
    :nat_destination,
    :failaction,
    :load_bal_enable,
    :shutdown,
  ]
  ITDSERVICE_ARRAY_FLAT_PROPS = [
    :ingress_interface,
    :peer_vdc,
    :virtual_ip,
  ]
  ITDSERVICE_ALL_PROPS = ITDSERVICE_NON_BOOL_PROPS + ITDSERVICE_BOOL_PROPS +
                         ITDSERVICE_ARRAY_FLAT_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            ITDSERVICE_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            ITDSERVICE_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            ITDSERVICE_ARRAY_FLAT_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::ItdService.itds[@property_hash[:name]]
    @property_flush = {}
  end

  def self.properties_get(itd_service_name, nu_obj)
    debug "Checking instance, #{itd_service_name}."
    current_state = {
      itdser: itd_service_name,
      name:   itd_service_name,
      ensure: :present,
    }
    # Call node_utils getter for each property
    ITDSERVICE_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end

    ITDSERVICE_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    ITDSERVICE_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
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
    itdser
  end

  def properties_set(new_itd=false)
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

  # We need special handling for boolean properties in our custom
  # setters below. This helper method returns true if the property
  # flush contains a TrueClass or FalseClass value.
  def flush_boolean?(prop)
    @property_flush[prop].is_a?(TrueClass) ||
      @property_flush[prop].is_a?(FalseClass)
  end

  def load_balance_set
    buckets = @property_flush[:load_bal_buckets] ? @property_flush[:load_bal_buckets] : @nu.load_bal_buckets
    mpos = @property_flush[:load_bal_mask_pos] ? @property_flush[:load_bal_mask_pos] : @nu.load_bal_mask_pos
    bh = @property_flush[:load_bal_method_bundle_hash] ? @property_flush[:load_bal_method_bundle_hash] : @nu.load_bal_method_bundle_hash
    bs = @property_flush[:load_bal_method_bundle_select] ? @property_flush[:load_bal_method_bundle_select] : @nu.load_bal_method_bundle_select
    enport = @property_flush[:load_bal_method_end_port] ? @property_flush[:load_bal_method_end_port] : @nu.load_bal_method_end_port
    proto = @property_flush[:load_bal_method_proto] ? @property_flush[:load_bal_method_proto] : @nu.load_bal_method_proto
    start = @property_flush[:load_bal_method_start_port] ? @property_flush[:load_bal_method_start_port] : @nu.load_bal_method_start_port
    enable = flush_boolean?(:load_bal_enable) ? @property_flush[:load_bal_enable] : @nu.load_bal_enable
    # fail_attribute_check(type) TODO
    @nu.send(:load_balance=, enable, bs,
             bh, buckets, mpos, proto, start, enport)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      if @nu.nil?
        new_itd = true
        @nu = Cisco::ItdService.new(@resource[:itdser])
      end
      properties_set(new_itd)
    end
  end
end
