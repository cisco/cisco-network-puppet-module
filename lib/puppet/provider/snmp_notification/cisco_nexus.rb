module Puppet; end # rubocop:disable Style/Documentation
module Puppet::ResourceApi
  # Implementation for the snmp_notification type using the Resource API.
  class Puppet::Provider::SnmpNotification::CiscoNexus
    def canonicalize(_context, resources)
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        is = if context.type.feature?('simple_get_filter')
               change.key?(:is) ? change[:is] : (get(context, [name]) || []).find { |r| r[:name] == name }
             else
               change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
             end
        context.type.check_schema(is) unless change.key?(:is)

        should = change[:should]

        if should != is
          update(context, name, should)
        end
      end
    end

    def get(_context, notifications=nil)
      require 'cisco_node_utils'
      current_states = []
      if notifications.nil? || notifications.empty?
        @snmp_notifications ||= Cisco::SnmpNotification.notifications
        @snmp_notifications.each do |name, instance|
          current_states << get_current_state(name, instance)
        end
      else
        notifications.each do |notification|
          @snmp_notifications ||= Cisco::SnmpNotification.notifications
          individual_notification = @snmp_notifications[notification]
          next if individual_notification.nil?
          current_states << get_current_state(notification, individual_notification)
        end
      end
      current_states
    end

    def get_current_state(name, instance)
      {
        name:   name,
        enable: instance.enable,
      }
    end

    def update(context, name, should)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @snmp_notifications ||= Cisco::SnmpNotification.notifications
      snmp_notification = @snmp_notifications[name]
      snmp_notification = Cisco::SnmpNotification.new(name) if snmp_notification.nil?
      snmp_notification.enable = should[:enable] unless should[:enable].nil?
    end
  end
end
