# The NXAPI provider for cisco VTP.
#
# January 2014
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

Puppet::Type.type(:cisco_vtp).provide(:nxapi) do
  desc 'The nxapi provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  VTP_ALL_PROPS = [:domain, :filename, :version, :password]

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@vtp',
                                            VTP_ALL_PROPS)

  def initialize(value={})
    super(value)
    @vtp = Cisco::Vtp.new if Cisco::Vtp.enabled
    @property_flush = {}
  end

  def self.properties_get(vtp)
    current_state = {
      name:   'default',
      ensure: :present,
    }

    # Call node_utils getter for each property
    VTP_ALL_PROPS.each do |prop|
      current_state[prop] = vtp.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    vtps = []
    return vtps unless Cisco::Vtp.enabled

    vtp = Cisco::Vtp.new

    vtps << properties_get(vtp)
    vtps
  end # self.instances

  def self.prefetch(resources)
    resources.values.first.provider = instances.first unless instances.first.nil?
  end

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
    domain
  end

  def properties_set(new_vtp=false)
    VTP_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vtp
      unless @property_flush[prop].nil?
        @vtp.send("#{prop}=", @property_flush[prop]) if
          @vtp.respond_to?("#{prop}=")
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vtp.destroy
      @vtp = nil
    else
      # Create/Update
      if @vtp.nil?
        new_vtp = true
        @vtp = Cisco::Vtp.new
      end
      properties_set(new_vtp)
    end
    puts_config
  end

  def puts_config
    return if @vtp.nil?

    # Dump all current properties for this vtp
    current = sprintf("\n%30s: %s", 'vtp', instance_name)
    VTP_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @vtp.send(prop)))
    end
    debug current
  end # puts_config
end # Puppet::Type
