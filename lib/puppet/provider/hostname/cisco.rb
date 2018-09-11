# September, 2018
#
# Copyright (c) 2014-2018 Cisco and/or its affiliates.
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

Puppet::Type.type(:hostname).provide(:cisco) do
  desc 'The Cisco provider for hostname'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @hostname = Cisco::HostName.hostname[@property_hash[:name].to_s]
    @property_flush = {}
  end

  def self.instances
    name = []
    Cisco::HostName.hostname.each_key do |host|
      next unless host != ''
      name << new(
        name:   host,
        ensure: :present,
      )
    end
    name
  end

  def self.prefetch(resources)
    hostname = instances
    resources.keys.each do |name|
      provider = hostname.find { |instance| instance.name == name.to_s }
      resources[name].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def instance_name
    hostname
  end

  def flush
    if @property_flush[:ensure] == :absent
      @hostname.destroy
      @hostname = nil
      @property_hash[:ensure] = :absent
    else
      @hostname = Cisco::HostName.new(@resource[:name].to_s)
      @property_hash[:ensure] = :present
    end
  end
end # Puppet::Type
