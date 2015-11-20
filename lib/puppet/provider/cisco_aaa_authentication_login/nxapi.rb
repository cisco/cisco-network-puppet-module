# The NXAPI (cisco_aaa_authentication_login) provider.
#
# November, 2015
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_aaa_authentication_login).provide(:nxapi) do
  desc 'The nxapi provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  AAA_AUTHE_PROPS = [:ascii_authentication,
                     :chap,
                     :error_display,
                     :mschap,
                     :mschapv2]

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@aaa_authe_login',
                                            AAA_AUTHE_PROPS)

  def initialize(value={})
    super(value)
    @aaa_authe_login = Cisco::AaaAuthenticationLogin
    @property_flush = {}
    debug 'Created provider instance of cisco_aaa_authentication_login.'
  end

  def self.instances
    inst = []
    authe_login = Cisco::AaaAuthenticationLogin

    inst << new(
      ensure:               :present,
      name:                 'default', # necessary for puppet resource cmd
      ascii_authentication: authe_login.ascii_authentication ? :true : :false,
      chap:                 authe_login.chap ? :true : :false,
      error_display:        authe_login.error_display ? :true : :false,
      mschap:               authe_login.mschap ? :true : :false,
      mschapv2:             authe_login.mschapv2 ? :true : :false)
    debug 'Created new resource type cisco_aaa_authentication_login'
    inst
  end

  def self.prefetch(resources)
    resources.values.first.provider = instances.first
  end

  def properties_set
    # any current method of authentication must be turned off before a new
    # intended method can be turned on, so configuration order is important
    off_props = AAA_AUTHE_PROPS.select do |prop|
      @resource[prop] && @property_flush[prop] == false
    end
    on_props = AAA_AUTHE_PROPS.select do |prop|
      @resource[prop] && @property_flush[prop] == true
    end
    # add on_props to the end of off_props so they're configured last
    off_props.concat(on_props).each do |prop|
      @aaa_authe_login.send("#{prop}=", @property_flush[prop]) if
        @aaa_authe_login.respond_to?("#{prop}=")
    end
  end

  def flush
    properties_set
    put_aaa_authe_login
  end

  def put_aaa_authe_login
    debug 'Current state:'
    return if @aaa_authe_login.nil?

    debug "
      ascii_authentication: #{@aaa_authe_login.ascii_authentication}
                      chap: #{@aaa_authe_login.chap}
             error_display: #{@aaa_authe_login.error_display}
                    mschap: #{@aaa_authe_login.mschap}
                  mschapv2: #{@aaa_authe_login.mschapv2}
    "
  end
end
