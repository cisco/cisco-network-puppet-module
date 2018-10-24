require 'puppet/resource_api/simple_provider'

# Implementation for the domain_name type using the Resource API.
class Puppet::Provider::DomainName::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context)
    require 'cisco_node_utils'
    current_state = []
    @domains ||= Cisco::DomainName.domainnames
    @domains.each_key do |id|
      current_state << {
        name:     id,
        ensure:   'present',
      }
    end
    current_state
  end

  def create(_context, name, _should)
    Cisco::DomainName.new(name)
  end

  def delete(_context, name)
    @domains ||= Cisco::DomainName.domainnames
    @domains[name].destroy
  end
end
