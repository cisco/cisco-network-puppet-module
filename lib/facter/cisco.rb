require 'facter'

Facter.add(:cisco) do
  confine operatingsystem: [:ios_xr, :nexus]
  confine :cisco_node_utils do
    # Any version is OK so long as it is installed
    true
  end

  setcode do
    hash = {}

    hash['images'] = {}
    begin
      hash['images']['system_image'] = Platform.system_image
    rescue NameError
      # In more recent versions, Platform moved into the Cisco namespace.
      Platform = Cisco::Platform
      Feature = Cisco::Feature
      hash['images']['system_image'] = Platform.system_image
    end
    hash['images']['packages'] = Platform.packages

    hash['hardware'] = {}
    hash['hardware']['type'] = Platform.hardware_type
    hash['hardware']['cpu'] = Platform.cpu
    hash['hardware']['memory'] = Platform.memory
    hash['hardware']['board'] = Platform.board
    hash['hardware']['uptime'] = Platform.uptime
    hash['hardware']['last_reset'] = Platform.last_reset
    hash['hardware']['reset_reason'] = Platform.reset_reason

    hash['inventory'] = {}
    hash['inventory']['chassis'] = Platform.chassis
    Platform.slots.each do |slot, info|
      hash['inventory'][slot] = info
    end
    Platform.power_supplies.each do |ps, info|
      hash['inventory'][ps] = info
    end
    Platform.fans.each do |fan, info|
      hash['inventory'][fan] = info
    end

    hash['virtual_service'] = Platform.virtual_services

    hash['feature_compatible_module_iflist'] = {}
    interface_list = Feature.compatible_interfaces('fabricpath')
    hash['feature_compatible_module_iflist']['fabricpath'] = interface_list

    hash
  end
end
