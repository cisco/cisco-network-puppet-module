require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NetworkVlan')
require 'puppet/provider/network_vlan/cisco_nexus'

RSpec.describe Puppet::Provider::NetworkVlan::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:networkvlan) { instance_double('Cisco::NetworkVlan', 'networkvlan') }

  let(:vlan1) { instance_double('Cisco::Vlan', 'vlan1') }
  let(:vlan2) { instance_double('Cisco::Vlan', 'vlan2') }
  let(:vlans) do
    {
      '1' => vlan1,
      '2' => vlan2,
    }
  end
  let(:should_values) do
    {
      id:        '42',
      vlan_name: 'vlan_42',
      ensure:    'present',
      shutdown:  true,
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
  end

  describe '#get' do
    it 'processes resources' do
      allow(Cisco::Vlan).to receive(:vlans).and_return(vlans)

      expect(vlan1).to receive(:vlan_name).and_return('test1')
      expect(vlan1).to receive(:shutdown).and_return(false)
      expect(vlan2).to receive(:vlan_name).and_return('test2')
      expect(vlan2).to receive(:shutdown).and_return(true)

      expect(provider.get(context)).to eq [
        {
          id:        '1',
          ensure:    'present',
          shutdown:  false,
          vlan_name: 'test1',
        },
        {
          id:        '2',
          ensure:    'present',
          shutdown:  true,
          vlan_name: 'test2',
        },
      ]
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::Vlan).to receive(:vlans).and_return(vlans)
        expect(provider.get(context, ['3'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::Vlan).to receive(:vlans).and_return(vlans)
        expect(vlan2).to receive(:vlan_name).and_return('test2')
        expect(vlan2).to receive(:shutdown).and_return(true)
        expect(provider.get(context, ['2'])).to eq [
          {
            id:        '2',
            ensure:    'present',
            shutdown:  true,
            vlan_name: 'test2',
          }
        ]
      end
    end
  end

  describe '#set' do
    context 'create' do
      it 'creates resources' do
        expect(context).to receive(:notice).with(%r{\ACreating '42'})
        expect(provider).to receive(:create_update).with('42', should_values, true).once

        provider.create(context, '42', should_values)
      end

      it 'calls create_update to create' do
        expect(Cisco::Vlan).to receive(:new).with('42', true).and_return(vlan1)
        expect(vlan1).to receive(:shutdown).and_return(false)
        expect(vlan1).to receive(:shutdown=).with(true)
        expect(vlan1).to receive(:vlan_name).and_return('')
        expect(vlan1).to receive(:vlan_name=).with('vlan_42')
        provider.create_update('42', should_values, true)
      end
    end

    context 'update' do
      it 'updates resources' do
        expect(context).to receive(:notice).with("Updating '42' with {:id=>\"42\", :vlan_name=>\"vlan_42\", :ensure=>\"present\", :shutdown=>true}")
        expect(provider).to receive(:create_update).with('42', should_values, false).once

        provider.update(context, '42', should_values)
      end

      it 'calls create_update to update' do
        expect(Cisco::Vlan).to receive(:new).with('42', false).and_return(vlan1)
        expect(vlan1).to receive(:shutdown).and_return(false)
        expect(vlan1).to receive(:shutdown=).with(true)
        expect(vlan1).to receive(:vlan_name).and_return('')
        expect(vlan1).to receive(:vlan_name=).with('vlan_42')
        provider.create_update('42', should_values, false)
      end
    end

    context 'delete' do
      it 'deletes resources' do
        expect(context).to receive(:notice).with("Deleting '42'")
        expect(Cisco::Vlan).to receive(:new).with('42', false).and_return(vlan1)
        expect(vlan1).to receive(:destroy)
        provider.delete(context, '42')
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
