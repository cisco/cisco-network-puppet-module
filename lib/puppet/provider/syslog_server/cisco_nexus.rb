require 'puppet/resource_api/simple_provider'

# Implementation for the syslog_server type using the Resource API.
class Puppet::Provider::SyslogServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, servers=nil)
    require 'cisco_node_utils'
    current_states = []
    @syslog_servers ||= Cisco::SyslogServer.syslogservers
    if servers.nil? || servers.empty?
      @syslog_servers.each do |server, instance|
        current_states << get_current_state(server, instance)
      end
    else
      servers.each do |server|
        individual_server = @syslog_servers[server]
        next if individual_server.nil?
        current_states << get_current_state(server, individual_server)
      end
    end
    current_states
  end

  def get_current_state(server, instance)
    {
      name:             server,
      ensure:           'present',
      severity_level:   instance.severity_level.nil? ? instance.severity_level : instance.severity_level.to_i,
      port:             instance.port.nil? ? instance.port : instance.port.to_i,
      vrf:              instance.vrf,
      facility:         instance.facility,
    }
  end

  def update(context, name, should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    options = { 'name' => name }
    [:severity_level, :port, :vrf, :facility].each do |property|
      next unless should[property]
      options[property.to_s] = should[property].to_s
    end
    Cisco::SyslogServer.new(options)
  end

  alias create update

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @syslog_servers ||= Cisco::SyslogServer.syslogservers
    @syslog_servers[name].destroy if @syslog_servers[name]
  end
end
