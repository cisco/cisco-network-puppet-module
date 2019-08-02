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

    # Count interfaces and compute a lookup efficiency threshold. The threshold
    # is a cutoff for determining when to get each interface one at a time versus
    # getting all interfaces at once. The threshold is only useful to a certain
    # point - it depends on the total number of interfaces on the device - after
    # which it's better to just get all interfaces.
    facts['interface_count'] = count = Cisco::Interface.interface_count
    if Gem::Version.new(CiscoNodeUtils::VERSION) > Gem::Version.new('2.0.2')
      facts['single_intf_support'] = true
      if count < 1000 && facts['hardware']['type'][/Nexus7/]
        # N7 uses a less efficient show cmd get_value to workaround an image bug
        thresh_pct = 0.075
      else
        thresh_pct = 0.15
      end
    else
      facts['single_intf_support'] = false
      thresh_pct = 0
      info '## Notice: Unable to prefetch interfaces independently, using legacy lookup instead.'
      info '## Notice: cisco_node_utils gem does not contain interface lookup enhancements.'
      info '## Notice: Please upgrade cisco_node_utils to v2.1.0 or newer'
    end
    facts['show_run_int_threshold'] = count * thresh_pct

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
