# The NXAPI provider for tacacs.
#
# October, 2015
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:tacacs).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for tacacs.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @tacacs = Cisco::TacacsServer.new(false)
    @property_flush = {}
    debug 'Created provider instance of tacacs'
  end

  def self.get_properties(name)
    debug "Checking instance, TacacsServer #{name}"

    current_state = {}
    current_state[:name] = name
    current_state[:enable] = Cisco::TacacsServer.enabled ? :true : :false

    new(current_state)
  end # self.get_properties

  def self.instances
    tacacs = []
    tacacs << get_properties('default')
    tacacs
  end

  def self.prefetch(resources)
    tacacs = instances

    resources.keys.each do |id|
      provider = tacacs.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def validate
    fail ArgumentError,
         "This provider only supports a namevar of 'default'" unless @resource[:name].to_s == 'default'
  end

  def exists?
    true
  end

  def flush
    validate

    # Handle enable setting
    if @resource[:enable] && @resource[:enable].eql?(:true)
      @tacacs.enable
    elsif @resource[:enable] && @resource[:enable].eql?(:false)
      @tacacs.destroy
    end
  end
end # Puppet::Type
