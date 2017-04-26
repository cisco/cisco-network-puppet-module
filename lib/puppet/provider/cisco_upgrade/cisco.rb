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
  desc 'The Cisco Upgrade provider to upgrade Cisco devices.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  UPGRADE_NON_BOOL_PROPS = [
    :version,
    :package,
  ]

  UPGRADE_ALL_PROPS = UPGRADE_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            UPGRADE_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::Upgrade
    @property_flush = {}
  end

  def self.instances
    inst = []
    upgrade = Cisco::Upgrade

    inst << new(
      name:    'image',
      package: upgrade.package,
      version: upgrade.image_version)
  end

  def self.prefetch(resources)
    resources.values.first.provider = instances.first
  end

  def version=(new_version)
    return if new_version.nil?
    fail "The property 'version' has been deprecated."
  end

  def package=(new_package)
    return if new_package.nil?
    # Convert del_boot_image and force_upgrade from symbols
    # to Boolean Class
    del_boot_image = (@resource[:delete_boot_image] == :true)
    force_upgrade = (@resource[:force_upgrade] == :true)
    # The Node-utils API expects uri and image_name as two
    # separate arguments. Pre-processing the arguments here.
    pkg = @resource[:package]
    if pkg.include?('/')
      if pkg.include?('bootflash') || pkg.include?('usb')
        uri = pkg.split('/')[0]
      else
        uri = pkg.rpartition('/')[0] + '/'
      end
      image_name = pkg.split('/')[-1]
    else
      uri = pkg.split(':')[0] + ':'
      image_name = pkg.split(':')[-1]
    end
    @nu.upgrade(image_name, uri, del_boot_image, force_upgrade)
    @property_hash[:package] = pkg
  end
end
