require 'puppet/resource_api/simple_provider'

# Implementation for the domain_name type using the Resource API.
class Puppet::Provider::DomainName::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, domains=nil)
    require 'cisco_node_utils'
    current_state = []
    @domains ||= Cisco::DomainName.domainnames
    if domains.nil? || domains.empty?
      @domains.each_key do |id|
        current_state << get_current_state(id)
      end
    else
      domains.each do |domain|
        next if @domains[domain].nil?
        current_state << get_current_state(domain)
      end
    end
    current_state
  end

  def get_current_state(name)
    {
      name:     name,
      ensure:   'present',
    }
  end

  def create(_context, name, _should)
    Cisco::DomainName.new(name)
  end

  def delete(_context, name)
    @domains ||= Cisco::DomainName.domainnames
    @domains[name].destroy
  end
end
