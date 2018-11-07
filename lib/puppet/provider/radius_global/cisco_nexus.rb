module Puppet; end # rubocop:disable Style/Documentation
module Puppet::ResourceApi
  # Implementation for the radius_global type using the Resource API.
  class Puppet::Provider::RadiusGlobal::CiscoNexus
    def canonicalize(_contaxt, resources)
      require 'cisco_node_utils'
      resources.each do |resource|
        resource[:key] = resource[:key].gsub(/\A"|"\Z/, '') if resource[:key]
      end
      resources
    end

    def set(context, changes)
      changes.each do |name, change|
        is = change[:is]
        should = change[:should]

        if should != is
          update(context, name, should)
        end
      end
    end

    def get(_context, _names=nil)
      require 'cisco_node_utils'
      @radius_global ||= Cisco::RadiusGlobal.new('default')

      current_state = {
        name:             'default',
        timeout:          @radius_global.timeout ? @radius_global.timeout : -1,
        retransmit_count: @radius_global.retransmit_count ? @radius_global.retransmit_count : -1,
        key:              @radius_global.key ? @radius_global.key.gsub(/\A"|"\Z/, '') : 'unset',
        # Only return the key format if there is a key configured
        key_format:       @radius_global.key.nil? || @radius_global.key.empty? ? nil : @radius_global.key_format,
        source_interface: @radius_global.source_interface.nil? || @radius_global.source_interface.empty? ? ['unset'] : [@radius_global.source_interface],
      }

      [current_state]
    end

    def update(context, name, should)
      validate_should(should)
      context.notice("Updating '#{name}' with #{should.inspect}")
      @radius_global ||= Cisco::RadiusGlobal.new('default')
      [:retransmit_count, :source_interface, :timeout].each do |property|
        next unless should[property]
        # Other platforms require array for some types - Nexus does not
        should[property] = should[property][0] if should[property].is_a?(Array)
        should[property] = nil if should[property] == 'unset'
        @radius_global.send("#{property}=", should[property]) if @radius_global.respond_to?("#{property}=")
      end

      # Handle key and keyformat setting
      @radius_global.key_set(munge(should[:key]), should[:key_format]) if munge(should[:key])
    end

    def munge(value)
      if value.eql?('unset')
        nil
      else
        value
      end
    end

    def validate_should(should)
      raise Puppet::ResourceError, '`name` must be `default`' if should[:name] != 'default'
      raise Puppet::ResourceError, 'This provider does not support the `enable` property.' if should[:enable]
      raise Puppet::ResourceError, 'The `key` property must be set when specifying `key_format`.' if should[:key_format] && (!should[:key] || should[:key] == 'unset')
      raise Puppet::ResourceError, 'This provider does not support the `vrf` property.' if should[:vrf]
    end
  end
end
