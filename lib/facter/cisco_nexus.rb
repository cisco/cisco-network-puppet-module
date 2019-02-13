# class to handle the platform facts which are consistent between agent mode and agentless mode
class Facter::CiscoNexus
  def self.platform_facts
    facts = {}

    facts['images'] = {}

    platform = Cisco::Platform
    feature = Cisco::Feature

    facts['images']['system_image'] = platform.system_image
    facts['images']['full_version'] = platform.image_version

    facts['images']['packages'] = platform.packages

    facts['hardware'] = {}
    facts['hardware']['type'] = platform.hardware_type
    facts['hardware']['cpu'] = platform.cpu
    facts['hardware']['memory'] = platform.memory
    facts['hardware']['board'] = platform.board
    facts['hardware']['last_reset'] = platform.last_reset
    facts['hardware']['reset_reason'] = platform.reset_reason

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

    facts['virtual_service'] = platform.virtual_services

    facts['feature_compatible_module_iflist'] = {}
    interface_list = feature.compatible_interfaces('fabricpath')
    facts['feature_compatible_module_iflist']['fabricpath'] = interface_list
    facts['hardware']['uptime'] = platform.uptime

    facts
  end
end
