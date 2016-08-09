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

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@interface_ospf',
                                            INTF_OSPF_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@interface_ospf',
                                            INTF_OSPF_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @interface_ospf = Cisco::InterfaceOspf.interfaces[@property_hash[:interface]]
    @property_flush = {}
  end

  def self.properties_get(interface_name, interface_ospf)
    current_state = {
      interface: interface_name,
      name:      "#{interface_name} #{interface_ospf.ospf_name}",
      ospf:      interface_ospf.ospf_name,
      ensure:    :present,
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

  def self.instances
    intf_ospf_instances = []

    Cisco::InterfaceOspf.interfaces.each do |intf_name, intf_ospf|
      begin
        intf_ospf_instances << properties_get(intf_name, intf_ospf)
      end
    end
    intf_ospf_instances
  end

  def self.prefetch(resources)
    intf_ospf_instances = instances

    resources.keys.each do |name|
      provider = intf_ospf_instances.find { |intf_ospf| intf_ospf.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

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
        @interface_ospf.send("#{prop}=", @property_flush[prop]) if
          @interface_ospf.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    message_digest_key_set
  end

  def message_digest_key_set
    key = @property_flush[:message_digest_key_id] ? @property_flush[:message_digest_key_id] : @interface_ospf.message_digest_key_id
    pw = @property_flush[:message_digest_password] ? @property_flush[:message_digest_password] : @interface_ospf.message_digest_password
    algtype = @property_flush[:message_digest_algorithm_type] ? @property_flush[:message_digest_algorithm_type] : @interface_ospf.message_digest_algorithm_type
    enctype = @property_flush[:message_digest_encryption_type] ? @property_flush[:message_digest_encryption_type] : @interface_ospf.message_digest_encryption_type
    @interface_ospf.message_digest_key_set(key, algtype.to_s, enctype, pw)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @interface_ospf.destroy
      @interface_ospf = nil
    else
      new_instance = false
      if @interface_ospf.nil?
        new_instance = true
        @interface_ospf = Cisco::InterfaceOspf.new(@resource[:interface],
                                                   @resource[:ospf],
                                                   @resource[:area])
      end
      properties_set(new_instance)
    end
  end
end
