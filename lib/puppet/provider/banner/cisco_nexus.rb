module Puppet; end # rubocop:disable Style/Documentation
module Puppet::ResourceApi
  # Implementation for the banner type using the Resource API.
  class Puppet::Provider::Banner::CiscoNexus
    def set(context, changes)
      changes.each do |name, change|
        is = change[:is]
        should = change[:should]

        if should[:motd] != is[:motd]
          update(context, name, should)
        end
      end
    end

    def get(_context)
      require 'cisco_node_utils'
      @banner ||= Cisco::Banner.new('default')

      current_state = {
        name:     'default',
        motd:     "#{@banner.motd}",
      }

      [current_state]
    end

    def update(context, name, should)
      validate_name(name)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @banner ||= Cisco::Banner.new('default')
      @banner.motd = should[:motd]
    end

    def validate_name(name)
      raise Puppet::ResourceError, '`name` must be `default`' if name != 'default'
    end
  end
end
