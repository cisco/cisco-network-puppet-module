require 'puppet/util/network_device/simple/device'

module Puppet::Util::NetworkDevice::Nexus
  # Main connection class for a Cisco Nexus device
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def facts
      @facts ||= parse_device_facts
    end

    def config
      super
    end

    def parse_device_facts
      facts = {}
      facts
    end
  end
end
