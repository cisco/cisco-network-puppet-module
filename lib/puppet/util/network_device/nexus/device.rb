require 'puppet/util/network_device/simple/device'
require 'cisco_node_utils'

module Puppet::Util::NetworkDevice::Nexus
  # Translates from puppet's credential store to nodeutil's environment
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def initialize(url_or_config, _options={})
      super
      Cisco::Environment.add_env('default',
                                 host: config['address'],
                                 port: nil,
                                 username: config['username'],
                                 password: config['password'],
                                )
    end

    def facts
      {}
    end
  end
end
