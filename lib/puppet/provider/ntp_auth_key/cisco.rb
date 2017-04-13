# April, 2017
#
# Copyright (c) 2014-2017 Cisco and/or its affiliates.
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

Puppet::Type.type(:ntp_auth_key).provide(:cisco) do
  desc 'The Cisco provider for ntp_auth_key.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  NTP_AUTH_KEY_ALL_PROPS = [
    :algorithm,
    :mode,
    :password,
  ]

  def initialize(value={})
    super(value)
    @ntpkey = Cisco::NtpAuthKey.ntpkeys[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of ntp_auth_key'
  end

  def self.properties_get(key, v)
    debug "Checking instance, ntp_auth_key #{key}"

    current_state = {
      name:      key,
      ensure:    :present,
      algorithm: v.algorithm,
      mode:      v.mode,
      password:  v.password,
    }

    new(current_state)
  end # self.properties_get

  def self.instances
    ntpkeys = []
    Cisco::NtpAuthKey.ntpkeys.each do |key, v|
      ntpkeys << properties_get(key, v)
    end

    ntpkeys
  end

  def self.prefetch(resources)
    ntpkeys = instances

    resources.keys.each do |id|
      provider = ntpkeys.find { |ntpserver| ntpserver.name == id.to_s }
      resources[id].provider = provider unless provider.nil?
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

  def flush
    if @property_flush[:ensure] == :absent
      @ntpkey.destroy
      @ntpkey = nil
    else
      # Create/Update
      # Create new instance with configured options
      opts = { 'name' => @resource[:name] }
      NTP_AUTH_KEY_ALL_PROPS.each do |prop|
        next unless @resource[prop]
        opts[prop.to_s] = @resource[prop].to_s
      end

      begin
        @ntpkey = Cisco::NtpAuthKey.new(opts)
      rescue Cisco::CliError => e
        error "Unable to set new values: #{e.message}"
      end
    end
    # puts_config
  end
end # Puppet::Type
