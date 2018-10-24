require 'puppet/resource_api/simple_provider'

# Resource API provider for NameServer
class Puppet::Provider::NameServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context)
    require 'cisco_node_utils'
    nameserver_instances = []
    @name_servers = Cisco::NameServer.nameservers
    @name_servers.each_key do |id|
      individual_name_server ||= Cisco::NameServer.new(id, false)
      current_name_server = {
        ensure: 'present',
        name: "#{individual_name_server.name}"
      }

      nameserver_instances << current_name_server
    end
    nameserver_instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    Cisco::NameServer.new(name)
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @name_servers ||= Cisco::NameServer.nameservers
    @name_servers[name].destroy
  end
end
