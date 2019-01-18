require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NetworkSnmp')
require 'puppet/provider/network_snmp/cisco_nexus'

RSpec.describe Puppet::Provider::NetworkSnmp::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:snmp_server) { instance_double('Cisco::SnmpServer', 'snmp_server') }
  let(:changes) do
    {
      'default' =>
                   {
                     is:     {
                       name:     'default',
                       enable:   true,
                       contact:  'Mr Tayto',
                       location: 'Tayto Castle',
                     },
                     should: should_values
                   }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::SnmpServer).to receive(:new).and_return(snmp_server)
  end

  describe '#set(context, changes)' do
    context 'there are changes' do
      let(:should_values) do
        {
          name:     'default',
          enable:   true,
          contact:  'Purple Monster',
          location: 'Monster Munch Caves',
        }
      end

      it 'calls update' do
        expect(context).to receive(:updating).with('default')

        provider.set(context, changes)
      end
    end
  end

  bools = [true, false]

  describe '#get' do
    it 'processes resources' do
      bools.each do |bool|
        allow(snmp_server).to receive(:protocol?).and_return(bool)
        allow(snmp_server).to receive(:contact).and_return('some_contact')
        allow(snmp_server).to receive(:location).and_return('some_location')

        expect(provider.get(context)).to eq [
          {
            name:     'default',
            enable:   bool,
            contact:  'some_contact',
            location: 'some_location',
          },
        ]
      end
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
      expect(snmp_server).not_to receive(:protocol=)
      expect(snmp_server).not_to receive(:contact=)
      expect(snmp_server).not_to receive(:location=)

      provider.update(context, 'default',
                      name:   'default',
                      ensure: 'present')
    end
    it 'updates the resource with all optional fields' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'default'})
      expect(snmp_server).to receive(:protocol=).with(true)
      expect(snmp_server).to receive(:contact=).with('new contact')
      expect(snmp_server).to receive(:location=).with('new location')

      provider.update(context, 'default',
                      name:     'default',
                      ensure:   'present',
                      enable:   true,
                      contact:  'new contact',
                      location: 'new location')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      expect { provider.delete(context, 'foo') }.to raise_error Puppet::ResourceError, %r{delete .* 'foo'}
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
