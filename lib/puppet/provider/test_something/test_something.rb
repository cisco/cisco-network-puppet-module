require 'puppet/resource_api/simple_provider'

# Implementation for the test_something type using the Resource API.
class Puppet::Provider::TestSomething::TestSomething < Puppet::ResourceApi::SimpleProvider
  def get(_context)
    # cause a hard error at runtime if the library is not installed yet
    require 'cisco_node_utils'

    @network_snmp ||= Cisco::SnmpServer.new

    current_state = {
      name:     'default',
      ensure:   'present',
      enable:   (@network_snmp.protocol? || context.device.facts['operatingsystem'] == 'ios_xr') ? true : false,
      contact:  @network_snmp.contact.empty? ? 'unset' : @network_snmp.contact,
      location: @network_snmp.location.empty? ? 'unset' : @network_snmp.location,
    }

    [current_state]
  end

  def create(_context, name, should)
    raise Puppet::ResourceError, "Can't create new SNMP server settings '#{name}' with #{should.inspect}"
  end

  def update(context, name, should)
    require 'cisco_node_utils'
    context.notice("Updating '#{name}' with #{should.inspect}")
    @network_snmp ||= Cisco::SnmpServer.new
    @network_snmp.contact = should[:contact] == 'unset' ? '' : should[:contact]
    @network_snmp.location = should[:location] == 'unset' ? '' : should[:location]
    @network_snmp.protocol = should[:enable]
  end

  def delete(_context, name)
    raise Puppet::ResourceError, "Can't delete SNMP server settings '#{name}'"
  end
end
