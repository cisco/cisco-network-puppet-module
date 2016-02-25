#
# The NXAPI provider for cisco_aaa_authorization_login_exec_svc.
#
# December 2015
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
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:cisco_aaa_authorization_login_exec_svc).provide(:nxapi) do
  desc 'The NXAPI provider for cisco_aaa_authorization_login_exec_svc.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  AAA_EXEC_PROPS = [:method]
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@aaa_login_svc',
                                            AAA_EXEC_PROPS)

  def initialize(value={})
    super(value)
    # This is a shared node utils object between config and exec services.
    # The #services method retrieves a hash of all shared services, use the
    # :commands key to get those services relevant to this provider.
    all_exec_svc = Cisco::AaaAuthorizationService.services[:commands]
    @aaa_login_svc = all_exec_svc ? all_exec_svc[@property_hash[:name]] : nil
    @property_flush = {}
  end

  def self.instances
    services = []
    exec_svcs = Cisco::AaaAuthorizationService.services[:commands]
    return services if exec_svcs.nil?

    exec_svcs.each do |name, svc|
      begin
        services << new(ensure: :present,
                        name:   name,
                        groups: svc.groups,
                        method: svc.method)
      end
    end
    services
  end # self.instances

  def self.prefetch(resources)
    services = instances
    resources.keys.each do |name|
      provider = services.find { |svc| svc.name == name }
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

  def properties_set
    return unless @resource[:groups] || @resource[:method]

    # groups and method must be set at the same time
    g = @resource[:groups]
    g ||= @aaa_login_svc.groups
    self.groups = g
    m = @resource[:method]
    m ||= @aaa_login_svc.method
    self.method = m
    @aaa_login_svc.groups_method_set(@property_flush[:groups],
                                     @property_flush[:method])
  end

  # can't autogen groups, special array handling
  def groups
    return [:default] if @resource[:groups] &&
                         @resource[:groups][0] == :default &&
                         @property_hash[:groups] ==
                         @aaa_login_svc.default_groups
    @property_hash[:groups]
  end

  def groups=(set_value)
    if set_value.is_a?(Array) && set_value[0] == :default
      set_value = @aaa_login_svc.default_groups
    end
    @property_flush[:groups] = set_value.flatten
  end

  def flush
    if @property_flush[:ensure] == :absent
      @aaa_login_svc.destroy
      @aaa_login_svc = nil
    else
      # Create/Update
      if @aaa_login_svc.nil?
        @aaa_login_svc = Cisco::AaaAuthorizationService.new(:commands,
                                                            @resource[:name])
      end
      properties_set
    end
    puts_exec
  end

  def puts_exec
    debug 'Current state:'
    if @aaa_login_svc.nil?
      debug 'No aaa login exec service'
      return
    end
    debug "
        name: #{@resource[:name]}
      method: #{@aaa_login_svc.method}
      groups: #{@aaa_login_svc.groups}
    "
  end # puts_exec
end # Puppet::Type
