# The NXAPI provider for radius.
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

Puppet::Type.type(:radius).provide(:nxapi) do
  desc 'The Cisco NXAPI provider for radius_global.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  def initialize(value={})
    super(value)
    @property_flush = {}
    debug 'Created provider instance of radius'
  end

  def self.get_properties(name)
    debug "Checking instance, Radius #{name}"

    current_state = {
      name: 'default'
    }

    new(current_state)
  end # self.get_properties

  def self.instances
    radius = []
    radius << get_properties('default')
    radius
  end

  def self.prefetch(resources)
    radius = instances

    resources.keys.each do |id|
      provider = radius.find { |instance| instance.name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def enable
    @resource[:enable]
  end

  def enable=(_val)
    # Do Nothing
  end
end # Puppet::Type
