# The NXAPI provider for ip name-server
#
# September, 2015
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

Puppet::Type.type(:name_server).provide(:nxapi) do
  desc 'The NXAPI provider for ip name-server.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def initialize(value={})
    super(value)
    @nameserver = Cisco::NameServer.nameservers[@property_hash[:name]]
    @property_flush = {}
  end

  def self.instances
    nameserver_instances = []
    Cisco::NameServer.nameservers.each_key do |id|
      nameserver_instances << new(
        name:   id,
        ensure: :present,
      )
    end
    nameserver_instances
  end

  def self.prefetch(resources)
    instance_array = instances
    resources.keys.each do |name|
      provider = instance_array.find { |inst| inst.name == name }
      resources[name].provider = provider unless provider.nil?
    end
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

  def flush
    if @property_flush[:ensure] == :absent
      @nameserver.destroy
      @nameserver = nil
      @property_hash[:ensure] = :absent
    else
      @nameserver = Cisco::NameServer.new(@resource[:name])
      @property_hash[:ensure] = :present
    end
  end
end
