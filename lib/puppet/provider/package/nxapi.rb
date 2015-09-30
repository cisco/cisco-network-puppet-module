# package nxapi provider
#
# January, 2015
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

require 'puppet/util/package'

Puppet::Type.type(:package).provide :nxapi, parent: :yum do
  desc "The cisco nexus package provider.
  Local rpm installations will utilize the native yum provider.
  Cisco rpm installations from the host will utilize the native yum provider.
  Cisco rpm installations from guestshell will utilize nxapi to install to host."

  confine feature: :cisco_node_utils

  # same features as yum plus :package_settings
  has_feature :install_options, :versionable, :virtual_packages, :package_settings

  # these commands must exist to execute native yum provider
  commands yum: 'yum', rpm: 'rpm', python: 'python'

  defaultfor operatingsystem: :nexus

  # if the following commands aren't present, we're in trouble
  if command('rpm')
    commands_present = true
    begin
      rpm('--version')
      yum('--version')
      python('--version')
    rescue Puppet::ExecutionFailure
      commands_present = false
    end
    confine true: commands_present
  end

  # IMPORTANT: it's useless to override self.instances and prefetch,
  # because we can't know whether to retrieve packages for native or GS
  # because target->host is specified on a per-package basis. Instead,
  # retrieve the status of our package in properties method below.

  # this method in package.rb determines how to set ensure
  # @property_hash is empty at this point
  def properties
    if in_guestshell? && target_host?
      normalize_resource

      is_ver = current_version
      should_ver = @resource[:package_settings]['version']

      # set absent if no version is installed, or if installed version
      # does not match @resource version (if should_ver is provided)
      if !is_ver || (should_ver && is_ver != should_ver)
        status = :absent
      else
        status = :present
      end

      debug "determined package #{@resource[:name]} is #{status}"
      @property_hash = { ensure: status, version: is_ver }
    else
      super
    end
  end

  # set resource properties in a consistent way:
  # [name] should contain the simple package name
  # [source] should use ios-style file path
  # [platform] stores arch, if parsable from [source]
  # package_settings[version] stores version if parsable from [source]
  # if [source] isn't supplied, it's assumed [name] already exists in the
  # local repository
  def normalize_resource
    # ex: chef-12.0.0alpha.2+20150319.git.1.b6f-1.el5.x86_64.rpm
    name_ver_arch_regex = /^([\w\-\+]+)-(\d+\..*)\.(\w{4,})(?:\.rpm)?$/

    # ex n9000-dk9.LIBPROCMIBREST-1.0.0-7.0.3.x86_64.rpm
    name_var_arch_regex_nx = /^(.*)-([\d\.]+-[\d\.]+)\.(\w{4,})\.rpm$/

    # ex: b+z-ip2.x64_64
    name_arch_regex = /^([\w\-\+]+)\.(\w+)$/

    if @resource[:name] =~ name_arch_regex
      @resource[:name] = Regexp.last_match(1)
      @resource[:platform] = Regexp.last_match(2)
      debug "parsed name:#{Regexp.last_match(1)}, arch:#{Regexp.last_match(2)}"
    end
    # [source] overrides [name]
    return unless @resource[:source]

    # convert to linux-style path before parsing filename
    filename = @resource[:source].strip.tr(':', '/').split('/').last

    if filename =~ name_ver_arch_regex ||
       filename =~ name_var_arch_regex_nx
      @resource[:name] = Regexp.last_match(1)
      @resource[:package_settings]['version'] = Regexp.last_match(2)
      @resource[:platform] = Regexp.last_match(3)
      debug "parsed name:#{Regexp.last_match(1)}, version:#{Regexp.last_match(2)}, arch:#{Regexp.last_match(3)}"
    else
      @resource.fail 'Could not parse name|version|arch from source: ' \
        "#{@resource[:source]}"
    end
    # replace linux path with ios-style path
    @resource[:source].gsub!(%r{^/([^/]+)/}, '\1:')
  end

  # helper to retrieve version info for installed package
  def current_version
    if @resource[:platform]
      ver = Cisco::Yum.query("#{@resource[:name]}.#{@resource[:platform]}")
    else
      ver = Cisco::Yum.query("#{@resource[:name]}")
    end
    debug "retrieved version '#{ver}' for package #{@resource[:name]}"
    ver
  end

  # these methods only exist to satisfy the :package_settings feature interface
  def package_settings_validate(value)
    debug "package_settings_validate(#{value}): no-op"
    true
  end

  def package_settings_insync?(should, is)
    debug "package_settings_insync?(#{should},#{is}): no-op"
    true
  end

  def package_settings=(value)
    debug "package_settings=(#{value}): no-op"
  end

  def package_settings
    debug 'package_settings(): no-op'
  end

  # true if DSL defines "package_settings => {'target' => 'host'}"
  def target_host?
    @resource[:package_settings] &&
      @resource[:package_settings]['target'] == 'host'
  end

  def in_guestshell?
    # update this to more robust fact when new facter facts are implemented
    Facter.value(:virtual) =~ /lxc/
    true # temporarily force use of NXAPI if using target->host in native
  end

  def install
    if in_guestshell? && target_host?
      debug 'Guestshell + target=>host detected, using nxapi for install'
      if @resource[:source]
        Cisco::Yum.install(@resource[:source])
      else
        Cisco::Yum.install(@resource[:name])
      end
    else
      debug 'Not Guestshell + target=>host, use native yum provider for install'
      # replace bootflash:path with /bootflash/path for native env
      @resource[:source].gsub!(%r{^([^/]+):/?}, '/\1/') if @resource[:source]
      super
    end
  end

  # yum's update method calls self.install which will refer to this class' install

  def uninstall
    if in_guestshell? && target_host?
      debug 'Guestshell + target=>host detected, using nxapi for uninstall'
      if @resource[:platform]
        Cisco::Yum.remove("#{@resource[:name]}.#{@resource[:platform]}")
      else
        Cisco::Yum.remove(@resource[:name])
      end
    else
      debug 'Not Guestshell + target=>host, use native yum provider for uninstall'
      super
    end
  end
end
