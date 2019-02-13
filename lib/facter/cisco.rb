require 'facter'
require 'facter/cisco_nexus'

Facter.add(:cisco) do
  confine operatingsystem: [:ios_xr, :nexus]
  confine :cisco_node_utils do
    # Any version is OK so long as it is installed
    true
  end

  setcode do
    Facter::CiscoNexus.platform_facts
  end
end
