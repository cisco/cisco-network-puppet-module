# The NXAPI provider.
#
# March, 2014
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

Puppet::Type.type(:cisco_ospf).provide(:nxapi) do
  desc 'The NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def self.instances
    ospf_instances = []
    Cisco::RouterOspf.routers.each do |name, ospf_instance|
      debug "Checking resource OSPF #{name}"
      ospf_instances << new(
        name:   name,
        ospf:   ospf_instance,
        ensure: :present)
    end

    ospf_instances
  end # self.instances

  def self.prefetch(resources)
    ospf_instances = instances

    resources.keys.each do |name|
      provider = ospf_instances.find { |ospf| ospf.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def initialize(value={})
    super(value)
    @ospf = Cisco::RouterOspf.routers[@property_hash[:name]]
    @property_flush = {}
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

  def flush
    case @property_flush[:ensure]
    when :present
      @ospf = Cisco::RouterOspf.new(@resource[:name])
    when :absent
      @ospf.destroy
    end
  end
end
