require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::TestSomething')
require 'puppet/provider/test_something/test_something'

RSpec.describe Puppet::Provider::TestSomething::TestSomething do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:snmp_server) { instance_double('Cisco::SnmpServer', 'snmp_server') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    # TODO: fix this to correct value, and add second set of tests for ios_xr
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    # this specifies `once`, because the provider should cache the SnmpServer instance
    allow(Cisco::SnmpServer).to receive(:new).and_return(snmp_server).once
  end

  describe '#get' do
    it 'processes resources' do
      allow(snmp_server).to receive(:protocol?).and_return(true)
      allow(snmp_server).to receive(:contact).and_return('some_contact')
      allow(snmp_server).to receive(:location).and_return('some_location')

      expect(provider.get(context)).to eq [
        {
          name: 'default',
          ensure: 'present',
          enable: true,
          contact: 'some_contact',
          location: 'some_location',
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect { provider.create(context, 'a', name: 'a', ensure: 'present') }.to raise_error Puppet::ResourceError, %r{create .* 'a'}
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'default'})
      expect(snmp_server).to receive(:protocol=).with(true)
      expect(snmp_server).to receive(:contact=).with('new contact')
      expect(snmp_server).to receive(:location=).with('new location')

      provider.update(context, 'default',
                      name: 'default',
                      ensure: 'present',
                      enable: true,
                      contact: 'new contact',
                      location: 'new location')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      expect { provider.delete(context, 'foo') }.to raise_error Puppet::ResourceError, %r{delete .* 'foo'}
    end
  end
end
