# August, 2018
#
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
Puppet::Type.type(:cisco_interface_hsrp_group).provide(:cisco) do
  desc 'The Cisco interface hsrp group provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  INTERFACE_HSRP_GROUP_NON_BOOL_PROPS = [
    :authentication_auth_type,
    :authentication_enc_type,
    :authentication_key_type,
    :authentication_string,
    :authentication_timeout,
    :ipv4_vip,
    :mac_addr,
    :group_name,
    :preempt_delay_minimum,
    :preempt_delay_reload,
    :preempt_delay_sync,
    :priority,
    :priority_forward_thresh_lower,
    :priority_forward_thresh_upper,
    :timers_hello,
    :timers_hold,
  ]

  INTERFACE_HSRP_GROUP_BOOL_PROPS = [
    :authentication_compatibility,
    :ipv4_enable,
    :ipv6_autoconfig,
    :preempt,
    :timers_hello_msec,
    :timers_hold_msec,
  ]

  INTERFACE_HSRP_GROUP_ARRAY_FLAT_PROPS = [
    :ipv6_vip
  ]

  INTERFACE_HSRP_GROUP_ALL_PROPS = INTERFACE_HSRP_GROUP_BOOL_PROPS +
                                   INTERFACE_HSRP_GROUP_NON_BOOL_PROPS +
                                   INTERFACE_HSRP_GROUP_ARRAY_FLAT_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            INTERFACE_HSRP_GROUP_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            INTERFACE_HSRP_GROUP_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            INTERFACE_HSRP_GROUP_ARRAY_FLAT_PROPS)

  def initialize(value={})
    super(value)
    interface = @property_hash[:interface]
    group = @property_hash[:group]
    iptype = @property_hash[:iptype]
    @nu = Cisco::InterfaceHsrpGroup.groups[interface][group][iptype] unless
      interface.nil? || group.nil? || iptype.nil?
    @property_flush = {}
  end

  def self.properties_get(interface, group, iptype, nu_obj)
    debug "Checking hsrp group instance, #{interface} #{group} #{iptype}"
    current_state = {
      name:      "#{interface} #{group} #{iptype}",
      interface: interface,
      group:     group,
      iptype:    iptype,
      ensure:    :present,
    }

    # Call node_utils getter for each property
    (INTERFACE_HSRP_GROUP_NON_BOOL_PROPS).each do |prop|
      current_state[prop] = nu_obj.send(prop)
      if prop == :authentication_enc_type
        current_state[prop] = 'clear' if current_state[prop] == '0'
        current_state[prop] = 'encrypted' if current_state[prop] == '7'
      end
    end
    INTERFACE_HSRP_GROUP_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    INTERFACE_HSRP_GROUP_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    # Do not return authentication attributes if authentication_string is not set
    if current_state.include?(:authentication_string) && (current_state[:authentication_string] == '' || current_state[:authentication_string].nil?)
      auth_attrs = [:authentication_auth_type, :authentication_enc_type, :authentication_key_type, :authentication_timeout, :authentication_compatibility]
      auth_attrs.each { |k| current_state.delete k }
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    hg_instances = []
    Cisco::InterfaceHsrpGroup.groups.each do |interface, groups|
      groups.each do |group, iptypes|
        iptypes.each do |iptype, nu_obj|
          hg_instances << properties_get(interface, group, iptype, nu_obj)
        end
      end
    end
    hg_instances
  end # self.instances

  def self.prefetch(resources)
    hg_instances = instances
    resources.keys.each do |id|
      provider = hg_instances.find do |hgi|
        hgi.interface.to_s == resources[id][:interface].to_s &&
        hgi.group.to_s == resources[id][:group].to_s &&
        hgi.iptype.to_s == resources[id][:iptype].to_s
      end
      resources[id].provider = provider unless provider.nil?
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def properties_set(iptype, new_hg=false)
    INTERFACE_HSRP_GROUP_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      if new_hg
        if iptype == 'ipv4'
          send("#{prop}=", @resource[prop]) unless prop == :ipv6_autoconfig
        else
          send("#{prop}=", @resource[prop])
        end
      end
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    authentication_set
    ipv4_vip_set
    preempt_set
    priority_set
    timers_set
  end

  def authentication_set
    attrs = {}
    vars = [
      :authentication_auth_type,
      :authentication_enc_type,
      :authentication_key_type,
      :authentication_string,
      :authentication_timeout,
      :authentication_compatibility,
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
    attrs[:authentication_enc_type] = '0' if attrs[:authentication_enc_type].to_s == 'clear'
    attrs[:authentication_enc_type] = '7' if attrs[:authentication_enc_type].to_s == 'encrypted'
    @nu.authentication_set(attrs) unless attrs[:authentication_string].nil? || attrs[:authentication_string] == ''
  end

  def ipv4_vip_set
    enable = PuppetX::Cisco::Utils.flush_boolean?(@property_flush[:ipv4_enable]) ? @property_flush[:ipv4_enable] : @nu.ipv4_enable
    vip = @property_flush[:ipv4_vip] ? @property_flush[:ipv4_vip] : @nu.ipv4_vip
    @nu.ipv4_vip_set(enable, vip)
  end

  def preempt_set
    min = @property_flush[:preempt_delay_minimum] ? @property_flush[:preempt_delay_minimum] : @nu.preempt_delay_minimum
    rel = @property_flush[:preempt_delay_reload] ? @property_flush[:preempt_delay_reload] : @nu.preempt_delay_reload
    sync = @property_flush[:preempt_delay_sync] ? @property_flush[:preempt_delay_sync] : @nu.preempt_delay_sync
    pree = PuppetX::Cisco::Utils.flush_boolean?(@property_flush[:preempt]) ? @property_flush[:preempt] : @nu.preempt
    @nu.preempt_set(pree, min, rel, sync)
  end

  def priority_set
    pri = @property_flush[:priority] ? @property_flush[:priority] : @nu.priority
    low = @property_flush[:priority_forward_thresh_lower] ? @property_flush[:priority_forward_thresh_lower] : @nu.priority_forward_thresh_lower
    up = @property_flush[:priority_forward_thresh_upper] ? @property_flush[:priority_forward_thresh_upper] : @nu.priority_forward_thresh_upper
    @nu.priority_level_set(pri, low, up)
  end

  def timers_set
    hello = @property_flush[:timers_hello] ? @property_flush[:timers_hello] : @nu.timers_hello
    hold = @property_flush[:timers_hold] ? @property_flush[:timers_hold] : @nu.timers_hold
    hem = PuppetX::Cisco::Utils.flush_boolean?(@property_flush[:timers_hello_msec]) ? @property_flush[:timers_hello_msec] : @nu.timers_hello_msec
    hom = PuppetX::Cisco::Utils.flush_boolean?(@property_flush[:timers_hold_msec]) ? @property_flush[:timers_hold_msec] : @nu.timers_hold_msec
    @nu.timers_set(hem, hello, hom, hold)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      new_hg = false
      if @nu.nil?
        new_hg = true
        @nu = Cisco::InterfaceHsrpGroup.new(@resource[:interface],
                                            @resource[:group],
                                            @resource[:iptype])
      end
      properties_set(@resource[:iptype], new_hg)
    end
  end
end
