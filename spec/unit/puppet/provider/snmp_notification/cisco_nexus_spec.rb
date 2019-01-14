require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SnmpNotification')
require 'puppet/provider/snmp_notification/cisco_nexus'

RSpec.describe Puppet::Provider::SnmpNotification::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:type) { instance_double('Puppet::ResourceApi::TypeDefinition', 'type') }
  let(:snmp_notification) { instance_double('Cisco::SnmpNotification', 'snmp_notification') }

  let(:changes) do
    {
      'foo' =>
               {
                 is:     {
                   name:   'foo',
                   enable: false,
                 },
                 should: should_values
               }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::SnmpNotification).to receive(:notifications).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::SnmpNotification).to receive(:notifications).and_return('foo' => snmp_notification)
        allow(snmp_notification).to receive(:enable).and_return(true)
        expect(provider.get(context)).to eq [
          {
            name:   'foo',
            enable: true,
          }
        ]
      end
    end
    context 'with multiple notifications' do
      it 'still processes' do
        allow(Cisco::SnmpNotification).to receive(:notifications).and_return('foo' => snmp_notification,
                                                                             'bar' => snmp_notification)
        allow(snmp_notification).to receive(:enable).and_return(true, false)
        expect(provider.get(context)).to eq [
          {
            name:   'foo',
            enable: true,
          },
          {
            name:   'bar',
            enable: false,
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::SnmpNotification).to receive(:notifications).and_return('foo' => snmp_notification,
                                                                             'bar' => snmp_notification)
        allow(snmp_notification).to receive(:enable).never
        expect(provider.get(context, ['buzz'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::SnmpNotification).to receive(:notifications).and_return('foo' => snmp_notification,
                                                                             'bar' => snmp_notification)
        allow(snmp_notification).to receive(:enable).and_return(true)
        expect(provider.get(context, ['bar'])).to eq [
          {
            name:   'bar',
            enable: true,
          }
        ]
      end
    end
  end

  describe '#set(context, changes)' do
    context 'there are changes' do
      let(:should_values) do
        {
          name:   'foo',
          enable: true,
        }
      end

      it 'calls update' do
        expect(context).to receive(:type).and_return(type)
        allow(type).to receive(:feature?).with('simple_get_filter').and_return(false)
        expect(context).to receive(:notice).with(%r{\AUpdating 'foo'}).once

        expect(Cisco::SnmpNotification).to receive(:new).with('foo').and_return(snmp_notification)
        expect(snmp_notification).to receive(:enable=).with(true)

        provider.set(context, changes)
      end
    end

    context 'there are no changes' do
      let(:should_values) do
        {
          name:   'foo',
          enable: false,
        }
      end

      it 'will not call update' do
        expect(context).to receive(:type).and_return(type)
        allow(type).to receive(:feature?).with('simple_get_filter').and_return(true)
        expect(context).to receive(:notice).with(%r{\AUpdating 'foo'}).never

        expect(Cisco::SnmpNotification).to receive(:notifications).never
        expect(anything).to receive(:enable=).with(true).never

        provider.set(context, changes)
      end
    end
  end

  describe '#update' do
    context 'notification already exists' do
      let(:should_values) do
        {
          name:   'foo',
          enable: false,
        }
      end

      it 'will not call new' do
        expect(context).to receive(:notice).with(%r{\AUpdating 'foo'}).once
        expect(Cisco::SnmpNotification).to receive(:notifications).and_return('foo' => snmp_notification,
                                                                              'bar' => snmp_notification)
        expect(Cisco::SnmpNotification).to receive(:new).with('foo').never
        expect(snmp_notification).to receive(:enable=).with(false).once
        provider.update(context, 'foo', should_values)
      end
    end
    context 'notification does not exist' do
      let(:should_values) do
        {
          name:   'buzz',
          enable: true,
        }
      end

      it 'will call new' do
        expect(context).to receive(:notice).with(%r{\AUpdating 'buzz'}).once
        expect(Cisco::SnmpNotification).to receive(:notifications).and_return('foo' => snmp_notification,
                                                                              'bar' => snmp_notification)
        expect(Cisco::SnmpNotification).to receive(:new).with('buzz').and_return(snmp_notification).once
        expect(snmp_notification).to receive(:enable=).with(true).once
        provider.update(context, 'buzz', should_values)
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
