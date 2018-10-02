require 'puppet/util/network_device/simple/device'
require 'cisco_node_utils'

module Puppet::Util::NetworkDevice::Nexus
  # Translates from puppet's credential store to nodeutil's environment
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def initialize(url_or_config, _options={})
      super
      Cisco::Environment.add_env('default',
                                 host:     config['address'],
                                 port:     nil,
                                 username: config['username'],
                                 password: config['password'],
                                )
    end

    def facts
      @facts ||= parse_device_facts
    end

    def parse_device_facts
      facts = {}

      platform = Cisco::Platform
      feature = Cisco::Feature

      facts['operatingsystem'] = 'nexus'
      facts['cisco_node_utils'] = CiscoNodeUtils::VERSION
      cisco_facts = {}
      cisco_facts['images'] = {}
      cisco_facts['images']['system_image'] = platform.system_image
      cisco_facts['images']['full_version'] = platform.image_version

      cisco_facts['images']['packages'] = platform.packages

      cisco_facts['hardware'] = {}
      cisco_facts['hardware']['type'] = platform.hardware_type
      cisco_facts['hardware']['cpu'] = platform.cpu
      cisco_facts['hardware']['memory'] = platform.memory
      cisco_facts['hardware']['board'] = platform.board
      cisco_facts['hardware']['last_reset'] = platform.last_reset
      cisco_facts['hardware']['reset_reason'] = platform.reset_reason

      cisco_facts['inventory'] = {}
      cisco_facts['inventory']['chassis'] = platform.chassis
      platform.slots.each do |slot, info|
        cisco_facts['inventory'][slot] = info
      end
      platform.power_supplies.each do |ps, info|
        cisco_facts['inventory'][ps] = info
      end
      platform.fans.each do |fan, info|
        cisco_facts['inventory'][fan] = info
      end

      cisco_facts['virtual_service'] = platform.virtual_services

      cisco_facts['feature_compatible_module_iflist'] = {}
      interface_list = feature.compatible_interfaces('fabricpath')
      cisco_facts['feature_compatible_module_iflist']['fabricpath'] = interface_list
      cisco_facts['hardware']['uptime'] = platform.uptime

      facts['cisco'] = cisco_facts

      facts['hostname'] = Cisco::NodeUtil.node.host_name
      facts['operatingsystemrelease'] = facts['cisco']['images']['full_version']

      facts
    end
  end
end
