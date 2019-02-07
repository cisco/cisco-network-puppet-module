require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SyslogServer')
require 'puppet/provider/syslog_server/cisco_nexus'

RSpec.describe Puppet::Provider::SyslogServer::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:syslog_server_one) { instance_double('Cisco::SyslogServer', 'syslog_server_one') }
  let(:syslog_server_two) { instance_double('Cisco::SyslogServer', 'syslog_server_two') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        allow(Cisco::SyslogServer).to receive(:syslogservers).and_return({})
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::SyslogServer).to receive(:syslogservers).and_return('1.2.3.4' => syslog_server_one)
        allow(syslog_server_one).to receive(:severity_level).and_return('5').twice
        allow(syslog_server_one).to receive(:port).and_return('80').twice
        allow(syslog_server_one).to receive(:vrf).and_return('default')
        allow(syslog_server_one).to receive(:facility).and_return('mail')
        expect(provider.get(context)).to eq [
          {
            name:           '1.2.3.4',
            ensure:         'present',
            severity_level: 5,
            port:           80,
            vrf:            'default',
            facility:       'mail',
          }
        ]
      end
    end
    context 'with multiple facilities' do
      it 'still processes' do
        allow(Cisco::SyslogServer).to receive(:syslogservers).and_return('1.2.3.4' => syslog_server_one,
                                                                         '4.3.2.1' => syslog_server_two)
        allow(syslog_server_one).to receive(:severity_level).and_return('5').twice
        allow(syslog_server_one).to receive(:port).and_return('80').twice
        allow(syslog_server_one).to receive(:vrf).and_return('default')
        allow(syslog_server_one).to receive(:facility).and_return('mail')
        allow(syslog_server_two).to receive(:severity_level).and_return('2').twice
        allow(syslog_server_two).to receive(:port).and_return('40').twice
        allow(syslog_server_two).to receive(:vrf).and_return('default')
        allow(syslog_server_two).to receive(:facility).and_return('cron')
        expect(provider.get(context)).to eq [
          {
            name:           '1.2.3.4',
            ensure:         'present',
            severity_level: 5,
            port:           80,
            vrf:            'default',
            facility:       'mail',
          },
          {
            name:           '4.3.2.1',
            ensure:         'present',
            severity_level: 2,
            port:           40,
            vrf:            'default',
            facility:       'cron',
          }
        ]
      end
    end
    context 'get filter used without maches' do
      it 'still processes' do
        allow(Cisco::SyslogServer).to receive(:syslogservers).and_return('1.2.3.4' => syslog_server_one,
                                                                         '4.3.2.1' => syslog_server_two)
        expect(provider.get(context, ['5.5.5.5'])).to eq []
      end
    end
    context 'get filter used with maches' do
      it 'still processes' do
        allow(Cisco::SyslogServer).to receive(:syslogservers).and_return('1.2.3.4' => syslog_server_one,
                                                                         '4.3.2.1' => syslog_server_two)
        allow(syslog_server_one).to receive(:severity_level).and_return('5').twice
        allow(syslog_server_one).to receive(:port).and_return('80').twice
        allow(syslog_server_one).to receive(:vrf).and_return('default')
        allow(syslog_server_one).to receive(:facility).and_return('mail')
        expect(provider.get(context, ['1.2.3.4'])).to eq [
          {
            name:           '1.2.3.4',
            ensure:         'present',
            severity_level: 5,
            port:           80,
            vrf:            'default',
            facility:       'mail',
          },
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:           '1.2.3.4',
          ensure:         'present',
          severity_level: 5,
          port:           80,
          vrf:            'default',
          facility:       'mail',
        }
      end

      it 'sets the values' do
        expect(context).to receive(:notice).with(%r{Setting '1.2.3.4'})
        expect(Cisco::SyslogServer).to receive(:new).with('name'           => '1.2.3.4',
                                                          'severity_level' => '5',
                                                          'port'           => '80',
                                                          'vrf'            => 'default',
                                                          'facility'       => 'mail')
        provider.update(context, '1.2.3.4', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:           '1.2.3.4',
          ensure:         'present',
          severity_level: 5,
          port:           80,
          vrf:            'default',
          facility:       'mail',
        }
      end

      it 'sets the values' do
        expect(context).to receive(:notice).with(%r{Setting '1.2.3.4'})
        expect(Cisco::SyslogServer).to receive(:new).with('name'           => '1.2.3.4',
                                                          'severity_level' => '5',
                                                          'port'           => '80',
                                                          'vrf'            => 'default',
                                                          'facility'       => 'mail')
        provider.create(context, '1.2.3.4', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the server' do
        expect(context).to receive(:notice).with(%r{Destroying '4.3.2.1'})
        allow(Cisco::SyslogServer).to receive(:syslogservers).and_return('1.2.3.4' => syslog_server_one,
                                                                         '4.3.2.1' => syslog_server_two)
        expect(syslog_server_one).to receive(:destroy).never
        expect(syslog_server_two).to receive(:destroy).once
        provider.delete(context, '4.3.2.1')
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
