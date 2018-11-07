require 'puppet/resource_api/simple_provider'

# Implementation for the network_vlan type using the Resource API.
class Puppet::Provider::NetworkVlan::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, vlans=nil)
    require 'cisco_node_utils'
    vlan_instances = []
    @vlans ||= Cisco::Vlan.vlans
    if vlans.nil? || vlans.empty?
      @vlans.each do |vlan_id, v|
        vlan_instances << get_current_state(vlan_id, v)
      end
    else
      vlans.each do |vlan|
        individual_vlan = @vlans[vlan]
        next if individual_vlan.nil?
        vlan_instances << get_current_state(vlan, individual_vlan)
      end
    end
    vlan_instances
  end

  def get_current_state(name, instance)
    {
      ensure:    'present',
      id:        name,
      vlan_name: instance.send(:vlan_name),
      shutdown:  instance.shutdown,
    }
  end

  def create_update(name, should, create_bool)
    raise Puppet::ResourceError,
          'Invalid value(non-numeric Vlan id)' unless name[/^\d+$/]
    @vlan = Cisco::Vlan.new(name, create_bool)
    # Send shutdown= should[shutdown] if shutdown (get) is not already set
    # to should[shutdown]
    @vlan.shutdown = should[:shutdown] if @vlan.shutdown != should[:shutdown]
    @vlan.vlan_name = should[:vlan_name] if should[:vlan_name] && @vlan.vlan_name != should[:vlan_name]
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
    @vlan = Cisco::Vlan.new(name, false)
    @vlan.destroy
    @vlan = nil
  end
end
