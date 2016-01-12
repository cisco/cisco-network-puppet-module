#
# The NXAPI provider for cisco_acl.
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

Puppet::Type.type(:cisco_acl).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_acl.'

  confine feature: :cisco_node_utils

  mk_resource_methods

  ACL_NON_BOOL_PROPS = [
    :fragments
  ]
  ACL_BOOL_PROPS = [
    :stats_per_entry
  ]
  ACL_ALL_PROPS =
    ACL_NON_BOOL_PROPS + ACL_BOOL_PROPS

  # Dynamic method generation for getters & setters
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@acl',
                                            ACL_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@acl',
                                            ACL_BOOL_PROPS)

  def initialize(value={})
    super(value)
    afi = @property_hash[:afi]
    acl_name = @property_hash[:acl_name]
    @acl = Cisco::Acl.acls[afi][acl_name] unless afi.nil?
    @property_flush = {}
  end

  def self.properties_get(afi, acl, inst)
    current_state = {
      name:     "#{afi} #{acl}",
      afi:      afi,
      acl_name: acl,
      ensure:   :present,
    }
    # Call node_utils getter for each property
    ACL_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = inst.send(prop)
    end

    ACL_BOOL_PROPS.each do |prop|
      val = inst.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end

    new(current_state)
  end # self.properties_get

  def self.instances
    instance_array = []
    Cisco::Acl.acls.each do |afi, acls|
      acls.each do |acl, inst|
        begin
          instance_array << properties_get(afi, acl, inst)
        end
      end
    end
    instance_array
  end # self.instances

  def self.prefetch(resources)
    instance_array = instances
    resources.keys.each do |name|
      provider = instance_array.find do |acl|
        acl.afi.to_s == resources[name][:afi].to_s &&
        acl.acl_name.to_s == resources[name][:acl_name].to_s
      end
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

  def properties_set(new_instance=false)
    ACL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      # Call puppet setter to set @property_flush[prop]
      send("#{prop}=", @resource[prop]) if new_instance
      next if @property_flush[prop].nil?
      # Call node_utils setter to update node
      @acl.send("#{prop}=", @property_flush[prop]) if
        @acl.respond_to?("#{prop}=")
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @acl.destroy
      @acl = nil
    else
      if @acl.nil?
        # create new
        new_instance = true
        @acl = Cisco::Acl.new(@resource[:afi], @resource[:acl_name])
      end
      properties_set(new_instance)
    end
  end
end
