require 'puppet/resource_api/simple_provider'

# Implementation for the radius_server_group type using the Resource API.
class Puppet::Provider::RadiusServerGroup::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context)
    require 'cisco_node_utils'

    radius_server_groups = []
    Cisco::RadiusServerGroup.radius_server_groups.each_value do |v|
      radius_server_groups << {
        ensure:  'present',
        name:    v.name,
        servers: v.servers.empty? ? ['unset'] : v.servers,
      }
    end

    radius_server_groups
  end

  def munge(val)
    if val.is_a?(Array) && val.length == 1 && val[0].eql?('unset')
      []
    else
      val
    end
  end

  def create_update(name, should, create_bool)
    radius_server_group = Cisco::RadiusServerGroup.new(name, create_bool)
    radius_server_group.servers = munge(should[:servers]) if should[:servers]
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    create_update(name, should, true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    create_update(name, should, false)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    radius_server_group = Cisco::RadiusServerGroup.new(name, false)
    radius_server_group.destroy
  end
end
