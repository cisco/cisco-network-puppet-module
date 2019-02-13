require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NtpServer')
require 'puppet/provider/ntp_server/cisco_nexus'

RSpec.describe Puppet::Provider::NtpServer::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:ntp_server) { instance_double('Cisco::NtpServer', 'ntp_server') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::NtpServer).to receive(:ntpservers).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server)
        allow(ntp_server).to receive(:key).and_return('1')
        allow(ntp_server).to receive(:maxpoll).and_return('10')
        allow(ntp_server).to receive(:minpoll).and_return('5')
        allow(ntp_server).to receive(:prefer).and_return(false)
        allow(ntp_server).to receive(:vrf).and_return('default')
        expect(provider.get(context)).to eq [
          {
            name:    '1.1.1.1',
            ensure:  'present',
            key:     1,
            prefer:  false,
            maxpoll: 10,
            minpoll: 5,
            vrf:     'default',
          }
        ]
      end
    end
    context 'with multiple ntp servers' do
      it 'still processes' do
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server,
                                                                   '2.2.2.2' => ntp_server,
                                                                   '3.3.3.3' => ntp_server)
        allow(ntp_server).to receive(:key).and_return('1', '1', '2', '2', '3', '3')
        allow(ntp_server).to receive(:maxpoll).and_return('10', '10', '7', '7', '6', '6')
        allow(ntp_server).to receive(:minpoll).and_return('7', '7', '6', '6', '5', '5')
        allow(ntp_server).to receive(:prefer).and_return(false, false, true)
        allow(ntp_server).to receive(:vrf).and_return('default')
        expect(provider.get(context)).to eq [
          {
            name:    '1.1.1.1',
            ensure:  'present',
            key:     1,
            prefer:  false,
            maxpoll: 10,
            minpoll: 7,
            vrf:     'default',
          },
          {
            name:    '2.2.2.2',
            ensure:  'present',
            key:     2,
            prefer:  false,
            maxpoll: 7,
            minpoll: 6,
            vrf:     'default',
          },
          {
            name:    '3.3.3.3',
            ensure:  'present',
            key:     3,
            prefer:  true,
            maxpoll: 6,
            minpoll: 5,
            vrf:     'default',
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server)
        allow(ntp_server).to receive(:key).and_return('1').never
        allow(ntp_server).to receive(:maxpoll).and_return('10').never
        allow(ntp_server).to receive(:minpoll).and_return('5').never
        allow(ntp_server).to receive(:prefer).and_return(false).never
        allow(ntp_server).to receive(:vrf).and_return('default').never
        expect(provider.get(context, ['2.2.2.2'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server,
                                                                   '2.2.2.2' => ntp_server)
        allow(ntp_server).to receive(:key).and_return('1').twice
        allow(ntp_server).to receive(:maxpoll).and_return('10').twice
        allow(ntp_server).to receive(:minpoll).and_return('5').twice
        allow(ntp_server).to receive(:prefer).and_return(false).once
        allow(ntp_server).to receive(:vrf).and_return('default').once
        expect(provider.get(context, ['1.1.1.1'])).to eq [
          {
            name:    '1.1.1.1',
            ensure:  'present',
            key:     1,
            prefer:  false,
            maxpoll: 10,
            minpoll: 5,
            vrf:     'default',
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called with all values' do
      let(:should_values) do
        {
          name:    '1.1.1.1',
          ensure:  'present',
          key:     1,
          prefer:  false,
          maxpoll: 10,
          minpoll: 5,
          vrf:     'default',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1.1.1.1'})
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server)
        expect(ntp_server).to receive(:destroy).once
        expect(Cisco::NtpServer).to receive(:new).with('name'    => '1.1.1.1',
                                                       'key'     => '1',
                                                       'maxpoll' => '10',
                                                       'minpoll' => '5',
                                                       'vrf'     => 'default')
        provider.update(context, '1.1.1.1', should_values)
      end
    end
    context 'update is called with few values' do
      let(:should_values) do
        {
          name:   '1.1.1.1',
          ensure: 'present',
          prefer: true,
          vrf:    'default',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1.1.1.1'})
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server)
        expect(ntp_server).to receive(:destroy).once
        expect(Cisco::NtpServer).to receive(:new).with('name'   => '1.1.1.1',
                                                       'prefer' => 'true',
                                                       'vrf'    => 'default')
        provider.update(context, '1.1.1.1', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called with all values' do
      let(:should_values) do
        {
          name:    '1.1.1.1',
          ensure:  'present',
          key:     1,
          prefer:  false,
          maxpoll: 10,
          minpoll: 5,
          vrf:     'default',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1.1.1.1'})
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('2.2.2.2' => ntp_server)
        expect(ntp_server).to receive(:destroy).never
        expect(Cisco::NtpServer).to receive(:new).with('name'    => '1.1.1.1',
                                                       'key'     => '1',
                                                       'maxpoll' => '10',
                                                       'minpoll' => '5',
                                                       'vrf'     => 'default')
        provider.create(context, '1.1.1.1', should_values)
      end
    end
    context 'create is called with few values' do
      let(:should_values) do
        {
          name:   '1.1.1.1',
          ensure: 'present',
          prefer: true,
          vrf:    'default',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1.1.1.1'})
        allow(Cisco::NtpServer).to receive(:ntpservers).and_return('2.2.2.2' => ntp_server)
        expect(ntp_server).to receive(:destroy).never
        expect(Cisco::NtpServer).to receive(:new).with('name'   => '1.1.1.1',
                                                       'prefer' => 'true',
                                                       'vrf'    => 'default')
        provider.create(context, '1.1.1.1', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the server' do
        expect(context).to receive(:notice).with(%r{\ADestroying '1.1.1.1'})
        expect(Cisco::NtpServer).to receive(:ntpservers).and_return('1.1.1.1' => ntp_server,
                                                                    '2.2.2.2' => ntp_server)
        expect(ntp_server).to receive(:destroy).once
        provider.delete(context, '1.1.1.1')
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
