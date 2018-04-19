# February, 2018
#
# Copyright (c) 2018-2019 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_ip_multicast).provide(:cisco) do
  desc 'The Cisco provider for cisco ip multicast'

  confine feature: :cisco_node_utils

  mk_resource_methods

  IP_MULTICAST_BOOL_PROPS = [
    :overlay_distributed_dr,
    :overlay_spt_only,
  ]
  IP_MULTICAST_ALL_PROPS = IP_MULTICAST_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            IP_MULTICAST_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::IpMulticast.new(false)
    @property_flush = {}
  end # initialize

  def self.properties_get(nu_obj)
    current_state = {
      name:                   'default',
      ensure:                 :present,
      overlay_distributed_dr: nu_obj.overlay_distributed_dr,
      overlay_spt_only:       nu_obj.overlay_spt_only,
    }
    new(current_state)
  end # self.properties_get

  def self.instances
    inst = []
    ip_mc = Cisco::IpMulticast.new(false)
    inst << properties_get(ip_mc) if ip_mc.ip_multicast
    inst
  end # self.instances

  def self.prefetch(resources)
    resources.values.first.provider = instances.first unless instances.first.nil?
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

  def properties_set
    IP_MULTICAST_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop])

      next if @property_flush[prop].nil?
      @nu.send("#{prop}=", @property_flush[prop]) if
        @nu.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      @nu = Cisco::IpMulticast.new if @nu.nil? || !@nu.ip_multicast
      properties_set
    end
  end
end # Puppet::Type
