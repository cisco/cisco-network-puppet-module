require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::TacacsServer')
require 'puppet/provider/tacacs_server/cisco_nexus'

RSpec.describe Puppet::Provider::TacacsServer::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:tacacs_server_one) { instance_double('Cisco::TacacsServerHost', 'first tacacs_server') }
  let(:tacacs_server_two) { instance_double('Cisco::TacacsServerHost', 'second tacacs_server') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return({})
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one)
        allow(tacacs_server_one).to receive(:port).and_return(48)
        allow(tacacs_server_one).to receive(:timeout).and_return(5)
        allow(tacacs_server_one).to receive(:encryption_type).and_return(7)
        allow(tacacs_server_one).to receive(:encryption_password).and_return('"4444"')
        expect(provider.get(context)).to eq [
          {
            name:       '1.1.1.1',
            ensure:     'present',
            port:       48,
            timeout:    5,
            key_format: 7,
            key:        '4444',
          }
        ]
      end
    end
    context 'with multiple servers' do
      it 'still processes' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        allow(tacacs_server_one).to receive(:port).and_return(48)
        allow(tacacs_server_one).to receive(:timeout).and_return(5)
        allow(tacacs_server_one).to receive(:encryption_type).and_return(7)
        allow(tacacs_server_one).to receive(:encryption_password).and_return('"4444"')
        allow(tacacs_server_two).to receive(:port).and_return(80)
        allow(tacacs_server_two).to receive(:timeout).and_return(5)
        allow(tacacs_server_two).to receive(:encryption_type).and_return(7)
        allow(tacacs_server_two).to receive(:encryption_password).and_return('"6666"')
        expect(provider.get(context)).to eq [
          {
            name:       '1.1.1.1',
            ensure:     'present',
            port:       48,
            timeout:    5,
            key_format: 7,
            key:        '4444',
          },
          {
            name:       '2.2.2.2',
            ensure:     'present',
            port:       80,
            timeout:    5,
            key_format: 7,
            key:        '6666',
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(provider.get(context, ['3.3.3.3'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        allow(tacacs_server_two).to receive(:port).and_return(80)
        allow(tacacs_server_two).to receive(:timeout).and_return(5)
        allow(tacacs_server_two).to receive(:encryption_type).and_return(7)
        allow(tacacs_server_two).to receive(:encryption_password).and_return('"6666"')
        expect(provider.get(context, ['2.2.2.2'])).to eq [
          {
            name:       '2.2.2.2',
            ensure:     'present',
            port:       80,
            timeout:    5,
            key_format: 7,
            key:        '6666',
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:       '2.2.2.2',
          ensure:     'present',
          port:       80,
          timeout:    5,
          key_format: 7,
          key:        '6666',
        }
      end

      it 'updates the server' do
        expect(context).to receive(:notice).with(%r{\AUpdating '2.2.2.2'})
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:port=).with(80)
        expect(tacacs_server_two).to receive(:timeout=).with(5)
        expect(tacacs_server_two).to receive(:encryption_key_set).with(7, '6666')
        provider.update(context, '2.2.2.2', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:       '3.3.3.3',
          ensure:     'present',
          port:       80,
          timeout:    5,
          key_format: 7,
          key:        '6666',
        }
      end

      it 'creates the server' do
        expect(context).to receive(:notice).with(%r{\ACreating '3.3.3.3'})
        expect(Cisco::TacacsServerHost).to receive(:new).with('3.3.3.3')
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('3.3.3.3' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:port=).with(80).never
        expect(tacacs_server_two).to receive(:timeout=).with(5).never
        expect(tacacs_server_two).to receive(:encryption_key_set).with(7, '6666').never
        expect(tacacs_server_one).to receive(:port=).with(80)
        expect(tacacs_server_one).to receive(:timeout=).with(5)
        expect(tacacs_server_one).to receive(:encryption_key_set).with(7, '6666')
        provider.create(context, '3.3.3.3', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the server' do
        expect(context).to receive(:notice).with(%r{\ADestroying '2.2.2.2'})
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:destroy).once
        expect(tacacs_server_one).to receive(:destroy).never
        provider.delete(context, '2.2.2.2')
      end
    end
  end

  describe '#munge' do
    it { expect(provider.munge(nil)).to eq(nil) }
    it { expect(provider.munge('unset')).to eq(nil) }
    it { expect(provider.munge(-1)).to eq(nil) }
    it { expect(provider.munge('foo')).to eq('foo') }
  end

  describe '#handle_update' do
    context 'all values' do
      let(:should_values) do
        {
          name:       '2.2.2.2',
          ensure:     'present',
          port:       80,
          timeout:    5,
          key_format: 7,
          key:        '6666',
        }
      end

      it 'updates the server' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:port=).with(80)
        expect(tacacs_server_two).to receive(:timeout=).with(5)
        expect(tacacs_server_two).to receive(:encryption_key_set).with(7, '6666')
        provider.handle_update('2.2.2.2', should_values)
      end
    end
    context 'no port values' do
      let(:should_values) do
        {
          name:       '2.2.2.2',
          ensure:     'present',
          timeout:    5,
          key_format: 7,
          key:        '6666',
        }
      end

      it 'updates the server' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:port=).with(anything).never
        expect(tacacs_server_two).to receive(:timeout=).with(5)
        expect(tacacs_server_two).to receive(:encryption_key_set).with(7, '6666')
        provider.handle_update('2.2.2.2', should_values)
      end
    end
    context 'no timeout values' do
      let(:should_values) do
        {
          name:       '2.2.2.2',
          ensure:     'present',
          key_format: 7,
          key:        '6666',
        }
      end

      it 'updates the server' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:port=).with(anything).never
        expect(tacacs_server_two).to receive(:timeout=).with(anything).never
        expect(tacacs_server_two).to receive(:encryption_key_set).with(7, '6666')
        provider.handle_update('2.2.2.2', should_values)
      end
    end
    context 'no key values' do
      let(:should_values) do
        {
          name:       '2.2.2.2',
          ensure:     'present',
          key_format: 7,
        }
      end

      it 'updates the server' do
        allow(Cisco::TacacsServerHost).to receive(:hosts).and_return('1.1.1.1' => tacacs_server_one,
                                                                     '2.2.2.2' => tacacs_server_two)
        expect(tacacs_server_two).to receive(:port=).with(anything).never
        expect(tacacs_server_two).to receive(:timeout=).with(anything).never
        expect(tacacs_server_two).to receive(:encryption_key_set).with(7, anything).never
        provider.handle_update('2.2.2.2', should_values)
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
