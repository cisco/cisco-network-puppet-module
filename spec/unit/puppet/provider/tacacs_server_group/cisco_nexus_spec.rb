require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::TacacsServerGroup')
require 'puppet/provider/tacacs_server_group/cisco_nexus'

RSpec.describe Puppet::Provider::TacacsServerGroup::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:server_group_one) { instance_double('Cisco::TacacsServerGroup', 'server_group_one') }
  let(:server_group_two) { instance_double('Cisco::TacacsServerGroup', 'server_group_two') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one)
        allow(server_group_one).to receive(:servers).and_return(['2.2.2.2', '1.1.1.1']).twice
        expect(provider.get(context)).to eq [
          {
            name:    'cool',
            ensure:  'present',
            servers: ['1.1.1.1', '2.2.2.2'],
          }
        ]
      end
    end
    context 'with multiple servers' do
      it 'still processes' do
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        allow(server_group_one).to receive(:servers).and_return(['2.2.2.2', '1.1.1.1']).twice
        allow(server_group_two).to receive(:servers).and_return([])
        expect(provider.get(context)).to eq [
          {
            name:    'cool',
            ensure:  'present',
            servers: ['1.1.1.1', '2.2.2.2'],
          },
          {
            name:    'foo',
            ensure:  'present',
            servers: ['unset'],
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        expect(provider.get(context, ['moo'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        allow(server_group_two).to receive(:servers).and_return([])
        expect(provider.get(context, ['foo'])).to eq [
          {
            name:    'foo',
            ensure:  'present',
            servers: ['unset'],
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:    'foo',
          ensure:  'present',
          servers: ['1.1.1.1', '2.2.2.2', '3.3.3.3']
        }
      end

      it 'updates the server group' do
        expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})
        allow(Cisco::TacacsServerGroup).to receive(:new).with('foo').never
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        expect(server_group_one).to receive(:servers=).with(anything).never
        expect(server_group_two).to receive(:servers=).with(['1.1.1.1', '2.2.2.2', '3.3.3.3']).once
        provider.update(context, 'foo', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:    'foo',
          ensure:  'present',
          servers: ['1.1.1.1', '2.2.2.2', '3.3.3.3']
        }
      end

      it 'creates the server group' do
        expect(context).to receive(:notice).with(%r{\ACreating 'foo'})
        allow(Cisco::TacacsServerGroup).to receive(:new).with('foo')
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        expect(server_group_one).to receive(:servers=).with(anything).never
        expect(server_group_two).to receive(:servers=).with(['1.1.1.1', '2.2.2.2', '3.3.3.3']).once
        provider.create(context, 'foo', should_values)
      end
    end
  end

  describe '#handle_update' do
    context 'all values' do
      let(:should_values) do
        {
          name:    'foo',
          ensure:  'present',
          servers: ['1.1.1.1']
        }
      end

      it 'updates the server group' do
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        expect(server_group_one).to receive(:servers=).with(anything).never
        expect(server_group_two).to receive(:servers=).with(['1.1.1.1']).once
        provider.handle_update('foo', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the server' do
        expect(context).to receive(:notice).with(%r{\ADestroying 'foo'})
        allow(Cisco::TacacsServerGroup).to receive(:tacacs_server_groups).and_return('cool' => server_group_one,
                                                                                     'foo'  => server_group_two)
        expect(server_group_one).to receive(:destroy).never
        expect(server_group_two).to receive(:destroy).once
        provider.delete(context, 'foo')
      end
    end
  end

  describe '#munge' do
    it { expect(provider.munge(nil)).to eq(nil) }
    it { expect(provider.munge(['unset'])).to eq([]) }
    it { expect(provider.munge(['1.1.1.1', '2.2.2.2'])).to eq(['1.1.1.1', '2.2.2.2']) }
    it { expect(provider.munge('foo')).to eq('foo') }
  end

  canonicalize_data = [
    {
      desc:      '`resources` with servers already sorted',
      resources: [{
        name:    'foo',
        ensure:  'present',
        servers: ['1.1.1.1', '2.2.2.2', '10.10.10.10'],
      }],
      results:   [{
        name:    'foo',
        ensure:  'present',
        servers: ['1.1.1.1', '2.2.2.2', '10.10.10.10'],
      }],
    },
    {
      desc:      '`resources` with servers requiring sorting',
      resources: [{
        name:    'foo',
        ensure:  'present',
        servers: ['1.1.1.1', '10.10.10.10', '2.2.2.2'],
      }],
      results:   [{
        name:    'foo',
        ensure:  'present',
        servers: ['1.1.1.1', '2.2.2.2', '10.10.10.10'],
      }],
    },
    {
      desc:      '`resources` with servers set as unset',
      resources: [{
        name:    'foo',
        ensure:  'present',
        servers: ['unset'],
      }],
      results:   [{
        name:    'foo',
        ensure:  'present',
        servers: ['unset'],
      }],
    },
  ]

  describe '#canonicalize' do
    canonicalize_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns canonicalized resource' do
          expect(provider.canonicalize(context, test[:resources])).to eq(test[:results])
        end
      end
    end
  end
end
