# Implementation for the network_snmp type using the Resource API.
class Puppet::Provider::NetworkSnmp::CiscoNexus
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, _names=nil)
    require 'cisco_node_utils'

    @network_snmp ||= Cisco::SnmpServer.new

    current_state = {
      name:     'default',
      enable:   @network_snmp.protocol? ? true : false,
      contact:  @network_snmp.contact.empty? ? 'unset' : @network_snmp.contact,
      location: @network_snmp.location.empty? ? 'unset' : @network_snmp.location,
    }

    [current_state]
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      context.updating(name) do
        update(context, name, should)
      end
    end
  end

  def create(_context, name, should)
    raise Puppet::ResourceError, "Can't create new SNMP server settings '#{name}' with #{should.inspect}"
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    @network_snmp ||= Cisco::SnmpServer.new
    if should[:contact]
      @network_snmp.contact = should[:contact] == 'unset' ? '' : should[:contact]
    end
    if should[:location]
      @network_snmp.location = should[:location] == 'unset' ? '' : should[:location]
    end
    @network_snmp.protocol = should[:enable] unless should[:enable].nil?
  end

  def delete(_context, name)
    raise Puppet::ResourceError, "Can't delete SNMP server settings '#{name}'"
  end
end
