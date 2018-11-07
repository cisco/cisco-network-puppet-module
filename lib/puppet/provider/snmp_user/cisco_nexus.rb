require 'puppet/resource_api/simple_provider'

# Implementation for the snmp_user type using the Resource API.
class Puppet::Provider::SnmpUser::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, users=nil)
    require 'cisco_node_utils'
    current_states = []
    @snmpusers ||= Cisco::SnmpUser.users
    if users.nil? || users.empty?
      @snmpusers.each do |user, instance|
        current_states << get_current_state(user, instance)
      end
    else
      users.each do |user|
        individual_user = @snmpusers[user]
        next if individual_user.nil?
        current_states << get_current_state(user, individual_user)
      end
    end
    current_states
  end

  def get_current_state(user, instance)
    {
      name:           user,
      ensure:         'present',
      engine_id:      instance.engine_id,
      roles:          instance.groups,
      auth:           instance.auth_protocol.to_s == 'none' ? nil : instance.auth_protocol.to_s,
      password:       instance.auth_password,
      privacy:        instance.priv_protocol.to_s == 'none' ? nil : instance.priv_protocol.to_s,
      private_key:    instance.priv_password,
      # FM-7548 - device has no ability to check localized_key
      # as localized_key is a flag to determine if the `private_key`
      # and/or `password` should be hashed, if it is `false` during
      # a creation/update then it will auto hash the entered value
      # which means on a `get` the `private_key` and `password` will
      # be in a hashed format - which is why we always return `true`
      # if the snmp_user has either a `password` and/or a `private_key`
      localized_key:  instance.auth_password || instance.priv_password ? true : nil,
    }
  end

  def delete(context, name)
    raise Puppet::ResourceError, 'The admin account cannot be deactivated on this platform.' if name == 'admin'
    context.notice("Destroying '#{name}'")
    @snmpusers ||= Cisco::SnmpUser.users
    @snmpusers[name].destroy if @snmpusers[name]
  end

  def update(context, name, should)
    validate_should(should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    Cisco::SnmpUser.new(name,
                        should[:roles] || [],
                        should[:auth] ? should[:auth].to_sym : :none,
                        should[:password] || '',
                        should[:privacy] ? should[:privacy].to_sym : :none,
                        should[:private_key] || '',
                        should[:localized_key] ? true : false,
                        should[:engine_id] || '')
  end

  alias create update

  def validate_should(should)
    unless should[:auth]
      invalid = []
      [:password, :privacy, :private_key, :localized_key, :engine_id].each do |property|
        invalid << property if should[property]
      end
      raise Puppet::ResourceError, "You must specify the 'auth' property when specifying any of the following properties: #{invalid}" unless invalid.empty?
    end
    raise Puppet::ResourceError, "The 'password' property must be set when specifying 'auth'" if should[:password].nil? && should[:auth]
    raise Puppet::ResourceError, "The 'private_key' property must be set when specifying 'privacy'" if should[:private_key].nil? && should[:privacy]
    raise Puppet::ResourceError, "The 'engine_id' and 'roles' properties are mutually exclusive" if should[:engine_id] && should[:roles]
    raise Puppet::ResourceError, "The 'enforce_privacy' property is not supported by this provider" if should[:enforce_privacy]
  end
end
