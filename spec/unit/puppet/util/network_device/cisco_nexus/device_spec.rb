require 'puppet/util/network_device/cisco_nexus/device'

RSpec.describe Puppet::Util::NetworkDevice::Cisco_nexus do
  describe Puppet::Util::NetworkDevice::Cisco_nexus::Device do
    let(:device_config) { { host: 'www.example.com', user: 'admin', password: 'password' } }

    it 'Initialises Correctly' do
      expect(described_class.new(device_config).transport).to be_instance_of(Puppet::Transport::CiscoNexus)
    end
  end
end
