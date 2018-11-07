require 'puppet/resource_api/simple_provider'

# Implementation for the syslog_facility type using the Resource API.
class Puppet::Provider::SyslogFacility::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, facilities=nil)
    require 'cisco_node_utils'
    current_states = []
    @syslog_facilities ||= Cisco::SyslogFacility.facilities
    if facilities.nil? || facilities.empty?
      @syslog_facilities.each do |facility, instance|
        current_states << get_current_state(facility, instance)
      end
    else
      facilities.each do |facility|
        individual_facility = @syslog_facilities[facility]
        next if individual_facility.nil?
        current_states << get_current_state(facility, individual_facility)
      end
    end
    current_states
  end

  def get_current_state(facility, instance)
    {
      name:     facility,
      ensure:   'present',
      level:    instance.level,
    }
  end

  def update(context, name, should)
    context.notice("Setting '#{name}' with #{should.inspect}")
    Cisco::SyslogFacility.new('facility' => name,
                              'level' => should[:level].to_s)
  end

  alias create update

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @syslog_facilities ||= Cisco::SyslogFacility.facilities
    @syslog_facilities[name].destroy if @syslog_facilities[name]
  end
end
