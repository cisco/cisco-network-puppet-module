require 'puppet/resource_api/simple_provider'
require 'puppet_x/cisco/cmnutils'

# Implementation for the radius_server type using the Resource API.
class Puppet::Provider::RadiusServer::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:key] = resource[:key].gsub(/\A"|"\Z/, '') if resource[:key]
    end
    resources
  end

  RADIUS_SERVER_PROPS = {
    auth_port:           :auth_port,
    acct_port:           :acct_port,
    timeout:             :timeout,
    retransmit_count:    :retransmit_count,
    accounting_only:     :accounting,
    authentication_only: :authentication,
  }

  UNSUPPORTED_PROPS = [:group, :deadtime, :vrf, :source_interface]

  def get(context, _names=nil)
    require 'cisco_node_utils'

    radius_servers = []
    Cisco::RadiusServer.radiusservers.each_value do |v|
      radius_servers << {
        ensure:               'present',
        name:                 v.name,
        auth_port:            v.auth_port ? v.auth_port : nil,
        acct_port:            v.acct_port ? v.acct_port : nil,
        timeout:              v.timeout ? v.timeout : -1,
        retransmit_count:     v.retransmit_count ? v.retransmit_count : -1,
        key:                  v.key ? v.key.gsub(/\A"|"\Z/, '') : 'unset',
        key_format:           v.key_format ? v.key_format : -1,
        accounting_only:      v.accounting,
        authentication_only:  v.authentication
      }
    end

    PuppetX::Cisco::Utils.enforce_simple_types(context, radius_servers)
  end

  def munge_flush(val)
    if val.is_a?(String) && val.eql?('unset')
      nil
    elsif val.is_a?(Integer) && val.eql?(-1)
      nil
    elsif val.is_a?(Symbol)
      val.to_s
    else
      val
    end
  end

  def validate(should)
    raise Puppet::ResourceError,
          "This provider does not support the 'hostname' property. The namevar should be set to the IP of the Radius Server" \
          if should[:hostname]

    invalid = []
    UNSUPPORTED_PROPS.each do |prop|
      invalid << prop if should[prop]
    end

    raise Puppet::ResourceError, "This provider does not support the following properties: #{invalid}" unless invalid.empty?

    raise Puppet::ResourceError,
          "The 'key' property must be set when specifying 'key_format'." if should[:key_format] && !should[:key]

    raise Puppet::ResourceError,
          "The 'accounting_only' and 'authentication_only' properties cannot both be set to false." if munge_flush(should[:accounting_only]) == false && \
                                                                                                      munge_flush(should[:authentication_only]) == false
  end

  def create_update(name, should, create_bool)
    validate(should)
    radius_server = Cisco::RadiusServer.new(name, create_bool)
    RADIUS_SERVER_PROPS.each do |puppet_prop, cisco_prop|
      if !should[puppet_prop].nil? && radius_server.respond_to?("#{cisco_prop}=")
        radius_server.send("#{cisco_prop}=", munge_flush(should[puppet_prop]))
      end
    end

    # Handle key and keyformat setting
    return unless should[:key]
    radius_server.send('key_set', munge_flush(should[:key]), munge_flush(should[:key_format]))
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
    radius_server = Cisco::RadiusServer.new(name, false)
    radius_server.destroy
  end
end
