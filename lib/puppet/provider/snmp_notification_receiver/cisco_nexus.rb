require 'puppet/resource_api/simple_provider'

# Implementation for the snmp_notification_receiver type using the Resource API.
class Puppet::Provider::SnmpNotificationReceiver::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def get(_context, receivers=nil)
    require 'cisco_node_utils'
    current_states = []
    @snmp_notification_receivers ||= Cisco::SnmpNotificationReceiver.receivers
    if receivers.nil? || receivers.empty?
      @snmp_notification_receivers.each do |receiver, instance|
        current_states << get_current_state(receiver, instance)
      end
    else
      receivers.each do |receiver|
        individual_receiver = @snmp_notification_receivers[receiver]
        next if individual_receiver.nil?
        current_states << get_current_state(receiver, individual_receiver)
      end
    end
    current_states
  end

  def get_current_state(receiver, instance)
    {
      name:             receiver,
      ensure:           'present',
      port:             instance.port.to_i,
      username:         instance.username,
      version:          instance.version.prepend('v').delete('c'),
      type:             instance.type,
      security:         instance.security,
      vrf:              instance.vrf,
      source_interface: instance.source_interface,
    }
  end

  def update(context, name, should)
    validate_should(should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    Cisco::SnmpNotificationReceiver.new(name,
                                        instantiate:      true,
                                        type:             munge(should[:type]) || '',
                                        security:         should[:version].eql?('v3') ? munge(should[:security]) || '' : '',
                                        version:          should[:version].eql?('v2') ? should[:version].delete('v') << 'c' : should[:version].delete('v'),
                                        username:         munge(should[:username]) || '',
                                        port:             munge(should[:port]) || '',
                                        vrf:              munge(should[:vrf]) || '',
                                        source_interface: munge(should[:source_interface]) || '')
  end

  alias create update

  def munge(val)
    if val.is_a?(String) && val.eql?('unset')
      nil
    elsif val.is_a?(Integer)
      val.to_s
    else
      val
    end
  end

  def validate_should(should)
    required = []
    [:type, :version, :username].each do |property|
      required << property unless should[property]
    end
    raise Puppet::ResourceError, "You must specify the following properties: #{required}" unless required.empty?
    raise Puppet::ResourceError, "The 'type' property only supports a setting of 'traps' when 'version' is set to 'v1'" if !should[:type].eql?('traps') && should[:version].eql?('v1')
    raise Puppet::ResourceError, "The 'security' property is only supported when 'version' is set to 'v3'" if should[:security] && !should[:version].eql?('v3')
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @snmp_notification_receivers ||= Cisco::SnmpNotificationReceiver.receivers
    @snmp_notification_receivers[name].destroy if @snmp_notification_receivers[name]
  end
end
