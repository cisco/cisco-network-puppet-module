require 'facter'

Facter.add(:cisco_node_utils) do
  # Facter isn't aware of Puppet features so we have to check for the gem:
  confine do
    begin
      require 'cisco_node_utils'
      true
    rescue LoadError
      false
    end
  end

  setcode do
    CiscoNodeUtils::VERSION
  end
end
