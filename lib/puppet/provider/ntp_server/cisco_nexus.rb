require 'puppet/resource_api/simple_provider'

# Implementation for the ntp_server type using the Resource API.
class Puppet::Provider::NtpServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context, servers=nil)
    current_states = []
    if servers.nil? || servers.empty?
      @ntpservers ||= Cisco::NtpServer.ntpservers
      @ntpservers.each do |server, instance|
        server_result = {
          name:    server,
          ensure:  'present',
          key:     instance.key,
          prefer:  instance.prefer,
          maxpoll: instance.maxpoll ? instance.maxpoll.to_i : instance.maxpoll,
          minpoll: instance.minpoll ? instance.minpoll.to_i : instance.minpoll,
          vrf:     instance.vrf,
        }
        current_states << server_result
      end
    else
      servers.each do |server|
        @ntpservers ||= Cisco::NtpServer.ntpservers
        individual_server = @ntpservers[server]
        next if individual_server.nil?
        server_result = {
          name:    server,
          ensure:  'present',
          key:     individual_server.key,
          prefer:  individual_server.prefer,
          maxpoll: individual_server.maxpoll ? individual_server.maxpoll.to_i : individual_server.maxpoll,
          minpoll: individual_server.minpoll ? individual_server.minpoll.to_i : individual_server.minpoll,
          vrf:     individual_server.vrf,
        }
        current_states << server_result
      end
    end
    current_states
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
