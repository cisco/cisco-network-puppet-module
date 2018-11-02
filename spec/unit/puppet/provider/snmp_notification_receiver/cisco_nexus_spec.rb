require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SnmpNotificationReceiver')
require 'puppet/provider/snmp_notification_receiver/cisco_nexus'

RSpec.describe Puppet::Provider::SnmpNotificationReceiver::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:receiver) { instance_double('Cisco::SnmpNotificationReceiver', 'receiver') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::SnmpNotificationReceiver).to receive(:receivers).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::SnmpNotificationReceiver).to receive(:receivers).and_return('2.2.2.2' => receiver)
        allow(receiver).to receive(:port).and_return('47')
        allow(receiver).to receive(:username).and_return('foo')
        allow(receiver).to receive(:version).and_return('2c')
        allow(receiver).to receive(:type).and_return('traps')
        allow(receiver).to receive(:vrf).and_return('management')
        allow(receiver).to receive(:security)
        allow(receiver).to receive(:source_interface).and_return('ethernet1/2')
        expect(provider.get(context)).to eq [
          {
            name:             '2.2.2.2',
            ensure:           'present',
            port:             47,
            username:         'foo',
            version:          'v2',
            security:         nil,
            type:             'traps',
            vrf:              'management',
            source_interface: 'ethernet1/2',
          }
        ]
      end
    end
    context 'with multiple receivers' do
      it 'still processes' do
        allow(Cisco::SnmpNotificationReceiver).to receive(:receivers).and_return('2.2.2.2' => receiver,
                                                                                 '3.3.3.3' => receiver)
        allow(receiver).to receive(:port).and_return('47', '80')
        allow(receiver).to receive(:username).and_return('foo', 'bar')
        allow(receiver).to receive(:version).and_return('2c', '3')
        allow(receiver).to receive(:type).and_return('traps', 'informs')
        allow(receiver).to receive(:vrf).and_return('management', 'buzz')
        allow(receiver).to receive(:security).and_return(nil, 'auth')
        allow(receiver).to receive(:source_interface).and_return('ethernet1/2', 'ethernet1/3')
        expect(provider.get(context)).to eq [
          {
            name:             '2.2.2.2',
            ensure:           'present',
            port:             47,
            username:         'foo',
            version:          'v2',
            security:         nil,
            type:             'traps',
            vrf:              'management',
            source_interface: 'ethernet1/2',
          },
          {
            name:             '3.3.3.3',
            ensure:           'present',
            port:             80,
            username:         'bar',
            version:          'v3',
            security:         'auth',
            type:             'informs',
            vrf:              'buzz',
            source_interface: 'ethernet1/3',
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::SnmpNotificationReceiver).to receive(:receivers).and_return('2.2.2.2' => receiver,
                                                                                 '3.3.3.3' => receiver)
        expect(provider.get(context, ['4.4.4.4'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::SnmpNotificationReceiver).to receive(:receivers).and_return('2.2.2.2' => receiver,
                                                                                 '3.3.3.3' => receiver)
        allow(receiver).to receive(:port).and_return('80')
        allow(receiver).to receive(:username).and_return('bar')
        allow(receiver).to receive(:version).and_return('3')
        allow(receiver).to receive(:type).and_return('informs')
        allow(receiver).to receive(:vrf).and_return('buzz')
        allow(receiver).to receive(:security).and_return('auth')
        allow(receiver).to receive(:source_interface).and_return('ethernet1/3')
        expect(provider.get(context, ['3.3.3.3'])).to eq [
          {
            name:             '3.3.3.3',
            ensure:           'present',
            port:             80,
            username:         'bar',
            version:          'v3',
            security:         'auth',
            type:             'informs',
            vrf:              'buzz',
            source_interface: 'ethernet1/3',
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:             '1.1.1.1',
          ensure:           'present',
          port:             47,
          username:         'foo',
          version:          'v2',
          type:             'traps',
          vrf:              'management',
          source_interface: 'ethernet1/2',
        }
      end

      it 'performs the update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1.1.1.1'})
        expect(Cisco::SnmpNotificationReceiver).to receive(:new).with('1.1.1.1',
                                                                      instantiate: true,
                                                                      port: '47',
                                                                      username: 'foo',
                                                                      version: '2c',
                                                                      type: 'traps',
                                                                      vrf: 'management',
                                                                      security: '',
                                                                      source_interface: 'ethernet1/2')

        provider.update(context, '1.1.1.1', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:             '1.1.1.1',
          ensure:           'present',
          port:             47,
          username:         'foo',
          version:          'v2',
          type:             'traps',
          vrf:              'management',
          source_interface: 'ethernet1/2',
        }
      end

      it 'performs the update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1.1.1.1'})
        expect(Cisco::SnmpNotificationReceiver).to receive(:new).with('1.1.1.1',
                                                                      instantiate: true,
                                                                      port: '47',
                                                                      username: 'foo',
                                                                      version: '2c',
                                                                      type: 'traps',
                                                                      vrf: 'management',
                                                                      security: '',
                                                                      source_interface: 'ethernet1/2')

        provider.create(context, '1.1.1.1', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the receiver' do
        expect(context).to receive(:notice).with(%r{\ADestroying '2.2.2.2'})
        allow(Cisco::SnmpNotificationReceiver).to receive(:receivers).and_return('2.2.2.2' => receiver,
                                                                                 '3.3.3.3' => receiver)
        expect(receiver).to receive(:destroy).once

        provider.delete(context, '2.2.2.2')
      end
    end
  end

  describe '#munge' do
    it {
      expect(provider.munge(46)).to eq '46'
    }
    it {
      expect(provider.munge('unset')).to eq nil
    }
    it {
      expect(provider.munge('foo')).to eq 'foo'
    }
  end

  describe '#validate_should' do
    it { expect { provider.validate_should(type: 'traps', version: 'v2') }.to raise_error Puppet::ResourceError, 'You must specify the following properties: [:username]' }
    it { expect { provider.validate_should(username: 'foo', version: 'v2') }.to raise_error Puppet::ResourceError, 'You must specify the following properties: [:type]' }
    it { expect { provider.validate_should(username: 'foo', type: 'traps') }.to raise_error Puppet::ResourceError, 'You must specify the following properties: [:version]' }
    it { expect { provider.validate_should(name: '2.2.2.2') }.to raise_error Puppet::ResourceError, 'You must specify the following properties: [:type, :version, :username]' }
    it { expect { provider.validate_should(username: 'foo', type: 'traps', version: 'v2') }.not_to raise_error }
    it {
      expect {
        provider.validate_should(username: 'foo', type: 'informs', version: 'v1')
      }.to raise_error Puppet::ResourceError, "The 'type' property only supports a setting of 'traps' when 'version' is set to 'v1'"
    }
    it { expect { provider.validate_should(username: 'foo', type: 'traps', version: 'v1') }.not_to raise_error }
    it {
      expect {
        provider.validate_should(username: 'foo', type: 'traps', version: 'v1', security: 'auth')
      }.to raise_error Puppet::ResourceError, "The 'security' property is only supported when 'version' is set to 'v3'"
    }
    it { expect { provider.validate_should(username: 'foo', type: 'traps', version: 'v3', security: 'auth') }.not_to raise_error }
  end
end
