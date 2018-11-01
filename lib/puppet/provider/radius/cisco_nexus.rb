require 'puppet/resource_api/simple_provider'
require 'cisco_node_utils'

# Basic implementation for the radius type using the Resource API.
class Puppet::Provider::Radius::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  # NOTE that we just return default name
  def get(_context)
    radius = []
    radius << {
      name: 'default'
    }
    radius
  end

  # Does not create / update / delete
  def create(context, name, should)
    context.notice("No operation in creating '#{name}' with #{should.inspect}")
  end

  def update(context, name, should)
    context.notice("No operation in updating '#{name}' with #{should.inspect}")
  end

  def delete(context, name)
    context.notice("No operation in deleting '#{name}'")
  end
end
