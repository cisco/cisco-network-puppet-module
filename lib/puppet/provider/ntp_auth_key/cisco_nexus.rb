# Copyright (c) 2018 Cisco and/or its affiliates.
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
require 'puppet/resource_api/simple_provider'

# Implementation for the ntp_auth_key type using the Resource API.
class Puppet::Provider::NtpAuthKey::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, keys=nil)
    require 'cisco_node_utils'
    current_states = []
    if keys.nil? || keys.empty?
      @ntpkeys = Cisco::NtpAuthKey.ntpkeys
      @ntpkeys.each do |key, instance|
        current_states << get_current_state(key, instance)
      end
    else
      keys.each do |key|
        @ntpkeys = Cisco::NtpAuthKey.ntpkeys
        instance = @ntpkeys[key]
        next if instance.nil?
        current_states << get_current_state(instance.name, instance)
      end
    end
    current_states
  end

  def get_current_state(name, instance)
    {
      name:      name,
      ensure:    'present',
      algorithm: instance.algorithm,
      mode:      instance.mode.to_i,
      password:  instance.password,
    }
  end

  def update(context, name, should)
    validate_should(should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    options = { 'name' => name }
    [:algorithm, :mode, :password].each do |option|
      options[option.to_s] = should[option] if should[option]
    end
    Cisco::NtpAuthKey.new(options)
  end

  alias create update

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @ntpkeys = Cisco::NtpAuthKey.ntpkeys
    @ntpkeys[name].destroy
  end

  def validate_should(should)
    raise Puppet::ResourceError, 'Invalid name, must be 1-65535' if should[:name].to_i > 65_535 || should[:name].to_i.zero?
    raise Puppet::ResourceError, 'Invalid password length, max length is 15' if should[:password] && should[:password].length > 15
    raise Puppet::ResourceError, 'Invalid mode, supported modes are 0 and 7' if should[:mode] && ![0, 7].include?(should[:mode])
  end
end
