require 'puppet/resource_api/simple_provider'

# Implementation for the tacacs_server_group type using the Resource API.
class Puppet::Provider::TacacsServerGroup::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:servers] = resource[:servers].sort_by(&:to_i) if resource[:servers]
    end
  end

  def get(_context, servers=nil)
    require 'cisco_node_utils'
    current_states = []
    # using = instead of ||= due to creation behaviour and having
    # to reevaluate the hosts upon creation
    @tacacs_servers = Cisco::TacacsServerGroup.tacacs_server_groups
    if servers.nil? || servers.empty?
      @tacacs_servers.each do |server, instance|
        current_states << get_current_state(server, instance)
      end
    else
      servers.each do |server|
        individual_server = @tacacs_servers[server]
        next if individual_server.nil?
        current_states << get_current_state(server, individual_server)
      end
    end
    current_states
  end

  def get_current_state(server, instance)
    {
      name:     server,
      ensure:   'present',
      servers:  instance.servers.empty? ? ['unset'] : instance.servers.sort_by(&:to_i),
    }
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    handle_update(name, should)
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    Cisco::TacacsServerGroup.new(name)
    handle_update(name, should)
  end

  def handle_update(name, should)
    @tacacs_servers = Cisco::TacacsServerGroup.tacacs_server_groups
    @tacacs_servers[name].servers = munge(should[:servers]) if should[:servers]
  end

  def munge(value)
    if value.is_a?(Array) && value.length == 1 && value[0].eql?('unset')
      []
    else
      value
    end
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @tacacs_servers = Cisco::TacacsServerGroup.tacacs_server_groups
    @tacacs_servers[name].destroy if @tacacs_servers[name]
  end
end
