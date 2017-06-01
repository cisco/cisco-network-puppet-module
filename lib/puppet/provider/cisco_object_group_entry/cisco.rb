# June 2017
#
# Copyright (c) 2017 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_object_group_entry).provide(:cisco) do
  desc 'The Cisco provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  # Property symbol array for method auto-generation.
  OGE_NON_BOOL_PROPS = [
    :address,
    :port,
  ]

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            OGE_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    afi = @property_hash[:afi]
    type = @property_hash[:type]
    grp_name = @property_hash[:grp_name]
    seqno    = @property_hash[:seqno]
    @nu = Cisco::ObjectGroupEntry.object_group_entries[afi][type][grp_name][seqno] unless grp_name.nil? || seqno.nil?
    @property_flush = {}
  end

  def self.properties_get(afi, type, grp_name, seqno, instance)
    debug "Checking object_group_entry instance, #{afi} #{type} #{grp_name} #{seqno}"
    current_state = {
      name:     "#{afi} #{type} #{grp_name} #{seqno}",
      afi:      afi,
      type:     type,
      grp_name: grp_name,
      seqno:    seqno,
      ensure:   :present,
    }

    # Call node_utils getter for each property
    OGE_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = instance.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    oge_hash = []
    Cisco::ObjectGroupEntry.object_group_entries.each do |afi, types|
      types.each do |type, grp_names|
        grp_names.each do |grp_name, entries|
          entries.each do |seqno, instance|
            oge_hash << properties_get(afi, type, grp_name, seqno, instance)
          end
        end
      end
    end
    oge_hash
  end

  def self.prefetch(resources)
    oge_instances = instances
    resources.keys.each do |name|
      provider = oge_instances.find do |oge|
        resources[name][:afi].to_s == oge.afi.to_s &&
        resources[name][:type].to_s == oge.type.to_s &&
        resources[name][:grp_name].to_s == oge.grp_name.to_s &&
        resources[name][:seqno].to_i == oge.seqno.to_i
      end
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

  def properties_set(new_object_group_entry=false)
    OGE_NON_BOOL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_object_group_entry
      next if @property_flush[prop].nil?
      @nu.send("#{prop}=", @property_flush[prop]) if
        @nu.respond_to?("#{prop}=")
    end
    entry_set
  end

  # The following properties are setters and cannot be handled
  # by PuppetX::Cisco::AutoGen.mk_puppet_methods.
  def entry_set
    attrs = {}
    vars = [
      :address,
      :port,
    ]
    if vars.any? { |p| @property_flush.key?(p) }
      # At least one var has changed, get all vals from manifest
      vars.each do |p|
        attrs[p] = @resource[p]
      end
    end
    return if attrs.empty?
    @nu.entry_set(attrs)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      if @nu.nil?
        new_object_group_entry = true
        @nu = Cisco::ObjectGroupEntry.new(@resource[:afi], @resource[:type],
                                          @resource[:grp_name], @resource[:seqno])
      end
      properties_set(new_object_group_entry)
    end
  end
end
