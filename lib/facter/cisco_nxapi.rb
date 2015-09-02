require 'facter'

Facter.add(:cisco_nxapi) do
  confine do
    begin
      require 'cisco_nxapi'
      true
    rescue LoadError
      false
    end
  end

  setcode do
    CiscoNxapi::VERSION
  end
end
