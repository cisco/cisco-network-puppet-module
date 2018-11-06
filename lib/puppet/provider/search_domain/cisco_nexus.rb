require 'puppet/resource_api/simple_provider'

# Implementation for the search_domain type using the Resource API.
class Puppet::Provider::SearchDomain::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, domains=nil)
    require 'cisco_node_utils'
    current_states = []
    if domains.nil? || domains.empty?
      @domainnames ||= Cisco::DomainName.domainnames
      @domainnames.each do |name, instance|
        current_states << get_current_state(name, instance)
      end
    else
      domains.each do |domain|
        @domainnames ||= Cisco::DomainName.domainnames
        domainname = @domainnames[domain]
        next if domainname.nil?
        current_states << get_current_state(domain, domainname)
      end
    end
    current_states
  end

  def get_current_state(name, _instance)
    {
      name:   name,
      ensure: 'present',
    }
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    Cisco::DomainName.new(name)
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @domainnames ||= Cisco::DomainName.domainnames
    @domainnames[name].destroy
  end
end
