#
# The NXAPI provider for cisco_itd_device_group.
#
# Feb 2016
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

Puppet::Type.type(:cisco_itd_device_group).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_itd_device_group.'

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

  # We need special handling for boolean properties in our custom
  # setters below. This helper method returns true if the property
  # flush contains a TrueClass or FalseClass value.
  def flush_boolean?(prop)
    @property_flush[prop].is_a?(TrueClass) ||
      @property_flush[prop].is_a?(FalseClass)
  end

  def fail_attribute_check(type)
    case type.to_sym
    when :icmp
      fail ArgumentError, 'control, dns_host, port are not applicable' if
        @resource[:probe_control] || @resource[:probe_dns_host] ||
        @resource[:probe_port]
    when :dns
      fail ArgumentError, 'control, port are not applicable' if
        @resource[:probe_control] || @resource[:probe_port]
      fail ArgumentError, 'dns_host MUST be specified' unless
        @resource[:probe_dns_host]
    when :tcp, :udp
      fail ArgumentError, 'dns_host is not applicable' if
        @resource[:probe_dns_host]
      fail ArgumentError, 'port MUST be specified' unless
        @resource[:probe_port]
    end
  end

  def probe_set
    type = @property_flush[:probe_type] ? @property_flush[:probe_type] : @nu.probe_type
    to = @property_flush[:probe_timeout] ? @property_flush[:probe_timeout] : @nu.probe_timeout
    ru = @property_flush[:probe_retry_up] ? @property_flush[:probe_retry_up] : @nu.probe_retry_up
    rd = @property_flush[:probe_retry_down] ? @property_flush[:probe_retry_down] : @nu.probe_retry_down
    freq = @property_flush[:probe_frequency] ? @property_flush[:probe_frequency] : @nu.probe_frequency
    dh = @property_flush[:probe_dns_host] ? @property_flush[:probe_dns_host] : @nu.probe_dns_host
    port = @property_flush[:probe_port] ? @property_flush[:probe_port] : @nu.probe_port
    con = flush_boolean?(:probe_control) ? @property_flush[:probe_control] : @nu.probe_control
    fail_attribute_check(type)
    @nu.send(:probe=, type, dh, con, freq, ru, rd, port, to)
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
