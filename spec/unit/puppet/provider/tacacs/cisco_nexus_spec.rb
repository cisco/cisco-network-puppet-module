require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::Tacacs')
require 'puppet/provider/tacacs/cisco_nexus'

RSpec.describe Puppet::Provider::Tacacs::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:tacacs_server) { instance_double('Cisco::TacacsServer', 'tacacs_server') }

  let(:changes) do
    {
      'default' =>
                   {
                     is:     {
                       name:   'default',
                       enable: true,
                     },
                     should: should_values
                   }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::TacacsServer).to receive(:new).with(false).and_return(tacacs_server)
  end

  describe '#set' do
    context 'enable is set to false' do
      let(:should_values) do
        {
          name:   'default',
          enable: false,
        }
      end

      it 'calls delete' do
        expect(tacacs_server).to receive(:destroy)
        expect(context).to receive(:notice).with("Disabling tacacs 'default' service")

        provider.set(context, changes)
      end
    end

    context 'enable is set to true' do
      let(:should_values) do
        {
          name:   'default',
          enable: true,
        }
      end

      it 'calls update' do
        expect(tacacs_server).to receive(:enable)
        expect(context).to receive(:notice).with(%r{Enabling tacacs 'default'})

        provider.set(context, changes)
      end
    end
  end

  describe '#get' do
    context 'tacacs server is enabled' do
      it {
        allow(Cisco::TacacsServer).to receive(:enabled).and_return(true)
        expect(provider.get(context)).to eq [
          {
            name:   'default',
            enable: true,
          }
        ]
      }
    end
    context 'tacacs server is not enabled' do
      it {
        allow(Cisco::TacacsServer).to receive(:enabled).and_return(false)
        expect(provider.get(context)).to eq [
          {
            name:   'default',
            enable: false,
          }
        ]
      }
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it {
        expect(tacacs_server).to receive(:destroy)
        expect(context).to receive(:notice).with("Disabling tacacs 'default' service")
        provider.delete(context, 'default')
      }
    end
  end

  describe '#update' do
    context 'update is called' do
      it {
        expect(tacacs_server).to receive(:enable)
        expect(context).to receive(:notice).with(%r{Enabling tacacs 'default'})

        provider.update(context, 'default', name: 'default', enable: true)
      }
    end
  end
end
