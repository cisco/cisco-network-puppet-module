# January, 2015
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:package).provide :cisco, parent: :yum do
  desc "The cisco package provider.
  Local rpm installations will utilize the native yum provider.
  Cisco rpm installations from the host will utilize the native yum provider.
  Cisco NX-OS rpm installations from guestshell will use this provider to install to host.
  Cisco IOS XR rpm installations will utilize this provider to install to host via sdr_instcmd."

  confine feature: :cisco_node_utils

  # same features as yum plus :package_settings
  has_feature :install_options, :versionable, :virtual_packages, :package_settings

  # these commands must exist to execute native yum provider
  commands yum: 'yum', rpm: 'rpm', python: 'python'

  defaultfor operatingsystem: [:ios_xr, :nexus]

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

  # Returns true if operating system is nexus else false.
  def in_nexus?
    os = Facter.value('operatingsystem')
    (os == 'nexus') ? true : false
  end

  # Returns true if operating system is ios_xr else false.
  def in_ios_xr?
    os = Facter.value('operatingsystem')
    (os == 'ios_xr') ? true : false
  end

  def cisco_rpm_xr?
    name_var_arch_regex_xr = /^(.*\d.*)-([\d.]*)-(r\d+.*)\.(\w{4,}).rpm/
    if @resource[:source]
      @resource[:source].match(name_var_arch_regex_xr) ? true : false
    elsif @resource[:name] && @resource[:package_settings] && @resource[:platform]
      source = @resource[:name] + '-' + @resource[:package_settings]['version'] + \
               '.' + @resource[:platform] + '.rpm'
      source.match(name_var_arch_regex_xr) ? true : false
    end
  end

  def version?(t)
    return unless @resource[:package_settings]
    regex = /^([\d.]*)-(r\d+.*)$/
    @resource[:package_settings]['version'].match(regex)
    if t == 'package'
      Regexp.last_match(1)
    elsif t == 'xr'
      Regexp.last_match(2)
    end
  end

  # IMPORTANT: it's useless to override self.instances and prefetch,
  # because we can't know whether to retrieve packages for native or GS
  # because target->host is specified on a per-package basis. Instead,
  # retrieve the status of our package in properties method below.

  # this method in package.rb determines how to set ensure
  # @property_hash is empty at this point
  def properties
    if (in_ios_xr?) ||
       (in_guestshell? && target_host?)
      normalize_resource
    else
      super
    end

    if (in_ios_xr? && cisco_rpm_xr?) ||
       (in_guestshell? && target_host?)

      is_ver = current_version
      should_ver = version?('package')

      # set absent if no version is installed, or if installed version
      # does not match @resource version (if should_ver is provided)
      if !is_ver || (should_ver && is_ver != should_ver)
        status = :absent
      else
        status = :present
      end

      debug "determined package #{@resource[:name]} is #{status}"
      @property_hash = { ensure: status, version: is_ver }

    elsif in_ios_xr?
      info = super
      if info[:version]
        status = :present
        ver = info[:version]
      else
        status = :absent
        ver = ''
      end
      debug "determined package #{@resource[:name]} is #{status}."
      @property_hash = { ensure: status, version: ver }
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

    if in_nexus? && @resource[:name] =~ name_arch_regex
      @resource[:name] = Regexp.last_match(1)
      @resource[:platform] = Regexp.last_match(2)
      debug "parsed name:#{Regexp.last_match(1)}, arch:#{Regexp.last_match(2)}"
    end
    # [source] overrides [name]
    return unless @resource[:source]

    # ex xrv9k-k9sec-1.0.0.0-r600.x86_64.rpm-6.0.0
    #    xrv9k-k9sec-1.0.0.0-r61102I.x86_64.rpm-XR-DEV-16.02.22C
    # This regex is used to create a match group of
    # 1. package name, 2. package version, 3. platform
    name_var_arch_regex_xr = /^(.*\d.*)-([\d.]*-r\d+.*)\.(\w{4,}).rpm/
    name_regex_xr = /(.*).rpm$/

    # convert to linux-style path before parsing filename
    filename = @resource[:source].strip.tr(':', '/').split('/').last

    if in_ios_xr?
      if filename =~ name_var_arch_regex_xr
        @resource[:name] = Regexp.last_match(1)
        @resource[:package_settings]['version'] = Regexp.last_match(2)
        @resource[:platform] = Regexp.last_match(3)
        debug "parsed name:#{Regexp.last_match(1)}," \
          "version:#{Regexp.last_match(2)}, " \
          "arch:#{Regexp.last_match(3)}"
      else
        @resource[:name] = filename.match(name_regex_xr)[1]
        return
      end
    elsif filename =~ name_ver_arch_regex ||
          filename =~ name_var_arch_regex_nx
      @resource[:name] = Regexp.last_match(1)
      @resource[:package_settings]['version'] = Regexp.last_match(2)
      @resource[:platform] = Regexp.last_match(3)
      debug "parsed name:#{Regexp.last_match(1)}," \
          "version:#{Regexp.last_match(2)}, arch:#{Regexp.last_match(3)}"
    else
      @resource.fail 'Could not parse name|version|arch from source: ' \
        "#{@resource[:source]}"
    end
    # replace linux path with ios-style path
    @resource[:source].gsub!(%r{^/([^/]+)/}, '\1:')
  end

  # helper to retrieve version info for installed package
  def current_version
    # Platform is not used in XR query.
    if @resource[:platform] && in_nexus?
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
    if in_ios_xr?
      if cisco_rpm_xr?
        debug 'using sdr_instcmd for install'
        Cisco::Yum.install("#{@resource[:name]}-" \
                           "#{@resource[:package_settings]['version']}")
      elsif @resource[:source]
        debug "using yum for install #{@resource[:source]}"
        @resource[:name] = @resource[:source]
        super
      end
    elsif in_nexus? && (in_guestshell? && target_host?)
      if @resource[:source]
        debug 'Guestshell + target=>host detected, using nxapi for install'
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
    if in_ios_xr?
      if cisco_rpm_xr?
        debug 'using sdr_instcmd for uninstall'
        Cisco::Yum.remove("#{@resource[:name]}-"\
                          "#{@resource[:package_settings]['version']}")
      else
        debug "using yum for uninstall #{@resource[:name]}"
        super
      end
    elsif in_nexus? && (in_guestshell? && target_host?)
      if @resource[:platform]
        Cisco::Yum.remove("#{@resource[:name]}.#{@resource[:platform]}")
      else
        Cisco::Yum.remove(@resource[:name])
      end
    else
      debug 'Not XR || Guestshell + target=>host, use native yum provider for uninstall'
      super
    end
  end
end
