# The NXAPI provider for Cisco_interface_ospf
#
# April, 2015
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_interface_ospf).provide(:nxapi) do
  desc 'The nxapi provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Getter properties that need to generate the getter functions
  GETTER_PROPS = [
    :hello_interval, :dead_interval
  ]

  # Setter properties
  SETTER_NON_BOOL_PROPS = [
    :cost, :hello_interval, :dead_interval, :message_digest_key_id,
    :message_digest_password, :area
  ]

  SETTER_BOOL_PROPS = [
    :passive_interface, :message_digest
  ]

  ALL_SETTER_PROPS = SETTER_NON_BOOL_PROPS + SETTER_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_getters_non_bool(self, '@interface_ospf',
                                                     GETTER_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_setters_non_bool(self, '@interface_ospf',
                                                     SETTER_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_setters_bool(self, '@interface_ospf',
                                                 SETTER_BOOL_PROPS)

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
    ALL_SETTER_PROPS.each do |prop|
      current_state[prop] = interface_ospf.send(prop)
    end

    current_state[:passive_interface] =
      current_state[:passive_interface].to_s.to_sym
    current_state[:message_digest] =
      current_state[:message_digest].to_s.to_sym

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
    ALL_SETTER_PROPS.each do |prop|
      send("#{prop}=", @resource[prop]) if new_instance && @resource[prop]
      unless @property_flush[prop].nil?
        @interface_ospf.send("#{prop}=", @property_flush[prop]) if
          @interface_ospf.respond_to?("#{prop}=")
      end
    end

    if @property_flush[:message_digest_key_id].nil?
      should_message_digest_key_id = @interface_ospf.message_digest_key_id
    else
      should_message_digest_key_id = @property_flush[:message_digest_key_id]
    end

    if @property_flush[:message_digest_password].nil?
      should_message_digest_password = @interface_ospf.message_digest_password
    else
      should_message_digest_password = @property_flush[:message_digest_password]
    end

    # should_message_digest_password could still be nil if not configured on box
    should_message_digest_password = '' if should_message_digest_password.nil?

    if @resource[:message_digest_algorithm_type].nil?
      should_message_digest_algorithm_type = @interface_ospf.message_digest_algorithm_type
    else
      should_message_digest_algorithm_type = @resource[:message_digest_algorithm_type]
    end

    if @resource[:message_digest_encryption_type].nil?
      should_message_digest_encryption_type = @interface_ospf.message_digest_encryption_type
    else
      should_message_digest_encryption_type = @resource[:message_digest_encryption_type]
    end

    return unless (new_instance &&
                   (should_message_digest_key_id !=
                    @interface_ospf.default_message_digest_key_id)) ||
                  (@property_flush[:message_digest_key_id] && !new_instance) ||
                  (@property_flush[:message_digest_password] && !new_instance)

    @interface_ospf.message_digest_key_set(
      should_message_digest_key_id,
      should_message_digest_algorithm_type.to_s,
      should_message_digest_encryption_type,
      should_message_digest_password)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @interface_ospf.destroy
      @interface_ospf = nil
    elsif @property_flush[:ensure] == :present
      @interface_ospf = Cisco::InterfaceOspf.new(@resource[:interface],
                                                 @resource[:ospf],
                                                 @resource[:area])
      properties_set(true)
    else
      properties_set
    end
  end
end
