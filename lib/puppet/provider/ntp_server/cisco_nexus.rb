require 'puppet/resource_api/simple_provider'

# Implementation for the ntp_server type using the Resource API.
class Puppet::Provider::NtpServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context, servers=nil)
    require 'cisco_node_utils'
    current_states = []
    @ntpservers ||= Cisco::NtpServer.ntpservers
    if servers.nil? || servers.empty?
      @ntpservers.each do |server, instance|
        current_states << get_current_state(server, instance)
      end
    else
      servers.each do |server|
        individual_server = @ntpservers[server]
        next if individual_server.nil?
        current_states << get_current_state(server, individual_server)
      end
    end
    current_states
  end

  def get_current_state(name, instance)
    {
      name:    name,
      ensure:  'present',
      key:     instance.key ? instance.key.to_i : instance.key,
      prefer:  instance.prefer,
      maxpoll: instance.maxpoll ? instance.maxpoll.to_i : instance.maxpoll,
      minpoll: instance.minpoll ? instance.minpoll.to_i : instance.minpoll,
      vrf:     instance.vrf,
    }
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @ntpservers ||= Cisco::NtpServer.ntpservers
    @ntpservers[name].destroy
  end

  def update(context, name, should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    @ntpservers ||= Cisco::NtpServer.ntpservers
    @ntpservers[name].destroy unless @ntpservers[name].nil?
    options = { 'name' => name }
    [:key, :prefer, :maxpoll, :minpoll, :vrf].each do |option|
      options[option.to_s] = should[option].to_s if should[option]
    end

    Cisco::NtpServer.new(options)
  end

  alias create update
end
