#
# Puppet provider to manage upgrade of Cisco devices
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end
Puppet::Type.type(:cisco_upgrade).provide(:cisco) do
  desc 'The Cisco Service provider to upgrade Cisco devices.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  SERVICE_NON_BOOL_PROPS = [
    :version
  ]

  SERVICE_ALL_PROPS = SERVICE_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            SERVICE_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::Service
    @property_flush = {}
  end

  def self.instances
    inst = []
    service = Cisco::Service

    inst << new(
      name:              'image',
      version:           service.image_version,
      source_uri:        service.image,
      force_upgrade:     :false,
      delete_boot_image: :false)
  end

  def self.prefetch(resources)
    resources.values.first.provider = instances.first
  end

  def version=(set_value)
    return if set_value.nil?
    @nu.upgrade(@resource[:source_uri][:image_name], @resource[:source_uri][:media],
                @resource[:delete_boot_image], @resource[:force_upgrade])
    @property_hash[:version] = set_value
  end
end
