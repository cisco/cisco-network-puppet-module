# April, 2015
#
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
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:cisco_interface_ospf).provide(:cisco) do
  desc 'The Cisco provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  INTF_OSPF_NON_BOOL_PROPS = [
    :area,
    :cost,
    :hello_interval,
    :dead_interval,
    :message_digest_key_id,
    :message_digest_algorithm_type,
    :message_digest_encryption_type,
    :message_digest_password,
    :network_type,
    :priority,
    :transmit_delay,
  ]

  INTF_OSPF_BOOL_PROPS = [
    :passive_interface,
    :bfd,
    :message_digest,
    :mtu_ignore,
    :shutdown,
  ]

  INTF_OSPF_ALL_PROPS = INTF_OSPF_NON_BOOL_PROPS + INTF_OSPF_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            INTF_OSPF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            INTF_OSPF_BOOL_PROPS)

  def initialize(value={})
    super(value)

    if value.is_a?(Hash)
      # value is_a hash when initialized from properties_get()
      all_intf = value[:all_intf]
      single_intf = value[:interface]
      ospf_name = value[:ospf]
    else
      # @property_hash[:name] is nil in this codepath; since it's nil
      # it will cause @nu to become nil, thus @nu instantiation is just
      # skipped altogether.
      all_intf = false
    end
    if all_intf
      @nu = Cisco::InterfaceOspf.interfaces[@property_hash[:interface]]
    elsif single_intf
      # 'puppet agent' caller
      @nu = Cisco::InterfaceOspf.interfaces(ospf_name, single_intf)[@property_hash[:interface]]
    end
    @property_flush = {}
  end

  def self.properties_get(interface_name, interface_ospf, all_intf: nil)
    current_state = {
      interface: interface_name,
      name:      "#{interface_name} #{interface_ospf.ospf_name}",
      ospf:      interface_ospf.ospf_name,
      ensure:    :present,
      all_intf:  all_intf,
    }

    # Call node_utils getter for each property
    INTF_OSPF_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = interface_ospf.send(prop)
    end
    INTF_OSPF_BOOL_PROPS.each do |prop|
      val = interface_ospf.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    new(current_state)
  end # self.properties_get

  def self.instances(name=nil, interface_threshold=0)
    # 'puppet resource' calls here directly; will always get all interfaces.
    # 'puppet agent' callpath is initialize->prefetch; may pass a single intf.
    if name && interface_threshold > 0
      all_intf = false
      single_intf, ospf_name = name.split
      nu_interfaces = Cisco::InterfaceOspf.interfaces(ospf_name, single_intf)
    else
      all_intf = true
      nu_interfaces = Cisco::InterfaceOspf.interfaces
    end
    interfaces = []
    nu_interfaces.each do |intf_ospf, nu_obj|
      begin
        interfaces << properties_get(intf_ospf, nu_obj, all_intf: all_intf)
      end
    end
    interfaces
  end # self.instances

  def self.prefetch(resources)
    interface_threshold = PuppetX::Cisco::Utils.interface_threshold
    # resource.key syntax is 'interface_name ospf_name'
    if resources.keys.length > interface_threshold
      info '[prefetch all interfaces]:begin - please be patient...'
      interfaces = instances
      resources.keys.each do |name|
        provider = interfaces.find { |intf| intf.name == name }
        resources[name].provider = provider unless provider.nil?
      end
      info "[prefetch all interfaces]:end - found: #{interfaces.length}"
    else
      info "[prefetch each interface independently] (threshold: #{interface_threshold})"
      resources.keys.each do |name|
        provider = instances(name, interface_threshold).find { |intf| intf.name == name }
        resources[name].provider = provider unless provider.nil?
      end
    end
  end # self.prefetch

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    debug "Creating ospf instance with name #{@resource[:interface]}"
    @property_flush[:ensure] = :present
  end

  def destroy
    debug "Removing interface_ospf instance with name #{resource[:interface]}."
    @property_flush[:ensure] = :absent
  end

  def properties_set(new_instance=false)
    INTF_OSPF_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_instance
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    message_digest_key_set
  end

  def message_digest_key_set
    key = @property_flush[:message_digest_key_id] ? @property_flush[:message_digest_key_id] : @nu.message_digest_key_id
    pw = @property_flush[:message_digest_password] ? @property_flush[:message_digest_password] : @nu.message_digest_password
    algtype = @property_flush[:message_digest_algorithm_type] ? @property_flush[:message_digest_algorithm_type] : @nu.message_digest_algorithm_type
    enctype = @property_flush[:message_digest_encryption_type] ? @property_flush[:message_digest_encryption_type] : @nu.message_digest_encryption_type
    @nu.message_digest_key_set(key, algtype.to_s, enctype, pw)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      new_instance = false
      if @nu.nil?
        new_instance = true
        @nu = Cisco::InterfaceOspf.new(@resource[:interface],
                                       @resource[:ospf],
                                       @resource[:area],
                                       new_instance,
                                       @resource[:interface])
      end
      properties_set(new_instance)
    end
  end
end
