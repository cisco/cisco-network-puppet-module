# class to handle the platform facts which are consistent between agent mode and agentless mode
class Facter::CiscoNexus
  def self.platform_facts
    facts = {}

    facts['images'] = {}

    platform = Cisco::Platform
    feature = Cisco::Feature

    # sh hardware
    facts['images']['system_image'] = platform.system_image
    facts['images']['full_version'] = platform.image_version
    facts['hardware'] = {}
    facts['hardware']['type'] = platform.hardware_type
    facts['hardware']['cpu'] = platform.cpu
    facts['hardware']['board'] = platform.board
    facts['hardware']['last_reset'] = platform.last_reset
    facts['hardware']['reset_reason'] = platform.reset_reason

    # sh system resources
    facts['hardware']['memory'] = platform.memory

    # show inventory
    facts['inventory'] = {}
    facts['inventory']['chassis'] = platform.chassis
    platform.slots.each do |slot, info|
      facts['inventory'][slot] = info
    end
    platform.power_supplies.each do |ps, info|
      facts['inventory'][ps] = info
    end
    platform.fans.each do |fan, info|
      facts['inventory'][fan] = info
    end

    # show install patches
    facts['images']['packages'] = platform.packages

    # show virtual-service detail
    facts['virtual_service'] = platform.virtual_services

    # show feature + slot compare
    facts['feature_compatible_module_iflist'] = {}
    interface_list = feature.compatible_interfaces('fabricpath')
    facts['feature_compatible_module_iflist']['fabricpath'] = interface_list

    # sh system uptime
    facts['hardware']['uptime'] = platform.uptime

    facts
  end
end
