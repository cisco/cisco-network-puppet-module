# The Nxapi (cisco_snmp_user) provider.
#
# February, 2015
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

Puppet::Type.type(:cisco_snmp_user).provide(:nxapi) do
  desc 'The NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  def self.instances
    snmp_users = []

    Cisco::SnmpUser.users.each_value do |snmp_user|
      snmp_users << new(
        user:          snmp_user.name,
        name:          "#{snmp_user.name} #{snmp_user.engine_id}".strip,
        ensure:        :present,
        engine_id:     snmp_user.engine_id,
        groups:        snmp_user.groups,
        priv_protocol: snmp_user.priv_protocol,
        priv_password: snmp_user.priv_password,
        auth_protocol: snmp_user.auth_protocol,
        auth_password: snmp_user.auth_password,
        localized_key: :true)
    end
    snmp_users
  end

  def self.prefetch(resources)
    snmp_users = instances
    resources.keys.each do |name|
      provider = snmp_users.find { |snmp_user| snmp_user.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def initialize(value={})
    super(value)
    @snmp_user = Cisco::SnmpUser.users[@property_hash[:name]]
    @localized_key = false

    # When this hash is changed, it means that  one property has
    # changed and needs to flush
    @property_flush = {}
  end

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    info "Creating snmp user #{@property_hash[:name]}"
    @property_flush[:ensure] = :present
  end

  def destroy
    info "Removing snmp user #{@property_hash[:name]}"
    @property_flush[:ensure] = :absent
  end

  def groups
    curr_groups = @property_hash[:groups]
    if @resource[:groups] == ['default']
      if curr_groups.empty? || curr_groups == Cisco::SnmpUser.default_groups
        curr_groups = ['default']
      end
    end
    curr_groups
  end

  def groups=(_should_groups)
    @property_flush[:ensure] = :reconfigure
  end

  def priv_protocol=(_should_priv_protocol)
    @property_flush[:ensure] = :reconfigure
  end

  def priv_password_in_sync?
    return false if @snmp_user.nil?

    if @resource[:priv_password]
      return @snmp_user.priv_password_equal?(
        @resource[:priv_password], (@resource[:localized_key] == :true))
    else
      return true
    end
  end

  def priv_password=(_should_password)
    @property_flush[:ensure] = :reconfigure
  end

  def auth_protocol=(_should_auth_protocol)
    @property_flush[:ensure] = :reconfigure
  end

  def auth_password_in_sync?
    return false if @snmp_user.nil?

    if @resource[:auth_password]
      return @snmp_user.auth_password_equal?(
        @resource[:auth_password], (@resource[:localized_key] == :true))
    else
      return true
    end
  end

  def auth_password=(_should_password)
    @property_flush[:ensure] = :reconfigure
  end

  def configure_snmp_user
    debug "Configuring snmp user for user #{@resource[:user]}"

    config = handle_attribute_update

    debug 'Creating a snmp user, '          \
      "name #{@resource[:user]}, "          \
      "groups #{config[:groups]}, "                 \
      "auth_protocol #{config[:auth_protocol]}, "   \
      "auth_password #{config[:auth_password]}, "   \
      "priv_protocol #{config[:priv_protocol]}, "   \
      "priv_password #{config[:priv_password]}, "   \
      "engine id #{@resource[:engine_id]}, "\
      "localized_key #{@localized_key}. "

    @snmp_user = Cisco::SnmpUser.new(@resource[:user],
                                     config[:groups],
                                     config[:auth_protocol],
                                     config[:auth_password],
                                     config[:priv_protocol],
                                     config[:priv_password],
                                     @localized_key,
                                     "#{@resource[:engine_id]}")

    @property_hash[:ensure] = :present
    @property_hash[:groups] = config[:groups]
    @property_hash[:user] = @resource[:user]
    @property_hash[:priv_protocol] = config[:priv_protocol]
    @property_hash[:priv_password] = config[:priv_password]
    @property_hash[:auth_protocol] = config[:auth_protocol]
    @property_hash[:auth_password] = config[:auth_password]
    @property_hash[:localized_key] = @localized_key
    @property_hash[:engine_id] = @resource[:engine_id]
    @property_hash[:name] = @resource[:name]

  rescue RuntimeError => e
    raise e.message + ' The user has been unconfigured.'
  end

  def update_attribute(attribute, default_value=:none)
    if @resource[attribute].nil?
      # there is no such attribute specified in manifest
      if @property_hash[attribute].nil?
        # this is a create action. Since it is not specified anywhere,
        # use default value
        should_value = default_value
      else
        # this is a reconfigure action, since manifest is not specifying
        # the value, use the current configured one
        should_value  = @property_hash[attribute]

        # for passwords, property hash only had hashed password, change
        # localized key to true
        if attribute == :auth_password || attribute == :priv_password
          @localized_key = true
        end
      end
    else
      # manifest specified value. Use it except it is groups
      if attribute != :groups || @resource[:groups] != ['default']
        should_value = @resource[attribute]
      else
        # groups supports default, do not configure
        should_value = []
      end
    end
    should_value
  end

  def handle_attribute_update
    attributes = {
      auth_protocol: update_attribute(:auth_protocol),
      priv_protocol: update_attribute(:priv_protocol),
      auth_password: update_attribute(:auth_password, ''),
      priv_password: update_attribute(:priv_password, ''),
      groups:        update_attribute(:groups, []),
    }

    # If @localized_key is true, it means priv password or auth password have
    # been set as hashed. Otherwise, those password should be consisistent with
    # what have been specified by @resource[:localized_key]
    @localized_key ||= (@resource[:localized_key] == :true)

    attributes
  end

  def unconfigure_snmp_user
    @snmp_user.destroy
    @snmp_user = nil
    @property_hash[:ensure] = :absent
  end

  def flush
    if @property_flush[:ensure] == :absent
      unconfigure_snmp_user
    elsif @property_flush[:ensure] == :present
      configure_snmp_user
    else
      debug "reconfigure #{@resource[:user]} #{@resource[:engine_id]}"
      unconfigure_snmp_user
      configure_snmp_user
    end
  end
end
