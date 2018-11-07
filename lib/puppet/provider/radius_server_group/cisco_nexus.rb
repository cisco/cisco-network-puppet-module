require 'puppet/resource_api/simple_provider'

# Implementation for the radius_server_group type using the Resource API.
class Puppet::Provider::RadiusServerGroup::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, groups=nil)
    require 'cisco_node_utils'

    radius_server_groups = []
    @radiusgroups ||= Cisco::RadiusServerGroup.radius_server_groups

    if groups.nil? || groups.empty?
      @radiusgroups.each_value do |v|
        radius_server_groups << get_current_state(v.name, v)
      end
    else
      groups.each do |group|
        individual_group = @radiusgroups[group]
        next if individual_group.nil?
        radius_server_groups << get_current_state(individual_group.name, individual_group)
      end
    end
    radius_server_groups
  end

  def get_current_state(name, instance)
    {
      ensure:  'present',
      name:    name,
      servers: instance.servers.empty? ? ['unset'] : instance.servers,
    }
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
