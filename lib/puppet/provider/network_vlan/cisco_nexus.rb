require 'puppet/resource_api/simple_provider'
require 'cisco_node_utils'

# Implementation for the network_vlan type using the Resource API.
class Puppet::Provider::NetworkVlan::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context)
    vlan_instances = []
    Cisco::Vlan.vlans.each do |vlan_id, v|
      vlan = {
        ensure:    'present',
        id:        vlan_id,
        vlan_name: v.send(:vlan_name),
        shutdown:  v.send(:shutdown),
      }
      vlan_instances << vlan
    end
    vlan_instances
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
