require 'facter'

Facter.add(:cisco) do
  # Facter isn't aware of Puppet features so we have to check for the gem:
  confine do
    begin
      require 'cisco_node_utils'
      true
    rescue LoadError
      false
    end
  end
  confine :kernel => 'Linux' # TODO be more specific

  setcode do
    hash = {}

    hash["images"] = {}
    hash["images"]["system_image"] = Platform.system_image
    hash["images"]["packages"] = Platform.packages

    hash["hardware"] = {}
    hash["hardware"]["type"] = Platform.hardware_type
    hash["hardware"]["cpu"] = Platform.cpu
    hash["hardware"]["memory"] = Platform.memory
    hash["hardware"]["board"] = Platform.board
    hash["hardware"]["uptime"] = Platform.uptime
    hash["hardware"]["last_reset"] = Platform.last_reset
    hash["hardware"]["reset_reason"] = Platform.reset_reason

    hash["inventory"] = {}
    hash["inventory"]["chassis"] = Platform.chassis
    Platform.slots.each { |slot, info|
      hash["inventory"][slot] = info
    }
    Platform.power_supplies.each { |ps, info|
      hash["inventory"][ps] = info
    }
    Platform.fans.each { |fan, info|
      hash["inventory"][fan] = info
    }

    hash["virtual_service"] = Platform.virtual_services

    hash
  end
end
