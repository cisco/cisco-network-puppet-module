require 'puppet/util/network_device/simple/device'
require 'cisco_node_utils'

module Puppet::Util::NetworkDevice::Cisco_nexus # rubocop:disable Style/ClassAndModuleCamelCase
  # Translates from puppet's credential store to nodeutil's environment
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def initialize(url_or_config, _options={})
      super
      Cisco::Environment.add_env('default',
                                 host:        config['address'],
                                 port:        config['port'],
                                 transport:   config['transport'],
                                 verify_mode: config['verify_mode'],
                                 username:    config['username'],
                                 password:    config['password'],
                                )
    end

    def facts
      @facts ||= parse_device_facts
    end

    def parse_device_facts
      require 'facter/cisco_nexus'
      facts = {}

      facts['operatingsystem'] = 'nexus'
      facts['cisco_node_utils'] = CiscoNodeUtils::VERSION

      facts['cisco'] = Facter::CiscoNexus.platform_facts

      facts['hostname'] = Cisco::NodeUtil.node.host_name
      facts['operatingsystemrelease'] = facts['cisco']['images']['full_version']

      facts
    end
  end
end
