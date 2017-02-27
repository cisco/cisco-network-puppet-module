#
# Puppet provider for feature service
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end
Puppet::Type.type(:cisco_service).provide(:cisco) do
  desc 'The Cisco Service provider to upgrade Cisco devices.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  SERVICE_NON_BOOL_PROPS = [
    :source_uri,
  ]

  SERVICE_ALL_PROPS = SERVICE_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
					    SERVICE_NON_BOOL_PROPS)
  
  def initialize(value={})
    super(value)
    version = @property_hash[:version]
    force_all = @property_hash[:force_all]
    delete_boot = @property_hash[:delete_boot]
    @nu = Cisco::Service.image_version unless version.nil?
    @property_flush = {}
  end

  def self.instances
    inst = []
    service = Cisco::Service

    inst << new(
      name: service.image_version,
      version: service.image_version,
      source_uri: service.image,
      force_all: :false,
      delete_boot: :false)
  end

  def self.prefetch(resources)
    image_instances = instances
    resources.keys.each do |id|
      provider = image_instances.find do |i|
        i.version.to_s == resources[id][:version].to_s &&
        i.force_all == resources[id][:force_all] &&
        i.delete_boot == resources[id][:delete_boot]
      end
      resources[id].provider = provider unless provider.nil?
    end
  end

  def properties_set
    SERVICE_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop])
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    upgrade
  end
  

  def upgrade
    attrs = {}	  
    vars = [
      :source_uri,
    ]
    if vars.any? { |p| @property_flush.key?(p) }
      # At least one var has changed, get all vals from manifest
      vars.each do |p|
        val = @resource[p]
        if val == :default
          val = @nu.send("default_#{p}")
        else
          val = PuppetX::Cisco::Utils.bool_sym_to_s(val)
        end
        next if val == false || val.to_s.empty?
        attrs[p] = val
      end
    end

    attrs.each do |k, v|
      if k == :source_uri
        media = v.split('/')[0]
        image = v.split('/')[-1]
        Cisco::Service.upgrade(image,media,@resource[:delete_boot],@resource[:force_all])
      end
    end
  end

  def flush
    properties_set	  
  end
end
