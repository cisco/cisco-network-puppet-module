module Puppet; end # rubocop:disable Style/Documentation
module Puppet::ResourceApi
  # Implementation for the tacacs type using the Resource API.
  class Puppet::Provider::Tacacs::CiscoNexus
    def canonicalize(_context, resources)
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        should = change[:should]

        if should[:enable]
          update(context, name, should)
        else
          delete(context, name)
        end
      end
    end

    def get(_context, _tacacs=nil)
      require 'cisco_node_utils'
      current_state = {
        name:   'default',
        enable: Cisco::TacacsServer.enabled,
      }

      [current_state]
    end

    def delete(context, name)
      context.notice("Disabling tacacs '#{name}' service")
      @tacacs ||= Cisco::TacacsServer.new(false)
      @tacacs.destroy
    end

    def update(context, name, should)
      context.notice("Enabling tacacs '#{name}' with #{should.inspect}")
      @tacacs ||= Cisco::TacacsServer.new(false)
      @tacacs.enable
    end
  end
end
