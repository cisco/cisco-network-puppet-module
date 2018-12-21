require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SnmpCommunity')
require 'puppet/provider/snmp_community/cisco_nexus'

RSpec.describe Puppet::Provider::SnmpCommunity::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:snmp_community) { instance_double('Cisco::SnmpCommunity', 'snmp_community') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::SnmpCommunity).to receive(:communities).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::SnmpCommunity).to receive(:communities).and_return('foo' => snmp_community)
        allow(snmp_community).to receive(:group).and_return('bar')
        allow(snmp_community).to receive(:acl).and_return('fizz')
        expect(provider.get(context)).to eq [
          {
            name:   'foo',
            ensure: 'present',
            group:  'bar',
            acl:    'fizz',
          }
        ]
      end
    end
    context 'with multiple snmp communities' do
      it 'still processes' do
        allow(Cisco::SnmpCommunity).to receive(:communities).and_return('foo' => snmp_community,
                                                                        'moo' => snmp_community)
        allow(snmp_community).to receive(:group).and_return('bar', 'car')
        allow(snmp_community).to receive(:acl).and_return('fizz', 'buzz')
        expect(provider.get(context)).to eq [
          {
            name:   'foo',
            ensure: 'present',
            group:  'bar',
            acl:    'fizz',
          },
          {
            name:   'moo',
            ensure: 'present',
            group:  'car',
            acl:    'buzz',
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::SnmpCommunity).to receive(:communities).and_return('foo' => snmp_community,
                                                                        'moo' => snmp_community)
        allow(snmp_community).to receive(:group).never
        allow(snmp_community).to receive(:acl).never
        expect(provider.get(context, ['car'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::SnmpCommunity).to receive(:communities).and_return('foo' => snmp_community,
                                                                        'moo' => snmp_community)
        allow(snmp_community).to receive(:group).and_return('car').once
        allow(snmp_community).to receive(:acl).and_return('buzz').once
        expect(provider.get(context, ['moo'])).to eq [
          {
            name:   'moo',
            ensure: 'present',
            group:  'car',
            acl:    'buzz',
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called with all values' do
      let(:should_values) do
        {
          name:   'moo',
          ensure: 'present',
          group:  'car',
          acl:    'buzz',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\AUpdating 'moo'})
        allow(Cisco::SnmpCommunity).to receive(:communities).and_return('foo' => snmp_community,
                                                                        'moo' => snmp_community)
        provider.update(context, 'moo', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called with all values' do
      let(:should_values) do
        {
          name:   'moo',
          ensure: 'present',
          group:  'car',
          acl:    'buzz',
        }
      end

      it 'creates snmp_community' do
        expect(context).to receive(:notice).with(%r{\ACreating 'moo'})
        allow(Cisco::SnmpCommunity).to receive(:new).with('moo', 'car')
        provider.create(context, 'moo', should_values)
      end
    end
  end

  describe '#should_apply' do
    context 'should_apply is called' do
      let(:should_values) do
        {
          name:   'moo',
          ensure: 'present',
          group:  'car',
          acl:    'buzz',
        }
      end

      it 'sends snmp_community values' do
        allow(Cisco::SnmpCommunity).to receive(:new).with('moo', 'car')
        expect(snmp_community).to receive(:respond_to?).with('group=').and_return(true)
        expect(snmp_community).to receive(:respond_to?).with('acl=').and_return(true)
        expect(snmp_community).to receive(:send).with('group=', 'car').once
        expect(snmp_community).to receive(:send).with('acl=', 'buzz').once
        provider.should_apply(snmp_community, should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the community' do
        expect(context).to receive(:notice).with(%r{\ADestroying 'foo'})
        allow(Cisco::SnmpCommunity).to receive(:communities).and_return('foo' => snmp_community,
                                                                        'moo' => snmp_community)
        expect(snmp_community).to receive(:destroy).once
        provider.delete(context, 'foo')
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
