require 'puppet/resource_api/simple_provider'

# Implementation for the ntp_auth_key type using the Resource API.
class Puppet::Provider::NtpAuthKey::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context, keys=nil)
    require 'cisco_node_utils'
    current_states = []
    if keys.nil? || keys.empty?
      @ntpkeys ||= Cisco::NtpAuthKey.ntpkeys
      @ntpkeys.each do |key, instance|
        key = {
          name:      key,
          ensure:    'present',
          algorithm: instance.algorithm,
          mode:      instance.mode.to_i,
          password:  instance.password,
        }
        current_states << key
      end
    else
      keys.each do |key|
        @ntpkeys ||= Cisco::NtpAuthKey.ntpkeys
        key = @ntpkeys[key]
        next if key.nil?
        key_result = {
          name:      key.name,
          ensure:    'present',
          algorithm: key.algorithm,
          mode:      key.mode.to_i,
          password:  key.password,
        }
        current_states << key_result
      end
    end
    current_states
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
    @ntpkeys ||= Cisco::NtpAuthKey.ntpkeys
    @ntpkeys[name].destroy
  end

  def validate_should(should)
    raise Puppet::ResourceError, 'Invalid name, must be 1-65535' if should[:name].to_i > 65_535 || should[:name].to_i.zero?
    raise Puppet::ResourceError, 'Invalid password length, max length is 15' if should[:password] && should[:password].length > 15
    raise Puppet::ResourceError, 'Invalid mode, supported modes are 0 and 7' if should[:mode] && ![0, 7].include?(should[:mode])
  end
end
